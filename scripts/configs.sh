#! /usr/bin/env bash

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Disable SELinux by default."
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux && \
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config && \
setenforce 0

# e "Configure NTP"
# systemctl enable ntpd
# systemctl stop ntpd
# ntpdate time.nist.gov
# service ntpd start

e "Setup UTC Timezone"
cat << EOF > /etc/sysconfig/clock
ZONE="UTC"
UTC=true
EOF

e "Make the sshd config more secure"
sed -i -e "s/#Protocol 2/Protocol 2/" /etc/ssh/sshd_config
sed -i -e "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
#sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart sshd.service

e "Clean up network interface persistence"
rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -rf /dev/.udev/;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

e "New-style network device naming for CentOS 7"
if grep -q -i "release 7" /etc/redhat-release ; then
  # radio off & remove all interface configration
  nmcli radio all off
  /bin/systemctl stop NetworkManager.service
  for ifcfg in `ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v ifcfg-lo` ; do
    rm -f $ifcfg
  done
  rm -rf /var/lib/NetworkManager/*

  e "Setup /etc/rc.d/rc.local for CentOS7"
  cat <<_EOF_ | cat >> /etc/rc.d/rc.local
#BENTO-BEGIN
LANG=C
# delete all connection
for con in \`nmcli -t -f uuid con\`; do
  if [ "\$con" != "" ]; then
    nmcli con del \$con
  fi
done
# add gateway interface connection.
gwdev=\`nmcli dev | grep ethernet | egrep -v 'unmanaged' | head -n 1 | awk '{print \$1}'\`
if [ "\$gwdev" != "" ]; then
  nmcli c add type eth ifname \$gwdev con-name \$gwdev
fi
sed -i "/^#BENTO-BEGIN/,/^#BENTO-END/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#BENTO-END
_EOF_
  chmod +x /etc/rc.d/rc.local
fi

e "Remove yum cron job"
rm -f /etc/cron.daily/0yum*

e "Update the hostname"
sed -i -e "s/HOSTNAME=localhost.localdomain/HOSTNAME=centos7-1708-x64/" /etc/sysconfig/network

e "Writable /var/log"
chmod -f 0777 /var/log

e "Fix slow DNS"
# https://github.com/chef/bento/blob/05d98910d835b503e7be3d2e4071956f66fbbbc4/centos/scripts/networking.sh
case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

    if [ "$major_version" -ge 6 ]; then
        # Fix slow DNS:
        # Add 'single-request-reopen' so it is included when /etc/resolv.conf is
        # generated
        # https://access.redhat.com/site/solutions/58625 (subscription required)
        echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network;
        service network restart;
        echo 'Slow DNS fix applied (single-request-reopen)';
    fi
    ;;

esac

e "Configure sshd"
# https://github.com/chef/bento/blob/05d98910d835b503e7be3d2e4071956f66fbbbc4/_common/sshd.sh
SSHD_CONFIG="/etc/ssh/sshd_config"
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
    echo "$USEDNS" >>"$SSHD_CONFIG"
fi

GSSAPI="GSSAPIAuthentication no"
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
    sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
else
    echo "$GSSAPI" >>"$SSHD_CONFIG"
fi
