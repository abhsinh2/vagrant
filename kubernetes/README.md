## Clone Repository

```
git clone https://bitbucket-eng-sjc1.cisco.com/bitbucket/scm/~abhsinh2/notes.git
cd notes/kubernetes/kubernetes-vm
```

## Edit Vagrantfile to add node details

**Only Master:**

```
nodes = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    }
]
```

**Master with two nodes:**

```
nodes = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "192.168.205.11",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "192.168.205.12",
        :mem => "2048",
        :cpu => "2"
    }
]
```

**NOTE: Make sure that master is defined first, it will make master vm to start first**

## Start VMs

`vagrant up`

If you see error:

```
The error output from the command was:

: No such device
```

Run:

```
vagrant plugin install vagrant-vbguest
vagrant vbguest k8s-master
vagrant vbguest k8s-node-1
vagrant vbguest k8s-node-2
```

## SSH Machines

```
vagrant ssh k8s-master
vagrant ssh k8s-node-1
vagrant ssh k8s-node-2
```

## Kubernetes Configuration

If you running only single VM with Master then run below commands:

```
sudo kubectl taint nodes <NODE_NAME> node-role.kubernetes.io/master:NoSchedule-

e.g.

sudo kubectl taint nodes k8s-mongo node-role.kubernetes.io/master:NoSchedule-
```