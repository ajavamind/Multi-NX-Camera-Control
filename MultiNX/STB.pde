// Flash Strobe 
// M5Stack.com Timer Camera 
// Expects Flash unit connected to a device receiving WiFi trigger commands (shutter)
// Does not use camera functions

import netP5.*;
//import oscP5.*; // does not use this part of oscP5 library
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import java.net.DatagramSocket;

class STBCamera extends RCamera {

  // LCD screen dimensions
  static final int SCREEN_WIDTH = 720;
  static final int SCREEN_HEIGHT = 480;
  static final float offsetPercent = 3.0;

  final String[] SHUTTER_NAME = { "Bulb", "30\"", "25\"", "20\"", "15\"", "13\"", "10\"", "8\"", "6\"", "5\"",
    "4\"", "3\"", "2.5\"", "2\"", "1.6\"", "1.3\"", "1\"", "0.8\"", "0.6\"", "0.5\"",
    "0.4\"", "0.3\"", "1/4", "1/5", "1/6", "1/8", "1/10", "1/13", "1/15", "1/20",
    "1/25", "1/30", "1/40", "1/50", "1/60", "1/80", "1/100", "1/125", "1/160", "1/200",
    "1/250", "1/320", "1/400", "1/500", "1/640", "1/800", "1/1000", "1/1250", "1/1600", "1/2000",
    "1/2500", "1/3200", "1/4000", "1/5000", "1/6000"
  };

  final int[] SHUTTER_VALUE = { -80, -80, -75, -69, -64, -59, -53, -48, -43, -37,
    -32, -27, -21, -16, -11, -5, 0, 5, 11, 16,
    21, 27, 32, 37, 43, 48, 53, 59, 64, 69,
    75, 80, 85, 91, 96, 101, 107, 112, 117, 123,
    128, 133, 139, 144, 149, 155, 160, 165, 171, 176,
    181, 187, 192, 197, 202};

  final String[] FN_NAME = { "F2.4", "F2.8", "F3.2", "F3.5", "F4.0", "F4.5", "F5.0",
    "F5.6", "F6.3", "F7.1", "F8.0",
    "F9.0", "F10", "F11", "F13",
    "F14", "F16", "F18", "F20", "F22" };

  final int[] FN_VALUE = {41, 48, 53, 59, 64, 69, 75,
    80, 85, 91, 96,
    101, 107, 112, 117,
    123, 128, 133, 139, 144 };

  final String[] EV_NAME = { "-5.0", "-4.6", "-4.3", "-4.0", "-3.6", "-3.3", "-3.0", "-2.6", "-2.3", "-2.0", "-1.6", "-1.3", "-1.0", "-0.6", "-0.3",
    "0.0", "+0.3", "+0.6", "+1.0", "+1.3", "+1.6", "+2.0", "+2.3", "+2.6", "+3.0", "+3.3", "+3.6", "+4.0", "+4.3", "+4.6", "+5.0" };
  //int evId = 9;

  UdpClient udpClient;

  int photoIndex = 0;  // next photo index for filename
  int videoIndex = 0;  // next video index for filename
  boolean useTimeStamp = true;
  String numberFilename = ""; // last used number filename
  String datetimeFilename = ""; // last used date_time filename
  String lastFilename = ""; // last used filename

  int flashDelayTime = 100;  // milliseconds to delay before first strobe flash trigger
  int flashIntervalTime = 500; // milliseconds to delay between strobe flash triggers
  int flashIntervalCount = 4;  // number of strobes to the flash
  
  static final int SAME = 0;
  static final int UPDATE = 1;
  static final int NEXT = 2;
  static final int PHOTO_MODE = 0;
  static final int VIDEO_MODE = 1;
  int mode = PHOTO_MODE;

