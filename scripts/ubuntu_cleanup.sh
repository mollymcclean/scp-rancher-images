#!/bin/bash
sudo -H python3 -m pip uninstall ansible -y
rm -f /home/ubuntu/*.iso

cat << EOF > /tmp/rc_local
#!/bin/bash

test -f /etc/ssh_host_rsa_key || dpkg-reconfigure openssh-server
EOF

sudo mv /tmp/rc_local /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod +x /etc/rc.local

sudo rm -f /etc/ssh/ssh_host*key*

# Null-out the mchine-id file so the dhcp server assigns a unique IP
sudo rm -f /etc/machine-id
sudo touch /etc/machine-id
sudo chmod 444 /etc/machine-id
