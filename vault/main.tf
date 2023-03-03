module "aws_secret_engine" {
  source = "./modules/aws"
  creds = {
    access = var.MY_AWS_ACCESS_KEY_ID
    secret = var.MY_AWS_SECRET_ACCESS_KEY
  }
  account_id = var.account_id
}

module "users" {
  source        = "./modules/user"
  policy_ids    = [vault_policy.admins.id]
  userpass_path = var.userpass_path
}

module "secret" {
  source = "./modules/secrets"

}

module "postgres" {
  source = "./modules/psql"

}

resource "vault_password_policy" "alphanumeric" {
  name   = "strongpasswd"
  policy = <<EOF
length=20

rule "charset" {
  charset = "abcdefghijklmnopqrstuvwxyz"
  min-chars = 1
}

rule "charset" {
  charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  min-chars = 3
}

rule "charset" {
  charset = "0123456789"
  min-chars = 3
}

rule "charset" {
  charset = "!@#$%^&*"
  min-chars = 2
}
EOF
}
