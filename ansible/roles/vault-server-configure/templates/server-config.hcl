{% if 'consul' in vault_backend -%}
	backend "consul" {
	  address = "{{ consul_node.stdout }}:8500"
	  scheme = "http"
	  path = "vault/"
	}
{% else -%}
	backend "file" {
	  path = "{{ vault.root_dir }}/data/"
	}
{% endif %}

listener "tcp" {
  address = "{{ ansible_host }}:{{ vault.service_listen_port }}"
  tls_disable = 1
}