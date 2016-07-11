#! /usr/bin/env bash

# https://github.com/phase2/veewee-boxes/blob/9396f667ca34180dbe7424ee43fcd1aa34fe2cad/definitions/CentOS-6.0-x86_64-netboot/postinstall.sh
# http://bascht.com/tech/2013/10/07/building-a-vagrant-box-with-centos-64-and-vmware/
# https://github.com/shiguredo/packer-templates/tree/develop/centos-7.1

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Add a permanent datestamp for the image."
echo "$(date -I)" > /etc/vagrant_box_build_time
