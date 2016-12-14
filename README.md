# CentOS 7.3 Vagrant/Docker Boxes

Building Vagrant images based on CentOS 7.3 (minimal install). All instructions were tested against macOS 10.12 “Sierra”, VMware Fusion 8.5, VirtualBox 5, and Parallels Desktop 11.

If your intention is only to _use_ one of these CentOS 7.3 images, you can open your `Vagrantfile` and set:

```ruby
config.vm.box = "skyzyx/centos7"
```

* [atlas.hashicorp.com](https://atlas.hashicorp.com/skyzyx/boxes/centos7/)
* [hub.docker.com](https://hub.docker.com/r/skyzyx/centos7/)

## Why CentOS?

CentOS is a very good, very stable, very reliable server OS. It is essentially an all-open-source version of Red Hat Enterprise Linux.

The flip side is that sometimes we can end up with an older set of packages than we might prefer, which is why I maintain this particular Vagrant/Docker image.

By leveraging [centos7-repos], we can maintain modern software — securely — on a more conservative OS.

### What do you install on top of the base image?

These images are based on a minimal install of CentOS 7.3. On top of that base installation, we install the following:

* We write the image's build time to `/etc/vagrant_box_build_time`.
* Disable SELinux.
* Configure `ntp` to speak to `time.nist.gov`, and set the timezone to UTC.
* Make SSH more secure by forcing _Protocol 2_ and disabling `root` login.
* Disable all default `yum` updates.
* Remove ancient PHP and Maria DB libs.
* Add `/usr/local/bin` to the `$PATH` by default.
* Enable all `yum` repositories from [centos7-repos].
* Install the _Development Tools_ `yum` group.
* Install _modern_ cURL, which can speak HTTP/2, TLS 1.1, and TLS 1.2.
* Install updates to OpenSSL, strace, htop, nano, vi, and a number of other core packages.
* Install modern VMware Tools and/or VirtualBox tools.
* Allow user Vagrant to use `sudo` without entering a password.

## Prerequisites

* [Packer](https://www.packer.io/downloads.html) 0.10.1 or newer.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads), for building the VirtualBox Vagrant box.
    * [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plug-in to keep VirtualBox tools up-to-date.
* [VMware Fusion](http://www.vmware.com/products/fusion), for building the VMware Vagrant box.
    * [Vagrant Provider for VMware](https://www.vagrantup.com/docs/vmware/installation.html) plug-in to enable Vagrant to use VMware as a provider.
* [Parallels Desktop](http://www.parallels.com/products/desktop/download/), for building the Parallels Vagrant box.
    * [Parallels Virtualization SDK for Mac](http://www.parallels.com/download/pvsdk/) so that your Mac can talk to Parallels through Vagrant.
    * [vagrant-parallels](http://parallels.github.io/vagrant-parallels/) plug-in to enable Vagrant to use Parallels as a provider.
* [vagrant-cachier](http://fgrehm.viewdocs.io/vagrant-cachier/) plug-in to enable caching of `yum` packages.
* [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) plug-in to automatically updated your hosts file.

## Updating your Plug-Ins

This is simply a good thing to do from time to time.

```bash
vagrant plugin update
```

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

See “[Install Packer](https://www.packer.io/intro/getting-started/setup.html)” for more information.

## Building Vagrant Boxes

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

## Building the Docker Image

1. Boot-up a Vagrant VM. This will automatically kick-off the Packer build for Docker.

   ```bash
   vagrant up
   ```

2. If you would like to test it, you can import the image into Docker and run the container.

   ```bash
   # SSH into the VM.
   vagrant ssh
   
   cd /vagrant
   cat builds/centos7-x64-docker.tar | docker import - skyzyx/centos7:latest
   docker run -ti skyzyx/centos7:latest /bin/bash
   ```

3. When you're done, exit the Vagrant VM, then terminate it.

   ```bash
   exit
   vagrant destroy
   ```

  [centos7-repos]: https://github.com/luckyrocketshipunderpants/centos7-repos
