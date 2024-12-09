# Cilium 

## Intro 
Cilium is eBPF based network observability and security tool. On high level, it provides
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

## Multiple Projects
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
















