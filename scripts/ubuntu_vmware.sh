#!/bin/bash
sudo apt -y install open-vm-tools git ntpdate
sudo apt -y install python3-pip python3-cryptography python3-cffi python-apt
sudo python3 -m pip install ansible
sudo python3 -m pip install --upgrade pip setuptools
sudo python3 -m pip install --upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git
sudo python3 -m pip install pyvmomi
# Ensure python3 is being used
sudo rm -f /usr/bin/python && sudo ln -s /usr/bin/python3 /usr/bin/python