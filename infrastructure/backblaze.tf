resource "b2_bucket" "backups" {
  bucket_name = "${local.name_prefix}-home-backups-b2"
  bucket_type = "allPrivate"

  lifecycle {
    prevent_destroy = true
  }
}

resource "b2_application_key" "restic" {
  for_each = local.machines

  key_name    = "${local.name_prefix}-${each.key}-restic"
  bucket_ids  = [b2_bucket.backups.id]
  name_prefix = "${each.key}/"

  capabilities = [
    "listBuckets",
    "listAllBucketNames",
    "listFiles",
    "readFiles",
    "writeFiles"
  ]
}