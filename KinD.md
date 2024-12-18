# KinD => Kubernetes (k8s) in Docker 

## Export KinD logs

```bash
kind export logs
```

It will output as

```
Exporting logs for cluster "kind" to:
/tmp/2444677848
```

## Create a cluster nodes using yaml file
```bash
cat <<EOF >> kind-local-k8s-cluster-baremin.yaml 
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: worker
  - role: worker
  - role: control-plane
EOF
```

```bash
kind create cluster --config ./kind-local-k8s-cluster-baremin.yaml --name k8s
```
Above commands creates three docker containers representing k8s nodes
```bash
kubectl get nodes -o wide
NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-control-plane   Ready    control-plane   47s   v1.26.3   172.18.0.4    <none>        Ubuntu 22.04.2 LTS   6.8.0-49-generic   containerd://1.6.19-46-g941215f49
k8s-worker          Ready    <none>          22s   v1.26.3   172.18.0.2    <none>        Ubuntu 22.04.2 LTS   6.8.0-49-generic   containerd://1.6.19-46-g941215f49
k8s-worker2         Ready    <none>          22s   v1.26.3   172.18.0.3    <none>        Ubuntu 22.04.2 LTS   6.8.0-49-generic   containerd://1.6.19-46-g941215f49
```

```bash
docker ps -a
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS                    PORTS                       NAMES
82a4ff800ab5   kindest/node:v1.26.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute                                     k8s-worker2
b22a493aa91d   kindest/node:v1.26.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute         127.0.0.1:44299->6443/tcp   k8s-control-plane
bc2a17ed2965   kindest/node:v1.26.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute                                     k8s-worker
```

In each node (i.e docker container), containerd runtime is used
```bash
docker exec -it k8s-worker2 crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD
35329a988e951       a329ae3c2c52f       2 minutes ago       Running             kindnet-cni         0                   05b6eb78a14f6       kindnet-glwn6
2abb1cc3a8166       eb3079d47a23a       2 minutes ago       Running             kube-proxy          0                   636c3833a20cf       kube-proxy-7599g
```

## Delete a cluster
```bash
kind delete cluster --name k8s
```
