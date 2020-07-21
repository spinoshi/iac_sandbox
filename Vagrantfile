# -*- mode: ruby -*-
# vi: set ft=ruby :
### 
### --------------------------------------------------------------------------------------------
### 
my_group_name = "terraform-dev"
###
### --------------------------------------------------------------------------------------------
### 
###


Vagrant.configure("2") do |config|

 
 config.vm.define "os-controller" do |controller|
    controller.vm.hostname = "os-controller"
    controller.vm.box = "ubuntu/bionic64"
    controller.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--groups", "/#{my_group_name}"]
        v.memory = 8196
        v.cpus = 4
    end
    controller.vm.network "private_network", ip: "192.168.56.200"
  ## Inject my keyPair
    controller.vm.provision 'shell', inline: 'mkdir -p /root/.ssh'
    controller.vm.provision 'shell', inline: "fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile"
    controller.vm.provision 'shell', inline: "echo '/swapfile  swap swap  sw  0  0 '>> /etc/fstab"
    controller.vm.provision 'shell', inline: "sudo snap install microstack --classic --beta"
    controller.vm.provision 'shell', inline: "sudo microstack.init --auto"
  end


 config.vm.define "dev-host" do |dev|
    dev.vm.hostname = "dev-host"
    dev.vm.box = "ubuntu/bionic64"
    dev.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--groups", "/#{my_group_name}"]
        v.memory = 2048
        v.cpus = 2
    end
    dev.vm.network "private_network", ip: "192.168.56.10"
  ## Inject my keyPair
    dev.vm.provision 'shell', inline: 'mkdir -p /root/.ssh'
    dev.vm.provision 'shell', inline: "fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile"
    dev.vm.provision 'shell', inline: "echo '/swapfile  swap swap  sw  0  0 '>> /etc/fstab"
    dev.vm.provision 'shell', inline: "apt-get install unzip"
    dev.vm.provision 'shell', path: "./scripts/install_packer_and_terraform.sh"
    dev.vm.provision 'shell', path: "./scripts/install_openstack_client.sh"
    dev.vm.provision 'shell', path: "./scripts/os_refinements.sh"
  end

end


