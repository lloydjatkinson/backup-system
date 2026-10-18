resource "b2_bucket" "backups" {
  bucket_name = "${local.name_prefix}-home-backups-b2"
  bucket_type = "allPrivate"

  lifecycle {
    prevent_destroy = true
  }
}

resource "b2_application_key" "restic" {
  key_name   = "${local.name_prefix}-restic"
  bucket_ids = [b2_bucket.backups.id]

  capabilities = [
    "listBuckets",
    "listAllBucketNames",
    "listFiles",
    "readFiles",
    "writeFiles",
    "deleteFiles"
  ]
}