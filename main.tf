# openshift MAIN.tf
# This file runs each of the modules

# Create a new ssh key
resource "ibm_compute_ssh_key" "ssh_key_ose" {
    label      = "${var.ssh-label}"
    notes      = "ncolon terraform SSH key for deploying OSE using Terraform"
    public_key = "${file(var.ssh_public_key)}"
}

resource "random_id" "ose_name" {
    byte_length = 5
}

module "vlan" {
    source        = "./modules/network/network_vlan"
    datacenter    = "${var.datacenter}"
    vlan_count    = "${var.vlan_count}"
}

module "lbaas" {
    source                      = "./modules/network/lbaas/"
    infra_count                 = "${var.infra_count}"
    infra_subnet                = "${module.infranode.subnet}"
    infra_private_ip_addresses  = "${module.infranode.infra_private_ip}"
    master_count                = "${var.master_count}"
    master_subnet               = "${module.masternode.subnet}"
    master_private_ip_addresses = "${module.masternode.master_private_ip}"
}

module "publicsg" {
    source              = "./modules/infrastructure/node_sg"
    random_id           = "${random_id.ose_name.hex }"
    node_sg_name        = "nc_ose_node_pub_sg"
    node_sg_description = "Public security group"
}

module "privatesg" {
    source              = "./modules/infrastructure/node_sg"
    random_id           = "${random_id.ose_name.hex }"
    node_sg_name        = "nc_ose_node_prv_sg"
    node_sg_description = "Private security group"
}

#####################################################
# Create vm cluster for bastion
#####################################################
module "bastion" {
    source                  = "./modules/bastion/bastion_node"
    random_id               = "${random_id.ose_name.hex}"
    datacenter              = "${var.datacenter}"
    domain                  = "${var.domain}"
    private_vlan_id         = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id          = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    hourly_billing          = "${var.hourly_billing}"
    bastion_os_ref_code     = "${var.os_reference_code}"
    bastion_hostname_prefix = "${var.hostname_prefix}"
    bastion_flavor          = "${var.bastion_flavor}"
    bastion_ssh_key_id      = "${ibm_compute_ssh_key.ssh_key_ose.id}"
    bastion_private_ssh_key = "${var.private_ssh_key}"
    bastion_ssh_key_file    = "${var.bastion_ssh_key_file}"
}

#####################################################
# Create vm cluster for master
#####################################################
module "masternode" {
    source                 = "./modules/infrastructure/master_node"
    random_id              = "${random_id.ose_name.hex}"
    datacenter             = "${var.datacenter}"
    domain                 = "${var.domain}"
    private_vlan_id        = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id         = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    hourly_billing         = "${var.hourly_billing}"
    master_os_ref_code     = "${var.os_reference_code}"
    master_node_count      = "${var.master_count}"
    master_hostname_prefix = "${var.hostname_prefix}"
    master_flavor          = "${var.master_flavor}"
    master_ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
    master_private_ssh_key = "${var.private_ssh_key}"
}

#####################################################
# Create vm cluster for infra node
#####################################################
module "infranode" {
    source                = "./modules/infrastructure/infra_node"
    random_id             = "${random_id.ose_name.hex}"
    datacenter            = "${var.datacenter}"
    domain                = "${var.domain}"
    private_vlan_id       = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id        = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    infra_os_ref_code     = "${var.os_reference_code}"
    hourly_billing        = "${var.hourly_billing}"
    infra_node_count      = "${var.infra_count}"
    infra_hostname_prefix = "${var.hostname_prefix}"
    infra_flavor          = "${var.infra_flavor}"
    infra_ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
    infra_private_ssh_key = "${var.private_ssh_key}"
    infra_node_pub_sg     = "${module.publicsg.openshift_node_id}"
    infra_node_prv_sg     = "${module.privatesg.openshift_node_id}"
}

#####################################################
# Create vm cluster for app
#####################################################
module "appnode" {
  source              = "./modules/infrastructure/app_node"
  random_id           = "${random_id.ose_name.hex}"
  datacenter          = "${var.datacenter}"
  domain              = "${var.domain}"
  private_vlan_id     = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id      = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
  app_os_ref_code     = "${var.os_reference_code}"
  hourly_billing      = "${var.hourly_billing}"
  app_node_count      = "${var.app_count}"
  app_hostname_prefix = "${var.hostname_prefix}"
  app_flavor          = "${var.app_flavor}"
  app_ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
  app_private_ssh_key = "${var.private_ssh_key}"
  app_node_pub_sg     = "${module.publicsg.openshift_node_id}"
  app_node_prv_sg     = "${module.privatesg.openshift_node_id}"
}

