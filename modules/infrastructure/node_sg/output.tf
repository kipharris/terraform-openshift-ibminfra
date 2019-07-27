# Outputs
output "openshift_node_id" {
  value = "${ibm_security_group.openshift-node.id}"
}

output "openshift_master_id" {
  value = "${ibm_security_group.openshift-master.id}"
}
