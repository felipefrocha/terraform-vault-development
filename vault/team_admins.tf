

resource "vault_policy" "admins" {
  name   = "admins"
  policy = data.vault_policy_document.admins.hcl
}

data "vault_policy_document" "admins" {
  # Generic premissions
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }

  rule {
    description  = "Read system health check|"
    path         = "sys/health"
    capabilities = ["read", "sudo"]
  }

  # Create and manage ACL policies broadly across Vault
  rule {
    description  = "List existing policies|"
    path         = "sys/policies/acl"
    capabilities = ["list"]
  }
  rule {
    description  = "Create and manage ACL policies|"
    path         = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  # Enable and manage authentication methods broadly across Vault
  rule {
    description  = "Manage auth methods broadly across Vault|"
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "Create, update, and delete auth methods|"
    path         = "sys/auth/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    description  = "List auth methods|"
    path         = "sys/auth"
    capabilities = ["read"]
  }

  rule {
    description  = "Create, update, and delete auth methods|"
    path         = "sys/policies/password/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    description  = "List auth methods|"
    path         = "sys/policies/password/strongpasswd/*"
    capabilities = ["read"]
  }

  # Enable and manage the key/value secrets engine at `secret/` path
  rule {
    description  = "List, create, update, and delete key/value secrets|"
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "Manage secrets engines|"
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "List existing secrets engines.|"
    path         = "sys/mounts"
    capabilities = ["read"]
  }

  rule {
    description  = "List, create, update, and delete key/value secrets|"
    path         = "local/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  # Enable and manage the secrets engine all aws paths
  dynamic "rule" {
    for_each = toset([module.aws_secret_engine.aws_path, module.postgres.psql_path])
    content {
      description  = "List, create, update, and delete key/value secrets|"
      path         = format("%s/*", rule.key)
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  }


}

