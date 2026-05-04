terraform {
  backend "s3" {
    bucket         = "terraform-state-assignment-3-bce35194"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-bce35194"
    encrypt        = true
  }
}
