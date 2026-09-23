###############################################################################
# AISIA — Multi-cloud Phase 4 partie 2 (sprint v6.13.18)
#
# Module Terraform OVH Public Cloud : déploie un cluster Docker Swarm AISIA
# minimal sur OVH Public Cloud Instances (b2-7 manager + workers).
#
#   ┌──────────────────────────────────────────────────────────────────┐
#   │ Project Public Cloud existant + Network privé + Subnet IP        │
#   │ 1 manager Instance (b2-7) + N workers (b2-7)                      │
#   │ user_data installe Docker + initialise Swarm                      │
#   │ Worker join token via OVH Object Storage S3-compat (TODO v5.5.67) │
#   └──────────────────────────────────────────────────────────────────┘
#
# Statut : SKELETON DOCUMENTÉ — pas exécuté en CI. Provisioning manuel.
#
# Usage :
#   cd infra/terraform/ovh
#   export OVH_ENDPOINT=ovh-eu
#   export OVH_APPLICATION_KEY=...
#   export OVH_APPLICATION_SECRET=...
#   export OVH_CONSUMER_KEY=...
#   terraform init
#   terraform plan -var="image_tag=v6.13.11"
#   terraform apply
#
# Dépendances : Terraform >= 1.5, OVH provider >= 0.50, project_id Public Cloud.
###############################################################################

###############################################################################
# DATA — image Ubuntu 24.04 OVH catalogue
###############################################################################
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 24.04"
  most_recent = true
}

data "openstack_compute_flavor_v2" "manager" {
  name = var.instance_flavor
}

data "openstack_compute_flavor_v2" "worker" {
  name = var.instance_flavor
}

###############################################################################
# Réseau privé OVH (vRack-compatible)
###############################################################################
resource "openstack_networking_network_v2" "aisia" {
  name           = "${var.cluster_name}-net"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "aisia" {
  name       = "${var.cluster_name}-subnet"
  network_id = openstack_networking_network_v2.aisia.id
  cidr       = var.subnet_cidr
  ip_version = 4
}

###############################################################################
# Security Group — Swarm + HTTP/HTTPS + SSH
###############################################################################
resource "openstack_networking_secgroup_v2" "swarm" {
  name        = "${var.cluster_name}-sg"
  description = "AISIA Swarm cluster (sprint v6.13.18)"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count             = var.ssh_allowed_cidr == null ? 0 : 1
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

resource "openstack_networking_secgroup_rule_v2" "swarm_mgmt" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2377
  port_range_max    = 2377
  remote_ip_prefix  = var.subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

resource "openstack_networking_secgroup_rule_v2" "swarm_gossip" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_ip_prefix  = var.subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

resource "openstack_networking_secgroup_rule_v2" "swarm_overlay" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_ip_prefix  = var.subnet_cidr
  security_group_id = openstack_networking_secgroup_v2.swarm.id
}

###############################################################################
# Keypair SSH
###############################################################################
resource "openstack_compute_keypair_v2" "aisia" {
  name       = "${var.cluster_name}-key"
  public_key = var.ssh_public_key
}

###############################################################################
# user_data scripts cloud-init
###############################################################################
locals {
  user_data_manager = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker ubuntu
      - PRIV_IP=$(hostname -I | awk '{print $1}') && docker swarm init --advertise-addr "$PRIV_IP"
      - docker swarm join-token -q worker > /tmp/worker-token
      # AISIA image tag : ${var.image_tag}
      # TODO v5.5.67 : publier worker-token dans OVH Object Storage S3-compat
  EOT

  user_data_worker = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker ubuntu
      # TODO v5.5.67 : fetch worker-token depuis OVH Object Storage puis
      # docker swarm join --token <TOKEN> <manager-private-ip>:2377
  EOT
}

###############################################################################
# Manager Instance
###############################################################################
resource "openstack_compute_instance_v2" "manager" {
  name      = "${var.cluster_name}-manager"
  image_id  = data.openstack_images_image_v2.ubuntu.id
  flavor_id = data.openstack_compute_flavor_v2.manager.id
  key_pair  = openstack_compute_keypair_v2.aisia.name
  user_data = local.user_data_manager

  security_groups = [openstack_networking_secgroup_v2.swarm.name]

  network {
    uuid = openstack_networking_network_v2.aisia.id
  }
  # Ext-Net OVH = IP publique
  network {
    name = "Ext-Net"
  }

  metadata = {
    Role    = "swarm-manager"
    Project = "AISIA"
  }
}

###############################################################################
# Workers Instances
###############################################################################
resource "openstack_compute_instance_v2" "worker" {
  count     = var.node_count
  name      = "${var.cluster_name}-worker-${count.index + 1}"
  image_id  = data.openstack_images_image_v2.ubuntu.id
  flavor_id = data.openstack_compute_flavor_v2.worker.id
  key_pair  = openstack_compute_keypair_v2.aisia.name
  user_data = local.user_data_worker

  security_groups = [openstack_networking_secgroup_v2.swarm.name]

  depends_on = [openstack_compute_instance_v2.manager]

  network {
    uuid = openstack_networking_network_v2.aisia.id
  }
  network {
    name = "Ext-Net"
  }

  metadata = {
    Role    = "swarm-worker"
    Project = "AISIA"
  }
}
