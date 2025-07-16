output s3_bucket {
    value = aws_s3_bucket.gitlab-iac-bucket.id
    description = "The name of the S3 bucket created"
}