terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "ist-dcn-vcenter"
    }
  }
}
### Nested Modules ###

## DCNM Networking Module
module "dcnm" {
  source = "./modules/dcnm"

  dcnm_user       = var.dcnm_user
  dcnm_password   = var.dcnm_password
  dcnm_url        = var.dcnm_url
  dc_fabric       = var.dc_fabric
  dc_switches     = var.dc_switches
  svr_cluster     = var.svr_cluster
  dc_vrf          = var.dc_vrf
  dc_networks     = var.dc_networks
  vpc_interfaces  = var.vpc_interfaces
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
}
