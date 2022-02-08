# Open Camera Remote Android App

MultiNX can control focus and shutter on multiple Android phone cameras almost simultaneously, all running the Open Camera Remote app. This open source camera app is on the Google play store  [https://play.google.com/store/apps/details?id=net.sourceforge.opencameraremote](https://play.google.com/store/apps/details?id=net.sourceforge.opencameraremote). The phone should have WiFi enabled and be connected to the same network as MultiNX app host computer or phone. 

## Open Camera Remote Settings

To view photos taken with OCR, MultiNX needs the OCR HTTP Server on. In the OCR app turn on the HTTP Server using Settings->Camera Controls -> HTTP Server. The same folder used to store pictures is the folder used by the built-in web server. A web browser can see a directory listing with the link http://PHONE_IP_ADDRESS:8080 - change PHONE_IP_ADDRESS to match your phone. The app will show the PHONE_IP_ADDRESS by selecting Settings -> Camera Conrotls -> Pairing QR Code. You can use the QR code to launch a browser on a phone connected to the same network.
