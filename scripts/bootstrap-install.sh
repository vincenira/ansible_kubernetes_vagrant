#!/bin/bash -   
# title          :bootstrap-install.sh
# description    :install prerequisites for ansible
# author         :vincenira
# date           :20200823
# version        :1.0.0  
# usage          :./bootstrap-install.sh
# notes          :       
# bash_version   :4.4.23(1)-release
# ============================================================================


set -e
requester_name="requester.kubevincelabs.com"
host_name=$(hostname)
ip_tag="192"
os_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o "\w*"| head -n 1)
home_ssh="/home/vagrant/.ssh"
case "${os_name}" in
  "CentOS")
    requester_name="requester.kubevincelabs.com"
    sudo yum install -y epel-release
    sudo yum install -y git ansible sshpass openssl-devel python3
    sudo yum -y update && sudo yum -y upgrade
  ;;
  "Ubuntu")
    requester_name="requester"
    sudo sed -i 's/us.archive.ubuntu.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
    sudo apt-add-repository -y ppa:ansible/ansible
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -yq && sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq ansible git sshpass python-netaddr libssl-dev
  ;;
  *)
    echo "${os_name} is not support ..."; exit 1
esac

#yes "/root/.ssh/id_rsa" | sudo ssh-keygen -t rsa -n ""
sudo sed -i -e 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config; sudo systemctl restart sshd

if [ $host_name = $requester_name ]; then
  ssh-keygen -b 2048 -t rsa -f /tmp/id_rsa -q -N ""
  cp /tmp/id_rsa /tmp/id_rsa.pub ${home_ssh}/.
  sudo chown vagrant:vagrant ${home_ssh}/id_rsa ${home_ssh}/id_rsa.pub
  rm -rf /tmp/id_rsa*
  for host in $(grep "$ip_tag" /etc/hosts | cut -d " " -f1); do
     sudo sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no -f -i ${home_ssh}/id_rsa vagrant@${host}
      #sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo cd ${home_ssh}|| sudo mkdir -p ~/.ssh"
      #sudo cat ~/.ssh/id_rsa.pub | \
       # sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo tee -a ${home_ssh}authorized_keys"
      #sudo sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@${host} "sudo sed -i -e 's/PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config; sudo systemctl restart sshd"
      echo "******** I WAS EXECUTED *********"
  done
  sudo echo "[kubecluster]" >> /etc/ansible/hosts
  sudo echo "192.168.56.16" >> /etc/ansible/hosts
  sudo echo "192.168.56.26" >> /etc/ansible/hosts
  sudo echo "192.168.56.36" >> /etc/ansible/hosts
  #sudo ansible-playbook -e network_interface=eth1 site.yml
fi

#cd /vagrant
#sudo ansible-playbook -e network_interface=eth1 site.yaml


