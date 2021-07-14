variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type = string
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_dc" {
  type = string
}

variable "vcenter_cluster" {
  type = string
}

variable "vcenter_datastore" {
  type = string
}

variable "vcenter_vmtemplate" {
  type = string
}

variable "vcenter_dvs" {
  type = string
}

variable "dc_networks" {
}

variable "vm_group_a" {
  type = map(object({
    name = string
    host_name = string
    num_cpus = number
    memory = number
    network_id = string  ## TBC
    domain = string
    ip_address = string
    mask_length = number
    ip_gateway = string
    dns_list = list(string) ##["64.104.123.245","171.70.168.183"]
  }))
}

variable "vm_group_b" {
  type = map(object({
    name = string
    host_name = string
    num_cpus = number
    memory = number
    network_id = string  ## TBC
    domain = string
    ip_address = string
    mask_length = number
    ip_gateway = string
    dns_list = list(string) ##["64.104.123.245","171.70.168.183"]
  }))
}
