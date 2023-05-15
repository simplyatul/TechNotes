# Documenting k8s/kubernetes commands/notes 

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