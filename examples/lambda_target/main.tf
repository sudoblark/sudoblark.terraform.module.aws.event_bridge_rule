terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.63.0"
    }
  }
  required_version = "~> 1.5.0"
}

provider "aws" {
  region = "eu-west-2"
}

module "sns" {
  source = "github.com/sudoblark/sudoblark.terraform.module.aws.event_bridge_rule?ref=1.0.0"

  application_name = var.application_name
  environment      = var.environment
  raw_sns_topics   = local.raw_event_bridge_rules
}