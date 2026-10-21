resource "random_password" "restic_repo" {
  for_each = local.machines

  length  = 32
  special = false
}

# Inits each repo once, on create. A repo that later vanishes is not recreated;
# use scripts/recreate-repo.sh to make one again.
resource "terraform_data" "restic_init" {
  for_each = local.repo_pairs

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    environment = merge(each.value.env, {
      RESTIC_PASSWORD   = each.value.password
      RESTIC_REPOSITORY = each.value.repository
    })
    command = "restic cat config >/dev/null 2>&1 || restic init"
  }
}