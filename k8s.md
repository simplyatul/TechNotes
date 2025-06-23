# Documenting k8s/kubernetes commands/notes 

## Examples of sidecar containers
- log rotators and collectors
- data processors
- communication adapters

## Echo Server Pod
```bash
cat <<EOF >> echo-server-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: echo-server-pod
  labels:
    app: echo-server-pod
spec:
  containers:
  - name: echo-server-container
    image: jmalloc/echo-server:latest
    ports:
    - containerPort: 8080
    env:
    - name: LOG_HTTP_HEADERS
      value: "true"
    - name: LOG_HTTP_BODY
      value: "true"
EOF
```

```bash
k apply -f echo-server-pod.yaml
k port-forward echo-server-pod 8080:8080 &
```

Access echo service using either 
```bash
curl http://localhost:8080/
Request served by echo-server-pod

GET / HTTP/1.1

Host: localhost:8080
Accept: */*
User-Agent: curl/8.5.0
```
Or
```bash
ECHO_SERVER_POD_IP=$(kubectl get pod echo-server-pod -o jsonpath='{.status.podIP}')
kubectl exec pod/curl -- curl --silent http://$ECHO_SERVER_POD_IP:8080/
Request served by echo-server-pod

GET / HTTP/1.1

Host: 10.244.1.9:8080
Accept: */*
User-Agent: curl/8.14.1
```

## Replica Set 
- Vs ReplicationController (RC)
    - behaves exactly same as RC, but has more expressive pod selectors
    - ReplicaSet’s selector also allows matching pods that lack a certain label 
    or pods that include a certain label key, regardless of its value

```bash
cat <<EOF >> echo-server-replicaset.yaml 
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: echo-server-replicaset
  labels:
    app: echo-server-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: echo-server-rs
  template:
    metadata:
      labels:
        app: echo-server-rs
    spec:
      containers:
      - name: echo-server-container
        image: jmalloc/echo-server:latest
        ports:
        - containerPort: 8080
        env:
        - name: LOG_HTTP_HEADERS
          value: "true"
        - name: LOG_HTTP_BODY
          value: "true"
EOF

k apply -f ./echo-server-replicaset.yaml
```

List pods
```bash
kubectl get pod -o wide
NAME                           READY   STATUS    RESTARTS      AGE     IP            NODE          NOMINATED NODE   READINESS GATES
curl                           1/1     Running   1 (35m ago)   35m     10.244.1.12   demo-worker   <none>           <none>
echo-server-pod                1/1     Running   0             4m39s   10.244.1.13   demo-worker   <none>           <none>
echo-server-replicaset-f9ksh   1/1     Running   0             2m33s   10.244.1.16   demo-worker   <none>           <none>
echo-server-replicaset-ldmdx   1/1     Running   0             2m33s   10.244.1.14   demo-worker   <none>           <none>
echo-server-replicaset-sgk8p   1/1     Running   0             2m33s   10.244.1.15   demo-worker   <none>           <none>
```

Access one of echo-server's replica

```bash
k port-forward echo-server-replicaset-f9ksh 8090:8080 &

curl http://localhost:8090/
Request served by echo-server-replicaset-f9ksh

GET / HTTP/1.1

Host: localhost:8090
Accept: */*
User-Agent: curl/8.5.0
```

Replica Set info
```bash
k describe replicasets.apps 
Name:         echo-server-replicaset
Namespace:    default
Selector:     app=echo-server-rs
Labels:       app=echo-server-rs
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=echo-server-rs
  Containers:
   echo-server-container:
    Image:      jmalloc/echo-server:latest
    Port:       8080/TCP
    Host Port:  0/TCP
    Environment:
      LOG_HTTP_HEADERS:  true
      LOG_HTTP_BODY:     true
    Mounts:              <none>
  Volumes:               <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  5m56s  replicaset-controller  Created pod: echo-server-replicaset-ldmdx
  Normal  SuccessfulCreate  5m56s  replicaset-controller  Created pod: echo-server-replicaset-sgk8p
  Normal  SuccessfulCreate  5m56s  replicaset-controller  Created pod: echo-server-replicaset-f9ksh
```

## K8s Service
### ClusterIP Service
Create service which acts as a front-end to ```echo-server-replicaset```

```bash
cat << EOF >> cat echo-server-service-clusterip.yaml 
apiVersion: v1
kind: Service
metadata:
  name: echo-server-clusterip-service
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: echo-server-rs
EOF

k apply -f echo-server-service-clusterip.yaml 
```