#####################################################
# Create vm cluster for storage
#####################################################
module "storagenode" {
  source                  = "modules/infrastructure/storage_node"
  random_id               = "${random_id.ose_name.hex}"
  datacenter              = "${var.datacenter}"
  domain                  = "${var.domain}"
  private_vlan_id         = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id          = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
  storage_os_ref_code     = "${var.os_reference_code}"
  hourly_billing          = "${var.hourly_billing}"
  storage_node_count      = "${var.storage_count}"
  storage_hostname_prefix = "${var.hostname_prefix}"
  storage_flavor          = "${var.storage_flavor}"
  storage_ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
  storage_private_ssh_key = "${var.private_ssh_key}"
  storage_node_pub_sg     = "${module.publicsg.openshift_node_id}"
  storage_node_prv_sg     = "${module.privatesg.openshift_node_id}"
}

# module "inventory" {
#   source             = "modules/inventory"
#   domain             = "${var.domain}"
#   bastion_private_ip = "${module.bastion.bastion_private_ip}"
#   master_private_ip  = "${module.masternode.master_private_ip}"
#   master_public_ip   = "${module.masternode.master_public_ip}"
#   infra_private_ip   = "${module.infranode.infra_private_ip}"
#   infra_public_ip    = "${module.infranode.infra_public_ip}"
#   app_private_ip     = "${module.appnode.app_private_ip}"
#   storage_private_ip = "${module.storagenode.storage_private_ip}"
#   master_host        = "${module.masternode.master_host}"
#   infra_host         = "${module.infranode.infra_host}"
#   app_host           = "${module.appnode.app_host}"
#   storage_host       = "${module.storagenode.storage_host}"
#   master_node_count  = "${var.master_count}"
#   infra_node_count   = "${var.infra_count}"
#   app_node_count     = "${var.app_count}"
#   storage_node_count = "${var.storage_count}"
#   ose_version        = "${var.ose_version}"
# }

#####################################################
# Deploy openshift
#####################################################
# module "openshift" {
#   source                  = "modules/openshift"
#   bastion_ip_address      = "${module.bastion.bastion_ip_address}"
#   bastion_private_ssh_key = "${var.private_ssh_key}"
#   master_private_ip       = "${module.masternode.master_private_ip}"
#   infra_private_ip        = "${module.infranode.infra_private_ip}"
#   app_private_ip          = "${module.appnode.app_private_ip}"
#   storage_private_ip      = "${module.storagenode.storage_private_ip}"
#   master_host             = "${module.masternode.master_host}"
#   infra_host              = "${module.infranode.infra_host}"
#   app_host                = "${module.appnode.app_host}"
#   storage_host            = "${module.storagenode.storage_host}"
#   domain                  = "${var.domain}"
# }

# module "rhn_register" {
#   source                  = "modules/infrastructure/rhn_register"
#   master_ip_address       = "${module.masternode.master_public_ip}"
#   master_private_ssh_key  = "${var.private_ssh_key}"
#   rhn_username            = "${var.rhn_username}"
#   rhn_password            = "${var.rhn_password}"
#   pool_id                 = "${var.pool_id}"
#   master_count            = "${var.master_count}"
#   infra_ip_address        = "${module.infranode.infra_public_ip}"
#   infra_private_ssh_key   = "${var.private_ssh_key}"
#   infra_count             = "${var.infra_count}"
#   app_ip_address          = "${module.appnode.app_public_ip}"
#   app_private_ssh_key     = "${var.private_ssh_key}"
#   app_count               = "${var.app_count}"
#   storage_ip_address      = "${module.storagenode.storage_public_ip}"
#   storage_private_ssh_key = "${var.private_ssh_key}"
#   storage_count           = "${var.storage_count}"
#   bastion_ip_address      = "${module.bastion.bastion_ip_address}"
#   bastion_private_ssh_key = "${var.private_ssh_key}"
# }
