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
  for_each = toset(var.dc_switches)

  fabric_name = var.dc_fabric
  switch_name = each.key
}

## Load Existing DCNM VRF ###
data "dcnm_vrf" "dc_vrf" {
  fabric_name = var.dc_fabric
  name        = var.dc_vrf
}

## Build New L3 Networks ##

resource "dcnm_network" "tf-net-1" {
  for_each = toset(var.dc_networks)

  fabric_name     = var.dc_fabric
  name            = each.value.name
  network_id      = each.value.vni
  # display_name    = each.key.name
  description     = each.value.description
  vrf_name        = data.dcnm_vrf.dc_vrf.name
  vlan_id         = each.value.vlan
  vlan_name       = each.value.name
  ipv4_gateway    = each.value.ip_subnet
  # ipv6_gateway    = "2001:db8::1/64"
  # mtu             = 1500
  # secondary_gw_1  = "192.0.3.1/24"
  # secondary_gw_2  = "192.0.3.1/24"
  # arp_supp_flag   = true
  # ir_enable_flag  = false
  # mcast_group     = "239.1.2.2"
  # dhcp_1          = "1.2.3.4"
  # dhcp_2          = "1.2.3.5"
  # dhcp_vrf        = "VRF1012"
  # loopback_id     = 100
  # tag             = "1400"
  # rt_both_flag    = true
  # trm_enable_flag = true
  l3_gateway_flag = true
  deploy = false

  # attachments {
  #   serial_number = data.dcnm_inventory.DC3-N9K1.serial_number
  #   # vlan_id       = 2400
  #   attach        = true
  #   switch_ports = ["Ethernet1/1"]
  # }
  # attachments {
  #   serial_number = data.dcnm_inventory.DC3-N9K2.serial_number
  #   # vlan_id       = 2500
  #   attach        = true
  #   switch_ports = ["Ethernet1/1"]
  # }
}
