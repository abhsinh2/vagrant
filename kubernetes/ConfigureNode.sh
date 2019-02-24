#!/bin/bash

if [ ! -f /home/vagrant/.firsttime ]; then
    echo "Node: First Time Configuration"

    HOME=/home/vagrant
    sudo --user=vagrant mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) $HOME/.kube/config

    export KUBECONFIG=/etc/kubernetes/admin.conf

    sudo apt-get install -y sshpass

    #Using the master (API Server) IP address or name, the token and the cert has, let's join this Node to our cluster.
    #sudo kubeadm join 192.168.205.10:6443 \
    #    --token <> \
    #    --discovery-token-ca-cert-hash <sha256:>

    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
    sh ./kubeadm_join_cmd.sh
else
    echo "Node is already configured"
fi
