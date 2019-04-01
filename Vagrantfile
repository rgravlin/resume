# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.network "private_network", type: "dhcp"
  config.vm.synced_folder ".", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 4096
  end

  config.vm.provision "shell", inline: <<-EOF
    export DEBIAN_FRONTEND=noninteractive
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    apt-get install -y awscli git-core curl jq docker-ce build-essential ruby-dev
    usermod -a -G docker vagrant
    snap install microk8s --classic
    ln -s /vagrant_data /home/vagrant/workspace
    mkdir scratch
  EOF

end
