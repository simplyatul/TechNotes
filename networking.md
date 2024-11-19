# Networking...

## iptables/ip6tables

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

