provider "kubernetes" {
  host             = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.endpoint
  token            = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
  data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].cluster_ca_certificate
  )
}


resource "helm_release" "ingress_nginx" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  name = "${var.project_name}-ingress-nginx"
  namespace = var.project_name
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

resource "digitalocean_domain" "app_backend_domain" {
  name = "www.dsmorrison.com"
}

resource "digitalocean_record" "backend_api" {
  domain = digitalocean_domain.app_backend_domain.name
  name = "@"
  type = "A"
  value = kubernetes_ingress.app_backend_ingress.status[0].load_balancer[0].ingress[0].ip
}