  STBCamera(PApplet app, String ipAddr) {
    this.ipAddr = ipAddr;
    udpClient = null;
    port = UDPport;
    // use direct IP address for flash not broadcast IP address
    //String broadcastIpAddress = ipAddr;
    try {
      if (!testGui) {
        udpClient = new UdpClient( ipAddress, port);  // from netP5.* library
        if (DEBUG) println("UdpClient "+ ipAddress);
      }
    }
    catch (Exception e) {
      if (DEBUG) println("Wifi problem");
      udpClient = null;
    }
    connected = false;
    if (udpClient != null) {
      connected = true;
    }

    inString = "";
    prompt = "]# ";
    prefix = "[root";
    systemrw = "sysrw";
    screenShot = "/mnt/mmc/screenshot";
    focusOffset = screenWidth*(offsetPercent/100);
    type = STB;
    shutterId = 1;
    fnId = 10;
    evName = EV_NAME;
    shutterName = SHUTTER_NAME;
    shutterValue = SHUTTER_VALUE;
    fnName = FN_NAME;
    fnValue = FN_VALUE;

    screenWidth = SCREEN_WIDTH;
    screenHeight = SCREEN_HEIGHT;
  }

  void updatePhotoIndex() {
    photoIndex++;
    if (photoIndex > 9999) {
      photoIndex = 1;
    }
    //SharedPreferences.Editor edit = preferences.edit();
    //edit.putInt(PHOTOINDEX, photoIndex);
    //edit.commit();
  }

  void updateVideoIndex() {
    videoIndex++;
    if (videoIndex > 9999) {
      videoIndex = 1;
    }
    //SharedPreferences.Editor edit = preferences.edit();
    //edit.putInt(VIDEOINDEX, videoIndex);
    //edit.commit();
  }

  String getDateTime() {
    Date current_date = new Date();
    String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(current_date);
    return timeStamp;
  }

  /**
   * get filename for Multi Remmote Camera (Android Camera App)
   *  param 0 update: SAME, UPDATE, NEXT
   *  param 1 mode
   */
  String getFilename(int update, int mode) {
    String fn = "";
    if (useTimeStamp) {
      if (update == UPDATE || update == NEXT) {
        fn = getDateTime();
        datetimeFilename = fn;
      } else {  // SAME
        fn = datetimeFilename;
      }
    } else {
      if (mode == PHOTO_MODE) {
        if (update == SAME) {
          fn = number(photoIndex);
          numberFilename = fn;
        } else if (update == UPDATE) {
          updatePhotoIndex();
          fn = number(photoIndex);
          numberFilename = fn;
        } else { // NEXT
          fn = number(photoIndex+1);
        }
      } else {
        if (update == SAME) {
          fn = number(videoIndex);
          numberFilename = fn;
        } else if (update == UPDATE) {
          updateVideoIndex();
          fn = number(videoIndex);
          numberFilename = fn;
        } else {  // NEXT
          fn = number(videoIndex+1);
        }
      }
    }
    lastFilename = fn;
    return fn;
  }

  boolean isActive() {
    if (udpClient != null) {
      return true;
    }
    return false;
  }

  void stop() {
    if (udpClient != null) {
      DatagramSocket ds = udpClient.socket();
      if (ds != null) {
        ds.close();
        ds.disconnect();
      }
    }
  }

  int[] getCameraResult() {
    return null;
  }

  void getCameraFnShutterEvISO() {
  }

  void setCameraFnShutterISO(int fnId, int shutterId, int isoId) {
    this.shutterSpeed = shutterValue[shutterId];
    this.fn = fnValue[fnId];
    this.iso = isoId;
  }

  void getCameraEv() {
  }

  void focusPush() {
    udpClient.send("F");
  }

  void focusRelease() {
    focus = false;
    udpClient.send("R");
  }

  void shutterPush() {
    String fn = getFilename(UPDATE, PHOTO_MODE);
    strobeFlash("S"+fn);
  }

  void shutterRelease() {
    udpClient.send("R");
  }

