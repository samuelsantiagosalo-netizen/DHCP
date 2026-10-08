Checkpoint 1 and 2: Server Setup

To start, I made the Vagrantfile using a Debian box. I configured two network adapters: a public one (bridge) so the machine has internet, and a private one for the intnet network with the IP 192.168.57.10. 

After booting the server, I installed the DHCP package (isc-dhcp-server). I checked my interfaces with ip a and saw that the internal one was eth2, so I added that to /etc/default/isc-dhcp-server. 

Before touching the main config file, I made a backup just in case. In /etc/dhcp/dhcpd.conf, I changed the default lease time to 1 day and the max to 8 days. I also set my domain to samuel.test. For the IP distribution, I created a subnet for 192.168.57.0/24 and told it to give dynamic IPs from .20 to .50. 

To finish, I ran dhcpd -t to make sure I didn't have any syntax errors, restarted the service, and checked the status. Everything was green and running.


Checkpoint 3: Client Configuration

I added a new virtual machine called c1 to my Vagrantfile. I connected it to the same internal network (intnet) but configured it to use DHCP to get its IP automatically. 

When I started c1 and ran ip a, I saw that it got an IP address from the dynamic range I created earlier (it gave me an IP between .20 and .50). 

To be completely sure it worked, I went back to the server terminal and checked the file /var/lib/dhcp/dhcpd.leases. I found the lease for c1 right there. I also checked the syslog and saw the four DHCP communication steps (Discover, Offer, Request, and Ack).

Checkpoint 4: Fixed IP Address Based on MAC

I added a third VM named printer to the Vagrantfile. To give it a static IP, I specified the MAC address 080027112233 in the Vagrant configuration. 

Then, I went back to the DHCP server and added a host declaration in /etc/dhcp/dhcpd.conf. I linked the MAC address (using colons) to the fixed IP 192.168.57.111 and set a default lease time of 2 hours (7200 seconds). 

I restarted the DHCP service and logged into the printer. I used dhclient -r to release any old IP and dhclient to request a new one. I ran ip a and confirmed the printer got the .111 IP successfully.