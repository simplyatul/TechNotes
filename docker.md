# Documenting Docker commands/notes 

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
FROM busybox
ENTRYPOINT while true; do echo 'SSD OK'; sleep 5; done
```
