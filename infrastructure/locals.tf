locals {
  family_prefix = "atkinson"
  machines      = toset(jsondecode(file("${path.module}/machines.json")).machines)

  # Region only exists inside the S3 endpoint; pull it out so restic signs
  # against it rather than defaulting to us-east-1.
  b2_region = regex("s3\\.([a-z0-9-]+)\\.backblazeb2\\.com", data.b2_account_info.this.s3_api_url)[0]

  repositories = {
    for machine in local.machines : machine => {
      password = random_password.restic_repo[machine].result
      destinations = {
        b2 = {
          repository = "s3:${data.b2_account_info.this.s3_api_url}/${b2_bucket.backups.bucket_name}/${machine}"
          env = {
            AWS_ACCESS_KEY_ID     = b2_application_key.restic_b2[machine].application_key_id
            AWS_SECRET_ACCESS_KEY = b2_application_key.restic_b2[machine].application_key
            AWS_DEFAULT_REGION    = local.b2_region
          }
        }

        # aws = {
        #   repository = "s3:s3.${aws_s3_bucket.backups.region}.amazonaws.com/${aws_s3_bucket.backups.bucket}/${machine}"
        #   env = {
        #     AWS_ACCESS_KEY_ID     = aws_iam_access_key.restic[machine].id
        #     AWS_SECRET_ACCESS_KEY = aws_iam_access_key.restic[machine].secret
        #     AWS_DEFAULT_REGION    = aws_s3_bucket.backups.region
        #   }
        # }
      }
    }
  }

  repository_pairs = merge([
    for machine, machine_config in local.repositories : {
      for destination, destination_config in machine_config.destinations : "${machine}/${destination}" => {
        repository = destination_config.repository
        password   = machine_config.password
        env        = destination_config.env
      }
    }
  ]...)
}