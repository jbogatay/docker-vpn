#!/bin/bash
echo "Adding static route"

ip route add 192.168.1.0/24 via 192.168.5.1