List services
```bash
kubectl get services -o wide
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
echo-server-clusterip-service   ClusterIP   10.96.217.253   <none>        80/TCP    16m   app=echo-server-rs
kubernetes                      ClusterIP   10.96.0.1       <none>        443/TCP   11d   <none>
```

Describe Service
```bash
k describe service/echo-server-clusterip-service 
Name:              echo-server-clusterip-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=echo-server-rs
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.217.253
IPs:               10.96.217.253
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.244.1.14:8080,10.244.1.15:8080,10.244.1.16:8080
Session Affinity:  None
Events:            <none>
```

See IPs listed in Endpoints matches to Pods IPs of ```echo-server-rs```

Access the Service
```bash
k exec pods/curl -- curl --silent http://echo-server-clusterip-service.default.svc.cluster.local
Request served by echo-server-replicaset-ldmdx

GET / HTTP/1.1

Host: echo-server-clusterip-service.default.svc.cluster.local
Accept: */*
User-Agent: curl/8.14.1

k exec pods/curl -- curl --silent \
    http://echo-server-clusterip-service.default.svc.cluster.local

Request served by echo-server-replicaset-sgk8p

GET / HTTP/1.1

Host: echo-server-clusterip-service.default.svc.cluster.local
Accept: */*
User-Agent: curl/8.14.1

```
- Notes
    - one can drop ```svc.cluster.local``` from URL.
    - if calling pod is in same namespace, then you can drop namespace 
    name ```default``` as well
        ```bash
        k exec pods/curl -- curl --silent \
            http://echo-server-clusterip-service
        ```

### External Service
- service consists of only a reference to an external name 
- kubedns or equivalent will return as a CNAME record
- no exposing or proxying of any pods involved.

```bash
cat << EOF >> external-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  type: ExternalName
  externalName: google.co.in
  ports:
  - port: 80
EOF

k apply -f external-service.yaml
```

Just attach netshoot container in any of the running service as ephemeral container

```bash
kubectl debug echo-server-pod -it --image=nicolaka/netshoot

echo-server-pod~ nslookup external-service
Server:         10.96.0.10
Address:        10.96.0.10#53

external-service.default.svc.cluster.local      canonical name = google.co.in.
Name:   google.co.in
Address: 142.250.192.35
Name:   google.co.in
Address: 2404:6800:4009:803::2003

```

### NodePort Service
- Make Kubernetes reserve a port on all its nodes
- NodePort service can be accessed using Node's IP:port along with service's 
internal cluster IP

```bash
cat <<EOF >> echo-server-service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: echo-server-nodeport-service
spec:
  type: NodePort
  ports:
  - port: 80                 # port of the service’s internal cluster IP.
    targetPort: 8080         # target port of backing pod
    nodePort: 30123          # node's port on which service is accessible
  selector:
    app: echo-server-rs
EOF

k apply -f echo-server-service-nodeport.yaml
```

Access the service using nodeport
```bash
kubectl get services -o wide
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE    SELECTOR
echo-server-clusterip-service   ClusterIP      10.96.217.253   <none>         80/TCP         174m   app=echo-server-rs
echo-server-nodeport-service    NodePort       10.96.160.8     <none>         80:30123/TCP   18s    app=echo-server-rs
external-service                ExternalName   <none>          google.co.in   80/TCP         19m    <none>
kubernetes                      ClusterIP      10.96.0.1       <none>         443/TCP        11d    <none>

kubectl get nodes -o wide
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
demo-control-plane   Ready    control-plane   11d   v1.26.3   172.20.0.3    <none>        Ubuntu 22.04.2 LTS   6.8.0-60-generic   containerd://1.6.19-46-g941215f49
demo-worker          Ready    <none>          11d   v1.26.3   172.20.0.2    <none>        Ubuntu 22.04.2 LTS   6.8.0-60-generic   containerd://1.6.19-46-g941215f49

curl http://172.20.0.2:30123/
Request served by echo-server-replicaset-f9ksh

GET / HTTP/1.1

Host: 172.20.0.2:30123
Accept: */*
User-Agent: curl/8.5.0

curl http://172.20.0.3:30123/
Request served by echo-server-replicaset-f9ksh

GET / HTTP/1.1

Host: 172.20.0.3:30123
Accept: */*
User-Agent: curl/8.5.0

```

### Headless Service
- Such service won't get dedicated Cluster IP
- Instead, it returns DNS A records of backing pods

