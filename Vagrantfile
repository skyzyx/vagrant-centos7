Vagrant.require_version ">= 1.8.0"

environment_name = "Docker builder environment"
memsize = 2048
numvcpus = 2

Vagrant.configure("2") do | config |

  # Box
  config.vm.box = "skyzyx/centos7"
  config.vm.box_url = "file://./builds/centos7-x64-virtualbox.box"
  config.vm.boot_timeout = 120

  # Check for vbguest plugin
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = true
    config.vbguest.no_remote = false
  end

  # Synced folders
  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder "", "/vagrant", type: "smb"
  else
    config.vm.synced_folder "", "/vagrant", type: "nfs"
  end

  # Oracle VirtualBox
  config.vm.provider :virtualbox do | vb |
    vb.name = environment_name
    vb.gui = false

    vb.memory = memsize
    vb.cpus = numvcpus
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # VMware Fusion
  config.vm.provider :vmware_fusion do | vm |
    vm.name = environment_name
    vm.gui = false

    vm.vmx["memsize"] = memsize
    vm.vmx["numvcpus"] = numvcpus
  end

  # Parallels Desktop
  config.vm.provider :parallels do | prl |
    prl.name = environment_name
    prl.update_guest_tools = true

    prl.memory = memsize
    prl.cpus = numvcpus
  end

  config.vm.provision :shell, inline: "yum -y install docker-engine"
  config.vm.provision :shell, inline: "systemctl enable docker.service"
  config.vm.provision :shell, inline: "systemctl start docker.service"
  config.vm.provision :shell, inline: "wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip"
  config.vm.provision :shell, inline: "unzip -o -d /usr/local/bin/ /tmp/packer.zip"
  config.vm.provision :shell, inline: "ln -fs /usr/local/bin/packer /usr/local/bin/packer-io"
  config.vm.provision :shell, inline: "groupmems -g docker -a vagrant"
  config.vm.provision :shell, inline: "cd /vagrant && packer-io build template-docker.json"
end
