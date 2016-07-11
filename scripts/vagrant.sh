#! /usr/bin/env bash

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Comment out requiretty in /etc/sudoers"
# This change is important because it allows ssh to send remote commands using sudo. Without this change vagrant
# will be unable to apply changes (such as configuring additional NICs) at startup:
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

e "Installing Vagrant user and keys"
useradd vagrant
mkdir -m 0700 -p /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

e "Allow user Vagrant to use sudo without entering a password"
usermod -G wheel vagrant > /dev/null 2>&1
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
