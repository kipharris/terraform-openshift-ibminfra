#################################################
# VM Instance for App Node on Private VLAN
#################################################
resource "ibm_compute_vm_instance" "node" {
  count                      = "${var.node["nodes"]}"
  os_reference_code          = "${var.os_ref_code}"
  hostname                   = "${var.hostname_prefix}-${var.random_id}-${var.hostname}-${count.index}"
  domain                     = "${var.domain}"
  datacenter                 = "${var.datacenter}"
  private_network_only       = "false"
  cores                      = "${var.node["vcpu"]}"
  memory                     = "${var.node["memory"]}"
  network_speed              = 1000
  local_disk                 = "false"
  disks                      = ["${var.node["disk_size"]}", "${var.node["docker_disk_size"]}", "${lookup(var.node, "gluster_disk_size", 0)}"]
  ssh_key_ids                = ["${var.ssh_key_ids}"]
  private_vlan_id            = "${var.private_vlan_id}"
  public_vlan_id             = "${var.public_vlan_id}"
  public_security_group_ids  = ["${var.node_pub_sg}"]
  private_security_group_ids = ["${var.node_prv_sg}"]
  hourly_billing             = "${var.hourly_billing}"
}
