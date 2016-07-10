#! /usr/bin/env bash

# http://thornelabs.net/2013/10/15/create-a-centos-6-vagrant-base-box-from-scratch-using-vmware-fusion.html
# https://github.com/phase2/veewee-boxes/blob/9396f667ca34180dbe7424ee43fcd1aa34fe2cad/definitions/CentOS-6.0-x86_64-netboot/postinstall.sh
# http://bascht.com/tech/2013/10/07/building-a-vagrant-box-with-centos-64-and-vmware/

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Add a permanent datestamp for the image."
echo "$(date -I)" > /etc/vagrant_box_build_time

e "Disable SELinux by default."
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux && \
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config && \
setenforce 0

e "Remove known-bad or known-conflicting packages."
yum -y remove \
    check-mk-agent* \
    check_mk-agent* \
    mariadb-libs* \
    mysql-5.1* \
    mysql-libs-5.1* \
    mysql-server-5.1* \
    php-5.3* \
    php-cli-5.3* \
    php-common-5.3* \
    php-gd-5.3* \
    php-mbstring-5.3* \
    php-mysql-5.3* \
    php-pdo-5.3* \
    php-pdo-5.3* \
    php-snmp-5.3* \
;

e "Add /usr/local/bin to the \$PATH."
echo "export PATH=\$PATH:/usr/local/bin" >> /etc/bashrc

e "Pick up the new changes."
exec -l $SHELL

e "Remove all .repo files."
rm -f /etc/yum.repos.d/*

e "Add a set of known/trusted repos."
curl -s -o /etc/yum.repos.d/all.repo https://raw.githubusercontent.com/skyzyx/centos7-repos/master/all.repo

e "Sync the correct packages for the distro."
yum -y distro-sync

e "Remove any errant CentOS repo files."
rm -f /etc/yum.repos.d/CentOS-*

e "Clean the Yum cache"
yum clean all

e "Install new packages"
yum -y groupinstall "Development Tools"
yum -y install \
    bash \
    bash-completion \
    bind-utils \
    bzip2 \
    ca-certificates \
    cronie \
    cronie-anacron \
    crontabs \
    curl \
    deltarpm \
    gawk \
    glib2 \
    glibc \
    htop \
    iftop \
    iptables \
    iputils \
    libcgroup \
    libselinux-python \
    make \
    nano \
    nc \
    net-tools \
    nscd \
    ntp \
    ntpdate \
    openssh \
    openssh-clients \
    openssh-server \
    openssl \
    open-vm-tools \
    pcre \
    readline \
    rpm \
    rsync \
    screen \
    sed \
    setuptool \
    strace \
    sysstat \
    tcp_wrappers \
    telnet \
    traceroute \
    tree \
    tzdata \
    uuid \
    vim-enhanced \
    wget \
    xz \
    yum \
    yum-cron \
    yum-plugin-aliases \
    yum-plugin-changelog \
    yum-plugin-fastestmirror \
    yum-plugin-list-data \
    yum-plugin-ps \
    yum-plugin-show-leaves \
    yum-plugin-upgrade-helper \
    yum-plugin-versionlock \
    yum-utils \
    yum \
    zip \
    zlib \
;

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

e "Installing Vagrant user and keys"
useradd vagrant
mkdir -m 0700 -p /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

e "Comment out requiretty in /etc/sudoers"
# This change is important because it allows ssh to send remote commands using sudo. Without this change vagrant
# will be unable to apply changes (such as configuring additional NICs) at startup:
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

e "Allow user Vagrant to use sudo without entering a password"
usermod -G wheel vagrant > /dev/null 2>&1
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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

e "CLEAN UP ALL THE THINGS"
yum clean all
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp

e "Clean empty space on disk"
dd if=/dev/zero of=/tmp/clean || rm -f /tmp/clean
vmware-toolbox-cmd disk shrink /

echo ""
e "Shutdown immediately by running"
e "#=> shutdown -h now"
echo ""

history -c
exit
