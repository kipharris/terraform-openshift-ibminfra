## Abstract
This article provide guidelines and considerations to provision the IBM Cloud Infrastructure to deploy a reference implementation of Red Hat® OpenShift Container Platform 3.

Refer to https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/02-Deploy-OpenShift.md to Deploy & Manage the Red Hat® OpenShift Container Platform on IBM Cloud.

## Summary
Red Hat® OpenShift Container Platform 3 is built around a core of application containers, with orchestration and management provided by Kubernetes, on a foundation of Atomic Host and Red Hat® Enterprise Linux. OpenShift Origin is the upstream community project that brings it all together along with extensions, to accelerate application development and deployment.
This reference environment provides an example of how OpenShift Container Platform 3 can be set up to take advantage of the native high availability capabilities of Kubernetes and IBM Cloud in order to create a highly available OpenShift Container Platform 3 environment. The configuration consists of
* one OpenShift Container Platform *masters*,
* three OpenShift Container Platform *infrastructure nodes*,
* two OpenShift Container Platform *application nodes*, and
* native IBM Cloud Infrastructure services.

# Phase 1: Provision Infrastructure

This is meant to be used as a module, make sure your module implementation sets all the variables in its terraform.tfvars file

```terraform
module "infrastructure" {
    source                = "git::ssh://git@github.ibm.com/ncolon/terraform-openshift-ibminfra.git"
    ibm_sl_username       = "${var.ibm_sl_username}"
    ibm_sl_api_key        = "${var.ibm_sl_api_key}"
    datacenter            = "${var.datacenter}"
    domain                = "${var.domain}"
    hostname_prefix       = "${var.hostname_prefix}"
    vlan_count            = "${var.vlan_count}"
    public_vlanid         = "${var.public_vlanid}"
    private_vlanid        = "${var.private_vlanid}"
    private_ssh_key       = "${var.private_ssh_key}"
    ssh_public_key        = "${var.public_ssh_key}"
    private_ssh_key       = "${var.private_ssh_key}"
    hourly_billing        = "${var.hourly_billing}"
    os_reference_code     = "${var.os_reference_code}"
    master                = "${var.master}"
    infra                 = "${var.infra}"
    worker                = "${var.worker}"
    storage               = "${var.storage}"
    bastion               = "${var.bastion}"
}
```

## Module Inputs Variables

|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|ibm_sl_username|User Name to login to IBM Cloud Infra (Softlayer)|-|
|ibm_sl_api_key|API Key (or password) to access IBM Cloud Infra (Softlayer). You can run `bluemix cs locations` to see a list of all data centers in your region.|-|
|datacenter|Data Center Location to deploy the OpenShift cluster.|wdc04|
|domain|Domain Name for the network interface used by VMs in the cluster.|ibm.com|
|hostname_prefix|Previx all hosts with this string|OCP-IBM|
|vlan_count       |Create a private & public VLAN, in your account, for deploying Red Hat OpenShift. Default '1'. Set to '0' if use existing vlans id and '1' to deploy new vlan|1|
|public_vlanid|Existing public vlan ID.    Ignored if `vlan_count = 0`|-|
|private_vlanid|Existing private vlan ID.  Ignored if `vlan_count = 0`|-|
|ssh_private_key|Path to SSH private key.|~/.ssh/id_rsa|
|ssh_public_key|Path to SSH public key.|~/.ssh/id_rsa.pub|
|ssh_label|An identifying label to assign to the SSH key.|ssh_key_openshift|
|hourly_billing|Set hourly billing on deployments|true|
|bastion_ssh_key_file|Path to Bastion SSH private key|~/.ssh/openshift_rsa|
|os_reference_code|OS to use to deploy OpenShift|REDHAT_7_64|
|bastion|A map variable for configuration of bastion node|See sample variables.tf|
|master|A map variable for configuration of master nodes|See sample variables.tf|
|infra|A map variable for configuration of infra nodes|See sample variables.tf|
|worker|A map variable for configuration of worker nodes|See sample variables.tf|
|storage|A map variable for configuration of storage nodes|See sample variables.tf|
|ssh_user|SSH username.  Must have passwordless sudo access|root|