  void record() {
    //String fn = getFilename(UPDATE, VIDEO_MODE);
    //udpClient.send("V"+fn);
    //if (DEBUG) println("STB video record");
    //gui.displayMessage(fn, 45);
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void end() {
  }

  void menu() {
  }

  void cameraMode(int m) {
    if (DEBUG) println("camera mode "+ cameraModes[m]+"\n");
  }

  void cameraInfo() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void cameraOk() {
    //udpClient.send("P"); // pause in video mode
    //gui.displayMessage("Video Pause/Resume for Multi Remote Camera", 60);
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void touchBack() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void touchFocus(int x, int y) {
    if (DEBUG) println("touchFocus x="+x + " y="+y);
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void function() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void home() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void toggleFilenamePrefix(String data) {
    //if (data == null ) data = "";
    //useTimeStamp = !useTimeStamp;
    //if (useTimeStamp) {
    //  gui.displayMessage("Date-Time Filename " + datetimeFilename + " "+ data, 60);
    //} else {
    //  gui.displayMessage("Number Filename " + numberFilename + " "+ data, 60);
    //}
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  // request playback in each Multi Remote Camera app
  void playback() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
    //udpClient.write("st key click pb\n");
    //udpClient.send();  //TODO
  }

  boolean toggleEv = false;
  void ev() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
    toggleEv = !toggleEv;
    if (toggleEv) {
      //udpClient.write("st key push ev\n");
    } else {
      //udpClient.write("st key release ev\n");
    }
  }

  void shutterPushRelease() {
    String fn = getFilename(UPDATE, PHOTO_MODE);
    strobeFlash("S"+fn);
  }

  void takePhoto() {
    String fn = getFilename(UPDATE, PHOTO_MODE);
    strobeFlash("C"+fn);
  }

  void strobeFlash(String msg) {
    if (DEBUG) println("strobeFlash "+msg);
    int count = flashIntervalCount;
    udpClient.send(msg);
    delay(flashDelayTime);
    count--;
    while (count > 0) {
      if (DEBUG) println("strobeFlash count="+count);
      delay(flashIntervalTime);
      udpClient.send(msg);
      count--;
    }
    gui.displayMessage("Strobe Flash Completed", 45);

  }
  
  void sendMsg(String msg) {
  }

  void jogcw() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void jogccw() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
  }

  void screenshot(String filename) {
    if (DEBUG) println("screenshot("+filename+")");
  }

  boolean screenshot() {
    if (DEBUG) println("screenshot()");
    gui.displayMessage(NOT_IMPLEMENTED, 40);
    return true;
  }

  void getPhotoFile() {
    gui.displayMessage(NOT_IMPLEMENTED, 40);
    //String aName = getFilename(SAME, PHOTO_MODE);
    //String aFilename = "IMG_"+ aName+ suffix + ".jpg";
    //filename = aFilename;
    ////String afilenameUrl = "http:"+ File.separator+ File.separator+ipAddr + ":" + HTTPport + File.separator + aFilename;
    //String afilenameUrl = "http://" + ipAddr + ":" + HTTPport + "/" + aFilename;
    //afilenameUrl.trim();
    //afilenameUrl = afilenameUrl.replaceAll("(\\r|\\n)", "");
    //String afilename = filename.replaceAll("(\\r|\\n)", "");
    //if (DEBUG) println("result filename = " + afilename + " filenameURL= "+afilenameUrl);
    //if (!afilenameUrl.equals(filenameUrl) || lastPhoto == null || lastPhoto.width <= 0 || lastPhoto.height <=0) {
    //  filename = afilename.substring(afilename.lastIndexOf('/')+1);
    //  if (DEBUG) println("filename="+filename);
    //  filenameUrl = afilenameUrl;
    //  if (aName.equals("")) {
    //    lastPhoto = null;
    //  } else {
    //    try {
    //    lastPhoto = loadImage(filenameUrl);
    //    } catch (Exception ex) {
    //      lastPhoto = null;
    //    }
    //  }
    //  if (DEBUG) println("STB getPhotoFile loadImage "+filenameUrl);
    //  gui.displayMessage("Get Photo... \n"+ filenameUrl, 90);
    //  if (orientation != 0) {
    //    needsRotation = true;
    //  }
    //  //showPhoto = true;
    //  if (lastPhoto == null || lastPhoto.width <= 0 || lastPhoto.height <= 0) {
    //    showPhoto = false;
    //    gui.displayMessage("Photo Not Found\n"+ filenameUrl, 90);
    //  }
    //} else {
    //  gui.displayMessage("Photo \n"+ filenameUrl, 20);
    //  if (DEBUG) println("same filename "+ afilenameUrl + " "+ filenameUrl);
    //}
  }

  void save() {
  }

  void getShutterCount() {
    if (DEBUG) println("get shutter count");
  }

  void updateFn() {
    if (DEBUG) println("updateFn()");
  }

  void updateSs() {
  }

  void updateIso() {
  }
}
