###############################################################################
# terraform-ovh-aisia — contraintes providers (module publiable, sans bloc provider).
# Le consumer configure `provider "ovh" { endpoint = "ovh-eu" ... }` dans son root module.
###############################################################################
terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
