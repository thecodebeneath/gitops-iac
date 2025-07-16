resource "aws_s3_bucket" "gitlab-iac-bucket" {
  bucket = "${var.project_name}-iac"
  force_destroy = true
}