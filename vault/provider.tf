terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
  //ca_cert_dir = "/opt/vault/tls"
  skip_tls_verify = true
}
