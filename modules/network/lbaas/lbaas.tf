resource "ibm_lbaas" "app-lbaas" {
    name        = "ncolon-ocp-app-${var.random_id}"
    description = "load balancer for OSE apps"

    subnets     = ["${var.infra_subnet}"]
    protocols   = [{
        frontend_protocol = "TCP"
        frontend_port = 443

        backend_protocol = "TCP"
        backend_port = 443
    },{
        frontend_protocol = "TCP"
        frontend_port = 80

        backend_protocol = "TCP"
        backend_port = 80
    }]
}

resource "ibm_lbaas_server_instance_attachment" "infra" {
    count              = "${var.infra["nodes"]}"
    private_ip_address = "${var.infra_private_ip_addresses[count.index]}"
    lbaas_id           = "${ibm_lbaas.app-lbaas.id}"
}


resource "ibm_lbaas" "master-lbaas" {
    name        = "ncolon-ocp-master-${var.random_id}"
    description = "load balancer for OSE master"

    subnets     = ["${var.master_subnet}"]
    protocols   = [{
        frontend_protocol = "TCP"
        frontend_port = 443

        backend_protocol = "TCP"
        backend_port = 443
    },{
        frontend_protocol = "TCP"
        frontend_port = 5443

        backend_protocol = "TCP"
        backend_port = 5443
    },{
        frontend_protocol = "TCP"
        frontend_port = 3443

        backend_protocol = "TCP"
        backend_port = 3443
    },{
        frontend_protocol = "TCP"
        frontend_port = 9443

        backend_protocol = "TCP"
        backend_port = 9443
    }]
}

resource "ibm_lbaas_server_instance_attachment" "ose_master" {
    count              = "${var.master["nodes"]}"
    private_ip_address = "${var.master_private_ip_addresses[count.index]}"
    lbaas_id           = "${ibm_lbaas.master-lbaas.id}"
}
