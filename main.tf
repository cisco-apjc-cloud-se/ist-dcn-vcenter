terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "ist-challenge-dcn"
    }
  }
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

### Nested Modules ###

## DCNM Networking Module
module "dcnm" {
  source = "./modules/dcnm"

  dcnm_user     = var.dcnm_user
  dcnm_password = var.dcnm_password
  dcnm_url      = var.dcnm_url
  dc_fabric     = var.dc_fabric
  dc_switches   = var.dc_switches
  svr_cluster   = var.svr_cluster
  dc_vrf        = var.dc_vrf
  dc_networks   = var.dc_networks
}

## VMware vCenter Module
module "vcenter" {
  source = "./modules/vcenter"

  vcenter_user        = var.vcenter_user
  vcenter_password    = var.vcenter_password
  vcenter_server      = var.vcenter_server
  vcenter_dc          = var.vcenter_dc
  vcenter_cluster     = var.vcenter_cluster
  vcenter_datastore   = var.vcenter_datastore
  vcenter_vmtemplate  = var.vcenter_vmtemplate
  vcenter_dvs         = var.vcenter_dvs
  dc_networks         = module.dcnm.dc_networks
  vm_group_a          = var.vm_group_a
  vm_group_b          = var.vm_group_b

  # depends_on = [module.dcnm]
}

## Firewpower Management Center (FMC) Module
module "fmc" {
  source = "./modules/fmc"

  fmc_user      = var.fmc_user
  fmc_password  = var.fmc_password
  fmc_server    = var.fmc_server

  vm_group_a    = module.vcenter.vm_group_a
  vm_group_b    = module.vcenter.vm_group_b

  # depends_on = [module.vcenter]

}
