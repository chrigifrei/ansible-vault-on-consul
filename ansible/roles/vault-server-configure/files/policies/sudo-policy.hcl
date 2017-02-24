path "sys/*" {
  policy = "write"
  capabilities = ["create", "sudo"]
}

path "secret/{{ realm }}/*" {
  policy = "write"
  capabilities = ["create", "sudo"]
}
