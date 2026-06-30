# Changelog — terraform-ovh-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

## [1.0.0] — 2026-06-29

### Added
- Module initial publiable (HCP private registry) : substrat Kubernetes OVHcloud Managed
  Kubernetes Service (MKS).
- **Cluster** : `ovh_cloud_project_kube` (control plane managé, mise à jour `MINIMAL_DOWNTIME`).
- **Node pools** : pool principal (b2-7 par défaut, autoscale optionnel) + pool GPU optionnel
  (t1-45 par défaut, taint `nvidia.com/gpu=present:NoSchedule`, autoscale 0→4).
- **Parité dual-substrate** : pendant K8s du module OVH/Swarm interne. Contrat normalisé v6.9.61.
- Outputs normalisés : `cluster_id`, `cluster_name`, `cluster_endpoint` (sensitive), `kubeconfig`
  (sensitive), `kubeconfig_command`, `region`, `node_count`.
- Chaîner avec `terraform-aisia-cluster` pour déployer la stack AISIA sur le substrat MKS.
- Auth OVH : `provider "ovh"` configuré dans le root module du consumer (jamais de creds en dur).
- README (Inputs/Outputs/Usage), LICENSE MPL-2.0, `versions.tf` (TF >= 1.5, ovh ~> 0.50).
- `examples/basic` : usage minimal validable (`tofu validate`).
