variable "role_names" {
  type = map(any)
  default = {
    s3  = "AssumeS3Role"
    ec2 = "AssumeEC2Role"
  }
}

variable "account_id" {
  type        = string
  description = "Account number Id for identity its resources"
  sensitive   = true
}

variable "creds" {
  type = object({
    access = string
    secret = string
  })
  description = "Access Key and Secret Key to access AWS Account and retrive its creds dynamically"
  sensitive   = true
}
