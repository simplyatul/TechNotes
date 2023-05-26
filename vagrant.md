# Vagrant useful commands

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

## Run a privisioner (out of others) on running/halted VM 

```bash
vagrant up --provision-with kind
```