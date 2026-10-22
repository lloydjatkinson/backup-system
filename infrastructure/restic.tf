resource "random_password" "restic_repo" {
  for_each = local.machines

  length  = 32
  special = false
}

# Inits each repo on create, and again if its repository URL changes (bucket or
# region). A vanished repo doesn't change the URL, so it's not silently recreated;
# use scripts/recreate-repo.sh for that.
resource "terraform_data" "restic_init" {
  for_each = local.repo_pairs

  triggers_replace = each.value.repository

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    environment = merge(each.value.env, {
      RESTIC_PASSWORD   = each.value.password
      RESTIC_REPOSITORY = each.value.repository
    })
    command = "restic cat config >/dev/null 2>&1 || restic init"
  }
}