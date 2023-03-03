output "role_names" {
  value = [for k, v in var.role_names : v]
}
output "aws_path" {
  value = vault_aws_secret_backend.my_aws.path
}
