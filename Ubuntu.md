# Ubuntu 22.04.02 Setup/Config Details

## Set the fixed number of Workspaces
Settings -> Multitasking -> Fixed number of workspaces (3)

## Display Workday (like Monday, Sunday) with Date/Time on top bar 

```
Install Gnome Tweaks  
Opne Gnome Tweaks  
Enable Top Bar->Clock->Weekday  
```

Or

```
gsettings set org.gnome.desktop.interface clock-show-weekday true
```

## Usefull Tools
### General
```
apt install net-tools, vim, curl, git, kdiff3, tree, traceroute, make
```

### VPN

```
apt install network-manager-openconnect network-manager-openconnect-gnome
```

### Nvidea 
```
sudo apt install nvidia-prime
```

### SSH Server
```
apt install openssh-server
systemctl enable --now ssh
```


## Only show open windows from current Workspace

Issue: On clicking application icon on the Dock, ubuntu shows all open windows from all workspaces. 
```
$ gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
```


## Move Maximize, Minimize buttons to right of the each Window

```
Gnome Tweaks -> Windows tilebar -> Placement -> Right
```


