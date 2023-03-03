
variable "databases" {
  type = map(object({
    password = string
    dba      = string
    url      = string
    port     = number
    db_name  = string
  }))
  default = {
    "test" = {
      password = "bla123"
      dba      = "postgres"
      url      = "localhost"
      port     = 5432
      db_name  = "postgres"
    }
  }
  description = "Map of objects with the desired configs for each database"
}
