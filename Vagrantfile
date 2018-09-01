# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: This file is for testing the ansible provisioner after the box is built
# It is NOT included in the Vagrant box built by Packer
# Its purpose is to run the *exact same* provisioner that packer will run, i.e. the same ansible playbook
# NOTE: This is designed to run exactly one machine at a time. Destroy a machine before starting another
box_prefix = :rjayroach

# On error, display a message and exit with an error code
def vexit(msg, code)
  STDOUT.puts msg
  exit code
end

# Must be in the os build directory
vexit('Wrong directory', 1) unless File.exists?('../../Vagrantfile')

# Set environment from vagrant cli arguments and cwd
args = ARGV
args.delete('--provision')
action, type = args
valid_types = Dir.glob('boxes/**/*.box').map { |f| f.split('/').last.gsub('debian-stretch-amd64-', '').gsub('.box', '') }
flavor, version = Dir.pwd.split('/').pop(2)

os_string = "#{flavor}-#{version}-amd64-#{type}"
box_url = "boxes/#{os_string}.box"
vagrant_host_name = "packer-#{type}.dev"

# If action is 'up' or 'provision' then test for valid type, conflicting directories and box is available
if %w(up provision).include?(action)
  vexit("Invalid machine type: '#{type}'. Available types are: #{valid_types.join(', ')}", 2) unless valid_types.include?(type)

  conflict_dirs = [
    '../../.vagrant',
    "#{Dir.home}/.vagrant.d/boxes/#{box_prefix}-VAGRANTSLASH-#{os_string}"
  ]

  # Prompt user to remove potentially conflicting directories
  conflict_dirs.each do |dir|
    next unless Dir.exists?(dir)
    STDOUT.puts "Potential conflicting directory '#{dir} exists. Remove? (y/n)"
    FileUtils.rm_rf(dir) if STDIN.gets.chomp.eql?('y')
  end

  STDOUT.puts "###\nMachine Type is '#{type}'\n###"
end


Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  config.vm.provider :virtualbox do |v|
    v.customize ['modifyvm', :id, '--memory', '2048']
    v.customize ['modifyvm', :id, '--cpus', '2']
    v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    v.name = vagrant_host_name
  end

  config.vm.define type, autostart: false do |node|
    node.vm.box = "#{box_prefix}/#{os_string}"
    node.vm.box_url = "#{box_url}"
    node.vm.box_check_update = false
    node.vm.hostname = type
    node.vm.hostname = vagrant_host_name
    node.vm.network :private_network, ip: '192.168.21.12'

    # See:
    # https://www.vagrantup.com/docs/provisioning/ansible.html
    # https://www.vagrantup.com/docs/provisioning/ansible_common.html
    # http://docs.ansible.com/ansible/latest/guide_vagrant.html
    config.vm.provision 'ansible' do |ansible|
      ansible.playbook = 'provision.yml'
      ansible.groups = { type => [vagrant_host_name] }
    end
  end
end
