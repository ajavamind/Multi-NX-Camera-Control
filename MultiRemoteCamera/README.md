# Multi Remote Camera (Android App)

MultiNX can control focus and shutter on multiple Android phone cameras almost simultaneously, 
that run the Multi Remote Camera app. This open source camera app is available on SourceForge.net at
 [https://sourceforge.net/projects/multi-remote-camera/](https://sourceforge.net/projects/multi-remote-camera/)
The phone should have WiFi enabled and be connected to the same network as computer or phone running the MultiNX app. 

## Multi Remote Camera Settings

To view photos taken with MultiRemoteCamera, MultiNX needs the app's WiFi Remote Control and HTTP Server turned on. 
In the Multi Remote Camera App: 
 1) turn on the WiFi Remote Control using Settings->Camera Controls -> WiFi Remote Control. 
 2) turn on the HTTP Server using Settings->Camera Controls -> HTTP Server. 
 
 The same folder used to store pictures is the folder used by the built-in web server. 
 A web browser can see a directory listing with the link http://PHONE_IP_ADDRESS:8080 - change PHONE_IP_ADDRESS to match your phone. 
 The app will show the PHONE_IP_ADDRESS by selecting Settings -> Camera Conrotls -> Pairing QR Code. 
 You can use the QR code to launch a browser on a computer or phone connected to the same network.
