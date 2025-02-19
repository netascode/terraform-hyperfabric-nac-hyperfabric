resource "hyperfabric_user" "user" {
  for_each = { for user in try(local.hyperfabric.users, []) : user.email => user }

  email   = each.key
  enabled = try(each.value.enabled, local.defaults.hyperfabric.users.enabled, null)
  role    = try(each.value.role, local.defaults.hyperfabric.users.role, null)
  labels  = try(each.value.labels, local.defaults.hyperfabric.users.labels, null)
}
