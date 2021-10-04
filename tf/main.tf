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

// Providers
provider "digitalocean" {
  token = var.DO_TOKEN
}

data "digitalocean_kubernetes_cluster" "dsm-k8-cluster" {
  name = "dsm-k8-cluster"
}

provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.endpoint
  token            = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
  data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.endpoint

    token = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].token
    client_certificate     = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].client_certificate)
    client_key             = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].cluster_ca_certificate)

  }
}


// Resources
resource "helm_release" "app_release" {
  name = "${var.project_name}-app"
  chart = "./helm"
}

resource "kubernetes_ingress" "app_backend_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "spring-${var.project_name}-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target": "/"
    }
  }
  spec {
    rule {
      host = "www.dsmorrison.com"
      http {
        path {
          backend {
            service_name = "spring-${var.project_name}-service"
            service_port = 80
          }
          path = "/"

        }
      }
    }
  }
}

// DNS
//resource "digitalocean_domain" "app_backend_domain" {
//  name = "www.dsmorrison.com"
//}
//
//resource "digitalocean_record" "backend_api" {
//  domain = digitalocean_domain.app_backend_domain.name
//  name = "@"
//  type = "A"
//  value = kubernetes_ingress.app_backend_ingress.status[0].load_balancer[0].ingress[0].ip
//}