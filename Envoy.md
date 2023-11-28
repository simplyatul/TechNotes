# Intro
Jotting down the Envoy Fundamentals and much more...

# Why Envoy
- Helps to segregate application and network issues
- Apps may use Inconsistent tracing and logging mechanisms
- Envoy deals with the network concerns
- Application deals with Business Logic

# Deployment Models
- Side car deployment
- Edge Pattern
    - Used to build API Gateways

# Architecture
- Out of process Architecture
- Takes care of routing
- Envoy is an L3/L4 network proxy 
    - Makes decisions based on IP addresses and TCP/UDP ports. 
- Contains filter chain to perform diff TCP/UDP tasks
- Some of pre-existing filters
    - TCP Proxy
    - UPD Proxy
    - HTTP Proxy
    - TLS client cert
    - HTTP L7 (HCM)
- Extensible Design
    - Can write your own filters

# Features
- Support HTTP/1.1 and HTTP/2
- TLS Termination + Mutual TLS
- Can operate as a transparent HTTP/1.1 to HTTP/2 proxy in both directions.
- Supports gRPC
    - Bec it supports HTTP/2
    - gRPC features support
        - Authentication
        - Bi-directional streaming
        - Flow control
- Supports all HTTP/2 features
- Dynamic configs
    - using Dynamic configuration (xDS) services
- Passive and active health checking
    - route traffic to healthy upstream => circuit breaking
- Passive health checking using outlier detection system
- Advance Load Balancing
    - Automatic retries
    - Circuit Breaking
    - Global+Local rate limiting
    - Request shadowing/traffic mirroring
    - Outlier detection
    - Request hedging ???
- Observability
    - Logs, metrics and traces
    - statsd compatible
    - can plugin diff statistic providers
- Envoy 1.19.0 supports HTTP/3 upstream and downstream and translates between HTTP/1.1, HTTP/2, and HTTP/3 in either direction.

# Envoy Building Blocks
- Listeners
- Routes
- Clusters
- Endpoints

## Listener Filters
    - 3 types of filters
        - Listeners
            - Kicks in as soon as packet received
            - Generally operates on Packet header
            - e.g. Proxy listener filter, TLS inspector filter, etc
        - Network
        - HTTP
## Clusters
- Group of similar upstream hosts
- Clusters are defined at the same level as listeners using the clusters field.
- Cluster contains the following optional features
    - Active health checking
    - Circuit breaking
    - Outlier detection
    - Protocol options for handling HTTP requests
    - optional filter to apply to all outgoing connections

# HTTP Connection Management (HCM)
- is one of filter
- converts raw bytes into HTTP level messages
- can have multiple http filters within the single HCM filter
- last filter in the chain must be router filter

## Usage
- Routing/forwarding
- Rate limiting
- Buffering
