set -eux
ip r del default via 10.0.2.2
ip r add default via 192.168.57.10