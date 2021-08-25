# output "vm_group_a" {
#   value = vsphere_virtual_machine.grp-a
# }
#
# output "vm_group_b" {
#   value = vsphere_virtual_machine.grp-b
# }

#
# locals {
#   vm_group_a = {
#       for vm in module.vcenter.vm_group_a :
#           vm.id => vm
#   }
#   vm_group_b = {
#       for vm in module.vcenter.vm_group_b :
#           vm.id => vm
#   }
# }


locals {
  vm_group_a = {
      for vm in vsphere_virtual_machine.grp-a :
          vm.id => vm
  }
  vm_group_b = {
      for vm in vsphere_virtual_machine.grp-b :
          vm.id => vm
  }
}

output "vm_group_a" {
  value = local.vm_group_a
}

output "vm_group_b" {
  value = local.vm_group_b
}
