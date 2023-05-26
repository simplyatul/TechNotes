# Istio - https://github.com/istio/

Open source implementation of a service mesh.

## Service Mesh
- Distributed application infrastructure
- Handles network traffic on behalf of the App
- Transparant and out-of-process
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


## Differnt ways to address service-to-service communication over the unrelible network
what if service A can not communicate to service B or having issues connectioning with service B

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
- Introduces another lay of complexity

