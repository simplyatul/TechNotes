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

## trace a program

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

# trace particular calls
strace -c -e brk,openat cat /dev/null
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 72.86    0.000051          12         4           openat
 27.14    0.000019           6         3           brk
------ ----------- ----------- --------- --------- ----------------
100.00    0.000070          10         7           total

```