output "public_master_vip" {
    value = "${ibm_lbaas.master-lbaas.vip}"
}

output "public_app_vip" {
    value = "${ibm_lbaas.app-lbaas.vip}"
}
