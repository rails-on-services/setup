#!/usr/bin/env ruby

require 'json'
require 'open-uri'

class Version
  attr_accessor :project, :name, :current_version

  def next_version(type = 'patch')
    idx = { 'major' => 0, 'minor' => 1, 'patch' => 2 }
    ver = current_version.split('.')
    ver[idx['patch']] = 0 if %w(major minor).include? type
    ver[idx['minor']] = 0 if %w(major).include? type
    ver[idx[type]] = ver[idx[type]].to_i + 1
    ver.join('.')
  end

  def current_version
    url = "https://perx-ros-boxes.s3-ap-southeast-1.amazonaws.com/vagrant/json/#{project}/#{name}.json"
    # STDOUT.puts "Using url: #{url}"
    json = open(url)
    @current_version ||= JSON.parse(json.read)['versions'].last['version']
  rescue
    @current_version ||= '0.0.0'
  end
end

version = Version.new
version.project = ARGV.shift
version.name = ARGV.shift
STDOUT.puts version.next_version(ARGV.shift)
