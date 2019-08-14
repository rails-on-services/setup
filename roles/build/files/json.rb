#!/usr/bin/env ruby
require 'json'

path, owner, name, version = ARGV
# path = "#{Dir.pwd}"
# owner = 'prepd'
# name = 'stretch64-developer'
# version = '0.0.1'

json = {
  name: "#{owner}/#{name}",
  versions: [
    {
      version: version,
      providers: [
        {
          name: 'virtualbox',
          url: "file://#{path}/#{owner}/#{name}.box"
        }
      ]
    }
  ]
}

File.open("#{path}/#{owner}/#{name}.json", 'w') { |f| f.write json.to_json }
