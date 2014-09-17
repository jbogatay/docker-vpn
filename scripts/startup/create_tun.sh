#!/bin/bash
echo "Checking for tun device"

# create the tun device
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200
