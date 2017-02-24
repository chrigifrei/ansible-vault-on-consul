#!/bin/bash
# unsealing a hashicorp vault (vaultproject.io) secrets store

secretsfile="{{ vault.config_dir }}/{{ vault.init_secrets_file }}"
if [ ! -e $secretsfile ]; then
	echo "ERROR: $secretsfile does not exist. exiting."
	exit 1
fi

keys=$(grep "Unseal Key" $secretsfile | awk '{print $4}')
token=$(egrep 'Initial Root Token' $secretsfile | awk '{print $4}')

source /etc/profile

for k in $keys; do
    vault unseal $k >/dev/null
done

sleep 2

if [ "$(vault status | grep Sealed | awk '{print $2}')" == "true" ]; then
    echo "ERROR: vault unsealing failed"
    exit 2
fi

# authenticate using the root token
vault auth $token >/dev/null

[[ $? -gt 0 ]] && echo "ERROR: vault auth failed" && exit 3

unset keys token

exit 0
