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
