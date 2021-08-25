terraform {
  required_providers {
    fmc = {
      source = "CiscoDevNet/fmc"
      # version = "0.1.1"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

### FMC Provider ###
provider "fmc" {
  # Configuration options
  fmc_username              = var.fmc_user
  fmc_password              = var.fmc_password
  fmc_host                  = var.fmc_server
  fmc_insecure_skip_verify  = true
}

### vSphere ESXi Provider
provider "vsphere" {
  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

### Existing Data Sources
data "vsphere_datacenter" "dc" {
  name          = var.vcenter_dc
}

## Read vCenter Inventory ##
data "vsphere_virtual_machine" "host-grp-a" {
  # for_each = transpose(var.dc_switches)
  count = 3
  name = format("%s-%d", "IST-SVR-A", (count.index + 1))
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "host-grp-b" {
  # for_each = transpose(var.dc_switches)
  count = 3
  name = format("%s-%d", "IST-SVR-B", (count.index + 1))
  datacenter_id = data.vsphere_datacenter.dc.id
}

# locals {
#   vm_group_a = {
#       for vm in var.vm_group_a :
#           vm.id => vm
#   }
#   vm_group_b = {
#       for vm in var.vm_group_b :
#           vm.id => vm
#   }
# }
#
# ### Build Host Objects per Server
#
# resource "fmc_host_objects" "host-grp-a" {
#   for_each = local.vm_group_a
#
#   name = each.value.name
#   value = each.value.clone.0.customize.0.network_interface.0.ipv4_address
#   description = format("Host %s - Managed by Terraform", each.value.name)
# }
#
# resource "fmc_host_objects" "host-grp-b" {
#   for_each = local.vm_group_b
#
#   name = each.value.name
#   value = each.value.clone.0.customize.0.network_interface.0.ipv4_address
#   description = format("Host %s - Managed by Terraform", each.value.name)
# }
#
#
# resource "fmc_network_group_objects" "host-grp-a" {
#   name          = "IST-HOST-GROUP-A"
#   description   = "Host Server Group A - Terraform Managed"
#
#   dynamic "objects" {
#     for_each = fmc_host_objects.host-grp-a
#     content {
#       id = objects.value["id"]
#       type = objects.value["type"]
#     }
#   }
# }
#
# resource "fmc_network_group_objects" "host-grp-b" {
#   name          = "IST-HOST-GROUP-B"
#   description   = "Host Server Group B - Terraform Managed"
#
#   dynamic "objects" {
#     for_each = fmc_host_objects.host-grp-b
#     content {
#       id = objects.value["id"]
#       type = objects.value["type"]
#     }
#   }
# }
