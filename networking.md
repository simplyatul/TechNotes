# Networking...

## iptables/ip6tables

### Concepts

- DNAT
    - technique of translating the Destination IP address of a packet, or to change it simply put
    - used together with SNAT to allow several hosts to share a single Internet routable IP address
- IP packets are called datagrams, while TCP packets are called segments
- DSCP => Differentiated Services Code Point (RFC 2474)

- 4 Tables => Raw, Nat, Mangle and Filter 

### Chains

- INPUT
- OUTPUT
- FORWARD
- PRE-ROUTING
- POST-ROUTING

### Target Rules
- ACCEPT
- REJECT    => Remote host will know pkt is rejected
- DROP      => Remote host  not notified about pkt drop
- FORWARD

### Setting a policy on chain
```bash
iptable -P INPUT DROP
```
### Some examples
Allow connection on port 22
```bash
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```
Remove/delete a rule
```bash
iptables -R INPUT 1
```

