set -eux
echo "1" > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -s 192.168.57.0/24 -o eth1 -j MASQUERADE
ip r del default via 10.0.2.2
ip r add default via 192.168.1.1