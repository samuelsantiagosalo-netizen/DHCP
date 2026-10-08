Server Setup and DHCP Installation
First, I created the Vagrantfile defining a Debian server with two adapters (a public bridge and a private intnet with IP 192.168.57.10).
I installed the DHCP server with:
sudo apt update
sudo apt install isc-dhcp-server -y

I configured the service to listen on the eth2 interface in /etc/default/isc-dhcp-server.

DHCP Configuration
Before modifying the main file, I made a backup:
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

I added the following configuration to /etc/dhcp/dhcpd.conf:
default-lease-time 86400;
max-lease-time 691200;
option domain-name "samuel.test";
option domain-name-servers 10.0.0.2, 4.4.4.4;

subnet 192.168.57.0 netmask 255.255.255.0 {
range 192.168.57.20 192.168.57.50;
}

I checked the syntax with sudo dhcpd -t (no errors were shown) and restarted the service:
sudo systemctl restart isc-dhcp-server.service
Everything was active and listening.

Client 1 Configuration
I connected the c1 machine to the internal network to obtain its IP automatically. I checked its network with:
ip a
It received an IP between .20 and .50 successfully.

On the server, I verified the lease database:
cat /var/lib/dhcp/dhcpd.leases
The output confirmed the active lease for c1:
binding state active;
client-hostname "c1";

Printer Reservation
For the printer, I assigned the MAC address 080027112233 in the Vagrantfile.
In the server, I created this MAC-based reservation:
host printer {
hardware ethernet 08:00:27:11:22:33;
fixed-address 192.168.57.111;
default-lease-time 7200;
}

I restarted the DHCP service. On the printer, I renewed the IP:
sudo dhclient -r
sudo dhclient
When I used ip a, the printer had the correct 192.168.57.111 IP. The reservation was working.

Routing and NAT
To give internet access to the clients, I configured the Linux server as a router. I enabled IPv4 forwarding and configured NAT.
The main iptables rule was:
iptables -t nat -A POSTROUTING -s 192.168.57.0/24 -o eth1 -j MASQUERADE

On the clients, I deleted the old default route and set the server as the new default gateway:
sudo ip r del default via 10.0.2.2
sudo ip r add default via 192.168.57.10

Finally, I tested the internet connection from the clients:
ping -c 4 8.8.8.8
Result: 4 packets transmitted, 4 received, 0% packet loss.
This confirmed that the routing and NAT configuration was working perfectly.