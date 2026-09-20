# AISIA — Terraform OVH — versions et providers (sprint v6.13.16)
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.50"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0"
    }
  }
}

provider "ovh" {
  endpoint = var.ovh_endpoint
}

# OVH expose OpenStack natif pour Public Cloud — token via OVH provider.
provider "openstack" {
  auth_url    = var.openstack_auth_url
  user_name   = var.openstack_user
  password    = var.openstack_password
  tenant_id   = var.project_id
  region      = var.region
  domain_name = "Default"
}
