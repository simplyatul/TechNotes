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
sudo apt install vim curl git gitk kdiff3 tree traceroute make dos2unix yamllint net-tools iproute2 bind9-dnsutils iputils-ping jq
```
net-tools => netstat  
iproute2 => ip  
bind9-dnsutils => dig  
iputils-ping => ping
jq => Command-line JSON processor

### VPN

```
sudo apt install network-manager-openconnect network-manager-openconnect-gnome
```

### Nvidea 
```
sudo apt install nvidia-prime
```

### SSH Server
```
sudo apt install openssh-server
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


