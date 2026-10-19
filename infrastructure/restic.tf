resource "random_password" "restic" {
  for_each = local.machines

  length  = 32
  special = false

  lifecycle {
    prevent_destroy = true
  }
}