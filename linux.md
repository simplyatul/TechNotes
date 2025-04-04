# General Linux commands

## User - CRUD

### Create an user with home dir
```bash
sudo useradd -m user1 

# Home dir => /home/user1
```
### Create an user with home dir + specific UID

```bash
sudo useradd -m -u 3000 user1

id -u user1
# 3000
```
### Add a user in sudo group

```bash
groups user1
# user1 : user1

sudo usermod -aG sudo user1

groups user1
# user1 : user1 sudo
```

### Remove user from sudo group
```bash
sudo usermod -rG sudo user1
```

## Get the octal/user readable permission of file/dir

```bash
chmod 00755 a.out && stat -c '%A %a %n' a.out
# -rwxr-xr-x 755 a.out

chmod 04755 a.out && stat -c '%A %a %n' a.out
# -rwsr-xr-x 4755 a.out

# s   => setuid bit set
# %a  => permission bits in octal
# %A  => permission bits and file type in human readable form
# %n  => file name
```

## List all syscalls a program makes

```bash
strace -c cat /dev/null
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 50.32    0.000390         390         1           execve
 17.03    0.000132          13        10           mmap
  5.81    0.000045          11         4           openat
  5.29    0.000041          20         2           munmap
  3.87    0.000030          10         3           mprotect
  3.74    0.000029           5         5           fstat
  3.61    0.000028           4         6           close
  2.06    0.000016           5         3           brk
  1.29    0.000010           5         2           read
  1.29    0.000010           5         2           pread64
  1.03    0.000008           8         1         1 access
  0.77    0.000006           6         1           arch_prctl
  0.77    0.000006           6         1           fadvise64
  0.77    0.000006           6         1           getrandom
  0.65    0.000005           5         1           prlimit64
  0.65    0.000005           5         1           rseq
  0.52    0.000004           4         1           set_tid_address
  0.52    0.000004           4         1           set_robust_list
------ ----------- ----------- --------- --------- ----------------
100.00    0.000775          16        46         1 total

# trace particular system calls
strace -c -e brk,openat cat /dev/null
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 72.86    0.000051          12         4           openat
 27.14    0.000019           6         3           brk
------ ----------- ----------- --------- --------- ----------------
100.00    0.000070          10         7           total

```

## Capture syscalls in a file

```bash
$ strace -ttt -ff --output=s-cat.log cat /dev/null

# -ff => Combine the effects of --follow-forks and --output-separately options
# -ttt => number of seconds since the epoch + microseconds

# 7277 is process id of cat command

$ head s-cat.log.7277 
1733033570.327626 execve("/usr/bin/cat", ["cat", "/dev/null"], 0x7ffcc10c2170 /* 60 vars */) = 0
1733033570.328617 brk(NULL)             = 0x5f379810f000
1733033570.328749 mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x76de9cf3f000
1733033570.328807 access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
1733033570.328935 openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
1733033570.328992 fstat(3, {st_mode=S_IFREG|0644, st_size=95715, ...}) = 0
1733033570.329040 mmap(NULL, 95715, PROT_READ, MAP_PRIVATE, 3, 0) = 0x76de9cf27000
1733033570.329091 close(3)              = 0
1733033570.329137 openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
1733033570.329179 read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220\243\2\0\0\0\0\0"..., 832) = 832
```

## Convert human readable time to epoch time
```bash
$ date -d '@1733033570'
Sunday 01 December 2024 11:42:50 AM IST

$ date --date='@1733033570'
Sunday 01 December 2024 11:42:50 AM IST
```

## Display date in Year-month-day format
```bash
date +%Y-%m-%d
date +%Y-%m-%d-%H-%M-%S
```
## Run multiple commands on piped output
```bash
docker ps --format '{{.Names}}' | xargs -I % sh -c '{ echo %; docker exec % ip addr; }'

# Or

ls | xargs -I % sh -c '{ echo %; ls -l "%"; }'
``` 
## List current time with timezone info
```bash
timedatectl
        Local time: Sat 2024-12-28 07:28:05 UTC
        Universal time: Sat 2024-12-28 07:28:05 UTC
        RTC time: Sat 2024-12-28 07:28:05
        Time zone: Etc/UTC (UTC, +0000)
        System clock synchronized: yes
        NTP service: active
        RTC in local TZ: no
```
## Find timezone
```bash
timedatectl list-timezones | grep -i kolk
Asia/Kolkata
```
## Update/set timezone
```bash
sudo timedatectl set-timezone Asia/Kolkata
```

## install LLVM/Clang toolchain on Ubuntu
```bash
wget -4 https://apt.llvm.org/llvm.sh > llvm.sh
sudo bash llvm.sh

# By default llvm.sh uses wget. 
# In case wget do not work with IPv6 then use -4 option 
```bash

Ref: https://apt.llvm.org/