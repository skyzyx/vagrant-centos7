# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## 1.0.0 - 2016-07-10

* Initial release.
* Built on a minimum install of CentOS 7.2.1511.
* Check `/etc/vagrant_box_build_time` for the build date.
* SELinux is set to _Permissive_.
* `/usr/local/bin` has been added to the `$PATH`.
* Yum repos provided by <https://github.com/skyzyx/centos7-repos>.
* Vagrant public key is an authorized SSH key.
* The `vagrant` user is a no-password _sudoer_.