```bash
cat <<EOF >> echo-server-service-headless.yaml
apiVersion: v1
kind: Service
metadata:
  name: echo-server-headless-service
spec:
  clusterIP: None
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: echo-server-rs
EOF

k apply -f echo-server-service-headless.yaml
```

Check service
```bash
kubectl get services -o wide
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE     SELECTOR
echo-server-clusterip-service   ClusterIP      10.96.217.253   <none>         80/TCP         3h30m   app=echo-server-rs
echo-server-headless-service    ClusterIP      None            <none>         80/TCP         5m7s    app=echo-server-rs
echo-server-nodeport-service    NodePort       10.96.160.8     <none>         80:30123/TCP   36m     app=echo-server-rs
external-service                ExternalName   <none>          google.co.in   80/TCP         55m     <none>
kubernetes                      ClusterIP      10.96.0.1       <none>         443/TCP        11d     <none>
```

See the nslookup output on ClusterIP and headless service
```bash
kubectl debug echo-server-pod -it --image=nicolaka/netshoot

echo-server-pod~ nslookup  echo-server-headless-service  
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   echo-server-headless-service.default.svc.cluster.local
Address: 10.244.1.14
Name:   echo-server-headless-service.default.svc.cluster.local
Address: 10.244.1.15
Name:   echo-server-headless-service.default.svc.cluster.local
Address: 10.244.1.16


echo-server-pod~ nslookup  echo-server-clusterip-service
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   echo-server-clusterip-service.default.svc.cluster.local
Address: 10.96.217.253
```
- curl on headless service will fail
```bash
k exec pods/curl -- curl --silent http://echo-server-headless-service
command terminated with exit code 7
```

- A headless services still provides load balancing across pods
- It does it through the DNS round-robin mechanism
- Call nslookup on echo-server-headless-service multiple times and you will 
see pod IP addresses are returned in RR fashion


## Run a pod and delete it once the command finishes
```bash
kubectl run -i -n default --rm --restart=Never dummy --image=curlimages/curl --command -- sh -c 'cat /etc/resolv.conf'
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
pod "dummy" deleted
```

## Run a pod and keep it running
```bash
kubectl run -n default nginx --image=nginx
pod/nginx created

# Or

kubectl run alpine-pod --image alpine --restart Never -- /bin/sleep 999999
pod/alpine-pod created

kubectl exec pod/alpine-pod -- ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sleep 999999
   13 root      0:00 ps aux

# Or

kubectl run -n default curl --image=curlimages/curl -i --tty -- sh
If you don't see a command prompt, try pressing enter.
/ $ 
```

Re-attch to the pod

```bash
kubectl attach curl -c curl -i -t -n default
```

## Get IP address of all Pods from all namespaces

```bash
kubectl get pods -A -o custom-columns=NS:metadata.namespace,NAME:metadata.name,IP:status.podIP,NODE:spec.nodeName
```

## List k8s API Resources
```bash
kubectl api-resources -o wide
```

## Interact with specific cluster
```bash
kubectl cluster-info --context <cluster-name>
```
Check  ~/.kube/config for the cluster-name

## Get the details/help on k8s Objects and APIs

```bash
kubectl explain pod
kubectl explain pod.spec
```

## Show the labels

```bash
kubectl get all --show-labels
kubectl get nodes --show-labels
```

## Create a custom namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: new-namespace
```
Or

```bash
kubectl create namespace new-namespace
```

### Create a resource(s) in custom namespace

```bash
kubectl create -f <yaml file> -n new-namespace
```

### Delete the namespace

```bash
kubectl delete ns new-namespace
```

## Edit a k8s resource, say deployment

```bash
kubectl edit deployment.apps/godevsetup
```
This will open an editor and you can update the fields, say replicas

## Configure kubectl to use other editor

```bash
export KUBE_EDITOR="/usr/bin/nano"
```

## Scale the replicas/deployment

```bash
kubectl scale deployment.apps/godevsetup --replicas=5
```

## List the pods along with the Nodes on which they are running

```bash
kubectl get pod -o custom-columns=POD:metadata.name,NODE:spec.nodeName --sort-by spec.nodeName
```

## Prints the specific columns
```bash
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   36m
kube-node-lease      Active   36m
kube-public          Active   36m
kube-system          Active   36m
local-path-storage   Active   36m
```

```bash
kubectl get namespaces -o=jsonpath='{range.items[*]}{.metadata.name} {"\n"}{end}'
default 
kube-node-lease 
kube-public 
kube-system 
local-path-storage 
```

## Get the current namespace of current context using kubectl
```bash
kubectl config view --minify --output 'jsonpath={..namespace}'; echo
```

--minify => Remove all information not used by current-context from the output

; echo => makes output more readable

## Point kubectl to a specific namespace

```bash
kubectl config set-context $(kubectl config current-context) --namespace=custom-ns
```
## Get the current context information
```bash
kubectl config get-contexts $(kubectl config current-context)
CURRENT   NAME               CLUSTER            AUTHINFO           NAMESPACE
*         kind-k8s-samples   kind-k8s-samples   kind-k8s-samples   default
```
## Understand object API fields

```bash
kubectl explain pod
KIND:       Pod
VERSION:    v1

