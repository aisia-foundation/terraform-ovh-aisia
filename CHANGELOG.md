# Changelog — terraform-ovh-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

## [Unreleased] — correction pré-publication (2026-08-05)

### Fixed
- `image_tag` default et `VERSION` rétablis à `v6.12.80` (dernière version AISIA
  **certifiée LIVE**, DEPLOY-REPORT all-green — `project_facts.json:prod_live_version`).
  Le commit `5a5ab47fa` (bump global « prepare v6.12.81 ») avait fait passer le default
  à `v6.12.81`, alors que cette version est encore 🟡 **PRÉPARÉE** (code seulement — build
  multi-arch, déploiement et DEPLOY-REPORT tous PENDING, cf.
  `artifacts/prepare-v6.12.81.md`). Le commit `8d818d7826e` avait déjà corrigé le texte
  de description (« ex. v6.12.80 ») et les exemples, mais pas la valeur fonctionnelle
  `default`, laissant le module publié avec une incohérence interne (README annonçait
  v6.12.80 partout, le default réel déployait v6.12.81 — tag d'image potentiellement
  inexistant sur `registry.aisia.fr`). Gate `run_terraform_modules_gate` de nouveau vert
  (`VERSION == prod_live_version`). ⚠️ **registry.terraform.io a déjà ingéré une version
  `6.12.81` immuable avec le défaut fautif** — cette correction locale ne la retire pas ;
  elle doit être republiée dans une future version (ex. `6.12.82`, une fois qu'une release
  AISIA plus récente que 6.12.80 est certifiée LIVE, ou via un hotfix dédié) pour que les
  nouveaux `terraform init` récupèrent le default sûr.

## [6.12.80] — 2026-08-05

### Changed
- Sync `image_tag` default -> `v6.12.80` (release AISIA v6.12.80 LIVE, DEPLOY-REPORT
  all-green). Entrée rétroactive (bump réel non documenté au moment du commit
  `38058f47f`). Aucun changement fonctionnel des resources/variables/outputs.

## [6.12.79] — 2026-08-04

### Changed
- Sync `image_tag` default -> `v6.12.79` (bump AISIA patch, jamais déployé isolément —
  englobé par la chaîne v6.12.80). Entrée rétroactive (bump réel non documenté au moment
  du commit `0ac97ec9d`). Aucun changement fonctionnel des resources/variables/outputs.

## [6.12.78] — 2026-08-04

### Changed
- Sync `image_tag` default -> `v6.12.78` (release AISIA v6.12.78 LIVE). Rattrape aussi le
  saut `v6.12.77` (VERSION + image_tag bumpés en v6.12.77 par le commit `ad31e4ac8` sans
  entrée CHANGELOG, jamais publié au registry). Aucun changement fonctionnel des
  resources/variables/outputs (patch de synchronisation de version).

## [6.12.76] — 2026-08-02

### Changed
- Sync `image_tag` default -> `v6.12.76` (release AISIA v6.12.76 LIVE). Aucun changement
  fonctionnel des resources/variables/outputs (patch de synchronisation de version).

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
