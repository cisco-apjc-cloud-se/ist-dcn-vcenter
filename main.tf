terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "ist-challenge-dcn"
    }
  }
}

### Nested Modules ###

## DCNM Networking Module
module "dcnm" {
  source = "./modules/dcnm"
  # dc_fabric = var.dc_fabric
  # dc_switches = var.dc_switches
  # dc_vrf = var.dc_vrf
  # dc_networks = var.dc_networks
}

## VMware Module
# module "esxi" {
#   source = "./modules/esxi"
#   app1-web-net  = module.aci.app1-web-net
#   app1-db-net   = module.aci.app1-db-net
#   app2-web-net  = module.aci.app2-web-net
#   app2-db-net   = module.aci.app2-db-net
#   depends_on = [module.aci]
# }

# output "diskSize" {
#   value = module.esxi.diskSize
# }
