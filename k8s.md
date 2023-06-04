# Documenting k8s/kubernetes commands/notes 

## Run a pod and delete the it once the command finishes
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

## Interacti with specific cluster
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
kubectl config set-context $(kubectl config current-context) --namespace=istioinaction
```
