variable "deployment" {
  default = ""
}

variable "infra_subnet" {}
variable "master_subnet" {}


variable "infra_count" {}
variable "master_count" {}

variable "infra_private_ip_addresses" {
    type = "list"
}

variable "master_private_ip_addresses" {
    type = "list"
}
