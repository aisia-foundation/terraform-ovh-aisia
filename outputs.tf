###############################################################################
# terraform-ovh-aisia — outputs (contrat normalisé substrat K8s MKS OVH).
# Utiliser cluster_endpoint + kubeconfig pour configurer les providers
# kubernetes/helm dans le root module, puis appeler terraform-aisia-cluster.
###############################################################################

output "cluster_id" {
  description = "ID du cluster MKS OVH."
  value       = ovh_cloud_project_kube.aisia.id
}

output "cluster_name" {
  description = "Nom du cluster MKS OVH."
  value       = ovh_cloud_project_kube.aisia.name
}

output "cluster_status" {
  description = "Statut du cluster MKS (READY attendu après convergence)."
  value       = ovh_cloud_project_kube.aisia.status
}

output "cluster_endpoint" {
  description = "Endpoint du control plane MKS (API server)."
  value       = ovh_cloud_project_kube.aisia.kubeconfig_attributes[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Certificat client MKS (PEM)."
  value       = ovh_cloud_project_kube.aisia.kubeconfig_attributes[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Clé client MKS (PEM)."
  value       = ovh_cloud_project_kube.aisia.kubeconfig_attributes[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate MKS (PEM)."
  value       = ovh_cloud_project_kube.aisia.kubeconfig_attributes[0].cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig complet du cluster MKS (sensible — stocker dans un secret)."
  value       = ovh_cloud_project_kube.aisia.kubeconfig
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Commande pour exporter le kubeconfig depuis l'output Terraform."
  value       = "terraform output -raw kubeconfig > kubeconfig-${var.org_id}.yaml && export KUBECONFIG=kubeconfig-${var.org_id}.yaml"
}

output "region" {
  description = "Région OVH MKS du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Nombre de nœuds désirés sur le pool principal."
  value       = ovh_cloud_project_kube_nodepool.primary.desired_nodes
}

output "gpu_pool_enabled" {
  description = "Un node pool GPU a-t-il été provisionné ?"
  value       = var.gpu_enabled
}
