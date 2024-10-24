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

## Make a remote connection to Ubuntu from Windows

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

## Nvidia Graphics Card 

### Issue: Ubuntu 24.04.1 could not detect external monitor
- This happened suddenly on one fine day

### Troubleshooting

Identify Nvidia Graphics Card Type
```bash
# lspci -nn |grep 'VGA' 
00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-P Integrated Graphics Controller [8086:46a6] (rev 0c)
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA107BM [GeForce RTX 3050 Ti Mobile] [10de:25e0] (rev a1)
```

```bash
root@atul-lap:/home/atul# # Before connecting HDMI cable to Laptop
root@atul-lap:/home/atul# 
root@atul-lap:/home/atul# dmesg | grep -i 'hdmi\|nvidia'
[    2.298421] nvidia: loading out-of-tree module taints kernel.
[    2.298427] nvidia: module license 'NVIDIA' taints kernel.
[    2.298430] nvidia: module license taints kernel.
[    2.362862] nvidia-nvlink: Nvlink Core is being initialized, major device number 510
[    2.363996] nvidia 0000:01:00.0: enabling device (0006 -> 0007)
[    2.364350] nvidia 0000:01:00.0: vgaarb: VGA decodes changed: olddecodes=io+mem,decodes=none:owns=none
[    2.413728] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  550.107.02  Wed Jul 24 23:53:00 UTC 2024
[    2.639268] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  550.107.02  Wed Jul 24 23:24:27 UTC 2024
[    2.670367] [drm] [nvidia-drm] [GPU ID 0x00000100] Loading driver
[    3.121258] input: HDA NVidia HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input20
[    3.123817] input: HDA NVidia HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input21
[    3.124013] input: HDA NVidia HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input22
[    3.124053] input: HDA NVidia HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input23
[    3.524145] [drm:nv_drm_load [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to allocate NvKmsKapiDevice
[    3.524248] [drm:nv_drm_register_drm_device [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to register device
[    3.756562] nvidia_uvm: module uses symbols nvUvmInterfaceDisableAccessCntr from proprietary module nvidia, inheriting taint.
[    3.802019] nvidia-uvm: Loaded the UVM driver, major device number 507.
[    4.634102] skl_hda_dsp_generic skl_hda_dsp_generic: hda_dsp_hdmi_build_controls: no PCM in topology for HDMI converter 3
[    4.651167] input: sof-hda-dsp HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input37
[    4.651187] input: sof-hda-dsp HDMI/DP,pcm=4 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input38
[    4.651207] input: sof-hda-dsp HDMI/DP,pcm=5 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input39
root@atul-lap:/home/atul# 
root@atul-lap:/home/atul# 
root@atul-lap:/home/atul# 
root@atul-lap:/home/atul# # After connecting HDMI cable to Laptop
root@atul-lap:/home/atul# 
root@atul-lap:/home/atul# dmesg | grep -i 'hdmi\|nvidia'
[    2.298421] nvidia: loading out-of-tree module taints kernel.
[    2.298427] nvidia: module license 'NVIDIA' taints kernel.
[    2.298430] nvidia: module license taints kernel.
[    2.362862] nvidia-nvlink: Nvlink Core is being initialized, major device number 510
[    2.363996] nvidia 0000:01:00.0: enabling device (0006 -> 0007)
[    2.364350] nvidia 0000:01:00.0: vgaarb: VGA decodes changed: olddecodes=io+mem,decodes=none:owns=none
[    2.413728] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  550.107.02  Wed Jul 24 23:53:00 UTC 2024
[    2.639268] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  550.107.02  Wed Jul 24 23:24:27 UTC 2024
[    2.670367] [drm] [nvidia-drm] [GPU ID 0x00000100] Loading driver
[    3.121258] input: HDA NVidia HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input20
[    3.123817] input: HDA NVidia HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input21
[    3.124013] input: HDA NVidia HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input22
[    3.124053] input: HDA NVidia HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:01.0/0000:01:00.1/sound/card0/input23
[    3.524145] [drm:nv_drm_load [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to allocate NvKmsKapiDevice
[    3.524248] [drm:nv_drm_register_drm_device [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to register device
[    3.756562] nvidia_uvm: module uses symbols nvUvmInterfaceDisableAccessCntr from proprietary module nvidia, inheriting taint.
[    3.802019] nvidia-uvm: Loaded the UVM driver, major device number 507.
[    4.634102] skl_hda_dsp_generic skl_hda_dsp_generic: hda_dsp_hdmi_build_controls: no PCM in topology for HDMI converter 3
[    4.651167] input: sof-hda-dsp HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input37
[    4.651187] input: sof-hda-dsp HDMI/DP,pcm=4 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input38
[    4.651207] input: sof-hda-dsp HDMI/DP,pcm=5 as /devices/pci0000:00/0000:00:1f.3/skl_hda_dsp_generic/sound/card1/input39
root@atul-lap:/home/atul# 
```
### Issue

The NVIDIA driver is loaded correctly, but there are errors related to the NVIDIA DRM (Direct Rendering Manager)
```bash
[drm:nv_drm_load [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to allocate NvKmsKapiDevice
[drm:nv_drm_register_drm_device [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to register device
```

### Solution Worked (Suggested by ChatGPT)
Disable NVIDIA DRM

```bash
vi /etc/default/grub

# Append nvidia-drm.modeset=0 to GRUB_CMDLINE_LINUX_DEFAULT. So it should look like
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=0"

sudo update-grub
sudo reboot
```

### Other possible solutions

Clean out the current NVIDIA drivers and reinstall 

```bash
sudo apt-get remove --purge '^nvidia-.*'
sudo apt autoremove
sudo apt clean

sudo apt-get install nvidia-driver-550

# Or install old drivers if above do not work
sudo apt install nvidia-driver-525
```

### Utilities to install
```bash
# apt install nvidia-prime
# apt install nvidia-settings
```
### Other useful commands 
```bash
# prime-select 
Usage: /usr/bin/prime-select nvidia|intel|on-demand|query

# prime-select query
nvidia

# nvidia-smi

# nvidia-settings

# sudo lshw -C display

# forcing the system to detect the external monitor:
# xrandr --auto

# journalctl -xe | grep nvidia

```

### Ref:  
- https://askubuntu.com/questions/1456758/external-monitor-not-detected-in-ubuntu-20-04  
- https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/
- ChatGPT


## curl => print http response code only
```bash
curl -s -o /dev/null -w "%{http_code}\n%{local_ip}\n" https://google.com
301

-s => silent
-o <file> -> output to file
-w, --write-out <format>
```
