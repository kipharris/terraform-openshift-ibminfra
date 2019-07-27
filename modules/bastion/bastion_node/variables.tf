#################################################
# Common Variables
#################################################
variable "random_id" {}
variable "datacenter" {}
variable "domain" {}
variable "private_vlan_id" {}
variable "public_vlan_id" {}
variable "block_storage_type" {
    default = "Performance"
}
variable "hourly_billing" {}

#################################################
# Bastion node Variables
#################################################
variable "bastion_hostname" {
  default = "bastion"
}
variable "bastion_hostname_prefix" {
  default = "IBM"
}
variable "bastion_os_ref_code" {
  default = "REDHAT_7_64"
}

variable "bastion_ssh_key_id" {}
variable "bastion_private_ssh_key" {}
variable "bastion_ssh_key_file" {
  default     = ".bastionkey_id_rsa"
}
variable "bastion_ssh_label" {
  default = "ssh_key_rhopenshift"
}

variable "bastion_sg_name" {
  default     = "nc_ose_bastion_sg"
  description = "Name of the security group"
}

variable "bastion_sg_description" {
  default     = "bastion security grp for vms"
  description = "Description of the security group"
}

variable "node" {
    type = "map"
}

variable "ssh_username" {
    default = "root"
}

variable "disks" {
    type = "list"
}
