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

## Search the package along with available versions

```
apt list -a libboost-atomic-dev
Listing... Done
libboost-atomic-dev/jammy 1.74.0.3ubuntu7 amd64

libboost-atomic-dev/jammy 1.74.0.3ubuntu7 i386
```

## Make a remove connection to Ubuntu from Windows

**Worked with Ubuntu 22.04.2 LTS (Jammy)**

```
sudo apt install xrdp
sudo ufw allow 3389
sudo systemctl status xrdp
```

**Remember to logout**

Logging out (locally) is the most important part. If you login by physically going to the computer and connecting keyboard, mouse, monitor etc. then xrdp won't work until you logout.

To change the appearance of the desktop from the default gnome to Ubuntu, create the hidden file ```/home/$USER/.xsessionrc``` with the following content:

```
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
```

Ref: https://askubuntu.com/questions/1407444/ubuntu-22-04-remote-desktop-headless/1409120#1409120

