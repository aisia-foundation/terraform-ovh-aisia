###############################################################################
# terraform-ovh-aisia — substrat OVHcloud Managed Kubernetes Service (MKS).
#
#   ┌──────────────────────────────────────────────────────────────────────┐
#   │ Projet Public Cloud OVH (service_name) déjà existant                │
#   │  ├─ ovh_cloud_project_kube (control plane managé MKS)               │
#   │  ├─ ovh_cloud_project_kube_nodepool (pool principal)                 │
#   │  └─ ovh_cloud_project_kube_nodepool (pool GPU optionnel)             │
#   └──────────────────────────────────────────────────────────────────────┘
#
# Usage : chaîner avec terraform-aisia-cluster pour déployer la stack AISIA.
# Le consumer configure `provider "ovh" { endpoint = "ovh-eu" ... }` dans son root module.
# Output `kubeconfig` (sensitive) alimente les providers kubernetes/helm du root module.
###############################################################################

locals {
  name = "${var.cluster_name}-${var.org_id}"

  labels = {
    aisia_org     = var.org_id
    aisia_service = var.service_key
    aisia_tier    = var.tier
    managed_by    = "aisia-terraform"
  }
}

###############################################################################
# Cluster MKS managé
###############################################################################
resource "ovh_cloud_project_kube" "aisia" {
  service_name  = var.service_name
  name          = local.name
  region        = var.region
  version       = var.kube_version != "" ? var.kube_version : null
  update_policy = "MINIMAL_DOWNTIME"
}

###############################################################################
# Node pool principal
###############################################################################
resource "ovh_cloud_project_kube_nodepool" "primary" {
  service_name  = var.service_name
  kube_id       = ovh_cloud_project_kube.aisia.id
  name          = "${var.cluster_name}-primary"
  flavor_name   = var.instance_flavor
  desired_nodes = var.node_count
  autoscale     = var.node_pool_autoscale
  min_nodes     = var.node_pool_autoscale ? var.node_pool_min_nodes : var.node_count
  max_nodes     = var.node_pool_autoscale ? var.node_pool_max_nodes : var.node_count
}

###############################################################################
# Node pool GPU optionnel (inférence C4)
###############################################################################
resource "ovh_cloud_project_kube_nodepool" "gpu" {
  count         = var.gpu_enabled ? 1 : 0
  service_name  = var.service_name
  kube_id       = ovh_cloud_project_kube.aisia.id
  name          = "${var.cluster_name}-gpu"
  flavor_name   = var.gpu_flavor
  desired_nodes = 1
  autoscale     = true
  min_nodes     = 0
  max_nodes     = 4

  template {
    metadata {
      annotations = {}
      finalizers  = []
      labels      = merge(local.labels, { aisia_pool = "gpu" })
    }
    spec {
      unschedulable = false
      taints = [
        {
          key    = "nvidia.com/gpu"
          value  = "present"
          effect = "NoSchedule"
        }
      ]
    }
  }
}
