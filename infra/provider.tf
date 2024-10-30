terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    awscc = {
      source = "hashicorp/awscc"
      version = "~> 1.16.1"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  version = "~> 4.0"
}