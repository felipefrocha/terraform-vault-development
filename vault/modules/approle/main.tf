resource "vault_auth_backend" "github_approle" {
  type        = "approle"
  path        = "github"
  description = "This a app role for github runners in general"
  tune {
    max_lease_ttl = "15m"

    listing_visibility = "unauth"
  }
}

resource "vault_approle_auth_backend_role" "github" {
  backend        = vault_auth_backend.github_approle.path
  role_name      = "github-role"
  token_policies = ["github-policy"]
  # bind_secret_id        = false
  # secret_id_bound_cidrs = ["10.0.0.0/8"]
}

resource "vault_approle_auth_backend_role_secret_id" "github" {
  role_name = vault_approle_auth_backend_role.github.role_name
  backend   = vault_auth_backend.github_approle.id
}

resource "vault_policy" "github_policy" {
  name   = "github-policy"
  policy = data.vault_policy_document.github_policy.hcl
}

data "vault_policy_document" "github_policy" {
  rule {
    path         = "secret/*"
    capabilities = ["read", "list"]
    description  = "allow all on secrets"
  }
}