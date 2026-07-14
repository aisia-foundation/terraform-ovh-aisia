###############################################################################
# Exemple minimal — terraform-ovh-aisia (substrat OVH MKS)
#
# Prérequis : credentials OVH via env vars.
#   export OVH_ENDPOINT=ovh-eu
#   export OVH_APPLICATION_KEY=...
#   export OVH_APPLICATION_SECRET=...
#   export OVH_CONSUMER_KEY=...
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.50"
    }
  }
}

provider "ovh" {
  endpoint = "ovh-eu"
  # application_key    = "..."  # ou OVH_APPLICATION_KEY
  # application_secret = "..."  # ou OVH_APPLICATION_SECRET
  # consumer_key       = "..."  # ou OVH_CONSUMER_KEY
}

###############################################################################
# L1 — substrat MKS (1 nœud b2-7, profil S)
###############################################################################
module "aisia_ovh_k8s" {
  # Registre HCP privé (nécessite credentials) :
  #   source  = "app.terraform.io/AISIA/aisia/ovh"
  #   version = "~> 1.0"
  source = "../../"

  org_id       = "acme"
  service_key  = "C1"
  service_name = "your-ovh-project-id"
  image_tag    = "v6.12.29"
  tier         = "saas"

  region          = "GRA11"
  cluster_name    = "aisia-acme"
  node_count      = 1
  instance_flavor = "b2-7"
}

###############################################################################
# L2 — déploiement AISIA (dans votre root module après cet example) :
#
# provider "kubernetes" {
#   host                   = module.aisia_ovh_k8s.cluster_endpoint
#   client_certificate     = module.aisia_ovh_k8s.client_certificate
#   client_key             = module.aisia_ovh_k8s.client_key
#   cluster_ca_certificate = module.aisia_ovh_k8s.cluster_ca_certificate
# }
#
# module "aisia_app" {
#   source  = "app.terraform.io/AISIA/aisia-cluster/kubernetes"
#   version = "~> 1.0"
#   image_tag = "v6.12.29"
#   tier      = "saas"
#   domain    = "acme.aisia.fr"
# }
###############################################################################

output "cluster_id" {
  value = module.aisia_ovh_k8s.cluster_id
}

output "cluster_name" {
  value = module.aisia_ovh_k8s.cluster_name
}

output "kubeconfig_command" {
  value = module.aisia_ovh_k8s.kubeconfig_command
}
