terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
      configuration_aliases = [ aws.us-east-1 ]
    }
  }
}