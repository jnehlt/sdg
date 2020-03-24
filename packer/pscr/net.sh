#!/usr/bin/env bash

yum remove firewalld -y
yum install iptables iptables-services -y

rm -f /etc/sysconfig/iptables
cat << 'EOF' >> ./iptables
*filter

# Clear all iptables rules (everything is open)
-X
-F
-Z

# Allow loopback interface (lo0) and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT
-A INPUT -d 127.0.0.0/8 -j REJECT
-A OUTPUT -d 127.0.0.0/8 -j REJECT

# Keep all established connections
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow ping
-A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
-A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
-A INPUT -p icmp --icmp-type echo-request -j ACCEPT
-A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Protect from ping of death
-N PING_OF_DEATH
-A PING_OF_DEATH -p icmp --icmp-type echo-request -m hashlimit --hashlimit 1/s --hashlimit-burst 10 --hashlimit-htable-expire 300000 --hashlimit-mode srcip --hashlimit-name t_PING_OF_DEATH -j RETURN
-A PING_OF_DEATH -j DROP
-A INPUT -p icmp --icmp-type echo-request -j PING_OF_DEATH

# Prevent port scanning
-N PORTSCAN
-A PORTSCAN -p tcp --tcp-flags ACK,FIN FIN -j DROP
-A PORTSCAN -p tcp --tcp-flags ACK,PSH PSH -j DROP
-A PORTSCAN -p tcp --tcp-flags ACK,URG URG -j DROP
-A PORTSCAN -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
-A PORTSCAN -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
-A PORTSCAN -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
-A PORTSCAN -p tcp --tcp-flags ALL ALL -j DROP
-A PORTSCAN -p tcp --tcp-flags ALL NONE -j DROP
-A PORTSCAN -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
-A PORTSCAN -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
-A PORTSCAN -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

# Drop fragmented packages
-A INPUT -f -j DROP

# SYN packets check
-A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# Open ports for outgoing UDP traffic
-A INPUT -p udp --sport 53 -j ACCEPT
-A OUTPUT -p udp --dport 53 -j ACCEPT
-A INPUT -p udp --sport 123 -j ACCEPT
-A OUTPUT -p udp --dport 123 -j ACCEPT


# Open TCP ports for incoming traffic
-A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
-A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
-A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Open TCP ports for outgoing traffic
-A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
-A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT


# Drop all other traffic
-A INPUT -j DROP
-A FORWARD -j DROP
-A OUTPUT -j DROP

COMMIT
EOF

mv ./iptables /etc/sysconfig/iptables
restorecon -Rv /etc/sysconfig/iptables
systemctl enable iptables.service

exec /bin/bash -c "sleep 4; rm -f $(basename $0);"