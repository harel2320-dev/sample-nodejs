terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket       = "sample-nodejs-tfstate-027401589554"
    key          = "main/terraform.tfstate"
    region       = "il-central-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:il-central-1:027401589554:key/80490ddc-9968-410e-a49a-891167689073"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}
