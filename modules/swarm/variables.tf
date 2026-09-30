###############################################################################
# AISIA Terraform OVH — variables
#
# Contrat NORMALISÉ v6.14.1 : les 13 variables communes ci-dessous sont
# identiques (noms + types + defaults cloud-agnostiques) à tous les clouds ×
# substrats (référence : infra/terraform/gcp/{k8s,swarm}). Les defaults
# spécifiques au cloud (region, instance_flavor, substrate) sont adaptés à OVH.
###############################################################################

# ── Contrat normalisé (commun à tous les clouds) ───────────────────────────
variable "org_id" {
  description = "Identifiant de l'organisation AISIA (tenant)."
  type        = string
}

variable "service_key" {
  description = "Brique déployée (C1..C11, cf. aisia_deployable_services)."
  type        = string
}

variable "runtime_kind" {
  description = "edge|compute|compute-gpu|data|ops|security."
  type        = string
  default     = "compute"
}

variable "substrate" {
  description = "Substrat cible (k8s|swarm). Ici : swarm."
  type        = string
  default     = "swarm"
}

variable "profile" {
  description = "Profil de dimensionnement (S|M|L|XL)."
  type        = string
  default     = "S"
}

variable "region" {
  description = "Région OVH Public Cloud (GRA11=Gravelines, SBG5=Strasbourg, RBX-A=Roubaix)."
  type        = string
  default     = "GRA11"
}

variable "node_count" {
  description = "Nombre de nœuds workers (le manager est en plus)."
  type        = number
  default     = 1
}

variable "instance_flavor" {
  description = "Flavor OVH des nœuds (b2-7 = 2 vCPU / 7 GB RAM)."
  type        = string
  default     = "b2-7"
}

variable "image_registry" {
  description = "Registry des images AISIA."
  type        = string
  default     = "registry.aisia.fr"
}

variable "image_tag" {
  description = "Tag d'image AISIA à déployer."
  type        = string
  default     = "v6.14.8"
}

variable "domain" {
  description = "Domaine custom de l'org (vide = *.aisia.fr)."
  type        = string
  default     = ""
}

variable "tier" {
  description = "Offre (saas|baas|paas)."
  type        = string
  default     = "saas"
}

variable "gpu_enabled" {
  description = "Provisionner un pool GPU (runtime compute-gpu / inférence C4)."
  type        = bool
  default     = false
}

# ── Spécifiques OVH ────────────────────────────────────────────────────────
variable "ovh_endpoint" {
  description = "Endpoint API OVH (ovh-eu, ovh-ca, ovh-us)."
  type        = string
  default     = "ovh-eu"
}

variable "project_id" {
  description = "ID du projet OVH Public Cloud."
  type        = string
}

variable "openstack_auth_url" {
  description = "URL Keystone OpenStack OVH (ex. https://auth.cloud.ovh.net/v3)."
  type        = string
  default     = "https://auth.cloud.ovh.net/v3"
}

variable "openstack_user" {
  description = "User OpenStack OVH (créé via API /cloud/project/{id}/user)."
  type        = string
}

variable "openstack_password" {
  description = "Password OpenStack OVH (sensible)."
  type        = string
  sensitive   = true
}

variable "subnet_cidr" {
  description = "CIDR du réseau privé (par défaut 10.44.0.0/24)."
  type        = string
  default     = "10.44.0.0/24"
}

variable "cluster_name" {
  description = "Nom logique du cluster (préfixe des ressources)."
  type        = string
  default     = "aisia-ovh"
}

variable "ssh_public_key" {
  description = "Clé publique SSH (contenu OpenSSH du fichier id_rsa.pub)."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR optionnel autorisé pour SSH. Null désactive l'exposition SSH."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition = var.ssh_allowed_cidr == null || (
      trimspace(var.ssh_allowed_cidr) != "" &&
      var.ssh_allowed_cidr != "0.0.0.0/0" &&
      can(cidrhost(var.ssh_allowed_cidr, 0))
    )
    error_message = "ssh_allowed_cidr doit être un CIDR valide et ne peut jamais être 0.0.0.0/0. Omettez-le pour désactiver SSH."
  }
}
