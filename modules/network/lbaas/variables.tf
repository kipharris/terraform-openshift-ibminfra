variable "deployment" {
  default = ""
}

variable "infra_subnet" {}
variable "master_subnet" {}


variable "infra" {
    type = "map"
}
variable "master" {
    type = "map"
}

variable "infra_private_ip_addresses" {
    type = "list"
}

variable "master_private_ip_addresses" {
    type = "list"
}

variable "random_id" {
  default = ""
}
