# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## 2.2.0 - 2016-12-13

* Built on a minimum install of CentOS 7.3.1611.

## 2.1.0 - 2016-07-11

* Simplified some of the provisioning code by leveraging some scripts from [chef/bento](https://github.com/chef/bento).
* Resolved an issue with HGFS drivers in the VMware box.

## 2.0.0 - 2016-07-10

* Rebuilt version 1.0.0 with [Packer](https://packer.io) by forking [shiguredo/packer-templates](https://github.com/shiguredo/packer-templates/tree/develop/centos-7.1).
* Added support for VirtualBox.
* Added support for Parallels Desktop

## 1.0.0 - 2016-07-10

* Initial release.
* Built on a minimum install of CentOS 7.2.1511.
* Check `/etc/vagrant_box_build_time` for the build date.
* SELinux is set to _Permissive_.
* `/usr/local/bin` has been added to the `$PATH`.
* Yum repos provided by <https://github.com/skyzyx/centos7-repos>.
* Vagrant public key is an authorized SSH key.
* The `vagrant` user is a no-password _sudoer_.
