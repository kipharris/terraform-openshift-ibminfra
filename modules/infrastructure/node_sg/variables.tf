#Variable
variable "random_id" {}

//variable "openshift_gateway_public_address" {}

variable "node_sg_name" {

}

variable "node_sg_description" {

}

variable "master_sg_name" {
  default     = "nc_ose_master_sg"
  description = "Name of the security group"
}

variable "master_sg_description" {
  default     = "master security grp for vms"
  description = "Description of the security group"
}
