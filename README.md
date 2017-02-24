# Credentials Managment - Hashicorp Vault on Consul

based on: 
- https://www.vaultproject.io
- https://www.consul.io/

This playbook will setup a consul cluster and/or a vault server.  
Consul provides a HA backend for vault.



## Deployment


### Prepare

Make sure the consul cluster member nodes and the vault server are noted in env-<ENV>.ini with the `ansible_host` parameter set. E.g.:
```
deploy-local 		ansible_host=10.1.1.11
```

_NOTE_: If you choose to set `vault_backend="consul"` in `env-<ENV>.ini`, then the vault server needs a local consul client running. If no consul cluster available choose `"file"` as backend instead. Note that no HA will be possible for vault then. Therefore make sure only one host is listed under `vault_servers:children` in `env-<ENV>.ini`.

#### Vault Policies

Find policies in `roles/vault-server-configure/files/policies/` as `<NAME>-policy.hcl` files. They will be deployed to `/etc/vault/policies/` on the target hosts.

Map your policy to a LDAP group in `group_vars/all.yml`:
```
  ldap_groups:
    - name: <LDAP-GROUP>
      policy: <NAME>-policy
```

_NOTE_: To one LDAP group, ONLY ONE policy is applicable.


### Run

To setup a complete environment:
```
ansible-playbook -i env-<env>.ini vault-compound-setup.yml
```

To setup a consul cluster only:
```
ansible-playbook -i env-<env>.ini vault-compound-setup.yml --tags consul
```

To setup a vault server only (set in group_vars/all.yml: `vault.backend: "file"`):
```
ansible-playbook -i env-<env>.ini vault-compound-setup.yml --tags vault
```


### Validate

If you are behind a HTTP/S proxy: make sure /etc/profile is sourced after the setup

```
. /etc/profile
vault status
```

IMPORTANT:  
Find the keys for unsealing your vault in:  
```
/etc/vault/vault-init-secrets.txt
``` 

Find for you convenience (do not use this in any other stage then LOCAL) an unseal script in your PATH:
```
vault-unseal.sh
```



## Vault Operations


### Server Commands

control service: `service vault start|stop|status|restart`


### Client Commands

login: `vault auth -method=ldap username=<LDAPUser>`

list my token: `vault read -field id auth/token/lookup-self`

create a token: `vault token-create -policy="example-policy"`

get a value: `vault read secret/<path>/<to>/<password>`

put a value: `vault write secret/<path>/<to>/<password> user=api_user secret="12345QWERT"`

read ldap config: `vault read auth/ldap/config`


### Policies

Policies are stored as .hcl (or .json) files in `/etc/vault/policies`.

Load a policy file: `vault policy-write <policy-name> /etc/vault/policies/<name>-policy.hcl`

Map a policy to a LDAP group: `vault write auth/ldap/groups/<group-name> policies=<policy-name>`



## Consul Operations


### Server Commands

control service: `service consul start|stop|status|restart`


### Client Commands

display keyring: `consul keyring -list`

display peers and their roles: `consul operator raft -list-peers`

request service info using DNS: `dig @127.0.0.1 -p 8600 monitoring-local.node.consul`

read service catalog: `curl --noproxy localhost -sS http://localhost:8500/v1/catalog/services`

read active vault node: `curl --noproxy localhost -sS http://localhost:8500/v1/catalog/service/vault?tag=active`

read active vault node IP only: `curl --noproxy localhost -sS http://localhost:8500/v1/catalog/service/vault?tag=active | jq '.[0].Address'`

read vault storage: `curl --noproxy localhost http://localhost:8500/v1/kv/vault/?recurse`

remove vault storage: `curl --noproxy localhost -X DELETE http://localhost:8500/v1/kv/vault/?recurse`



## Issues

### no leader
- stop all three servers
- remove /var/consul/*
- restart all three in any order with one having -bootstrap-expect=3
- consul join from that 1st server with the other two IPs



## To be done
- Install binaries are stored in the playbook. This is due to have defined versions available. Wget would be more space efficient.
- Register Vault as Consul service ($VAULT_ADDR should not be hardcoded) 
  https://groups.google.com/forum/#!topic/vault-tool/V1zW_ySAIn4
- If you are behind a HTTP/S proxy: The `vault` and `consul` binaries do not read the `$no_proxy` env var. Therefore we use the shell wrapper script to unset the httpX_proxy vars. This is not a nice thing ...



## Helpful docs
- http://txt.fliglio.com/2015/07/12-factor-infrastructure-with-consul-and-vault/

