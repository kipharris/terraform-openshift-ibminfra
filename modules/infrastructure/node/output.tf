#################################################
# Output
#################################################
output "ip_address_id" {
  value = "${ibm_compute_vm_instance.node.*.ip_address_id_private}"
}

output "public_ip" {
  value = "${ibm_compute_vm_instance.node.*.ipv4_address}"
}

output "private_ip" {
  value = "${ibm_compute_vm_instance.node.*.ipv4_address_private}"
}

output "host" {
  value = "${ibm_compute_vm_instance.node.*.hostname}"
}

output "subnet" {
    value = "${ibm_compute_vm_instance.node.0.private_subnet_id}"
}
