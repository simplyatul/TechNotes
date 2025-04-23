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
  - role: control-plane
EOF
```

```bash
kind create cluster \
--config ./kind-local-k8s-cluster-baremin.yaml \
--name k8s
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

Identify PID of a container running within conatinerd
```bash
crictl inspect --output go-template --template '{{.info.pid}}' 2abb1cc3a8166
```

## kubelet config file 
located on the host

```bash
cat ~/.kube/config | yq
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: LS0t...0K
      server: https://127.0.0.1:41231
    name: kind-k8s
contexts:
  - context:
      cluster: kind-k8s
      user: kind-k8s
    name: kind-k8s
current-context: kind-k8s
kind: Config
preferences: {}
users:
  - name: kind-k8s
    user:
      client-certificate-data: LS0...S0K
      client-key-data: LS0....LQo=
```

## Kubelet file in k8s control plate

```bash
docker exec -ti k8s-control-plane cat /var/lib/kubelet/config.yaml | yq
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled:false
  webhook:
    cacheTTL:0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
cgroupRoot: /kubelet
clusterDNS:
  - 10.96.0.10
clusterDomain: cluster.local
containerRuntimeEndpoint: ""
cpuManagerReconcilePeriod: 0s
evictionHard:
  imagefs.available: 0%
  nodefs.available: 0%
  nodefs.inodesFree: 0%
evictionPressureTransitionPeriod: 0s
failSwapOn: false
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageGCHighThresholdPercent: 100
imageMaximumGCAge: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
logging:
  flushFrequency: 0
  options:
    json:
      infoBufferSize: "0"
    text:
      infoBufferSize: "0"
  verbosity: 0
memorySwap: {}
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
shutdownGracePeriod: 0s
shutdownGracePeriodCriticalPods: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s

```
## Delete a cluster
```bash
kind delete cluster --name k8s
```

## Get the cluster
```bash
kind get clusters
```

## Get the cluster context
```bash
kubectl cluster-info --context kind-k8s
Kubernetes control plane is running at https://127.0.0.1:46455
CoreDNS is running at https://127.0.0.1:46455/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

```