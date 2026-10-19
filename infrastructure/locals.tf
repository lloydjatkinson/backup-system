locals {
  family_prefix = "atkinson"
  machines      = toset(jsondecode(file("${path.module}/machines.json")).machines)
}