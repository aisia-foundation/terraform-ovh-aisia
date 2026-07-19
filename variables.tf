###############################################################################
# terraform-ovh-aisia — variables d'entrée.
# Substrat OVHcloud Managed Kubernetes Service (MKS). Contrat normalisé v6.9.61.
#
# Auth OVH : le consumer configure `provider "ovh" { endpoint = "ovh-eu" ... }`
# dans son root module. Les clés API (application_key / application_secret /
# consumer_key) sont passées via OVH_* env vars ou le provider block du root module.
# Elles ne transitent PAS par les variables de ce module.
###############################################################################

# ── Contrat normalisé (commun à tous les clouds × substrats) ───────────────
variable "org_id" {
  description = "Identifiant de l'organisation AISIA (tenant)."
  type        = string
}

variable "service_key" {
  description = "Brique déployée (C1..C11)."
  type        = string
}

variable "runtime_kind" {
  description = "edge | compute | compute-gpu | data | ops | security."
  type        = string
  default     = "compute"
}

variable "substrate" {
  description = "Substrat cible. Ce module provisionne le substrat 'k8s' (OVH MKS)."
  type        = string
  default     = "k8s"
}

variable "profile" {
  description = "Profil de dimensionnement (S | M | L | XL)."
  type        = string
  default     = "S"
}

variable "node_count" {
  description = "Nombre de nœuds workers (desired_nodes du node pool principal)."
  type        = number
  default     = 1
}

variable "instance_flavor" {
  description = "Flavor OVH des nœuds MKS (b2-7 = 2 vCPU / 7 GB RAM ; prod : b3-8, c3-8)."
  type        = string
  default     = "b2-7"
}

variable "image_registry" {
  description = "Registry des images AISIA (utilisé pour le tagging ; app deployée via terraform-aisia-cluster)."
  type        = string
  default     = "registry.aisia.fr"
}

variable "image_tag" {
  description = "Tag d'image AISIA à déployer (ex. v6.12.70)."
  type        = string
  default     = "v6.12.70"
}

variable "domain" {
  description = "Domaine custom de l'org (vide = *.aisia.fr)."
  type        = string
  default     = ""
}

variable "tier" {
  description = "Offre tarifaire AISIA (saas | baas | paas)."
  type        = string
  default     = "saas"
  validation {
    condition     = contains(["saas", "baas", "paas"], var.tier)
    error_message = "tier doit etre 'saas', 'baas' ou 'paas'."
  }
}

variable "gpu_enabled" {
  description = "Provisionner un node pool GPU (flavor gpu_flavor par défaut)."
  type        = bool
  default     = false
}

# ── Spécifiques OVH MKS ──────────────────────────────────────────────────
variable "service_name" {
  description = "ID du projet OVH Public Cloud (service_name MKS, requis)."
  type        = string
}

variable "region" {
  description = "Région OVH MKS (EU-WEST-PAR pour 3AZ ; GRA11, SBG5 pour mono-AZ)."
  type        = string
  default     = "GRA11"
}

variable "cluster_name" {
  description = "Nom logique du cluster MKS (préfixe des ressources)."
  type        = string
  default     = "aisia-ovh"
}

variable "kube_version" {
  description = "Version Kubernetes MKS (vide = dernière version supportée par OVH)."
  type        = string
  default     = ""
}

variable "node_pool_autoscale" {
  description = "Activer l'autoscaling du node pool principal."
  type        = bool
  default     = false
}

variable "node_pool_min_nodes" {
  description = "Borne min du node pool si autoscale activé."
  type        = number
  default     = 1
}

variable "node_pool_max_nodes" {
  description = "Borne max du node pool si autoscale activé."
  type        = number
  default     = 3
}

variable "gpu_flavor" {
  description = "Flavor GPU OVH pour le pool d'inférence optionnel (t1-45, t2-45, a10-45)."
  type        = string
  default     = "t1-45"
}
