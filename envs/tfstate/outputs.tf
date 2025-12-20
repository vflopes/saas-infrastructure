output "tfstate_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state storage"
  value       = aws_s3_bucket.tfstate.bucket
}