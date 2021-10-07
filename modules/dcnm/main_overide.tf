## Build New L3 Networks ##

resource "dcnm_network" "net" {
  deploy          = each.value.deploy

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
}
