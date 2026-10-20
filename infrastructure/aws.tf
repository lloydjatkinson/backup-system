# AWS S3 destination. To enable: add the aws provider and a `variable "aws_region"`,
# uncomment this and the `aws` block in outputs.tf, apply, then run the bootstrap.
# Append-only: no s3:DeleteObject; the lifecycle rule reclaims the files restic hides.

# resource "aws_s3_bucket" "backups" {
#   bucket = "${local.family_prefix}-backups-aws"
#   lifecycle { prevent_destroy = true }
# }
#
# resource "aws_s3_bucket_lifecycle_configuration" "backups" {
#   bucket = aws_s3_bucket.backups.id
#   rule {
#     id     = "expire-hidden"
#     status = "Enabled"
#     noncurrent_version_expiration { noncurrent_days = 7 }
#   }
# }
#
# resource "aws_iam_user" "restic" {
#   for_each = local.machines
#   name     = "${local.family_prefix}-restic-${each.key}"
# }
#
# resource "aws_iam_access_key" "restic" {
#   for_each = local.machines
#   user     = aws_iam_user.restic[each.key].name
# }
#
# resource "aws_iam_user_policy" "restic" {
#   for_each = local.machines
#   user     = aws_iam_user.restic[each.key].name
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "ListOwnPrefix"
#         Effect    = "Allow"
#         Action    = ["s3:ListBucket"]
#         Resource  = aws_s3_bucket.backups.arn
#         Condition = { StringLike = { "s3:prefix" = ["${each.key}/*"] } }
#       },
#       {
#         Sid      = "WriteReadOwnPrefix"
#         Effect   = "Allow"
#         Action   = ["s3:PutObject", "s3:GetObject"]
#         Resource = "${aws_s3_bucket.backups.arn}/${each.key}/*"
#       }
#     ]
#   })
# }