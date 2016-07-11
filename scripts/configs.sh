#! /usr/bin/env bash

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Add a permanent datestamp for the image."
echo "$(date -I)" > /etc/vagrant_box_build_time

e "Disable SELinux by default."
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux && \
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config && \
setenforce 0

e "Configure NTP"
chkconfig ntpd on
service ntpd stop
ntpdate time.nist.gov
service ntpd start

e "Setup UTC Timezone"
cat << EOF > /etc/sysconfig/clock
ZONE="UTC"
UTC=true
EOF
cp -f /usr/share/zoneinfo/UTC /etc/localtime

e "Make the sshd config more secure"
sed -i -e "s/#Protocol 2/Protocol 2/" /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
#sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart sshd.service

e "Remove the udev persistent net rules file"
ln -sf /dev/null /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules

e "Remove yum cron job"
rm -f /etc/cron.daily/0yum*

e "Update the hostname"
sed -i -e "s/HOSTNAME=localhost.localdomain/HOSTNAME=vagrant-centos7-1511-x64/" /etc/sysconfig/network

e "Writable /var/log"
chmod -f 0777 /var/log
