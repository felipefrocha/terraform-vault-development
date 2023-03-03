resource "vault_mount" "kvv2" {
  type        = "kv-v2"
  path        = "newsecret"
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "this" {
  for_each = {
    test = {
      data_name = "test"
      data_info = "test info"
    }
  }
  mount = vault_mount.kvv2.path
  name  = format("%s/%s", each.key, each.value.data_name)

  data_json = jsonencode({
    info = each.value.data_info
  })

  depends_on = [
    vault_mount.kvv2
  ]
}

