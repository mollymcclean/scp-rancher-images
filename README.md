
# Securing Images

This repo contains the code to generate Images that can be used for vSphere or AWS Clusters, for the purpose of setting up nodes for a secure container platform in an air-gapped environment. Some of the code in this repository has been adapted from the Royal Navy linux-image-hardening repository https://bitbucket.org/automationlogic/linux-image-hardening/src/master/. 

## SCP Project

To use this repository for the Innovation Lab SCP project, first install packer and ansible on the machine you will be running the commands on.

The `aws_common_template.json` file was adapted from the `vsphere_packer_CIS_common_template.json` so that AMIs could be built on AWS. 

Export AWS credentials, or set up IAM role to be able to access EC2.
```
$ cd
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install packer -y
$ sudo apt update && sudo apt install ansible -y

$ cd
$ git clone https://github.com/mollymcclean/scp-rancher-images.git && cd scp-rancher-images

# To build Bastion image
$ packer build -on-error=ask -var-file=ubuntu_20.04_bastion_variables.json aws_common_template.json 

# To build RKE node image
$ packer build -on-error=ask -var-file=ubuntu_20.04_rke_variables.json aws_common_template.json 
```

After these commands have been run, you should be able to see the Ubuntu AMIs in your AWS console.


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
