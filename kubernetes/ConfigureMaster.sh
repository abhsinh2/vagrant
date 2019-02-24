#!/bin/bash

# ip of this box
IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`
HOST_NAME=$(hostname -s)

echo "IP_ADDR is ${IP_ADDR}"
echo "HOST_NAME is ${HOST_NAME}"

if [ ! -f /home/vagrant/.firsttime ]; then
    echo "Master: First Time Configuration"

    # Create our kubernetes cluster, specifying a pod network range matching that in calico.yaml!
    #sudo kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=192.168.0.0/16
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --node-name $IP_ADDR

    # Configure our account on the master to have admin access to the API server from a non-privileged account.
    HOME=/home/vagrant
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    export KUBECONFIG=/etc/kubernetes/admin.conf

    sudo mkdir -p /etc/calico
    sudo cp /home/vagrant/calicoctl.cfg  /etc/calico/calicoctl.cfg

    # Install Calico pod network addon
    # Only on the master, download the yaml files for the pod network
    kubectl apply -f https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/hosted/etcd.yaml
    kubectl apply -f https://docs.projectcalico.org/v3.5/getting-started/kubernetes/installation/hosted/calico.yaml

    kubectl taint nodes --all node-role.kubernetes.io/master-

    curl -O -L https://github.com/projectcalico/calicoctl/releases/download/v2.0.7/calicoctl
    chmod +x calicoctl
    sudo mv calicoctl /usr/local/bin/

    export ETCD_ENDPOINTS=http://127.0.0.1:2379
    calicoctl apply -f /home/vagrant/calico-ip-pool.yaml

    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh

    # required for setting up password less ssh between guest VMs
    sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart

    sudo touch /home/vagrant/.firsttime
else
    echo "Master is already configured"
fi
