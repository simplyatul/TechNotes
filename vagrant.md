# Intro
- Vagrant box's location is ~/.vagrant.d/boxes
- ubuntu vagrant box images are at [here](https://portal.cloud.hashicorp.com/vagrant/discover/ubuntu)

## Vagrant useful commands

### Create a VM
Assuming Vagrant file is present in CWD.
```bash
vagrant up --provider=virtualbox
```
### VM Status
```bash
vagrant status
```
### SSH Config
```bash
vagrant ssh-config
```

### Enter into VM as SSH user
```bash
vagrant ssh
```
### List down the available boxes

```bash
vagrant box list
```
### Destroys the VM
```bash
vagrant destroy
```
## Run a provisioner (out of others) on running/halted VM

```bash
vagrant up --provision-with kind
```

## List all Vagrant managed VMs VM

```bash
vagrant global-status
```

