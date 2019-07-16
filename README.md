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
    source               = "git::ssh://git@github.ibm.com/ncolon/terraform-openshift-ibminfra.git"
    ibm_sl_username      = "${var.ibm_sl_username}"
    ibm_sl_api_key       = "${var.ibm_sl_api_key}"
    datacenter           = "${var.datacenter}"
    vlan_count           = "${var.vlan_count}"
    private_vlanid       = "${var.private_vlanid}"
    public_vlanid        = "${var.public_vlanid}"
    master_count         = "${var.master_count}"
    infra_count          = "${var.infra_count}"
    app_count            = "${var.app_count}"
    storage_count        = "${var.storage_count}"
    private_ssh_key      = "${var.private_ssh_key}"
    ssh_label            = "${var.ssh_label}"
    ssh_public_key       = "${var.public_ssh_key}"
    bastion_ssh_key_file = "${var.bastion_ssh_key_file}"
    domain               = "${var.domain}"
    bastion_flavor       = "${var.bastion_flavor}"
    master_flavor        = "${var.master_flavor}"
    infra_flavor         = "${var.infra_flavor}"
    app_flavor           = "${var.app_flavor}"
    storage_flavor       = "${var.storage_flavor}"
    hostname_prefix      = "${var.hostname_prefix}"
    os_reference_code    = "${var.os_reference_code}"
    hourly_billing       = "${var.hourly_billing}"
}
```

## Module Inputs Variables

|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|ibm_sl_username|User Name to login to IBM Cloud Infra (Softlayer)|-|
|ibm_sl_api_key|API Key (or password) to access IBM Cloud Infra (Softlayer). You can run `bluemix cs locations` to see a list of all data centers in your region.|-|
|datacenter|Data Center Location to deploy the OpenShift cluster.|wdc04|
|vlan_count       |Create a private & public VLAN, in your account, for deploying Red Hat OpenShift. Default '1'. Set to '0' if use existing vlans id and '1' to deploy new vlan|1|
|private_vlanid|Existing private vlan ID.  Ignored if `vlan_count = 0`|-|
|public_vlanid|Existing public vlan ID.    Ignored if `vlan_count = 0`|-|
|master_count|Number of Master nodes for the cluster.|1|
|infra_count|Number of Infra nodes for the cluster.|1|
|app_count|Number of app nodes for the cluster. |1|
|storage_count|Number of storage nodes for the cluster. Set to 0 to configure openshift without glusterfs configuration and 3 or more to configure openshift with glusterfs |0|
|ssh_private_key|Path to SSH private key.|~/.ssh/id_rsa|
|ssh_label|An identifying label to assign to the SSH key.|ssh_key_openshift|
|ssh_public_key|Path to SSH public key.|~/.ssh/id_rsa.pub|
|bastion_ssh_key_file|SSH Key to use for Bastion VM.  Must not have a passphrase set on it|~/.ssh/id_rsa|
|domain|Domain Name for the network interface used by VMs in the cluster.|ibm.com|
|bastion_flavor|Flavor used to create Bastion VM|B1_4X16X100|
|master_flavor|Flavor used to create Master node|B1_4X16X100|
|infra_flavor|Flavor used to create Infra nodes|B1_4X16X100|
|app_flavor|Flavor used to create app nodes|B1_4X16X100|
|storage_flavor|Flavor used to create storage nodes|B1_4X16X100|
|hostname_prefix|Previx all hosts with this string|OCP-IBM|
|os_reference_code|OS to use to deploy OpenShift|REDHAT_7_64|
|hourly_billing|Set hourly billing on deployments|true|

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

**Storage nodes:**s

* Used for deploying Container-Native Storage for OpenShift Container Platform. This deployment delivers a hyper-converged solution, where the storage containers that host Red Hat Gluster Storage co-reside with the compute containers and serve out storage from the hosts that have local or direct attached storage to the compute containers. Each storage node is mounted with 3 block storage devices.

**Compute node configurations**

|nodes | flavor | details | count |
|------|--------|---------|-------|
|Master Node | B1_4X16X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | master_count |
| Infra Nodes | B1_4X16X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | infra_count |
| App Nodes | B1_4X16X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | app_count |
| Bastion Nodes | B1_4X16X100 | <ul><li>disk : 100GB </li><li>disk : 50GB </li><ul> | 1 |
| Storage Nodes | B1_4X16X100 | <ul><li>disk : 100GB </li><li>disk : 50GB </li><ul> | storage_count |


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

You can use [terraform-openshift-cloudflare](https://github.ibm.com/ncolon/terraform-openshift-cloudflare) as a terraform module to provide DNS for cluster and [terraform-openshift-letsenctypt](https://github.ibm.com/ncolon/terraform-openshift-letsencrypt) to provide certificates for your custom domain.

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
