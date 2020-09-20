
# -*- mode: ruby -*-
# # vi: set ft=ruby :
# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 2.2.4"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

if File.exist?("nodes/nodes.yaml")
  nodes_config = YAML.load_file(File.join(File.dirname(__FILE__), 'nodes/nodes.yaml'))
end

# script = <<SCRIPT
# echo "#{hostname_ip} #{hostname_name}" | tee -a /etc/hosts
#SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/bionic64"
  #config.vm.box = "centos/7"
  config.vm.synced_folder "ansible_dir", "/ansible_dir", :mount_options=>["ro"]
  nodes_config["nodes"].each do |node|
    node_name = node["name"] # name of nodes
    node_ip = node[":ip"] # ip of nodes

    config.vm.define node_name do |config|
      # assign node names and ip addresses.
      config.vm.hostname = node_name
      config.vm.network :private_network, ip: node_ip
      
      config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", node[':memory']]
        vb.customize ["modifyvm", :id, "--name", node_name]
      end
      nodes_config["nodes"].each do |etc_nodes|
        hostname_name = etc_nodes["name"]
        hostname_ip = etc_nodes[":ip"]
        config.vm.provision :shell, :inline => "echo #{hostname_ip} #{hostname_name} | tee -a /etc/hosts"
      end
      # install of dependecy packages for ansible using script
      config.vm.provision :shell, :path => node[':bootstrap'] 
      #config.vm.provision :shell, path: "./scripts/bootstrap-install.sh"
      config.vm.provision :reload
      if config.vm.hostname == "requester.kubevincelabs.com"
        config.vm.provision "ansible_local" do |ansible|
          ## disable default limiti to connect to all the machines
          ansible.provisioning_path="/ansible_dir"
          ansible.limit = "all"
          ansible.playbook = "site.yml"
          ansible.config_file="ansible.cfg"
          ansible.inventory_path="hosts.ini"
         # ansible.raw_arguments=["network_interface=enp0s8"]
        end
      end
      
    end

  end
end