## Module Output
|Variable Name|Description|Type
|-------------|-----------|-------------|
|domain|Domain Name for the network interface used by VMs in the cluster.|string|
|bastion_public_ip|IPv4 address of Bastion VM|string|
|bastion_private_ip|Private IPv4 address of Bastion VM|string|
|bastion_hostname|hostname of Bastion VM|string|
|master_private_ip|Provate IPv4 addresses of Master Node vms|list|
|master_hostname|hostnames of Master Node vms|list|
|master_public_ip|Public IPv4 addresses of Master Node vms|list|
|infra_private_ip|Provate IPv4 addresses of Infra Node vms|list|
|infra_hostname|hostnames of Infra Node vms|list|
|infra_public_ip|Public IPv4 addresses of Infra Node vms|list|
|app_private_ip|Provate IPv4 addresses of Application Node vms|list|
|app_hostname|hostnames of Application Node vms|list|
|app_public_ip|Public IPv4 addresses of Application Node vms|list|
|storage_private_ip|Provate IPv4 addresses of Storage Node vms|list|
|storage_hostname|hostnames of Master Storage vms|list|
|storage_public_ip|Public IPv4 addresses of Storage Node vms|list|
|public_master_vip|FQDN of cluster master loadbalancer|string|
|public_app_vip|FQDN of cluster apps loadbalancer|string|


The infrastructure is provisioned using the terraform modules with the following configuration:

## Nodes

Nodes are VM_instances that serve a specific purpose for OpenShift Container Platform

***Master nodes***

* Contains the API server, controller manager server and etcd.
* Maintains the clusters configuration, manages nodes in its OpenShift cluster
* Assigns pods to nodes and synchronizes pod information with service configuration
* Used to define routes, services, and volume claims for pods deployed within the OpenShift environment.

***Infrastructure nodes***

* Used for the router and registry pods
* Optionally, used for Kibana / Hawkular metrics
* Recommends S3 storage for the Docker registry, which allows for multiple pods to use the same storage

***Application nodes***

* Runs non-infrastructure based containers
* Use block storage to persist application data; assigned to the pod using a Persistent Volume Claim.
* Nodes with the label app are nodes used for end user Application pods.
* Set a configuration parameter 'defaultNodeSelector: "role=app" on the master /etc/origin/master/master-config.yaml to ensures that OpenShift Container Platform user containers, will be placed on the application nodes by default.

**Bastion node:**

* The Bastion server provides a secure way to limit SSH access to the environment.
* The master and node security groups only allow for SSH connectivity between nodes inside of the Security Group while the Bastion allows SSH access from everywhere.
* The Bastion host is the only ingress point for SSH in the cluster from external entities. When connecting to the OpenShift Container Platform infrastructure, the bastion forwards the request to the appropriate server. Connecting through the Bastion server requires specific SSH configuration.

**Storage nodes:**

* Used for deploying Container-Native Storage for OpenShift Container Platform. This deployment delivers a hyper-converged solution, where the storage containers that host Red Hat Gluster Storage co-reside with the compute containers and serve out storage from the hosts that have local or direct attached storage to the compute containers. Each storage node is mounted with 3 block storage devices.

**Compute node configurations**

|nodes | details | count |
|------|---------|-------|
| Bastion Nodes | os disk: 100Gb | 1 |
| Master Node  | os disk: 100Gb<br>docker_disk : 100Gb | var.master["nodes"] |
| Infra Nodes | os disk: 100Gb<br>docker_disk : 100Gb | var.infra["nodes"] |
| Worker Nodes | os disk: 100Gb<br>docker_disk : 100Gb | var.worker["nodes"] |
| Storage Nodes | os disk: 100Gb<br>docker_disk : 100Gb<br>gluster_disk : 250GB | var.storage["nodes"] |


## Security Group configurations
The following security group configuration assumes:
* All public traffic flow through the Internet Gateway
* The Bastion server provides a secure way to limit SSH access to the environment.
* The Bastion server has connectivity with both the Public VLAN & Private VLAN.
* All the OpenShift nodes (Master, Infra & App nodes) are connected with both the Public VLAN & Private VLAN.

