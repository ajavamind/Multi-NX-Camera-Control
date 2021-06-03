#!/bin/sh

mkdir -p /dev/pts
mount -t devpts none /dev/pts
httpd -h /mnt/mmc
inetd /mnt/mmc/inetd.conf
