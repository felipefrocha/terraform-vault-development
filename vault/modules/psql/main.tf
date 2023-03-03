## Postgres RDS Regulation
resource "vault_mount" "this" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "rds_main" {
  for_each      = var.databases
  backend       = vault_mount.this.path
  name          = "admin"
  allowed_roles = ["dba-role"]


  postgresql {
    username = each.value.dba
    password = each.value.password

    connection_url = "postgres://${each.value.dba}:${each.value.password}@${each.value.url}:${each.value.port}/${each.value.db_name}"
  }
}


resource "vault_database_secret_backend_role" "role_main" {
  for_each = var.databases
  backend  = vault_mount.this.path
  name     = "dba-role"
  db_name  = vault_database_secret_backend_connection.rds_main[each.key].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT postgres to \"{{name}}\";"
  ]
  revocation_statements = [
    "DROP ROLE IF EXISTS \"{{name}}\";",
  ]
  default_ttl = "600"
  max_ttl     = "30879000"
}