|Group         |VLAN    |        |             |From     |To        |
|:-------------|:------:|:-------|:------------|:-------:|:--------:|
|ose_bastion_sg|Public  |Inbound | 22 / TCP    |Internet Gateway| - |
|ose_bastion_sg|Private |Outbound| All         | -       |All       |
|              |        |        |             |         |          |
|ose_master_sg |Private/Public |Inbound | 443 / TCP   |Internet Gateway| - |
|ose_master_sg |Private/Public  |Inbound | 80 / TCP    |Internet Gateway| - |
|ose_master_sg |Private/Public  |Inbound | 22 / TCP    |ose_bastion_sg | - |
|ose_master_sg |Private/Public  |Inbound | 443 / TCP   |All <br> (ose_master_sg & ose_node_sg) | - |
|ose_master_sg |Private/Public  |Inbound | 8053 / TCP  |All <br> (ose_node_sg) | - |
|ose_master_sg |Private/Public  |Inbound | 8053 / UDP  |All <br> (ose_node_sg) | - |
|ose_master_sg |Private/Public  |Outbound|  All        | -       | All      |
|ose_master_sg <br> (for etcd) |Private/Public  |Inbound | 2379 / TCP | All <br> (ose-master-sg) | - |
|ose_master_sg <br> (for etcd) |Private/Public  |Inbound | 2380 / TCP | All <br> (ose-master-sg) | - |
|              |        |        |             |         |          |
| ose_node_sg  |Private/Public  |Inbound | 443 / TCP   |All <br> (ose_bastion_sg) | - |
| ose_node_sg  |Private/Public  |Inbound | 22 / TCP    |All <br> (ose_bastion_sg) | - |
| ose_node_sg  |Private/Public  |Inbound | 10250 / TCP |All <br> (ose_master_sg & ose_node_sg) | - |
| ose_node_sg  |Private/Public  |Inbound | 4789 / UDP  |All <br> (ose_node_sg) | - |
| ose_node_sg  |Private/Public  |Outbound| All         | -       |      All |
|              |        |        |             |         |          |

## DNS Configuration

OpenShift Compute Platform requires a fully functional DNS server, and is properly configured wildcard DNS zone that resolves to the IP address of the OpenShift router. By default, *dnsmasq* is automatically configured on all masters and nodes to listen on port 53. The pods use the nodes as their DNS, and the nodes forward the requests.

You can use [terraform-openshift-dnscerts](https://github.ibm.com/ncolon/terraform-openshift-cloudflare) as a terraform module to provide DNS and certificates for your cluster

## Software Version Details
***RHEL OSEv3 Details***

|Software|Version|
|-------|--------|
|Red Hat® Enterprise Linux 7.4 x86_64| kernel-3.10.0.x|
|Atomic-OpenShift <br>{master/clients/node/sdn-ovs/utils} | 3.10.x.x |
|Docker|1.13.x|
|Ansible|2.7.x|

***Required Channels***

A subscription to the following channels is required in order to deploy this reference environment’s configuration.

You can use [terraform-openshift-rhnregister](https://github.ibm.com/ncolon/terraform-openshift-rhnregister) module to register your VMs with RHN

|Channel|Repository Name|
|-------|---------------|
|Red Hat® Enterprise Linux 7 Server (RPMs)|rhel-7-server-rpms|
|Red Hat® OpenShift Enterprise 3.10 (RPMs)|rhel-7-server-ose-3.10-rpms|
|Red Hat® Enterprise Linux 7 Server - Extras (RPMs)|rhel-7-server-extras-rpms|
|Red Hat® Enterprise Linux 7 Server - Fast Datapath (RPMs) |rhel-7-fast-datapath-rpms|


## Phase 2: Install OpenShift

Take a look at [terraform-openshfit-ivnentory](https://github.ibm.com/ncolon/terraform-openshift-inventory) to generate the ansible configuration file, and [terraform-openshift-deploy](https://github.ibm.com/ncolon/terraform-openshift-deploy) to kick off the installation.

----
