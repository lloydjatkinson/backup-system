output "backblaze_bucket_name" {
  description = "Name of the Backblaze B2 backup bucket"
  value       = b2_bucket.backups.bucket_name
}