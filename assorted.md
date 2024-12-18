# Miscellaneous Stuff...
 
## Setup bash aliases
```bash
wget -4 https://raw.githubusercontent.com/simplyatul/bin/master/setaliases.sh
source setaliases.sh

echo "source ~/setaliases.sh" >> ~/.bashrc
```
## Install some useful tools
```bash
wget -4 https://raw.githubusercontent.com/simplyatul/vagrant-vms/main/tools-0-install.sh
chmod +x tools-0-install.sh
sudo ./tools-0-install.sh
```
## Install sngrep on CentOS-7
create `/etc/yum.repos.d/irontec.repo` w/ following contents

```bash
[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/
```

Then...

```bash
$ rpm --import http://packages.irontec.com/public.key
$ yum install sngrep
```

## Simple File/Http Server on linux
```bash
$ cd /tmp
$ python -m http.server 8000
```

Now files in `/tmp` folder can be viewed/downlaoded in browser using http://\<ip\>:8000

## Yum IPv4/SSL Setting

yum update/list does not work – throws errors like
```bash
Timeout on http://mirrorlist.centos.org/
http://mirror.centos.org/centos/5/os...ta/repomd.xml: [Errno 12] Timeout: <urlopen error timed out>
Trying other mirror.
```

This is because yum tries to connect to IPv6 addresses return by DNS and sometimes IPv6 are not configured on these mirror sites. 
Solution is to tell yum to resolve to only IPv4 addresses. 

Add following setting in `/etc/yum.conf`
```bash
ip_resolve=IPv4
```

Ref/Credits:

https://unix.stackexchange.com/questions/444746/yum-fails-because-http-mirrorlist-centos-org-release-7arch-x86-64repo-os-is

Sometimes yum/dnf updates/install fails with SSL error (Peer certificate cannot be authenticated with given CA certificates).
Solution is to add following in /etc/yum.conf (/etc/dnf/dnf.conf)

```bash
sslverify=0
```

Ref/Credits:
http://fossdev.blogspot.com/2015/12/fedora-update-with-dnf-cannot.html


## List files in rpm package

List files in the package w/o installing the package
```bash
dnf repoquery -l csnappy-devel.x86_64
```

Ref/Credits:
https://stackoverflow.com/questions/104055/how-to-list-the-contents-of-a-package-using-yum


## Create file with size 1 GB, random data

```bash
dd if=/dev/urandom of=sample.txt bs=1M count=1024 iflag=fullblock
```

## Find a package of a binary in Ubuntu

```bash
dpkg -S /usr/bin/dig
bind9-dnsutils: /usr/bin/dig
```

## Location of installed packages (.deb files) in Ubuntu
```bash
ls /var/cache/apt/archives/
```

# Find the contents of the package in Ubuntu
```bash
# download package first
sudo apt-get --download-only install linux-tools-common

# check the contents of a package
sudo dpkg --contents /var/cache/apt/archives/linux-tools-common_5.15.0-126.136_all.deb
```
## Allow all selected characters to be highlighted in Notepad++

Settings -> Preferences -> Highlighting
Uncheck the "Match whole word only" under Smart Highlighting.


## Set the locale on Ubuntu
```bash
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```

## Reduce the image size

```bash
sudo apt-get install imagemagick

convert -resize 60% source.png dest.jpg
```

resize 60% => dest.jpg will be 60% of source.png

## Install dig and nslookup on Alpine Linux

```bash
apk update
apk add bind-tools
```

## Code navigation - ctags, cscope
```bash
cd ~/source-code

find . -name "*.c" -o -name "*.ccc" -o -name "*.h"  > cscope.files

ctags -B -L cscope.files
# outputs tags file in your current directory

cscope -q -R -b -i cscope.files
# outputs cscope.in.out, cscope.out, and cscope.po.out in your current directory

cscope -d
# starts the Cscope browser
# press Ctrl-d to exit.

```
### ctags flags

-B => Use backward searching patterns  
-L => Read from <file> a list of file names for which tags should be generated.

### cscope flags

-q => build a faster (but larger) database.  
-R => search for symbols recursively.  
-b => builds the database only, but does not start the Cscope browser.  
-i cscope.files => specifies the list of source files.  

## gcc to print all linked libraries

```bash
gcc hello.c -Xlinker --verbose
```