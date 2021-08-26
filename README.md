
# Securing Images

This repo contains the code to generate Images that can be used for vSphere or AWS Clusters, for the purpose of setting up nodes for a secure container platform in an air-gapped environment.

## SCP Project

To use this repository for the Innovation Lab SCP project, first install packer and ansible.

Export AWS credentials, or set up IAM role to be able to access EC2.

To build the Bastion image :
`packer build -on-error=ask -var-file=ubuntu_20.04_bastion_variables.json aws_packer_common_template.json`

To build the RKE node image :
`packer build -on-error=ask -var-file=ubuntu_20.04_rke_variables.json aws_packer_common_template.json `

NOTE :: The image hardening playbook was removed from aws_common_template.json. To include it, the following code should be placed after the shell command to install ansible.

```
{
  "playbook_dir": "ansible-provisioner",
  "playbook_file": "ansible-provisioner/ubuntu_CIS_hardening.yml",
  "role_paths": [
    "ansible-provisioner/roles"
  ],
  "type": "ansible-local"
},
```

### vCenter

If building vSphere images, need to edit the following variables in vsphere_packer_CIS_common_template.json and vsphere_packer_CIS_managed_worker_node_template.json files to match the vCenter system.

```
"type":
"datacenter":
"vcenter_server":
"username":
"password":
"cluster":
"datastore":
```

## RHEL/Centos7 CIS Images

Download the Ansible CIS hardening code from:

[Location 1] https://github.com/MindPointGroup/RHEL7-CIS.git

or

[Location 2] https://galaxy.ansible.com/MindPointGroup/RHEL7-CIS

## Ubuntu CIS Images

Download the Ansible CIS hardening code from:

[CIS Hardeniing] https://github.com/florianutz/ubuntu2004_cis

Add the following to the ansible-provisioner/requirements.yml:

- src: https://github.com/florianutz/ubuntu2004_cis.git

## vSphere 7 Cluster Node Preparation

[See] https://www.packer.io/docs/builders/vmware/vsphere-iso

Currently this repo can build CIS secured Ubuntu 18.04 and 20.04 Hardened images. This is the prefered method of image creation as it allows images to be built against a vSphere cluster and makes the resulting image available as a template in the Templates folder. VMware Player is not required. It uses the official vCenter API, does not require ESXi host modifications and is supported for vSphere version 6.5 and greater.

The Ubuntu image is currently sourced from cdimage.ubuntu.com.

When Packer uses the vsphere-iso builder type, it opens a http port in the range 8000 -- 9000 to the VM. You may need to add firewall rules to make these ports available between the build server and the vSphere cluster.

### How to run this repo

Ensure you have packer installed on your system. [See] https://www.packer.io/intro/getting-started/install.html

Edit the vsphere_packer_CIS_common_template.json file and set the parameters as required.

#### VMware Build

Build takes approximately 30 minutes to complete and creates a template in the Templates folder on the vCenter server.

$ packer build -force -on-error=ask -var-file=ubuntu_18.04_bastion_variables.json vsphere_packer_CIS_common_template.json
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_rke_variables.json vsphere_packer_CIS_common_template.json
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_harbor_with_redis_variables.json vsphere_packer_CIS_common_template.json
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_postgres_variables.json vsphere_packer_CIS_common_template.json
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_nfs_server_variables.json vsphere_packer_CIS_common_template.json

Controller and ETCD managed cluster image:
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_rancher_variables.json vsphere_packer_CIS_common_template.json

Worker node managed cluster image (includes 100GB second disk mounted as /var/lib/longhorn & formatted as XFS)
$ packer build -force -on-error=ask -var-file=ubuntu_18.04_managed_worker_node_variables.json vsphere_packer_CIS_managed_worker_node_template.json



## ESXi 5.5 Node Preparation

[See] https://blog.ukotic.net/2019/03/05/configuring-esxi-prerequisites-for-packer/

### Enable GuestIPHack

