Vagrant.configure('2') do |config|
  config.vm.define 'ros' do |node|
    node.vm.provider :virtualbox do |v|
      v.name = 'ros'
    end
    node.vm.hostname = 'ros.local'
    node.vm.network :private_network, type: :dhcp
  end

  config.vm.box = 'debian/contrib-stretch64'
  config.vm.box_version = '9.9.0'
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.ssh.forward_agent = true
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/dev', type: 'nfs',
    mount_options: ['rw', 'vers=3', 'tcp'],
    linux__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']
end
