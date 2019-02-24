## Clone Repository

```
git clone https://github.com/abhsinh2/vagrant.git
cd vagrant/kubernetes
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
        :eth1 => "172.28.128.4",
        :mem => "2048",
        :cpu => "2"
    }
]
```

**Two Masters:**

```
nodes = [
    {
        :name => "k8s-master-1",
        :type => "master",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "172.28.128.4",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-master-2",
        :type => "master",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "172.28.128.5",
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
        :eth1 => "172.28.128.4",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "172.28.128.5",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => "hashicorp-vagrant/ubuntu-16.04",
        :box_version => "1.0.1",
        :eth1 => "172.28.128.6",
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
vagrant vbguest <VM-NAME>
```

## SSH Machines

```
vagrant ssh <VM-NAME>
```
