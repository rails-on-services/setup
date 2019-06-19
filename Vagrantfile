Vagrant.configure('2') do |config|
  forward_ports = [
    { name: 'sftp', guest: 2222, host: 2222, enabled: true },
    { name: 'nginx', guest: 3000, host: 3000, enabled: true },
    { name: 'jekyll', guest: 4000, host: 4000, enabled: true },
    { name: 'angular', guest: 4200, host: 4200, enabled: true },
    { name: 'localstack-ui', guest: 8080, host: 8080, enabled: true },
    { name: 'live-reload', guest: 35729, host: 35729, enabled: true }
  ]

  required_plugins = %w(vagrant-persistent-storage vagrant-vbguest vagrant-disksize)
  _retry = false
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      _retry=true
    end
  end

  exec "vagrant " + ARGV.join(' ') if (_retry)

  config.persistent_storage.enabled = true
  config.persistent_storage.use_lvm = false
  config.persistent_storage.location = "./dockerhdd.vdi"
  config.persistent_storage.size = 20000
  config.persistent_storage.part_type_code = '83'
  config.persistent_storage.diskdevice = '/dev/sdb'
  config.persistent_storage.filesystem = 'ext4'
  config.persistent_storage.mountpoint = '/var/lib/docker'

  config.vm.provider :virtualbox do |v|
    # vb.customize ['modifyhd', 'disk id', '--resize', '30000']
    # v.memory = 2048
    # v.cpus = 1
    # v.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10000 ]
    # v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    # v.customize ['modifyvm', :id, '--nic1', 'hostonly', '--nic2', 'nat']

    host = RbConfig::CONFIG["host_os"]
    if host =~ /darwin/ # OS X
      # sysctl returns bytes, convert to MB
      # allocate 1/4 (25%) of available physical memory to the VM
      v.memory = %x(sysctl -n hw.memsize).to_i / 1024 / 1024 / 4

      v.cpus = 1 # %x(sysctl -n hw.physicalcpu).to_i
    elsif host =~ /linux/ # Linux
      # TODO: Linux host not tested
      # meminfo returns kilobytes, convert to MB
      # v.memory = rep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'to_i / 1024 / 8
      v.cpus = %x(nproc).to_i
    end
  end

  config.vm.define 'ros' do |node|
    node.vm.provider :virtualbox do |v|
      v.name = 'ros'
    end
    node.vm.hostname = 'ros.local'
    # node.vm.network :private_network, type: :dhcp
    node.vm.network :private_network, ip: '192.168.0.4'
  end

  config.vm.box = 'debian/contrib-stretch64'
  config.disksize.size = "20GB"
  config.vm.box_version = '9.9.0'
  forward_ports.each do |port|
    next unless port[:enabled]
    config.vm.network "forwarded_port", guest: port[:guest], host: port[:host]
  end
  config.ssh.forward_agent = true
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/dev', type: 'nfs',
    mount_options: ['rw', 'vers=3', 'tcp'],
    linux__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']
end
