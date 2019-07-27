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
# App Node Variables
#################################################
variable "hostname" {}
variable "hostname_prefix" {
  default = "IBM"
}
variable "os_ref_code" {
  default = "REDHAT_7_64"
}

variable "node_pub_sg" {
    type = "list"
}

variable "node_prv_sg" {
    type = "list"
}

variable "ssh_key_ids" {
  type = "list"
}

variable "private_ssh_key" {}
variable "node" {
    type = "map"
}

variable "ssh_username" {
  default = "root"
}

variable "disks" {
    type = "list"
}
