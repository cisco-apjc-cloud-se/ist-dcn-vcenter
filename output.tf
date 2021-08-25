output "vm_group_a" {
  value = module.vcenter.vm_group_a
  sensitive = true
}

output "vm_group_b" {
  value = module.vcenter.vm_group_b
  sensitive = true
}
