# Raspberry Pi Computer Camera

MultiNX can control a Raspberry Pi computer camera. The Raspberry Pi must have the libcamera library and a lighttpd web server installed. MultiNx uses SSH to login and issues libcamera commands libcamera-still (capture photos) and libcamera-vid (capture video). 

## Raspberry Pi OS
At the time I began working with libcamera on the Raspberry Pi, I installed a ArduCam Pivariety Motorized Focus Camera Module 21MP with Sony IMX230. The kernal driver installation for the camera requires Buster kernel version 5.10. This camera from Arducam is currently only works with Buster (32 bit OS).

## Libcamera
The ArduCam IMX230 requires ArduCam libcamera libraries installed from the Github ArduCam/Arducam-Pivariety-V4L2-Driver releases.

## Lighttpd
The lighttpd web server provides MultiNx with a way to retrive photos from the RPI camera. Instructions for installing the lighttpd web server are found at [https://kalitut.com/set-up-lighttpd-web-server-on-raspberry/](https://kalitut.com/set-up-lighttpd-web-server-on-raspberry/).

MultiNx expects to receive directory listings from the server. Lighttpd has an option to enable directory listing of folders. MultiNX reads photos and videos from port 8080. The lighttpd.conf file with the options needed goes in the /etc/lighttpd directory of the RPI. Port 8080 will begin with folder /home/pi/Media as specified in the lighttpd.conf file.
