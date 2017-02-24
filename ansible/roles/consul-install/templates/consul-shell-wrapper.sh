# wrapper function for hashicorp vault (vaultproject.io)
function consul() {
    for v in http_proxy HTTP_PROXY https_proxy HTTPS_PROXY; do
        unset $v
    done
    {{ all.bin_dir }}/consul $@
}