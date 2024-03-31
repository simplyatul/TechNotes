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
    - By default, filters are written in C++, but other ways exists too
        - Lua script
        - WASM => WebAssembly

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

# HTTP/2 Terminology
- Stream => bidirectional flow of bytes in a connection
- Stream carries one or more messages
- Message is sequence of frames that map to HTTP request/response message
- frame => smallest unit of communication in HTTP/2
- frame contains
    - header
        - contains stream id to which it belong
    - message payload

# HTTP Connection Management Filter (HCM)
- Network Level filter
- Converts raw bytes into HTTP level messages
- can have multiple http filters within the single HCM filter
- last filter in the chain must be router filter
- Supports HTTP functionality like logging, request ID generation and tracing, header manipulation, route table management, statistics, etc.

## Usage
- Routing/forwarding
- Rate limiting
- Buffering

## HTTP Filter
- Used within HCM
- Working on HTTP messages w/o knowing underlying protocol (HTTP/1.1 or HTTP/2.0, etc) and multiplexing capabilities
- 3 Types of HTTP Filters
    - Encoder
    - Decoder
    - Encoder and Decoder
- Filter order matters
```
http_filters:
- filter_1
- filter_2
- filter_3
```
- Request path: filter_1 -> filter_2 -> filter_3
- Response Path: filter_3 -> filter_2 -> filter_1

- Built-in HTTP Filters
    - CORS, CSRF, health check, JWT authentication, etc
    - Check [Full List](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/http_filters#http-filters)

## HTTP Routing

## Example of Routing and Matching
- Consider the following config

```yaml
route_config:
  name: my_route_config 
  virtual_hosts:
  - name: bar_route
    domains: ["bar.io"]
    routes:
    - match:
        prefix: "/"
      route:
        priority: HIGH
        cluster: bar_io
  - name: foo_route
    domains: ["foo.io"]
    routes:
    - match:
        prefix: "/"
      route:
        # priority is default
        cluster: foo_io
```
- Incoming requests' Host (HTTP/1.1) or Authority (HTTP/2.0) or SNI (TLS) header values are matched against domains value
- Once the domain is selected, route is identified using prefix value
- Do consider order of the route. Consider following example

```yaml
route_config:
  name: my_route_config 
  virtual_hosts:
  - name: hello_route
    domains: ["hello.com"]
    routes:
    - match:
        prefix: "/api"
      route:
        cluster: api_cluster
    - match:
        prefix: "/api/v1"
      route:
        cluster: api_v1_cluster
```
- as per above config, https://hello.com/api/v1 is routed to api_cluster and not to api_v1_cluster
- simple workaround is to reverse the order of declaration
- Following table explains the matching rules

| Route match   | Description   | Example |
| :---------- | :-------------- | :---------- |
| prefix  | The prefix must match the beginning of the :path header | /hello matches hello.com/hello, hello.com/helloworld, and hello.com/hello/v1 |
| path | The path must exactly match the :path header | /hello matches hello.com/hello, but not hello.com/helloworld or hello.com/hello/v1 |
| safe_regex | The provided regex must match the :path header | /\d{3} matches any 3 digit number after /. For example, hello.com/123, but not hello.com/hello or hello.com/54321 |
| connect_matcher | Matcher only matches CONNECT requests | |

- prefix and path matching is case-sensitive. 
- However, we can set case_sensitive to false as well.
- case_sensitive setting does not apply to safe_regex matching.

## Traffic Splitting
- Splits traffic bet routes in the same virtual host to diff upstream clusters
- Two approaches
    - using runtime %s
        - useful for canary releases or progressive/gradual shift traffic
    - using weighted clusters

## Header Manipulation
- One can manipulate requests/responses headers in following order
    - Weighted cluster-level headers
    - Route-level headers
    - Virtual host-level headers
    - Global-level headers
- The order means Envoy might overwrite a header set on the weighted cluster level by headers configured at the higher level (route, virtual host, or global).


# Credits
The above information is gathered/learned from different sources. Listing them out here.

[Envoy Tetrate Course](https://academy.tetrate.io/courses/take/envoy-fundamentals/)


