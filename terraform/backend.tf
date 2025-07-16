terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "wip/iac/iac-tfstate"
    region = "us-east-2"
  }
}