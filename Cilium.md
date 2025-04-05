# Cilium 

## Intro 
- Cilium is eBPF based network observability and security tool.
- From inception, Cilium was designed for large-scale, highly-dynamic containerized environments.

On high level, Cilium provides
- Networking
    - Container Networking
    - L3-L4 LB
    - Multi-Cluster
- Network Security
    - L3-L7 n/w policies
    - Encryption
    - mTLS
    - SIEM Integration
- Observability (Hubble)
    - Flow Logs
    - Metrics
    - Troubleshooting
    - supports Timescape
        - based on Clickhouse (col based DBMS) 
    - Vs Grafana
        - Timescape is native to Cilium project, so more efficient from analytic perspective
        - lot of data and you want short query time then Timescape is more efficient
- Service Mesh and Ingress
    - L7 LB (using Envoy)
    - Tracing
    - Sidecar less
    - mTLS
- Gateway API
- Can do L2 as well

## eBPF
- Makes Linux/Windows kernel programmable.
- JS => Browser
- eBPF => Kernel

## Cilium Commands

### Install/Uninstall Cilium
```bash
# Using helm
helm repo add cilium https://helm.cilium.io/
helm repo update

helm search repo cilium/cilium --versions

helm install cilium cilium/cilium --namespace kube-system \
  --set annotateK8sNode=true \
  --set debug.enabled=true \
  --set kubeProxyReplacement=true \
  --version 1.16.6

helm install cilium cilium/cilium --namespace kube-system \
  --set debug.enabled=true \
  --version 1.16.6

# Uninstall 
helm uninstall cilium --namespace kube-system

# Install using cilium-cli

cilium install --set annotateK8sNode=true --set debug.enabled=true

```

### restarts cilium pods
Generally requires when you update any config params in cilium-config map
```bash
kubectl -n kube-system delete pod -l k8s-app=cilium
```

## Cilium Projects
### Cilium CNI
- Scalable, secure, high performance CNI plugin

### Cilium Service Mesh
- Sidecar less + Ingress + G/W API

### Hubble
- N/w Observability

### Tetragon
- Provides security relevant observability data
- Runtime security and observability
- Runtime enforcement
- Can run w/o Cilium as well

## Cilium Internals

### Cilium Configs
- Stored in k8s ConfigMap => cilium-config
```bash
kubectl get -n kube-system configmap cilium-config -o yaml | yq .data.enable-ipv6
true
```
- One can use Cilium CLI to fetch the same
```bash
cilium config view | grep enable-ipv6
enable-ipv6             true
```
- Cilium CLI tool interface with K8s API Server as necessary, similar to that of kubectl

## References
### Ebook: Kubernetes Networking and Cilium by Nico Vibert

### History of Cilium - Talk by Thomas Graf
- https://www.youtube.com/watch?v=wv_9YxdC49Y
- Few screenshots from the talk

- Cilium from 10K Feet
<img src="/resources/images/Cilium-1-In-Brief.png" title="Cilium from 10K Feet" style="height: 400px; width:800px;"/>

 - Cilium's Initial Vision
<img src="/resources/images/Cilium-2-Initial-Vision.png" title="Cilium's Initial Vision" style="height: 400px; width:800px;"/>

- Cilium Nework Security
<img src="/resources/images/Cilium-3-Nework-Security-1.0.png" title="Cilium Nework Security" style="height: 400px; width:800px;"/>

- Cilium Cluster Mesh
<img src="/resources/images/Cilium-4-Cluster-Mesh.png" title="Cilium Cluster Mesh" style="height: 400px; width:800px;"/>

- Cilium Hubble
<img src="/resources/images/Cilium-4-Hubble.png" title="Cilium Hubble" style="height: 400px; width:800px;"/>

- Cilium Tetragon
<img src="/resources/images/Cilium-5-Tetragon.png" title="Cilium Tetragon" style="height: 400px; width:800px;"/>
<img src="/resources/images/Cilium-6-Tetragon-logo.png" title="Cilium Tetragon Logo" style="height: 400px; width:800px;"/>

- Cilium LB
<img src="/resources/images/Cilium-6-LB.png" title="Cilium LB" style="height: 400px; width:800px;"/>

- Cilium Timescape
<img src="/resources/images/Cilium-7-Timescape.png" title="Cilium Timescape" style="height: 400px; width:800px;"/>

- Cilium Service Mesh
<img src="/resources/images/Cilium-8-Service-Mesh.png" title="Cilium Service Mesh" style="height: 400px; width:800px;"/>

