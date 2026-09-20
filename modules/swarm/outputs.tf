###############################################################################
# AISIA Terraform OVH — outputs (sprint v6.13.16)
###############################################################################

# ── Contrat de sortie normalisé (commun substrat swarm) ────────────────────
output "region" {
  description = "Région OVH du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Nombre de workers provisionnés (hors manager)."
  value       = var.node_count
}

output "manager_ip" {
  description = "IP publique du manager (Ext-Net OVH)"
  value       = openstack_compute_instance_v2.manager.access_ip_v4
}

output "worker_ips" {
  description = "Liste des IPs publiques des workers"
  value       = [for w in openstack_compute_instance_v2.worker : w.access_ip_v4]
}

output "private_network_id" {
  description = "ID du réseau privé OVH"
  value       = openstack_networking_network_v2.aisia.id
}

output "swarm_join_token_path" {
  description = <<-EOT
    Chemin du token worker dans le manager :
      ssh ubuntu@<manager_ip> 'sudo cat /tmp/worker-token'
    NOTE : v5.5.67 publiera ce token dans OVH Object Storage S3-compat.
  EOT
  value       = "/tmp/worker-token"
}

output "next_steps" {
  description = "Étapes manuelles à exécuter après terraform apply"
  value       = <<-EOT
    1. Récupérer le worker token :
       ssh ubuntu@${openstack_compute_instance_v2.manager.access_ip_v4} 'sudo cat /tmp/worker-token'

    2. Joindre chaque worker manuellement (auto-join arrive v5.5.67) :
       ssh ubuntu@<worker_ip> "docker swarm join --token <TOKEN> <manager-priv-ip>:2377"

    3. Déployer la stack AISIA :
       scp deploy/stack-aisia.yml ubuntu@${openstack_compute_instance_v2.manager.access_ip_v4}:/tmp/
       ssh ubuntu@${openstack_compute_instance_v2.manager.access_ip_v4} 'docker stack deploy -c /tmp/stack-aisia.yml aisia'
  EOT
}
