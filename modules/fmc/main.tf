terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      # version = "0.1.1"
    }
  }
}

provider "fmc" {
  # Configuration options
  fmc_username              = var.fmc_user
  fmc_password              = var.fmc_password
  fmc_host                  = var.fmc_server
  fmc_insecure_skip_verify  = true
}


### Build Host Objects per Server

resource "fmc_host_objects" "host-grp-a" {
  for_each = var.vm_group_a

  name = each.value.name
  value = each.value.ipv4_address
  description = format("Host %s - Managed by Terraform", each.value.name)
}

resource "fmc_host_objects" "host-grp-b" {
  for_each = var.vm_group_b

  name = each.value.name
  value = each.value.ipv4_address
  description = format("Host %s - Managed by Terraform", each.value.name)
}
