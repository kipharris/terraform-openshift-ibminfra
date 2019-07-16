variable "ibm_sl_username" {}
variable "ibm_sl_api_key" {}

variable "datacenter" {
  default = "wdc04"
}

variable vlan_count {
  description = "Set to 0 if using existing and 1 if deploying a new VLAN"
  default = "1"
}
variable private_vlanid {
  description = "ID of existing private VLAN to connect VSIs"
  default = "2543851"
}

variable public_vlanid {
  description = "ID of existing public VLAN to connect VSIs"
  default = "2543849"
}

variable "master_count" {
  default = 1
}

variable "infra_count" {
  default = 1
}

variable "app_count" {
  default = 1
}

variable "storage_count" {
  description = "Set to 0 to configure openshift without glusterfs configuration and 3 or more to configure openshift with glusterfs"
  default = 0
}

variable "private_ssh_key" {
  default     = "~/.ssh/id_rsa"
}

variable "ssh-label" {
  default = "ssh_key_terraform"
}

variable "ssh_public_key" {
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "domain" {
  default = "ibm.com"
}

variable "hourly_billing" {
  default = "true"
}

variable "hostname_prefix" {
  default = "IBM-OCP"
}

variable "bastion_count" {
  default = 1
}

variable bastion_flavor {
  default = "B1_4X16X25"
}

variable master_flavor {
   default = "B1_4X16X25"
}

variable infra_flavor {
   default = "B1_4X16X25"
}

variable app_flavor {
   default = "B1_4X16X25"
}

variable storage_flavor {
   default = "B1_4X16X25"
}

variable "os_reference_code" {
    default = "REDHAT_7_64"
}
