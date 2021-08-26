#!/bin/bash

sudo apt install -y git ntpdate python3-cryptography python3-cffi
python3 -m pip install --upgrade pip setuptools
python3 -m pip install wheel

# Configure the python package installer to use a volume large enough to allow wheel packages to be built for the packages it installs.
sudo -H TMPDIR=/var/tmp/ python3 -m pip install ansible

python3 -m pip install pyvmomi