- Cilium Proxy
<img src="/resources/images/Cilium-9-Proxy.png" title="Cilium Proxy" style="height: 400px; width:800px;"/>

- Cilium Service Mesh & Netowrk Security
<img src="/resources/images/Cilium-10-Service-Mesh-Netowrk-Security.png" title="Cilium Service Mesh & Netowrk Security" style="height: 400px; width:800px;"/>



## Get list of cilium managed endpoints 
```bash
kubectl get cep
```

## Cilium Labs

### Notes from "Getting Started with Cilium" Lab

- Three microservice applications: deathstar, tiefighter, and xwing
- deathstar (bad guy)
    - HTTP webservice on port 80
    - Provides landing services to the empire’s spaceships so that they can request a landing port.
    - org=empire, class=deathstar

- tiefighter (The Imperial TIE fighter, bad guys)
    - represents landing-request client service on empire ship
    - org=empire, class=tiefighter

- xwing (The Rebel, good guys)
    - represents landing-request client service on alliance ship
    - org=alliance, class=xwing
 
- deathstar-service
    - LB traffic to all pds w/ label org=empire, class=deathstar


```bash
cilium install
cilium status --wait
kubectl get cep --all-namespaces
```

- Install the services 
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml
```

- APIs

```bash
kubectl exec tiefighter -- \
    curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec xwing -- \ 
    curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- \
    curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port
```

- Apply L3/L4 network policy
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_policy.yaml
```

- Apply L3/L4/L7 network policy
```bash
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_l7_policy.yaml
```

## Setup Development Environment
Steps to create a VM in which you can build Cilium and then install built 
cilium components on a kind k8s cluster

```bash
git clone
vagrant up

Setup aliases
Setup tmux

sudo bash tools-0-install.sh
kind-install.sh
kubectl-install.sh

install docker

install go
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.24.2.linux-amd64.tar.gz
PATH=$PATH:/usr/local/go/bin # put this in ~/.bashrc

install llvm
PATH=$PATH:/usr/lib/llvm-19/bin

install cilium-cli
https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli

clone cilium code 
git clone --depth 1 --branch 1.17.0 https://github.com/cilium/cilium/
cd cilium
make kind
make kind-image
make kind-install-cilium-fast

check status
cilium status
```

## Inspect StateDB Tables 
```bash
../code/self/cilium/contrib/k8s/k8s-cilium-exec.sh -e cilium-dbg shell -- db tables
Available Cilium pods:
1. cilium-cswp6   kind-control-plane
2. cilium-fccsh   kind-worker

Do you want to execute the command on a specific pod or (a) all pods?
Enter your choice (pod number or a): 1

==== Detail from pod cilium-cswp6 on node kind-control-plane ====
Name                 Object count   Zombie objects   Indexes                 Initializers   Go type                            Last WriteTxn
health               51             0                identifier, level       []             types.Status                       health (127.0us ago, locked for 50.3us)
sysctl               25             0                name, status            []             *tables.Sysctl                     sysctl (5.8m ago, locked for 22.3us)
mtu                  2              0                cidr                    []             mtu.RouteMTU                       mtu (1.9h ago, locked for 4.6us)
ipsets               0              0                ipsets                  []             *tables.IPSetEntry                 ipset (1.9h ago, locked for 20.9us)
node-addresses       6              0                id, name, node-port     []             tables.NodeAddress                 node-address (1.9h ago, locked for 12.1us)
ciliumenvoyconfigs   0              0                name, service           []             *ciliumenvoyconfig.CEC             experimental (1.9h ago, locked for 16.3us)
nat-stats            0              0                byTuple                 []             stats.NatMapStats                  
cilium-configs       0              0                key, name               []             dynamicconfig.DynamicConfig        
dynamic-features     0              0                feature                 []             *dynamiclifecycle.DynamicFeature   dynamic-lifecycle-manager (1.9h ago, locked for 8.6us)
bandwidth-edts       0              0                endpoint-id             []             bwmap.Edt                          
l2-announce          0              0                id, origin              []             *tables.L2AnnounceEntry            l2-responder (1.9h ago, locked for 34.7us)
bandwidth-qdiscs     0              0                id                      []             *tables.BandwidthQDisc             
devices              6              0                id, name, selected      []             *tables.Device                     devices-controller (6.8s ago, locked for 103.4us)
routes               39             0                LinkIndex, id           []             *tables.Route                      devices-controller (6.8s ago, locked for 103.4us)
neighbors            0              0                ID, IPAddr, LinkIndex   []             *tables.Neighbor                   devices-controller (6.8s ago, locked for 103.4us)

```


