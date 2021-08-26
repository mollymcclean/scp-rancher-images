#!/bin/bash
sudo yum install epel-release -y

# Install updated python2-cryptography and dependencies before ansible
# these are cherry-picked from the openstack repo upstream
sudo curl -sL https://www.centos.org/keys/RPM-GPG-KEY-CentOS-SIG-Cloud \
          -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud

RPMS_FROM_OPENSTACK=(
  python2-cffi-1.11.2-1.el7.x86_64.rpm
  python2-ipaddress-1.0.18-5.el7.noarch.rpm
  python2-cryptography-2.5-1.el7.x86_64.rpm
)

TMP_RPM_DIR=$(mktemp -d)
for RPM_NAME in "${RPMS_FROM_OPENSTACK[@]}"; do
  curl -sL "http://mirror.centos.org/centos-7/7/cloud/x86_64/openstack-train/Packages/p/${RPM_NAME}" \
       -o "${TMP_RPM_DIR}/${RPM_NAME}"
  sudo yum install "${TMP_RPM_DIR}/${RPM_NAME}" -y
  rm "${TMP_RPM_DIR}/${RPM_NAME}"
done
rmdir "${TMP_RPM_DIR}"

sudo yum install ansible -y
