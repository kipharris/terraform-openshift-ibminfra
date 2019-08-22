# openshift MAIN.tf
# This file runs each of the modules

# Create a new ssh key
resource "ibm_compute_ssh_key" "ssh_key_ose" {
    label      = "${var.ssh-label}"
    notes      = "terraform SSH key for deploying OSE using Terraform"
    public_key = "${file(var.ssh_public_key)}"
}

resource "random_id" "tag" {
    byte_length = 4
}

module "vlan" {
    source        = "./modules/network/network_vlan"
    datacenter    = "${var.datacenter}"
    vlan_count    = "${var.vlan_count}"
}

module "lbaas" {
    source                      = "./modules/network/lbaas/"
    infra                       = "${var.infra}"
    infra_subnet                = "${module.infranode.subnet}"
    infra_private_ip_addresses  = "${module.infranode.private_ip}"
    master                      = "${var.master}"
    master_subnet               = "${module.masternode.subnet}"
    master_private_ip_addresses = "${module.masternode.private_ip}"
    random_id                   = "${random_id.tag.hex}"
}

module "publicsg" {
    source              = "./modules/infrastructure/node_sg"
    random_id           = "${random_id.tag.hex }"
    node_sg_name        = "ose_node_pub_sg"
    node_sg_description = "Public security group"
}

module "privatesg" {
    source              = "./modules/infrastructure/node_sg"
    random_id           = "${random_id.tag.hex }"
    node_sg_name        = "ose_node_prv_sg"
    node_sg_description = "Private security group"
}

#####################################################
# Create vm cluster for bastion
#####################################################
module "bastion" {
    source                  = "./modules/bastion/bastion_node"
    random_id               = "${random_id.tag.hex}"
    datacenter              = "${var.datacenter}"
    domain                  = "${var.domain}"
    private_vlan_id         = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id          = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    hourly_billing          = "${var.hourly_billing}"
    bastion_os_ref_code     = "${var.os_reference_code}"
    bastion_hostname_prefix = "${var.hostname_prefix}"
    bastion_ssh_key_id      = "${ibm_compute_ssh_key.ssh_key_ose.id}"
    bastion_private_ssh_key = "${var.private_ssh_key}"
    bastion_ssh_key_file    = "${var.bastion_ssh_key_file}"
    node                    = "${var.bastion}"
    disks                   = ["${var.bastion["disk_size"]}",]
}

#####################################################
# Create vm cluster for master
#####################################################
module "masternode" {
    source          = "./modules/infrastructure/node"
    hostname        = "master"
    random_id       = "${random_id.tag.hex}"
    datacenter      = "${var.datacenter}"
    domain          = "${var.domain}"
    private_vlan_id = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id  = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    hourly_billing  = "${var.hourly_billing}"
    os_ref_code     = "${var.os_reference_code}"
    hostname_prefix = "${var.hostname_prefix}"
    ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
    private_ssh_key = "${var.private_ssh_key}"
    node_pub_sg     = []
    node_prv_sg     = []
    node            = "${var.master}"
    disks           = ["${var.master["disk_size"]}", "${var.master["docker_disk_size"]}"]
}

#####################################################
# Create vm cluster for infra node
#####################################################
module "infranode" {
    source          = "./modules/infrastructure/node"
    hostname        = "infra"
    random_id       = "${random_id.tag.hex}"
    datacenter      = "${var.datacenter}"
    domain          = "${var.domain}"
    private_vlan_id = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
    public_vlan_id  = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
    os_ref_code     = "${var.os_reference_code}"
    hourly_billing  = "${var.hourly_billing}"
    hostname_prefix = "${var.hostname_prefix}"
    ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
    private_ssh_key = "${var.private_ssh_key}"
    node_pub_sg     = ["${module.publicsg.openshift_node_id}"]
    node_prv_sg     = ["${module.privatesg.openshift_node_id}"]
    node            = "${var.infra}"
    disks           = ["${var.infra["disk_size"]}", "${var.infra["docker_disk_size"]}"]
}

#####################################################
# Create vm cluster for app
#####################################################
module "workernode" {
  source          = "./modules/infrastructure/node"
  hostname        = "worker"
  random_id       = "${random_id.tag.hex}"
  datacenter      = "${var.datacenter}"
  domain          = "${var.domain}"
  private_vlan_id = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id  = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
  os_ref_code     = "${var.os_reference_code}"
  hourly_billing  = "${var.hourly_billing}"
  hostname_prefix = "${var.hostname_prefix}"
  ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
  private_ssh_key = "${var.private_ssh_key}"
  node_pub_sg     = ["${module.publicsg.openshift_node_id}"]
  node_prv_sg     = ["${module.privatesg.openshift_node_id}"]
  node            = "${var.worker}"
  disks           = ["${var.worker["disk_size"]}", "${var.worker["docker_disk_size"]}"]
}

#####################################################
# Create vm cluster for storage
#####################################################
module "storagenode" {
  source          = "./modules/infrastructure/node"
  hostname        = "storage"
  random_id       = "${random_id.tag.hex}"
  datacenter      = "${var.datacenter}"
  domain          = "${var.domain}"
  private_vlan_id = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id  = "${var.vlan_count == "1" ? "${join("", module.vlan.openshift_public_vlan_id)}" : var.public_vlanid}"
  os_ref_code     = "${var.os_reference_code}"
  hourly_billing  = "${var.hourly_billing}"
  hostname_prefix = "${var.hostname_prefix}"
  ssh_key_ids     = ["${ibm_compute_ssh_key.ssh_key_ose.id}", "${module.bastion.bastion_public_ssh_key}"]
  private_ssh_key = "${var.private_ssh_key}"
  node_pub_sg     = ["${module.publicsg.openshift_node_id}"]
  node_prv_sg     = ["${module.privatesg.openshift_node_id}"]
  node            = "${var.storage}"
  disks           = ["${var.storage["disk_size"]}", "${var.storage["docker_disk_size"]}", "${var.storage["gluster_disk_size"]}"]
}
