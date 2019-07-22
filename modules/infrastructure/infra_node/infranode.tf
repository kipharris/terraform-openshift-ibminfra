#################################################
# VM Instance Setup for Infra Nodes
#################################################
resource "ibm_compute_vm_instance" "infranode" {
  count                      = "${var.infra_node_count}"
  os_reference_code          = "${var.infra_os_ref_code}"
  hostname                   = "${var.infra_hostname_prefix}-${var.random_id}-${var.infra_hostname}-${count.index}"
  domain                     = "${var.domain}"
  datacenter                 = "${var.datacenter}"
  private_network_only       = "false"
  cores                      = 4
  memory                     = 16384
  network_speed              = 1000
  local_disk                 = "false"
  disks                      = ["100", "100", "20"]
  ssh_key_ids                = ["${var.infra_ssh_key_ids}"]
  private_vlan_id            = "${var.private_vlan_id}"
  public_vlan_id             = "${var.public_vlan_id}"
  public_security_group_ids  = ["${var.infra_node_pub_sg}"]
  private_security_group_ids = ["${var.infra_node_prv_sg}"]
  hourly_billing             = "${var.hourly_billing}"
}
