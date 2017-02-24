path "sys/*" {
  policy = "deny"
}

path "secret/{{ realm }}/*" {
  policy = "read"
}
