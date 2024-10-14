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