DESCRIPTION:
    Pod is a collection of containers that can run on a host. This resource is
    created by clients and scheduled onto hosts.

FIELDS:
  apiVersion	<string>
    APIVersion defines the versioned schema of this representation of an object.
    Servers should convert recognized schemas to the latest internal value, and
    may reject unrecognized values. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

  kind	<string>
    Kind is a string value representing the REST resource this object
    represents. Servers may infer this from the endpoint the client submits
    requests to. Cannot be updated. In CamelCase. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

  metadata	<ObjectMeta>
    Standard object's metadata. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

  spec	<PodSpec>
    Specification of the desired behavior of the pod. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

  status	<PodStatus>
    Most recently observed status of the pod. This data may not be up to date.
    Populated by the system. Read-only. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
```

```bash
kubectl explain pod.kind

KIND:       Pod
VERSION:    v1

FIELD: kind <string>


DESCRIPTION:
    Kind is a string value representing the REST resource this object
    represents. Servers may infer this from the endpoint the client submits
    requests to. Cannot be updated. In CamelCase. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
```

## Create resource defined in yaml file

```bash
kubectl create -f <yaml file>
```

## Logging containerize app logs
```bash
kubectl logs pod/nginx -c nginx

-c => Container name
```
## Create DNS utils pod
```bash
kubectl run dnsutils --image=tutum/dnsutils --command -- sleep infinity
pod/dnsutils created

# Usage => Find IP address associated with headleass service
kubectl exec pod/dnsutils -- nslookup nginx-hl-srv
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	nginx-np-srv.default.svc.cluster.local
Address: 10.96.98.155
```

## Create a k8s resource (e.g. ConfigMap) using command and extract yaml file
```bash
kubectl create configmap fortune-config --from-literal=sleep-interval=25 --from-literal=foo=bar
configmap/fortune-config created

kubectl get configmaps fortune-config -o yaml
apiVersion: v1
data:
  foo: bar
  sleep-interval: "25"
kind: ConfigMap
metadata:
  creationTimestamp: "2024-10-16T04:23:02Z"
  name: fortune-config
  namespace: default
  resourceVersion: "141051"
  uid: f984d187-ea20-49c0-b92d-1e2df583eb97
```
## How to access K8s API Server APIs

```bash
kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:38919
CoreDNS is running at https://127.0.0.1:38919/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

# Above cluster is created using KinD
```

Accessing API Server fails bec it needs authentication

```bash
curl https://127.0.0.1:38919 -k
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}
```

Solution: Use kubectl proxy.
kubectl proxy accepts HTTP connections on your local machine and proxies them to the API server while taking care of authentication.
```bash
kubectl proxy &
[2] 18900
Starting to serve on 127.0.0.1:8001
```

```bash
curl 127.0.0.1:8001
{
  "paths": [
    "/.well-known/openid-configuration",
    "/api",
    "/api/v1",
    "/apis",
    ...
    ...
    ...
  ]
}
```

## Access etcd.
Following commands verified on a KinD setup

```bash
kubectl exec -it -n kube-system etcd-k8s-samples-control-plane -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key endpoint health
https://127.0.0.1:2379 is healthy: successfully committed proposal: took = 4.11813ms
```

To locate/access pod definition
```bash
kubectl exec -it -n kube-system etcd-k8s-samples-control-plane -- etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.cr
t --key=/etc/kubernetes/pki/etcd/healthcheck-client.key get /registry/pods/default/nginx-dep-7579c6ff58-7bgpv
```

## CNI Functions
- General Pod Connectivity
- IPAM => IP Address Management
- Service handling and load balancing 
- Network policy enforcement
- Monitoring and troubleshooting
