# Documenting Docker commands/notes 

## Install docker on Ubuntu
```bash
# uninstall all conflicting packages:
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world

# Post install steps
sudo groupadd docker
sudo usermod -aG docker $USER

# Log out and log back
# Verify
docker run hello-world

# Configure Docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

Ref:
https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
https://docs.docker.com/engine/install/linux-postinstall/

## Check listening tcp ports inside container

```bash
cn=<container name>
c_pid=`docker container inspect -f "{{.State.Pid}}" ${cn}`
nsenter -t ${c_pid} -n netstat -lt 
```
Or use the single command

```bash
sudo nsenter -t `docker inspect -f "{{.State.Pid}}" <containerid>` -n netstat

```
nsenter => run program in different namespaces  
-n => network ns

## Free up the space

```bash
$ docker system prune

This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache
```

## List all images
```bash
docker image ls
```

## List running containers
```bash
docker ps -a
```

## List Dangling images
```bash
docker images --filter "dangling=true"
```

## perform nslookup on busybox image

```bash
docker run busybox nslookup google.com
```
Once nslookup finishes, container will be stopped.

## Run Busybox container and let it run
```bash
docker run --name bb -dt busybox
```

## Enter into already running container

```bash
docker exec -it bb /bin/sh
```

## restart docker service
```bash
sudo service docker restart
```

## Remove only stopped containers

```bash
docker rm $(docker ps -q -f status=exited)
```

## Stop running containers
```bash
docker stop $(docker ps -qa)
```

## Remove stopped containers
```bash
docker rm $(docker ps -qa)
```

## Stop and Remove all running containers 
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa)
```

## Remove all docker images
```bash
docker rmi $(docker images -q)
```

## Copy a file from Host to Container
```bash
docker cp /tmp/a <container_name>:/
```

## Copy a file from Container to Host
```bash
docker cp <container_name>:/b /tmp
```

## Print container stats

```bash
docker stats --no-stream
```

## Build the docker image from (git) repo url and the tag (v1.1)
```bash
docker build -t godevsetup:1.1 https://github.com/simplyatul/godevsetup.git#v1.1
```

## Run the container and expose a port 
```bash
docker run -dit --name goserver -p 8080:8080 godevsetup:1.1
```

## List the docker networks
```bash
docker network ls
```

## IP address of docker container
```bash
docker container inspect <container-name> --format '{{ .NetworkSettings.Networks.kind.IPAddress }}'
```

## Dockerfile of a trivial busybox container
```bash
cat <<EOF >> Dockerfile
FROM busybox
ENTRYPOINT while true; do echo 'SSD OK'; sleep 5; done
EOF

docker build -f Dockerfile -t docker-test .
docker run --name dt -dt docker-test

```
## Delete all docker images
```bash
docker rmi $(docker images -a -q)
```