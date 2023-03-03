
## -----------------------------
# Create AWS Permissions for each role
## -----------------------------

resource "vault_aws_secret_backend" "my_aws" {
  path = "me"

  access_key = var.creds.access
  secret_key = var.creds.secret

  default_lease_ttl_seconds = "900"
  max_lease_ttl_seconds     = "43000"
}

resource "vault_aws_secret_backend_role" "roles_to_be_assumed" {
  for_each = var.role_names
  backend  = vault_aws_secret_backend.my_aws.path
  name     = format("me-%s", each.key)
  role_arns = [
    format("arn:aws:iam::%s:role/%s", var.account_id, each.value)
  ]
  credential_type = "assumed_role"
  default_sts_ttl = "900"
  max_sts_ttl     = "43000"
}
