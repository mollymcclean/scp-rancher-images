#!/bin/bash
rm -f /home/centos/*.iso

# Added the following to prevent an apt cache filling issue on rke02
sudo apt-cache clean
sudo rm -vf /var/lib/apt/lists/*
sudo apt-get update