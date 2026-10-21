data "b2_account_info" "this" {}

resource "b2_bucket" "backups" {
  bucket_name = "${local.family_prefix}-backups"
  bucket_type = "allPrivate"
}

resource "b2_application_key" "restic_b2" {
  for_each = local.machines

  key_name    = "${local.family_prefix}-restic-${each.key}"
  bucket_ids  = [b2_bucket.backups.id]
  name_prefix = "${each.key}/"

  capabilities = [
    "listBuckets",
    "listAllBucketNames",
    "listFiles",
    "readFiles",
    "writeFiles",
  ]
}