#!/bin/bash

# wrapper function for hashicorp vault (vaultproject.io)
function vault() {
    for v in http_proxy HTTP_PROXY https_proxy HTTPS_PROXY; do
        unset $v
    done
    {% if 'consul' in vault_backend -%}
    	# get working consul node
    	consulnode=$({{ vault.root_dir }}/bin/consul-node-evaluation.sh vault)
    	# get working vault node
    	vaultnode=$(curl --noproxy $consulnode \
    				-sS http://$consulnode:8500/v1/catalog/service/vault?tag=active | \
    				jq '.[0].Address' 2>/tmp/vault-jq.tmp | \
    				cut -d'"' -f2)
    	if grep -i error /tmp/vault-jq.tmp >/dev/null; then 
    		echo -e "WARNING: vault server address could not be evaluated using consul service discovery. Check \$VAULT_ADDR."
    		vaultnode={{ vault_addr }}
    	elif [ "$vaultnode" == "null" ]; then
    		vaultnode=$(curl --noproxy $consulnode \
    					-sS http://$consulnode:8500/v1/catalog/service/vault | \
    					jq '.[0].Address' | \
    					cut -d'"' -f2)
    	fi
    	rm -f /tmp/vault-jq.tmp
    {% else -%}
    	vaultnode={{ vault_addr }}
    {% endif -%}
    export VAULT_ADDR=http://${vaultnode}:{{ vault.service_listen_port }}
    
    {{ all.bin_dir }}/vault $@
}
