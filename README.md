# CentOS 7.2 Vagrant Boxes

Building Vagrant images based on CentOS 7.2 (minimal install). All instructions were tested against OS X 10.11 “El Capitan”, VMware Fusion 8, VirtualBox 5, and Parallels Desktop 11.

If your intention is only to _use_ one of these CentOS 7.2 images, you can open your `Vagrantfile` and set:

```ruby
config.vm.box = "skyzyx/centos7"
```

## Prerequisites

* Knowledge of the command line.
* [Packer](https://www.packer.io/downloads.html) 0.10.1 or newer.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads), for building the VirtualBox Vagrant box.
* [VMware Fusion](http://www.vmware.com/products/fusion), for building the VMware Vagrant box.
    * [Vagrant Provider for VMware](https://www.vagrantup.com/vmware/) if you want VMware to work with Vagrant.
* [Parallels Desktop](http://www.parallels.com/products/desktop/download/), for building the Parallels Vagrant box.
    * [Parallels Virtualization SDK for Mac](http://www.parallels.com/download/pvsdk/) so that your Mac can talk to Parallels through Vagrant.
* Knowledge of Bash scripting and JSON if you want to fork this repo and make changes.

## Installing Packer

I'm going to assume that you have already:

1. Installed Vagrant and its dependencies.
1. Installed (and paid for) the virtualization software of your choice.

You have two choices for installing Packer.

1. If you already have the [Homebrew](http://brew.sh) package manager installed, you can simply do:

   ```bash
   brew install packer
   ```

1. Otherwise, you can manually install it from <https://www.packer.io/downloads.html>.

## Building Boxes

### Build everything

This template has built-in support for VirtualBox, VMware, and Parallels Desktop. You can build everything at the same time (assuming you have the relevant prerequisites installed) with:

```bash
packer build template.json
```

### Build only one

If you only want to build one particular Vagrant box, you can use the `--only` flag.

```bash
# VMware
packer build --only=vmware-iso template.json

# VirtualBox
packer build --only=virtualbox-iso template.json

# Parallels
packer build --only=parallels-iso template.json
```
