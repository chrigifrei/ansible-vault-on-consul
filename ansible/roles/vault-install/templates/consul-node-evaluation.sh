#!/bin/bash

# evaluate working hashicorp consul node (consul.io)
#
# usage: $0 <servicename>

for host in {% for member in groups['consul_cluster'] -%}"{{ hostvars[member].ansible_host }}" {% endfor -%}; do
    catalog=$(curl --noproxy $host -sS http://$host:8500/v1/catalog/services 2>/dev/null)
    if [[ $catalog == *"$1"* ]]; then
        consulnode=$host; break; 
    else
        consulnode="none"
    fi 
done

if [ $consulnode == "none" ]; then
	echo -n "127.0.0.1"
    exit 1
else
    echo -n $consulnode
    exit 0
fi
