#!/bin/sh
# Samsung NX500 screenshot script
# Initialize counter to 0001
cp /mnt/mmc/save_screen_counter.txt /mnt/mmc/save_screen_enable.txt
rm /mnt/mmc/OSD0001.jpg
sync
sync
sync
# EV button triggers screenshot save jpg
# when save_screen_enable.txt file is present on power up
st key push ev
st key release ev
sync
sync
sync
