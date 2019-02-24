#!/bin/bash

if [ ! -f /home/vagrant/.firsttime ]; then
    echo "Node: First Time Configuration"

    HOME=/home/vagrant
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    export KUBECONFIG=/etc/kubernetes/admin.conf

    sudo apt-get install -y sshpass

    #Using the master (API Server) IP address or name, the token and the cert has, let's join this Node to our cluster.
    #sudo kubeadm join 192.168.205.10:6443 \
    #    --token 9woi9e.gmuuxnbzd8anltdg \
    #    --discovery-token-ca-cert-hash sha256:f9cb1e56fecaf9989b5e882f54bb4a27d56e1e92ef9d56ef19a6634b507d76a9

    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
    sh ./kubeadm_join_cmd.sh
else
    echo "Node is already configured"
fi
