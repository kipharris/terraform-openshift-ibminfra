#################################################
# Output Bastion Node
#################################################

output "domain" {
  value = "${module.bastion.bastion_domain}"
}

output "bastion_public_ip" {
  value = "${module.bastion.bastion_ip_address}"
}

output "bastion_private_ip" {
  value = "${module.bastion.bastion_private_ip}"
}

output "bastion_hostname" {
  value = "${module.bastion.bastion_hostname}"
}


#################################################
# Output Master Node
#################################################
output "master_private_ip" {
  value = "${module.masternode.private_ip}"
}

output "master_hostname" {
  value = "${module.masternode.host}"
}

output "master_public_ip" {
  value = "${module.masternode.public_ip}"
}


#################################################
# Output Infra Node
#################################################
output "infra_private_ip" {
  value = "${module.infranode.private_ip}"
}

output "infra_hostname" {
  value = "${module.infranode.host}"
}

output "infra_public_ip" {
  value = "${module.infranode.public_ip}"
}

#################################################
# Output App Node
#################################################
output "app_private_ip" {
  value = "${module.workernode.private_ip}"
}

output "app_hostname" {
  value = "${module.workernode.host}"
}

output "app_public_ip" {
  value = "${module.workernode.public_ip}"
}


#################################################
# Output Storage Node
#################################################
output "storage_private_ip" {
  value = "${module.storagenode.private_ip}"
}

output "storage_hostname" {
  value = "${module.storagenode.host}"
}

output "storage_public_ip" {
  value = "${module.storagenode.public_ip}"
}


#################################################
# Output LBaaS VIP
#################################################
output "public_master_vip" {
    value = "${module.lbaas.public_master_vip}"
}

output "public_app_vip" {
    value = "${module.lbaas.public_app_vip}"
}
