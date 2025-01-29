## Intro
The folder containing this file documents findings/logs about Envoy Gateway.  
Envoy Gateway implements K8s Gateway APIs => implements Ingress, Load Balancing, and Service Mesh as per the [specs](https://gateway-api.sigs.k8s.io/)

## Steps

- Create Kind K8s cluster

```bash
kind create cluster --config=kind-config.yaml --name env-gw
```
- Install the Gateway API CRDs and Envoy Gateway.

```bash
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.2.6 -n envoy-gateway-system --create-namespace
```

- Install GatewayClass and Gateway

```bash
kubectl apply -f Gateway.yaml
```

Observe envoy-default-eg-e41e7b31 service,deployment/pod is created post above step

- To capture metrics, do port-forward
```bash
export ENVOY_POD_NAME=$(kubectl get pod -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward pod/$ENVOY_POD_NAME -n envoy-gateway-system 19000:19000 &

```
- Collect Envoy Proxy settings/logs
```bash
./capture-envoy-data.sh --dir before_httproute
```

- Create backend-http service and HTTPRoute
```bash
kubectl apply -f backend-http-service.yaml
```

- Collect Envoy Proxy settings/logs
```bash
./capture-envoy-data.sh --dir after_httproute
```

- Port forward to the Envoy service as LB is not available in Kind cluster

```bash
export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')

kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80 &
```

- Test HTTPRoute
```bash
curl --verbose --header "Host: www.example.com" http://localhost:8888/get
# Output =>

*   Trying 127.0.0.1:8888...
Handling connection for 8888
* Connected to localhost (127.0.0.1) port 8888 (#0)
> GET /get HTTP/1.1
> Host: www.example.com
> User-Agent: curl/7.81.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-type: application/json
< x-content-type-options: nosniff
< date: Wed, 29 Jan 2025 07:51:45 GMT
< content-length: 460
< 
{
 "path": "/get",
 "host": "www.example.com",
 "method": "GET",
 "proto": "HTTP/1.1",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.81.0"
  ],
  "X-Envoy-Internal": [
   "true"
  ],
  "X-Forwarded-For": [
   "10.244.2.2"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "404c262f-b3c0-4b4f-b881-cd0117b0f63e"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend-http-7c877f78d9-dns6d"
* Connection #0 to host localhost left intact
```

## Notes
- 29-01-2025.log captures terminal log
- grep '^# AT:' 29-01-2025.log => for some notes

## Ref
- https://gateway.envoyproxy.io/docs/tasks/quickstart/
- https://gateway.envoyproxy.io/docs/tasks/observability/proxy-metric/
- https://gateway.envoyproxy.io/docs/tasks/traffic/http-routing/
