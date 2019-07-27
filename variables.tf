variable "ibm_sl_username" {}
variable "ibm_sl_api_key" {}

variable "datacenter" {
  default = "wdc04"
}

variable vlan_count {
  description = "Set to 0 if using existing and 1 if deploying a new VLAN"
  default = "1"
}
variable private_vlanid {
  description = "ID of existing private VLAN to connect VSIs"
  default = "2543851"
}

variable public_vlanid {
  description = "ID of existing public VLAN to connect VSIs"
  default = "2543849"
}

variable "private_ssh_key" {
  default     = "~/.ssh/id_rsa"
}

variable "ssh-label" {
  default = "ssh_key_terraform"
}

variable "ssh_public_key" {
  default     = "~/.ssh/id_rsa.pub"
}

variable "bastion_ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "domain" {
  default = "ibm.com"
}

variable "hourly_billing" {
  default = true
}

variable "hostname_prefix" {
  default = "IBM-OCP"
}

variable "bastion_count" {
  default = 1
}

variable "os_reference_code" {
    default = "REDHAT_7_64"
}


variable "bastion" {
    type = "map"

    default = {
        nodes  = "1"
        vcpu   = "2"
        memory = "8192"

        disk_size             = "100"      # Specify size or leave empty to use same size as template.
        datastore_disk_size   = "50"    # Specify size datastore directory, default 50.
        thin_provisioned      = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
        eagerly_scrub         = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
        keep_disk_on_remove   = "false" # Set to 'true' to not delete a disk on removal.

        start_iprange = "" # Leave blank for DHCP, else masters will be allocated range starting from this address
    }
}

variable "master" {
  type = "map"

    default = {
    nodes  = "1"
    vcpu   = "8"
    memory = "16384"

    disk_size             = "100"      # Specify size or leave empty to use same size as template.
    docker_disk_size      = "100"   # Specify size for docker disk, default 100.
    docker_disk_device    = ""
    datastore_disk_size   = "50"    # Specify size datastore directory, default 50.
    datastore_etcd_size   = "50"    # Specify size etcd datastore directory, default 50.
    thin_provisioned_etcd = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    thin_provisioned      = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub         = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove   = "false" # Set to 'true' to not delete a disk on removal.

    start_iprange = "" # Leave blank for DHCP, else masters will be allocated range starting from this address
  }
}

variable "infra" {
  type = "map"

    default = {
    nodes  = "1"
    vcpu   = "2"
    memory = "4096"

    disk_size           = "100"      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    docker_disk_device  = ""
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.

    start_iprange = "" # Leave blank for DHCP, else proxies will be allocated range starting from this address
  }
}

variable "worker" {
  type = "map"

    default = {
    nodes  = "1"
    vcpu   = "4"
    memory = "16384"

    disk_size           = "100"      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    docker_disk_device  = ""
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.

    start_iprange = "" # Leave blank for DHCP, else workers will be allocated range starting from this address
  }
}

variable "storage" {
  type = "map"

    default = {
    nodes  = "3"
    vcpu   = "8"
    memory = "16384"

    disk_size           = "100"      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    docker_disk_device  = ""
    log_disk_size       = "50"    # Specify size for /opt/ibm/cfc for log storage, default 50
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.

    start_iprange = "" # Leave blank for DHCP, else workers will be allocated range starting from this address
  }
}
