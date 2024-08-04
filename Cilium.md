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
    - supports Timescape
        - based on Clickhouse (col based DBMS) 
    - Vs Grafana
        - Timescape is native to Cilium project, so more efficient
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
- Runtime security and observability
- Runtime enforcement
- Can run w/o Cilium as well


## References
- History of Cilium
    - https://www.youtube.com/watch?v=wv_9YxdC49Y
    - By Thomas Graf, Co-Creator of Cilium

