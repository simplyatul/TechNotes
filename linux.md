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

# s=> setuid bit set
```

