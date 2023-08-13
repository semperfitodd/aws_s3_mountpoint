resource "random_string" "this" {
  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}