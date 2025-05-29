terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-12345" # Replace with your bucket
    key            = "global/s3/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
