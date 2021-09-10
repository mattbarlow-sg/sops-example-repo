variable "env" {
  type = string
}

terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
  }

  backend "s3" {
    bucket = "tfstate-sops-lal"
    key    = "env/tfstate"
    region = "us-west-2"
  }
}

provider "sops" {}

data "sops_file" "sops-secrets" {
  source_file = "secrets.${var.env}.tfvars.json"
}

resource "aws_secretsmanager_secret" "mysecret" {
  name = "mysecret-for-sops-2"
}

resource "aws_secretsmanager_secret_version" "mysecret" {
  secret_id     = aws_secretsmanager_secret.mysecret.id
  secret_string = data.sops_file.sops-secrets.data["super-secret"]
}

resource "aws_secretsmanager_secret" "mysecret-2" {
  name = "mysecret-for-sops-2"
}

resource "aws_secretsmanager_secret_version" "mysecret-2" {
  secret_id     = aws_secretsmanager_secret.mysecret-2.id
  secret_string = data.sops_file.sops-secrets.data["super-secret-2"]
}
