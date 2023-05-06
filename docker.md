# Documenting Docker commands/notes 

## Check the running containers within a k8s node created by KinD

```bash
docker exec -it kind-worker2 crictl ps
```

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
Above command is useful evenif netstat is not installed in the container

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

## Enter into already running container

```bash
docker exec -it [container-name] /bin/bash
```

## restart docker
```bash
sudo service docker restart
```


```bash
```

```bash
```


```bash
```


```bash
```

