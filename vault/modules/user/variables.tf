variable "userpass_path" {
  type        = string
  description = "Local of mount path to userpass"
}

variable "policy_ids" {
  type        = list(string)
  description = "List of policies ids to be add"
}
