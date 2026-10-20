resource "random_password" "restic_repo" {
  for_each = local.machines

  length  = 32
  special = false
}