terraform {
  required_version = ">= 0.13.5"
  backend "s3" {
    endpoint = "nyc3.digitaloceanspaces.com"
    region = "us-east-1" # Not actually used because state is in DO spaces, but required to pass tf init
    key = "iguana-k8.tfstate"
    bucket = "dsm-space"

    # Skip these checks, we aren't using AWS
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
    skip_metadata_api_check = true
  }
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.6"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.0.3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.DO_TOKEN
}

data "digitalocean_kubernetes_cluster" "dsm-k8-cluster" {
  name = "dsm-k8-cluster"
}