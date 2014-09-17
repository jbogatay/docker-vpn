#!/bin/bash

echo "Checking for pia client id"

if [ ! -f /config/openvpn/pia_client ]; then
   client_id=`head -n 100 /dev/urandom | md5sum | tr -d " -"`
   echo "PIA client set to $client_id"
   echo "$client_id" > /config/openvpn/pia_client
fi