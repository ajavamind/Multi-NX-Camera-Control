# Raspberry Pi Computer Camera

MultiNX can control a camera on a Raspberry Pi computer. The Raspberry Pi must have the libcamera library and a lighttpd web server installed. MultiNx uses SSH to login and issues libcamera shell commands libcamera-still (capture photos) and libcamera-vid (capture video). 

## Raspberry Pi OS
At the time I started working with libcamera on the Raspberry Pi, my camera was a ArduCam Pivariety Motorized Focus Camera Module 21MP with Sony IMX230. The kernal driver installation for the camera requires kernel version 5.10. This camera is currently only used with Buster (32 bit OS).

## Libcamera
The ArduCam IMX230 requires ArduCam libcamera libraries installed from the Github ArduCam/Arducam-Pivariety-V4L2-Driver releases.

## Lighttpd
The lighttpd web server provides MultiNx with a way to retrive photos from the RPI camera. Instructions for installing the lighttpd web server are found at [https://kalitut.com/set-up-lighttpd-web-server-on-raspberry/](https://kalitut.com/set-up-lighttpd-web-server-on-raspberry/).

MultiNx expects to receive directory listings from the server. Lighttpd has an option to enable directory listing of folders. MultiNX reads photos and videos from port 8080. The lighttpd.conf file with the options needed goes in the /etc/lighttpd directory of the RPI.
