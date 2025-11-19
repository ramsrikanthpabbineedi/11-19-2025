terraform {
  backend "s3" {
    bucket = "ramram-bucket--2"
    key = "ram/raa/terraform.tfstate"
    region = "eu-north-1"
    
  }
}