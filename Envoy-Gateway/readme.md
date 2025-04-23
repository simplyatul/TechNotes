# Intro
The folder containing this file documents findings/logs about Envoy Gateway.  
Envoy Gateway implements K8s Gateway APIs => implements Ingress, Load Balancing, and Service Mesh as per the [specs](https://gateway-api.sigs.k8s.io/)

# TOC
- [TLS Passthrough](#TLS-Passthrough)
- [Backend TLS Policy](#Backend-TLS-Policy)

## TLS Passthrough

- With this, client makes HTTPS connections with Backend directly.  
- Gateway (Envoy Proxy) simply acts as passthrough.


First, run the HTTP Route example and verify HTTP Route is working.

Change Dir
```bash
cd TLS-Passthrough
```

### HTTP Route

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
kubectl apply -f HTTPRoute/Gateway.yaml
```

Observe envoy-default-eg-e41e7b31 service,deployment/pod is created post above step

- To capture metrics, do port-forward
```bash
export ENVOY_POD_NAME=$(kubectl get pod -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')

kubectl port-forward pod/$ENVOY_POD_NAME -n envoy-gateway-system 19000:19000 &

```
- Collect Envoy Proxy settings/logs
```bash
../capture-envoy-data.sh --dir HTTPRoute/before_httproute
```

- Create backend-http service and HTTPRoute
```bash
kubectl apply -f HTTPRoute/backend-http-service.yaml
```

- Collect Envoy Proxy settings/logs
```bash
../capture-envoy-data.sh --dir HTTPRoute/after_httproute
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

#### Note
- Headers starting w/ ```X-``` are inserted by Envoy Proxy.
- This indicates curl request has passed via Envoy Proxy.
- If we do curl directly to backend-service, then you won't see above headers
```bash
k port-forward svc/backend-http 3000:3000 &

curl --verbose --header "Host: www.example.com" http://localhost:3000/get

*   Trying 127.0.0.1:3000...
* Connected to localhost (127.0.0.1) port 3000 (#0)
> GET /get HTTP/1.1
Handling connection for 3000
> Host: www.example.com
> User-Agent: curl/7.81.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Content-Type: application/json
< X-Content-Type-Options: nosniff
< Date: Sat, 19 Apr 2025 05:04:51 GMT
< Content-Length: 270
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
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend-http-5dbc74ccd5-lnk6l"
* Connection #0 to host localhost left intact

```

### TLS Passthrough setup and verification


### Create Certs and store it in k8s secrete

```bash
# First, Create CA certificate for domain example.com
# This creates 
# private key => example.com.key
# PEM encoded cert => example.com.crt
# ```-newkey``` option generates key for you
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
-subj '/O=example Inc./CN=example.com' \
-keyout TLS-Passthrough/example.com.key \
-out TLS-Passthrough/example.com.crt

# Create cert signing request for domain passthrough.example.com
# This creates - 
# private key => passthrough.example.com.key
# cert signing request => passthrough.example.com.csr
openssl req -out TLS-Passthrough/passthrough.example.com.csr \
-newkey rsa:2048 -nodes \
-keyout TLS-Passthrough/passthrough.example.com.key \
-subj "/CN=passthrough.example.com/O=some organization"

# Now use CA's cert (example.com.cert) and key (example.com.key) for signing passthrough's domain request (passthrough.example.com.csr)
# And generate public certificate for passthrough (passthrough.example.com.crt) 
openssl x509 -req -sha256 -days 365 \
-CA TLS-Passthrough/example.com.crt \
-CAkey TLS-Passthrough/example.com.key -set_serial 0 \
-in TLS-Passthrough/passthrough.example.com.csr \
-out TLS-Passthrough/passthrough.example.com.crt

# Verify the passthrough's cert
openssl verify -CAfile example.com.crt passthrough.example.com.crt

# Save's the  passthrough's key ((passthrough.example.com.key) and certificate (passthrough.example.com.crt) in k8s's secret object   
kubectl create secret tls passthrough-server-certs \
--key=TLS-Passthrough/passthrough.example.com.key \
--cert=TLS-Passthrough/passthrough.example.com.crt

```

### Deploy TLS Passthrough application Deployment, Service and TLSRoute:
```bash
kubectl apply -f TLS-Passthrough/tls-passthrough.yaml
```

### Patch the Gateway from the Quickstart to include a TLS listener that listens on port 6443 and is configured for TLS mode Passthrough
```bash
kubectl patch gateway eg --type=json --patch '
  - op: add
    path: /spec/listeners/-
    value:
      name: tls
      protocol: TLS
      hostname: passthrough.example.com
      port: 6443
      tls:
        mode: Passthrough
   '
```
### Port forward to the Envoy service:
```bash
kubectl -n envoy-gateway-system port-forward \
service/${ENVOY_SERVICE} 6043:6443 &

```

### Curl the example app through Envoy proxy:

```bash
curl -v --resolve "passthrough.example.com:6043:127.0.0.1" \
https://passthrough.example.com:6043 \
--cacert TLS-Passthrough/example.com.crt

* Added passthrough.example.com:6043:127.0.0.1 to DNS cache
* Hostname passthrough.example.com was found in DNS cache
*   Trying 127.0.0.1:6043...
Handling connection for 6043
* Connected to passthrough.example.com (127.0.0.1) port 6043 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
*  CAfile: passthrough.example.com.crt
*  CApath: /etc/ssl/certs
* TLSv1.0 (OUT), TLS header, Certificate Status (22):
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS header, Certificate Status (22):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS header, Finished (20):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.2 (OUT), TLS header, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=passthrough.example.com; O=some organization
*  start date: Jan 31 04:28:51 2025 GMT
*  expire date: Jan 31 04:28:51 2026 GMT
*  common name: passthrough.example.com (matched)
*  issuer: O=example Inc.; CN=example.com
*  SSL certificate verify ok.
* Using HTTP2, server supports multiplexing
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* Using Stream ID: 1 (easy handle 0x559410aaaeb0)
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
> GET / HTTP/2
> Host: passthrough.example.com:6043
> user-agent: curl/7.81.0
> accept: */*
>
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* Connection state changed (MAX_CONCURRENT_STREAMS == 250)!
* TLSv1.2 (OUT), TLS header, Supplemental data (23):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
* TLSv1.2 (IN), TLS header, Supplemental data (23):
< HTTP/2 200
< content-type: application/json
< x-content-type-options: nosniff
< content-length: 443
< date: Fri, 31 Jan 2025 05:43:45 GMT
<
* TLSv1.2 (IN), TLS header, Supplemental data (23):
{
 "path": "/",
 "host": "passthrough.example.com:6043",
 "method": "GET",
 "proto": "HTTP/2.0",
 "headers": {
  "Accept": [
   "*/*"
  ],
  "User-Agent": [
   "curl/7.81.0"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "passthrough-echoserver-5dddbf6b95-gzcvx",
 "tls": {
  "version": "TLSv1.3",
  "serverName": "passthrough.example.com",
  "negotiatedProtocol": "h2",
  "cipherSuite": "TLS_AES_128_GCM_SHA256"
 }
* Connection #0 to host passthrough.example.com left intact

```

### Collect Envoy Proxy settings/logs

```bash
../capture-envoy-data.sh --dir TLS-Passthrough/after_tlspassthrough
```

### Compare changes
```bash
meld HTTPRoute/after_httproute TLS-Passthrough/after_tlspassthrough 
```

## Backend TLS Policy

- In this, client to Gateway (Envoy Proxy) is http connection
- Gateway to backend is TLS/HTTPS connection

Change Dir
```bash
cd BackendTLSPolicy
```


### HTTP Route
First, create basic HTTP Route with non https backend

- Post creating kind cluster, Install the Gateway API CRDs and Envoy Gateway:
```bash
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.2.6 -n envoy-gateway-system --create-namespace
```

- Install the GatewayClass, Gateway, HTTPRoute and example app
```bash
kubectl apply -f HTTPRoute/quickstart.yaml
```

- Port forward to the Envoy service:

```bash
export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')

kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 8888:80 &
```

- Curl the example app through Envoy proxy:

```bash
curl --verbose --header "Host: www.example.com" http://localhost:8888/get
```

- To capture metrics, do port-forward. As mentioned above

- Collect Envoy Proxy settings/logs
```bash
../capture-envoy-data.sh --dir HTTPRoute/after_httproute
```

### BackendTLSPolicy setup and verification

- Generate self signed ca certs
```bash
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout ca.key -out ca.crt
```

- Create a certificate and a private key for ```www.example.com```


```bash
cat > openssl.conf  <<EOF
[req]
req_extensions = v3_req
prompt = no

[v3_req]
keyUsage = keyEncipherment, digitalSignature
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.example.com
EOF

```

- Create a certificate using this above openssl configuration file:
```bash
openssl req -out www.example.com.csr -newkey rsa:2048 -nodes -keyout www.example.com.key -subj "/CN=www.example.com/O=example organization"

openssl x509 -req -days 365 -CA ca.crt -CAkey ca.key -set_serial 0 -in www.example.com.csr -out www.example.com.crt -extfile openssl.conf -extensions v3_req
```
- Store the cert/key in a Secret:
```bash
kubectl create secret tls example-cert --key=www.example.com.key --cert=www.example.com.crt
```

- Store the CA Cert in another Secret:

```bash
kubectl create configmap example-ca --from-file=ca.crt
```

- Setup TLS on the backend by patching existing backend deployment
```bash
kubectl patch deployment backend --type=json --patch '
  - op: add
    path: /spec/template/spec/containers/0/volumeMounts
    value:
    - name: secret-volume
      mountPath: /etc/secret-volume
  - op: add
    path: /spec/template/spec/volumes
    value:
    - name: secret-volume
      secret:
        secretName: example-cert
        items:
        - key: tls.crt
          path: crt
        - key: tls.key
          path: key
  - op: add
    path: /spec/template/spec/containers/0/env/-
    value:
      name: TLS_SERVER_CERT
      value: /etc/secret-volume/crt
  - op: add
    path: /spec/template/spec/containers/0/env/-
    value:
      name: TLS_SERVER_PRIVKEY
      value: /etc/secret-volume/key
  '
```

- Create a service that exposes port 443 on the backend service.
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: backend
    service: backend
  name: tls-backend
  namespace: default
spec:
  selector:
    app: backend
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8443
EOF
```

- Create a BackendTLSPolicy
```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1alpha3
kind: BackendTLSPolicy
metadata:
  name: enable-backend-tls
  namespace: default
spec:
  targetRefs:
  - group: ''
    kind: Service
    name: tls-backend
    sectionName: https
  validation:
    caCertificateRefs:
    - name: example-ca
      group: ''
      kind: ConfigMap
    hostname: www.example.com
EOF
```

- Patch the existing HTTPRoute’s backend reference, so that it refers to the new TLS-enabled service:

```bash
kubectl patch HTTPRoute backend --type=json --patch '
  - op: replace
    path: /spec/rules/0/backendRefs/0/port
    value: 443
  - op: replace
    path: /spec/rules/0/backendRefs/0/name
    value: tls-backend
  '
```

- Verify the HTTPRoute status:

```bash
kubectl get HTTPRoute backend -o yaml
```

- Port forward to the Envoy service
```bash
export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system --selector=gateway.envoyproxy.io/owning-gateway-namespace=default,gateway.envoyproxy.io/owning-gateway-name=eg -o jsonpath='{.items[0].metadata.name}')


kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} 9999:80 &
```

- Query the TLS-enabled backend through Envoy proxy
```bash
curl -v -HHost:www.example.com --resolve "www.example.com:9999:127.0.0.1" http://www.example.com:9999/get

* Added www.example.com:9999:127.0.0.1 to DNS cache
* Hostname www.example.com was found in DNS cache
*   Trying 127.0.0.1:9999...
Handling connection for 9999 
* Connected to www.example.com (127.0.0.1) port 9999 (#0) 
> GET /get HTTP/1.1
> Host:www.example.com
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< content-type: application/json
< x-content-type-options: nosniff
< date: Fri, 31 Jan 2025 08:14:35 GMT
< content-length: 620
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
   "10.244.1.2"
  ],
  "X-Forwarded-Proto": [
   "http"
  ],
  "X-Request-Id": [
   "c06918f0-849b-427b-a2d2-1c1575ff873c"
  ]
 },
 "namespace": "default",
 "ingress": "",
 "service": "",
 "pod": "backend-88699b6f8-mmxmb",
 "tls": {
  "version": "TLSv1.2",
  "serverName": "www.example.com",
  "negotiatedProtocol": "http/1.1",
  "cipherSuite": "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
 }
* Connection #0 to host www.example.com left intact
}
```

- Collect Envoy Proxy settings/logs
```bash
../capture-envoy-data.sh --dir after-backendtlspolicy
```

- Compare the changes post creating backend policy
```bash
meld HTTPRoute/after_httproute/ after-backendtlspolicy/ &
```

## Ref
- https://gateway.envoyproxy.io/docs/tasks/quickstart/
- https://gateway.envoyproxy.io/docs/tasks/observability/proxy-metric/
- https://gateway.envoyproxy.io/docs/tasks/traffic/http-routing/
- https://gateway.envoyproxy.io/docs/tasks/security/tls-passthrough/
