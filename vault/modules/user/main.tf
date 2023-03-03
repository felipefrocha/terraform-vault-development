
resource "vault_auth_backend" "user_password" {
  type = "userpass"
  path = var.userpass_path

  tune {
    default_lease_ttl  = "8h"
    max_lease_ttl      = "12h"
    listing_visibility = "hidden"
  }
}

resource "vault_generic_endpoint" "this" {
  for_each             = local.users
  depends_on           = [vault_auth_backend.user_password]
  path                 = "auth/${var.userpass_path}/users/${each.value}"
  ignore_absent_fields = true

  data_json = jsonencode({
    policies = var.policy_ids
    password = "bl4123"
  })
  lifecycle {
    ignore_changes = [data_json]
  }
}

locals {
  users = toset([
    "felipe",
  ])
}
