locals {
  b2_region = "eu-central-003"
}

output "repositories" {
  description = "Per-machine restic repositories and credentials."
  sensitive   = true
  value = {
    for m in local.machines : m => {
      password = random_password.restic_repo[m].result
      destinations = {
        b2 = {
          repository = "s3:https://s3.${local.b2_region}.backblazeb2.com/${b2_bucket.backups.bucket_name}/${m}"
          env = {
            AWS_ACCESS_KEY_ID     = b2_application_key.restic_b2[m].application_key_id
            AWS_SECRET_ACCESS_KEY = b2_application_key.restic_b2[m].application_key
            AWS_DEFAULT_REGION    = local.b2_region
          }
        }

        # aws = {
        #   repository = "s3:s3.${aws_s3_bucket.backups.region}.amazonaws.com/${aws_s3_bucket.backups.bucket}/${m}"
        #   env = {
        #     AWS_ACCESS_KEY_ID     = aws_iam_access_key.restic[m].id
        #     AWS_SECRET_ACCESS_KEY = aws_iam_access_key.restic[m].secret
        #     AWS_DEFAULT_REGION    = aws_s3_bucket.backups.region
        #   }
        # }
      }
    }
  }
}