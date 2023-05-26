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
kind create cluster --config ./kind-local-k8s-cluster-baremin.yaml --name istio-0
```

## Delete a cluster
```bash
kind delete cluster --name istio-0
``` 