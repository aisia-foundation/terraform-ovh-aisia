# terraform-ovh-aisia

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-terraform-ovh-aisia-7B42BC?logo=terraform)](https://registry.terraform.io/modules/aisia-foundation/aisia/ovh/latest) [![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-brightgreen.svg)](LICENSE)

Module Terraform publié sur le registry HCP privé AISIA + public `aisia-foundation` sur registry.terraform.io.

Provisionne un substrat **OVHcloud Managed Kubernetes Service (MKS)** (L1) pour héberger la
plateforme AISIA. L'application AISIA est ensuite déployée via le module
[terraform-aisia-cluster](../terraform-aisia-cluster/) qui consomme les outputs de ce module.

**Version** : 1.0.0 — Voir [CHANGELOG](CHANGELOG.md)

## Architecture

```
Projet Public Cloud OVH (service_name)
  └─ MKS Cluster (update_policy=MINIMAL_DOWNTIME)
       ├─ Node pool "primary" (b2-7 × node_count, autoscale optionnel)
       └─ Node pool "gpu"    (t1-45, autoscale 0→4, optionnel — gpu_enabled=true)
```

## Usage

```hcl
provider "ovh" {
  endpoint = "ovh-eu"
  # Credentials via env vars OVH_APPLICATION_KEY / OVH_APPLICATION_SECRET / OVH_CONSUMER_KEY
}

provider "kubernetes" {
  host                   = module.aisia_ovh_k8s.cluster_endpoint
  client_certificate     = module.aisia_ovh_k8s.client_certificate
  client_key             = module.aisia_ovh_k8s.client_key
  cluster_ca_certificate = module.aisia_ovh_k8s.cluster_ca_certificate
}

# L1 — substrat MKS
module "aisia_ovh_k8s" {
  source  = "app.terraform.io/AISIA/aisia/ovh"
  version = "~> 1.0"

  org_id       = "acme"
  service_key  = "C1"
  service_name = "your-ovh-project-id"
  image_tag    = "v6.9.61"
  tier         = "saas"

  region       = "GRA11"
  node_count   = 2
}

# L2 — déploiement AISIA
module "aisia_app" {
  source  = "app.terraform.io/AISIA/aisia-cluster/kubernetes"
  version = "~> 1.0"

  image_tag = "v6.9.61"
  tier      = "saas"
  domain    = "acme.aisia.fr"
}
```

## Inputs

| Nom | Description | Type | Défaut | Requis |
|-----|-------------|------|--------|--------|
| `org_id` | Identifiant de l'organisation AISIA (tenant) | `string` | — | oui |
| `service_key` | Brique déployée (C1..C11) | `string` | — | oui |
| `service_name` | ID du projet OVH Public Cloud | `string` | — | oui |
| `runtime_kind` | edge \| compute \| compute-gpu \| data \| ops \| security | `string` | `"compute"` | non |
| `substrate` | Substrat cible (ce module = k8s) | `string` | `"k8s"` | non |
| `profile` | Profil de dimensionnement (S \| M \| L \| XL) | `string` | `"S"` | non |
| `node_count` | Nombre de nœuds du pool principal | `number` | `1` | non |
| `instance_flavor` | Flavor OVH MKS (b2-7 = 2 vCPU / 7 GB) | `string` | `"b2-7"` | non |
| `image_registry` | Registry des images AISIA | `string` | `"registry.aisia.fr"` | non |
| `image_tag` | Tag d'image AISIA à déployer | `string` | `"v6.9.61"` | non |
| `domain` | Domaine custom (vide = *.aisia.fr) | `string` | `""` | non |
| `tier` | Offre tarifaire (saas \| baas \| paas) | `string` | `"saas"` | non |
| `gpu_enabled` | Provisionner un node pool GPU | `bool` | `false` | non |
| `region` | Région OVH MKS (GRA11, SBG5, EU-WEST-PAR) | `string` | `"GRA11"` | non |
| `cluster_name` | Préfixe du cluster MKS | `string` | `"aisia-ovh"` | non |
| `kube_version` | Version Kubernetes MKS (vide = dernière OVH) | `string` | `""` | non |
| `node_pool_autoscale` | Activer l'autoscaling du pool principal | `bool` | `false` | non |
| `node_pool_min_nodes` | Min nœuds (autoscale actif) | `number` | `1` | non |
| `node_pool_max_nodes` | Max nœuds (autoscale actif) | `number` | `3` | non |
| `gpu_flavor` | Flavor GPU OVH (t1-45, t2-45, a10-45) | `string` | `"t1-45"` | non |

## Outputs

| Nom | Description | Sensible |
|-----|-------------|----------|
| `cluster_id` | ID du cluster MKS OVH | non |
| `cluster_name` | Nom du cluster MKS | non |
| `cluster_status` | Statut du cluster (READY après convergence) | non |
| `cluster_endpoint` | Endpoint API server MKS | oui |
| `client_certificate` | Certificat client MKS (PEM) | oui |
| `client_key` | Clé client MKS (PEM) | oui |
| `cluster_ca_certificate` | CA certificate MKS (PEM) | oui |
| `kubeconfig` | Kubeconfig complet | oui |
| `kubeconfig_command` | Commande pour exporter le kubeconfig | non |
| `region` | Région OVH du déploiement | non |
| `node_count` | Nœuds désirés sur le pool principal | non |
| `gpu_pool_enabled` | Node pool GPU provisionné ? | non |

## Prérequis

- OpenTofu >= 1.5 ou Terraform >= 1.5
- Provider `ovh/ovh ~> 0.50`
- Credentials OVH via env vars `OVH_APPLICATION_KEY` / `OVH_APPLICATION_SECRET` / `OVH_CONSUMER_KEY`
- Projet OVH Public Cloud existant (`service_name`)
- Module `terraform-aisia-cluster ~> 1.0` pour déployer l'application

## Licence

[Mozilla Public License 2.0](LICENSE) — Copyright (c) 2026 AISIA (Sébastien Lambert).
