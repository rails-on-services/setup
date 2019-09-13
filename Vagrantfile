Vagrant.configure('2') do |config|
  forward_ports = [
    { name: 'mail-catcher', guest: 1080, host: 1080, enabled: true },
    { name: 'sftp', guest: 2222, host: 2222, enabled: true },
    { name: 'nginx', guest: 3000, host: 3000, enabled: true },
    { name: 'kafka-ui', guest: 3040, host: 3040, enabled: true },
    { name: 'jekyll', guest: 4000, host: 4000, enabled: true },
    { name: 'angular', guest: 4200, host: 4200, enabled: true },
    { name: 'localstack-ui', guest: 8080, host: 8080, enabled: true },
    { name: 'locustio', guest: 8089, host: 8089, enabled: true },
    { name: 'live-reload', guest: 35729, host: 35729, enabled: true }
  ]

  required_plugins = %w()
  _retry = false
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin? plugin
      system "vagrant plugin install #{plugin}"
      _retry=true
    end
  end

  exec "vagrant #{ARGV.join(' ')}" if (_retry)

  config.vm.provider :virtualbox do |v|
    # v.gui = true
    # v.customize ['modifyhd', 'disk id', '--resize', '30000']
    # v.memory = 2048
    # v.cpus = 1
    # v.customize ['modifyvm', :id, '--nictype1', 'virtio']
    v.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10000 ]
    # v.customize ['modifyvm', :id, '--nic1', 'hostonly', '--nic2', 'nat']

    host = RbConfig::CONFIG['host_os']
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
    elsif host =~ /mswin|mingw|cygwin/
      # Windows. Tested on Win 7 SP1
      # 80% of available free memory, 50% of available CPUs
      v.memory = (`wmic OS get FreePhysicalMemory`.split[1].to_i / 1024 * 0.80).to_i
      cpus = `wmic computersystem Get NumberOfLogicalProcessors`.split[1].to_i / 2
      cpus < 1 ? v.cpus = 1 : v.cpus = cpus
    end
  end

  project_name = Dir.pwd.split('/').last
  # The hostname set for the VM should only contain letters, numbers, hyphens or dots. It cannot start with a hyphen or dot.
  # Strip any char that is not letter, number, hyphen or dot then strip any hypens and dots from the begining of the string
  project_name.gsub!(/[^0-9A-Za-z.-]+/, "")
  project_name.gsub!(/^[-.]+/, "")

  # Base machine
  config.vm.box = 'ros/generic'
  config.vm.box_url = 'https://perx-ros-boxes.s3-ap-southeast-1.amazonaws.com/vagrant/json/ros/generic.json'
  config.ssh.forward_agent = true

  # Basic networking
  config.vm.define project_name do |node|
    node.vm.provider :virtualbox do |v|
      v.name = project_name
    end
    node.vm.hostname = "#{project_name}.local"
    # Use an unlikely subnet to avoid clashes; It would be better to use dhcp, but NFS on MacOS doesn't like that
    node.vm.network :private_network, ip: '192.168.173.4'
  end

  # Port forwarding
  forward_ports.each do |port|
    next unless port[:enabled]
    config.vm.network 'forwarded_port', guest: port[:guest], host: port[:host]
  end

  # Windows compatible mount options. Tested on Win 7 SP1
  mount_options = Vagrant::Util::Platform.windows? ? ['dmode=775','fmode=775'] : ['rw', 'vers=3', 'tcp']

  # Shared directories
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', "/home/vagrant/#{project_name}", type: 'nfs', mount_options: mount_options,
    linux__nfs_options: ['rw', 'no_subtree_check', 'all_squash', 'async']

  # Provisioning
  config.vm.provision 'build', type: 'shell', privileged: false, inline: <<-SHELL
    # sudo apt install git --yes
    DIRECTORY=~/#{project_name}/ros-tools/setup
    if [ ! -d "$DIRECTORY" ]; then
      git clone https://github.com/rails-on-services/setup.git $DIRECTORY
    fi
    # $DIRECTORY/setup.sh
    # cd $DIRECTORY && ./backend.yml
    # cd $DIRECTORY && ./devops.yml
    cd $DIRECTORY && ./cli.yml
  SHELL
end
