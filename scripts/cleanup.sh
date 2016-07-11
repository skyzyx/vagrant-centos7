#! /usr/bin/env bash

e() {
  echo -e "  \e[1;32m[install] ==> $@\e[0m";
}

e "CLEAN UP ALL THE THINGS"
yum clean all
rm -rf /tmp/*
rm -f /var/log/wtmp /var/log/btmp

e "Clean empty space on disk"
dd if=/dev/zero of=/tmp/clean || rm -f /tmp/clean
