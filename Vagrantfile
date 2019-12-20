# -*- mode: ruby -*-
# vi: set ft=ruby :

# Include config
dir = File.dirname(File.expand_path(__FILE__))
require 'yaml'
configValues = YAML.load_file("#{dir}/config.yaml")

module OS
    def OS.is_windows
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
end

# NFS will be used for *nix and OSX hosts, if not disabled explicitly in config
use_nfs_for_synced_folders = !OS.is_windows && (configValues['use_nfs'] == 1)

Vagrant.configure("2") do |config|

  # Main settings
  config.vm.box = "bartoll/ubuntu-1804-server"
  config.vm.box_check_update = true

  # Machine memory settings
  config.vm.provider "virtualbox" do |vb|

    # Display the VirtualBox GUI when booting the machine
    #vb.gui = true
  
    # Customize CPU and memory
    vb.cpus = configValues['cpu_number']
    vb.memory = configValues['memory_size']
  end

  # Sync folders settings
  if use_nfs_for_synced_folders
    config.vm.synced_folder "./guest_www", "/var/www/",
    type: "nfs",
    mount_options: ['nolock', 'vers=3', 'tcp', 'fsc', 'rw', 'noatime']
  else
    config.vm.synced_folder "./guest_www", "/var/www/",
    owner: "www-data", group: "www-data",
    mount_options: ["dmode=777,fmode=777"]
  end

  # Set IP, hostname and aliases
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.define configValues['hostname'] do |node|
    node.vm.hostname = configValues['hostname']
    node.hostmanager.aliases = configValues['vhosts_fixed'] + configValues['vhosts_virtual'] + configValues['vhosts_virtual'].map { |string| 'demo1.' + string }
    node.vm.network :private_network, ip: configValues['private_ip']
  end

  # Resize disk
  # https://github.com/sprotheroe/vagrant-disksize
  if Vagrant.has_plugin?('vagrant-disksize')
    config.disksize.size = configValues['disk_size']

    config.vm.provision "shell", inline:<<-SHELL
      # Resize partition and filesystem
      sudo growpart /dev/sda 2
      sudo resize2fs /dev/sda2
    SHELL
  end

  # Install LAMP server
  #config.vm.provision "lamp", type: "shell", path: "./scripts/install_server.sh", env: configValues

  # Overwrite files in /etc
  config.vm.provision "settings", type: "file", source: "./guest_overwrite/etc", destination: "$HOME/guest_overwrite/etc", run: "always"
  config.vm.provision "etc", type: "shell", path: "./scripts/overwrite_etc.sh", env: configValues, privileged: false, run: "always"

  # Install virtual hosts
  config.vm.provision "vhosts", type: "shell", path: "./scripts/install_vhosts.sh", env: configValues, run: "always"
end
