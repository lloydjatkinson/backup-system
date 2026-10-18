resource "b2_bucket" "backups" {
  bucket_name = "${local.name_prefix}-home-backups-b2"
  bucket_type = "allPrivate"

  lifecycle {
    prevent_destroy = true
  }
}