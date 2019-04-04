# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = 4096
  end

  disable_ipv6_hostname = <<-EOF
    sudo sed -i 's/^\::1/#::1/g' /etc/hosts
  EOF

  docker_repository = <<-EOF
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  EOF

  package_dependencies = <<-EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y awscli git-core curl jq docker-ce build-essential ruby-dev iptables-persistent netfilter-persistent
  EOF

  iptables_pod_egress = <<-EOF
    iptables -P FORWARD ACCEPT
    iptables-save > /etc/iptables/rules.v4
  EOF

  vagrant_docker_permissions = <<-EOF
    sudo usermod -a -G docker vagrant
  EOF

  microk8s_install = <<-EOF
    sudo snap install microk8s --classic
  EOF

  microk8s_enable_services = <<-EOF
    microk8s.enable dns registry
  EOF

  workspace_setup = <<-EOF
    mkdir scratch
    ln -s /vagrant /home/vagrant/workspace
  EOF

  sleep_10 = <<-EOF
    sleep 10
  EOF

  config.vm.provision "shell", privileged: false, inline: disable_ipv6_hostname, keep_color: true, name: "disable_ipv6_hostname"
  config.vm.provision "shell", privileged: false, inline: docker_repository, keep_color: true, name: "docker_repository"
  config.vm.provision "shell", privileged: true, inline: package_dependencies, keep_color: true, name: "package_dependencies"
  config.vm.provision "shell", privileged: true, inline: iptables_pod_egress, keep_color: true, name: "iptables_pod_egress"
  config.vm.provision "shell", privileged: false, inline: vagrant_docker_permissions, keep_color: true, name: "vagrant_docker_permissions"
  config.vm.provision "shell", privileged: false, inline: microk8s_install, keep_color: true, name: "microk8s_install"
  config.vm.provision "shell", privileged: false, inline: sleep_10, keep_color: true, name: "sleep_10"
  config.vm.provision "shell", privileged: false, inline: microk8s_enable_services, keep_color: true, name: "microk8s_enable_services"
  config.vm.provision "shell", privileged: false, inline: workspace_setup, keep_color: true, name: "workspace_setup"

end
