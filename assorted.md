# Miscellaneous Stuff...
 
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

## Allow all selected characters to be highlighted in Notepad++

Settings -> Preferences -> Highlighting
Uncheck the "Match whole word only" under Smart Highlighting.


## Set the locale on Ubuntu
```bash
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```