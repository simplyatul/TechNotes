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
