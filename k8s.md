# Documenting k8s/kubernetes commands/notes 

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

Or

kubectl run alpine-pod --image alpine --restart Never -- /bin/sleep 999999
pod/alpine-pod created

kubectl exec pod/alpine-pod -- ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sleep 999999
   13 root      0:00 ps aux

```
Or
```bash
kubectl run -n default curl --image=curlimages/curl -i --tty -- sh
If you don't see a command prompt, try pressing enter.
/ $ 
```

Re-attch to the pod

```bash
kubectl attach curl -c curl -i -t -n default
```


## List k8s API Resources
```bash
kubectl api-resources -o wide
```

## Interactive with specific cluster
```bash
kubectl cluster-info --context <cluster-name>
```
Check  ~/.kube/config for the cluster-name

## Get the details/help on k8s Objects and APIs

```bash
kubectl explain pod
kubectl explain pod.spec
```

## Forwarding a local network port to a port in the pod

```bash
kubectl port-forward pod/godevsetup-575fcd74d5-9k6d9 8888:8080
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
