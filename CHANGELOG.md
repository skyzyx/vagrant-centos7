# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## 3.1.0 - 2017-11-20

* Built on a minimum install of CentOS 7.4.1708.
* Updated various scripts to align with [chef/bento @ commit:05d98910d8](https://github.com/chef/bento/tree/05d98910d835b503e7be3d2e4071956f66fbbbc4).

## 3.0.0 - 2016-12-29

* The CentOS 7.x image should be more-or-less exactly the same. Same packages, same configurations.
* Forked CentOS, Debian, and Ubuntu from [chef/bento @ tag:2.3.2](https://github.com/chef/bento/tree/2.3.2), and stripped out everything I don't care about.
* Forked Alpine Linux from [nlamirault/bento @ commit:ca8813](https://github.com/nlamirault/bento/tree/ca8813956fd1194e97e49e3be1b4fc306c6c845a).
* Added Alpine build definitions for VMware and Parallels Desktop.
* Properly adopted the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0), which is coincidentally what `chef/bento` and `nlamirault/bento` both use.

## 2.2.1 - 2016-12-27

* Ensure that the `centos7-repos` _package_ is installed, not just the `centos7.repo` file.

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
