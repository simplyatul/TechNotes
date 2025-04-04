# Networking...

## north-south traffic
- Network traffic flowing into and out of a data center. 

## east-west traffic
- Network traffic among devices within a specific data center. 

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

## Running termshark in a container

```bash
# Perform following is in container

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install tcpdump termshark
mkdir -p /root/.config/termshark/
echo -e "[main]\ndark-mode = true" > /root/.config/termshark/termshark.toml

```

### Capture packet and view with termshark
```bash
tcpdump -i any arp -w arp.pcap
Ctrl+C

TERM=xterm-256color termshark -r arp.pcap
```

### Or capture and view live
```bash
TERM=xterm-256color termshark -i any
```
