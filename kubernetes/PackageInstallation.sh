#!/bin/bash

# ip of this box
IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`
HOST_NAME=$(hostname -s)

echo "IP_ADDR is ${IP_ADDR}"
echo "HOST_NAME is ${HOST_NAME}"

#Disable swap, swapoff then edit your fstab removing any entry for swap partitions
#You can recover the space with fdisk. You may want to reboot to ensure your config is ok. 
# kubelet requires swap off
swapoff -a

# keep swap off after reboot
# Following change will keep swap off after reboot too
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
#vi /etc/fstab

echo "Patchin 10-kubeadm.conf"
sed -i '/ExecStart=/a Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#sed -i '0,/ExecStart=/s//Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"\n&/' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

apt-get update

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo "Docker is installed"
else
    echo "Docker is not installed"
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update

    #Install latest
    #sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    #Install specific version. Kubernetes certifies certain version
    sudo apt-get install -y docker-ce=18.03.1~ce-0~ubuntu
    sudo apt-get install -y docker-ce-cli=5:18.09.2~3-0~ubuntu-xenial
    sudo apt-get install -y containerd.io
fi

# run docker commands as vagrant user (sudo not required)
#usermod -aG vagrant

if command -v kubectl &>/dev/null; then
    echo "Kubectl is installed"
else
    echo "Kubectl is not installed"
    # Add Google's apt repository gpg key
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

    # Add the Kubernetes apt repository
    sudo touch /etc/apt/sources.list.d/kubernetes.list 
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

    # Update the package list and use apt-cache to inspect versions available in the repository
    sudo apt-get update

    #Install the required packages, if needed we can request a specific version
    #sudo apt-get install -y docker.io
    #sudo apt-mark hold docker.io
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl

    sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
    sudo systemctl restart kubelet
fi

#Check the status of our kubelet and our container runtime, docker.
#The kubelet will enter a crashloop until it's joined. 
sudo systemctl status kubelet.service 
sudo systemctl status docker.service 

#Ensure both are set to start when the system starts up.
sudo systemctl enable kubelet.service
sudo systemctl enable docker.service