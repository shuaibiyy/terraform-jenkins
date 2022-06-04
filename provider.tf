terraform {
  required_version = ">=1.0.0"
   aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
}
/*
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
*/
cloud {
    organization = "My_ProjectJenkings"

    workspaces {
      name = "gh-actions-jenkings"
    }
}