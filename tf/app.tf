provider "helm" {
  kubernetes {
    host = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.endpoint

    token = data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].token
    client_certificate     = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].client_certificate)
    client_key             = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.dsm-k8-cluster.kube_config[0].cluster_ca_certificate)

  }
}


resource "helm_release" "app_release" {
  name = "${var.project_name}-app"
  chart = "./helm"
}
