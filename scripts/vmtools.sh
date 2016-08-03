#!/bin/sh -eux
# https://github.com/chef/bento/blob/master/scripts/common/vmtools.sh

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "Set a default HOME_DIR environment variable if not set"
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    VER="`cat /home/vagrant/.vbox_version`";
    e "Virtualbox Tools Version: $VER";

    yum -y install kernel-devel-`uname -r` kernel-devel*

    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/VBoxGuestAdditions_${VER}.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;

vmware-iso|vmware-vmx)
    e "Use open-vm-tools"
    yum -y install open-vm-tools
    mkdir -p /mnt/hgfs;

    e "Also install old VMware tools"
    wget -O /tmp/vmware-tools.zip.tar https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/8.1.1/3771013/packages/com.vmware.fusion.tools.linux.zip.tar
    cd /tmp && \
        tar xzf vmware-tools.zip.tar && \
        unzip com.vmware.fusion.tools.linux.zip && \
        mkdir -p /mnt/vmware && \
        mount /tmp/payload/linux.iso /mnt/vmware && \
        tar xzf /mnt/vmware/VMwareTools-*.tar.gz -C /tmp/ && \
        cd /tmp/vmware-tools-distrib/ && ./vmware-install.pl --force-install --default
    ;;

    # /usr/src/kernels/3.18.34-20.el7.x86_64/include

parallels-iso|parallels-pvm)
    mkdir -p /tmp/parallels;
    mount -o loop $HOME_DIR/prl-tools-lin.iso /tmp/parallels;
    VER="`cat /tmp/parallels/version`";

    e "Parallels Tools Version: $VER";

    /tmp/parallels/install --install-unattended-with-deps \
      || (code="$?"; \
          echo "Parallels tools installation exited $code, attempting" \
          "to output /var/log/parallels-tools-install.log"; \
          cat /var/log/parallels-tools-install.log; \
          exit $code);
    umount /tmp/parallels;
    rm -rf /tmp/parallels;
    rm -f $HOME_DIR/*.iso;
    ;;

qemu)
    echo "Don't need anything for this one"
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac
