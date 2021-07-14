terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

### vSphere ESXi Provider
provider "vsphere" {
  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_url

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

### Existing Data Sources
data "vsphere_datacenter" "dc" {
  name          = var.vcenter_dc
}

data "vsphere_compute_cluster" "svr_cluster" {
  name          = var.vcenter_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.vcenter_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vcenter_vmtemplate
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vcenter_dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

### Build New Distribute Port Group(s)
resource "vsphere_distributed_port_group" "dpg" {
  for_each                        = var.dc_networks

  name                            = each.value.name
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = each.value.vlan_id
}

### Build VM Server Group A
resource "vsphere_virtual_machine" "grp-a" {
  for_each            = var.vm_group_a

  name                = each.value.name
  resource_pool_id    = data.vsphere_compute_cluster.svr_cluster.resource_pool_id
  datastore_id        = data.vsphere_datastore.ds.id

  num_cpus            = each.value.num_cpus  # 2
  memory              = each.value.memory
  guest_id            = data.vsphere_virtual_machine.template.guest_id
  scsi_type           = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    # network_id        = each.network_id #data.vsphere_network.aciNetworkEpg1.id
    network_id        = vsphere_distributed_port_group.dpg["$each.network"]
    adapter_type      = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label             = "disk0"
    size              = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub     = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned  = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid     = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name     = each.value.host_name
        domain        = each.value.domain
      }

      network_interface {
        ipv4_address  = each.value.ip_address
        ipv4_netmask  = each.value.mask_length
      }
      ipv4_gateway    = each.value.ip_gateway
      dns_server_list = each.value.dns_list #["64.104.123.245","171.70.168.183"]
    }
  }
}
