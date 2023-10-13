# Istio - https://github.com/istio/

Open source implementation of a service mesh.

## Service Mesh
- Distributed application infrastructure
- Handles network traffic on behalf of the App
- Transparent and out-of-process
- Made up of Data + Control Plane. Together they provide 
  - Observability
  - Security
  - Traffic Control => Route only 1% of traffic to newly deployed app version 
  - Resiliency
  - Policy Enforcement 


## Istios takes care of
- communication between services
- service to service connectivity challenges  
irrespective of app language
- service discovery 

## Makes Apps observable, secure, resilient w/ very few or no code changes in the App
- Observable => distributed tracing, metrics collection
  - request spikes, latency, throughput, failures
- Secure => secure communication between services (Authentication)
  - mTLS
- Resilient => Timeouts, retries, circuit breaking 


## Different ways to address service-to-service communication over the unreliable network
What if service A can not communicate to service B or having issues connecting with service B

- Client-side load balancing
- Service discovery => periodically updates list of healthy endpoints 
- Circuit breaking
- Bulkheading => limits resources (connections, threads, sessions) on client when making call to the service 
- Timeouts
- Retries
- Retry budgets => retry 50% of calls in a 10-sec window 
- Deadlines => how long response may still be useful

Data Plane
- manage networking traffic on behalf of an application  
- establishes, secures, and control the traffic through the mesh.

Control Plane
- brain of a mesh
- manage proxies/data plane

## Drawbacks to using a service mesh
- One more piece of software (proxy) added along with each service/app instance
- Becomes imp piece of the services as all calls traverse through the service mesh
- Introduces another layer of complexity

## Istiod Functions
- Security
  - Uses SPIFFE specification
  - handles certificate attestation, signing, delivery, rotation

## Resiliency Technique
Suppose Service A calling Service B's APIs

- Latency issue = Service B not responding in time
  - Service A may go to other Service B pod or go to other region or zone
- Servie B throwing errors intermittently
  - Service A wanna perform retries
- Service B throwing errors frequently
  - System want to remove that instance/pod from the mesh => Circuit Breaking
  - This avoids overloading Service B (instance) and hence avoids cascading failures too

## Resiliency Patterns
- Client-side load balancing
- Locality-aware load balancing
- Timeouts and retries
- Circuit breaking

## General Notes
Envoy - Service Proxy  
istiod - Control Plane  
xDS API - Allows to configure Service Proxy dynamically

## Get the log level of Istio Ingress Pod
```bash
istioctl proxy-config log -n istio-system istio-ingressgateway-8d56c999d-745db
istio-ingressgateway-8d56c999d-745db.istio-system:
active loggers:
  admin: info
  alternate_protocols_cache: info
  aws: info
  assert: info
  backtrace: info
  cache_filter: info
  client: info
  config: info
  connection: info
  conn_handler: info
  decompression: info
  dns: info
  dubbo: info
  envoy_bug: info
  ext_authz: info
  ext_proc: info
  rocketmq: info
  file: info
  filter: info
  forward_proxy: info
  grpc: info
  happy_eyeballs: info
  hc: info
  health_checker: info
  http: info
  http2: info
  hystrix: info
  init: info
  io: info
  jwt: info
  kafka: info
  key_value_store: info
  lua: info
  main: info
  matcher: info
  misc: info
  mongo: info
  multi_connection: info
  oauth2: info
  quic: info
  quic_stream: info
  pool: info
  rate_limit_quota: info
  rbac: info
  rds: info
  redis: info
  router: info
  runtime: info
  stats: info
  secret: info
  tap: info
  testing: info
  thrift: info
  tracing: info
  upstream: info
  udp: info
  wasm: info
  websocket: info
```

## Set the log level of Istio Ingress
```bash
# Set the log level to debug for all modules
istioctl proxy-config log -n istio-system istio-ingressgateway-8d56c999d-745db.istio-system --level debug

# Set the log level to debug for specific modules
istioctl proxy-config log -n istio-system istio-ingressgateway-8d56c999d-745db.istio-system --level http:debug,dns:debug,router:debug
```

## Acronyms
xDS - Discovery Services (Blanket name)
LDS - Listener Discovery Service  
EDS - Endpoint Discovery Service  
RDS - Route Discovery Service  
SPIFFE - Secure Production Identity Framework For Everyone (https://spiffe.io)  


