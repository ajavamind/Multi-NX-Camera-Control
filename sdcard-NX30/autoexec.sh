#!/bin/sh
# Samsung NX500 startup script
# wait for WiFi connection
#sleep 30
mkdir -p /dev/pts
mount -t devpts none /dev/pts
# Telnet server
/mnt/mmc/telnetd &
# HTTP server
/mnt/mmc/busybox httpd -h /mnt/mmc
# FTP server
/mnt/mmc/busybox tcpsvd -u root -vE 0.0.0.0 21 /mnt/mmc/busybox ftpd -w /mnt/mmc &
#killall dfmsd
