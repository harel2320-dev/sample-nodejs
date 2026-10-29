output "bucket_name" {
  value = aws_s3_bucket.tfstate.id
}

output "kms_key_arn" {
  value = aws_kms_key.tfstate.arn
}
