

variable "MY_AWS_ACCESS_KEY_ID" {
  type        = string
  description = "Access key Id From master user account"
  sensitive   = true
}

variable "MY_AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "Secret key From master user account"
  sensitive   = true
}

variable "account_id" {
  type        = string
  description = "Account id"
  sensitive   = true
}

variable "vault_addr" {
  type    = string
  default = "http://127.0.0.1:8200"
}

variable "vault_token" {
  type        = string
  default     = ""
  description = "Vault token with root credentials"
  sensitive   = true
}


variable "userpass_path" {
  type = string
}


variable "aws_ttl" {
  default = 3600
}

# variable "database" {
#   type = map(object({
#     host     = optional(string, "localhost")
#     host_ro  = optional(string, "localhost")
#     port     = optional(string, "5432")
#     user     = optional(string, "postgres")
#     password = optional(string, "bla123")
#     database = optional(string, "postgres")
#   }))
#   sensitive   = true
#   description = "Object with parameter"
# }