The GuestIPHack is required to allow Packer to infer the IP address of the Guest VM via ARP Packet Inspection. Enable it by running the following commands on the ESXi node used to build the OVF files:

1. ssh to the ESXi node (you'll need to enable the ESXi shell on the node)
2. Execute the following command:

esxcli system settings advanced set -o /Net/GuestIPHack -i 1

### Open VNC firewall ports on ESXi

[See] esxcli firewall commands: https://kb.vmware.com/s/article/2005284

Packer uses VNC to issue boot commands to the Guest VM. The default range is 5900 -- 6000, 5900 being the default for VNC. If you’re performing multiple builds or the port is in use Packer will cycle through the range until it finds an available one. The ports can be opened in two ways:

Option 1 - Set the default firewall action to PASS

~# esxcli network firewall set --default-action true

Option 2 - Edit the firewall rules file

Run the following commands to modify and save the firewall service.xml file:

~# chmod 644 /etc/vmware/firewall/service.xml
~# chmod +t /etc/vmware/firewall/service.xml
~# vi /etc/vmware/firewall/service.xml

Scroll to the very end of the file and just above the last line /ConfigRoot and insert the following below it:

<service id="1000">
  <id>packer-vnc-custom</id>
  <rule id="0000">
    <direction>inbound</direction>
    <protocol>tcp</protocol>
    <porttype>dst</porttype>
    <port>
      <begin>5900</begin>
      <end>6000</end>
    </port>
  </rule>
  <enabled>true</enabled>
  <required>true</required>
</service>

Press ESC and type in :wq! to save and quit out of the file.

Restore the permissions of the service.xml file and restart the firewall.
~# chmod 444 /etc/vmware/firewall/service.xml
~# esxcli network firewall refresh

Use the following commands on the host to confirm and see the entire range of ports set:
~# esxcli network firewall ruleset list
~# esxcli network firewall ruleset rule list

### Image Creation using ESXi 5.5

Currently this repo can build CIS secured Ubuntu 18.04 and 20.04 Hardened images

The Ubuntu image is currently sourced from cdimage.ubuntu.com.

### How to run this repo

Ensure you have packer installed on your system. [See] https://www.packer.io/intro/getting-started/install.html

Edit the packer_CIS_common_template.json file and set the following parameters as required:

      "insecure_connection": true,
      "type": "vsphere-iso",
      "datacenter": "SCP_Datacenter",
      "vcenter_server": "192.168.146.70",
      "username": "administrator@rnvcentre.local",
      "password": "Password123456!",
      "cluster": SCP_Cluster",
      "datastore": "vsanDatastore",
      "network_adapters": [
        {
          "network": "VM Network",
          "network_card": "vmxnet3"
        }
      ],
      "guest_os_type": "ubuntu64Guest",
      "host": "192.168.146.71",
      "http_directory": "src",
      "iso_checksum": "{{user `iso_checksum`}}",
      "iso_urls": "{{user `iso_urls`}}",
      "resource_pool": "build_pool",
      "shutdown_command": "sudo /sbin/halt -p",
      "ssh_handshake_attempts": "20",
      "ssh_pty": true,
      "ssh_timeout": "20m",
      "ssh_username": "ubuntu",
      "ssh_password": "mpxPIkhhZWINu5kmwQSxpEyqMCVutPOpKNc39adiOV0=",
      "convert_to_template": true,
      "folder": "Templates",
      "CPUs": 2,
      "RAM": 2048,
      "RAM_reserve_all": true,
      "storage": [
        {
          "disk_size": "51200",
          "disk_thin_provisioned": true
        }
      ],

#### VMware Template Build

Build takes approximately 30 minutes to complete and creates an ova in the output-vmware-iso sub-directory of this repository.

$ packer build -on-error=ask -var-file=ubuntu_18.04_bastion_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_rke_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_harbor_with_redis_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_postgres_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_vault_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_rancher_variables.json packer_CIS_common_template.json
$ packer build -on-error=ask -var-file=ubuntu_18.04_managed_worker_node_variables.json vsphere_packer_CIS_managed_worker_node_template.json
