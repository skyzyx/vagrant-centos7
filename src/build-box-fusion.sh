#!/usr/bin/env bash

# Defrag and shrink
/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -d Virtual\ Disk.vmdk
/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager -k Virtual\ Disk.vmdk

# metadata.json
echo '{"provider": "vmware_fusion"}' > metadata.json

# Remove the VMware log files
rm -f vmware*.log

# Finally, tar everything up into a box file:
tar cvzf centos7-x86_64.vmware.box ./*

# Delete metadata.json
rm -f metadata.json

echo "centos7-x86_64.vmware.box"
echo "Hash: $(openssl dgst -sha256 centos7-x86_64.vmware.box)"
