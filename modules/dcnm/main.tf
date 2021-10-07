terraform {
  required_providers {
    dcnm = {
      source = "CiscoDevNet/dcnm"
      # version = "0.0.5"
    }
  }
}

## If using DCNM to assign VNIs use -parallelism=1

provider "dcnm" {
  username = var.dcnm_user
  password = var.dcnm_password
  url      = var.dcnm_url
  insecure = true
}

## Read Switch Inventory ##
data "dcnm_inventory" "dc_switches" {
  for_each = transpose(var.dc_switches)

  # First item in list of transposed keys
  fabric_name = each.value.0
  switch_name = each.key
}

## Load Existing DCNM VRF ###
data "dcnm_vrf" "dc_vrf" {
  fabric_name = var.dc_fabric
  name        = var.dc_vrf
}

## Build Local Dictionary of Switch Name -> Serial Number ###

locals {
  serial_numbers = {
      for switch in data.dcnm_inventory.dc_switches :
          switch.switch_name => switch.serial_number
  }
  merged = {
    for switch in var.svr_cluster :
        switch.name => {
          name = switch.name
          attach = switch.attach
          switch_ports = switch.switch_ports
          serial_number = lookup(local.serial_numbers, switch.name)
        }
  }
}

## Build VPC Interfaces ##
resource "dcnm_interface" "vpc" {
  for_each = var.vpc_interfaces

  policy                  = "int_vpc_trunk_host_11_1"
  type                    = "vpc"
  name                    = each.value.name
  fabric_name             = var.dc_fabric
  switch_name_1           = each.value.switch1.name
  switch_name_2           = each.value.switch2.name
  vpc_peer1_id            = each.value.vpc_id
  vpc_peer2_id            = each.value.vpc_id
  mode                    = "active"
  bpdu_gaurd_flag         = "true"
  mtu                     = "default"
  vpc_peer1_allowed_vlans = "none"
  vpc_peer2_allowed_vlans = "none"
  // vpc_peer1_access_vlans  = "10"
  // vpc_peer2_access_vlans  = "20"
  vpc_peer1_interface     = each.value.switch1.ports
  vpc_peer2_interface     = each.value.switch1.ports
}

## Build New L3 Networks ##

resource "dcnm_network" "net" {
  for_each = var.dc_networks

  fabric_name     = var.dc_fabric
  name            = each.value.name
  network_id      = each.value.vni_id
  display_name    = each.value.name
  description     = each.value.description
  vrf_name        = data.dcnm_vrf.dc_vrf.name
  vlan_id         = each.value.vlan_id
  vlan_name       = each.value.name
  ipv4_gateway    = each.value.ip_subnet
  # ipv6_gateway    = ""
  # mtu             = 1500
  # secondary_gw_1  = ""
  # secondary_gw_2  = ""
  # arp_supp_flag   = true
  # ir_enable_flag  = false
  # mcast_group     = "239.1.2.2"
  # dhcp_1          = ""
  # dhcp_2          = ""
  # dhcp_vrf        = ""
  # loopback_id     = 100
  # tag             = "12345"
  # rt_both_flag    = true
  # trm_enable_flag = true
  l3_gateway_flag = true
  deploy          = false #each.value.deploy

  dynamic "attachments" {
    # for_each = each.value.attachments
    for_each = local.merged
    content {
      serial_number = attachments.value["serial_number"]
      vlan_id = each.value.vlan_id
      attach = attachments.value["attach"]
      switch_ports = attachments.value["switch_ports"]
    }
  }

  depends_on = [dcnm_interface.vpc]
}
