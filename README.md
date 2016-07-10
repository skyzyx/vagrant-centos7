# Building a new Vagrant-based CentOS 7.2 image

## Setting up the VM

> **NOTE:** These steps are written for VMware Fusion 8.

1. Install Vagrant, VMware Fusion and the VMware Provider for Vagrant.

1. Download [CentOS 7.2 (x86_64)](https://www.centos.org/download/).

1. Open VMware Fusion, go to _File → New…_.

1. Click _Create a custom virtual machine_ and click _Continue_.

1. Click _Linux → CentOS 64-bit_, and click _Continue_.

1. Choose _Create a new virtual disk_, and click _Continue_.

1. Click _Customize Settings_.

1. Save your virtual machine with what name you like, I chose `centos-7.2-x64`, and click _Save_.

### The VMware Settings Pane

<table class="remarkup-table">
<tbody><tr><td><strong>Pane</strong></td><td><strong>Option</strong></td><td><strong>Value</strong></td></tr>
<tr><td>Sharing</td><td>Shared Folders</td><td>Off</td></tr>
<tr><td>Processors &amp; Memory</td><td>Processors</td><td>1</td></tr>
<tr><td></td><td>Memory</td><td>512</td></tr>
<tr><td></td><td>Advanced → Enable hypervisor applications</td><td>On</td></tr>
<tr><td></td><td>Advanced → Enable code profiling applications</td><td>On</td></tr>
<tr><td>Display</td><td>Accelerate 3D Graphics</td><td>Off</td></tr>
<tr><td>Network Adapter</td><td>Share with my Mac</td><td>On</td></tr>
<tr><td>Hard Disk (SCSI)</td><td>Disk size</td><td>20.00 GB</td></tr>
<tr><td></td><td>Advanced → Bus Type</td><td>SATA</td></tr>
<tr><td></td><td>Advanced → Split into 2 GB files</td><td>Off</td></tr>
<tr><td>CD/DVD</td><td>Advanced options → Bus type</td><td>IDE</td></tr>
<tr><td>Cameras</td><td>Delete cameras</td><td></td></tr>
<tr><td>Compatibility</td><td>Advanced → Use Hardware Version</td><td>10</td></tr>
<tr><td></td><td>Allow upgrading the virtual hardware</td><td>On</td></tr>
<tr><td>Isolation</td><td>Enable Drag and Drop</td><td>Off</td></tr>
<tr><td></td><td>Enable Copy and Paste</td><td>Off</td></tr>
<tr><td>Sound Card</td><td>Remove Sound Card</td><td></td></tr>
<tr><td>USB &amp; Bluetooth</td><td>Advanced → Remove USB Controller</td><td></td></tr>
<tr><td>Printer</td><td>Remove Printer Port</td><td></td></tr>
</tbody></table>

Close the Settings menu. Start up the virtual machine and begin installation.

### Installing the OS

Install the operating system however you like. Most of the default options can be used, except for the **root password**, which should be `vagrant`.

### Enabling the network adapter

We need to do some basic work up-front before we can script the installation. Login as `root` (password: `vagrant`).

By default, networking is not brought up, so bring it up:

```bash
# Find the name of your network adapter
$ nmcli d

# Bring it up
ifup {adapter}
```

### Enabling SSH

Enable the `ssh` service to start on boot:

```bash
$ chkconfig sshd on
```

Then reboot the OS.

```bash
$ reboot
```

### Connecting over SSH

When the OS is back, log back in as `root`.

Restart the interface and lookup the IP address:

```bash
$ ifup {adapter} && ip addr
```

The results will look something like this:
```
eth0  Link encap:Ethernet  HWaddr 00:0C:29:1C:89:92
      inet addr:192.168.13.129  Bcast:192.168.13.255  Mask:255.255.255.0
      inet6 addr: fe80::20c:29ff:fe1c:8992/64 Scope:Link
      UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
      RX packets:137 errors:0 dropped:0 overruns:0 frame:0
      TX packets:115 errors:0 dropped:0 overruns:0 carrier:0
      collisions:0 txqueuelen:1000
      RX bytes:19705 (19.2 KiB)  TX bytes:12476 (12.1 KiB)

lo    Link encap:Local Loopback
      inet addr:127.0.0.1  Mask:255.0.0.0
      inet6 addr: ::1/128 Scope:Host
      UP LOOPBACK RUNNING  MTU:16436  Metric:1
      RX packets:0 errors:0 dropped:0 overruns:0 frame:0
      TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
      collisions:0 txqueuelen:0
      RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)</pre>
```

### SSH into the VM

In this example, the IP address for `eth0` is `192.168.13.129`. From your Mac terminal, SSH into the VM.

```bash
$ ssh root@192.168.13.129
```

Now, you can use your Mac-isms (like copy-paste).

## Running the installation script

Now that you're logged into the VM with your Mac, run the following command. This does the bootstrapping of the disk image.

```bash
$ curl -s https://raw.githubusercontent.com/skyzyx/vagrant-centos7/master/src/setup-install.sh | bash
```

This will make the necessary changes to the environment to prepare it for becoming a Vagrant box. Once the script completes, shutdown the VM immediately.

```bash
$ shutdown -h now
```

## Preparing the Vagrant box

1. Once the virtual machine is shutdown, open _Settings_ for the virtual machine.

1. Click the _CD/DVD (IDE)_ button, expand _Advanced options_, click _Remove CD/DVD Drive_, and click _Remove_.

1. Close the _Settings_ menu.

Go to the directory where your virtual machines are stored. By default this will be either `~/Documents/Virtual\ Machines` or `~/Documents/Virtual\ Machines.localized`.

```bash
$ cd ~/Documents/Virtual\ Machines/centos-7.2-x64.vmwarevm
```

Run the following command:

```bash
$ curl -s https://raw.githubusercontent.com/skyzyx/vagrant-centos7/master/src/build-box-fusion.sh | bash
```

## Updating the assets

First, you need to generate a hash of the `.box` file.

```bash
$ openssl dgst -sha256 centos-7.2-x64.vmware.box
```

### Vagrantfile

Inside the `Vagrantfile`, look for the following section:

```ruby
config.vm.box = "wepay/centos-6.7"
config.vm.box_url = "https://artifactory.devops.wepay-inc.com/artifactory/vagrant/centos-6.7-x86_64.vmware.box"
config.vm.box_download_checksum = "28e27735857e28b5ceab196398dbf1be4f9af9c5ae8ebe83ed938b8596a72b5b"
config.vm.box_download_checksum_type = "sha256"
```

1. Update `config.vm.box_download_checksum` with the hash value that you generated a moment ago.

1. The `config.vm.box_url` will be updated according to the next section.

### Artifactory

Change the value of `box_version` at the end of the following cURL URL to the distribution version + the build of this image (e.g., `6.7.5`).

```
curl -i \
    -X PUT \
    --progress-bar \
    --verbose \
    -T centos-6.7-x86_64.vmware.box \
    "https://artifactory.devops.wepay-inc.com/artifactory/vagrant/centos-6.7-x86_64.vmware.box;box_name=wepay/centos-6.7;box_provider=vmware_fusion;box_version=6.7.5" \
    | tee -a /tmp/artifactory-vagrant-upload ; test ${PIPESTATUS[0]} -eq 0
```
