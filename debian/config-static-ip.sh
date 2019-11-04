#!/bin/bash


echo "
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
# allow-hotplug ens192
# iface ens192 inet dhcp

auto ens192
allow-hotplug ens192
iface ens192 inet static
address <YOUR IP>/24
gateway <YOUR IP>
# dns-nameservers <DNS NameServers>

" > /etc/network/interfaces

service networking restart



