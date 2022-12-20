// M5Stack.com Timer Camera 
// Expects Arduino Web camera sketch running on the Timer camera

//import netP5.*;
//import oscP5.*; // does not use this part of oscP5 library
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;

//import java.net.DatagramSocket;

class TMCCamera extends RCamera {

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

  //UdpClient udpClient;
  
  int photoIndex = 0;  // next photo index for filename
  int videoIndex = 0;  // next video index for filename
  boolean useTimeStamp = true;
  String numberFilename = ""; // last used number filename
  String datetimeFilename = ""; // last used date_time filename
  String lastFilename = ""; // last used filename
  
  static final int SAME = 0;
  static final int UPDATE = 1;
  static final int NEXT = 2;
  static final int PHOTO_MODE = 0;
  static final int VIDEO_MODE = 1;
  int mode = PHOTO_MODE;
  static final String HTTPport = "80";  // for 

  TMCCamera(PApplet app, String ipAddr) {
    this.ipAddr = ipAddr;
    //udpClient = null;
    port = UDPport;
    //try {
    //  if (!testGui) {
    //    udpClient = new UdpClient( ipAddr, port);  // from netP5.* library
    //    if (DEBUG) println("UdpClient "+ ipAddr);
    //  }
    //}
    //catch (Exception e) {
    //  if (DEBUG) println("Wifi problem");
    //  udpClient = null;
    //}
    //connected = false;
    //if (udpClient != null) {
    //  connected = true;
    //}

    inString = "";
    prompt = "]# ";
    prefix = "[root";
    systemrw = "sysrw";
    screenShot = "/mnt/mmc/screenshot";
    focusOffset = screenWidth*(offsetPercent/100);
    type = TMC;
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

  boolean isConnected() {
    //println("Camera Client isConnected()="+connected);
    return true;
  }

  /**
   * get filename for M5Stack Timer Camera
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
    //if (udpClient != null && udpClient.active()) {
    //if (udpClient != null) {
      return true;
    //}
    //return false;
  }

  void stop() {
    //if (udpClient != null) {
    //  DatagramSocket ds = udpClient.socket();
    //  if (ds != null) {     
    //    ds.close();
    //    ds.disconnect();
    //  }
    //}
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
    //udpClient.send("F");
  }

  void focusRelease() {
    focus = false;
    //udpClient.send("R");
  }

  void shutterPush() {
    //udpClient.send("S"+getFilename(UPDATE, PHOTO_MODE));
    gui.displayMessage(lastFilename, 45);
  }

  void shutterRelease() {
    //udpClient.send("R");
  }

  void record() {
    //udpClient.send("V"+getFilename(UPDATE, VIDEO_MODE));
    gui.displayMessage(lastFilename, 45);
  }

  void end() {
    //udpClient.write("st key click end\n");
  }

  void menu() {
    //udpClient.write("st key click menu\n");
  }

  void cameraMode(int m) {
    //udpClient.write("st key mode "+ cameraModes[m]+";sleep 1\n");
    if (DEBUG) println("st key mode "+ cameraModes[m]+"\n");
  }

  void cameraInfo() {
    //udpClient.write("st key "+"\n");
  }

  void cameraOk() {
    //udpClient.send("P"); // pause in video mode
  }

  void touchBack() {
    //udpClient.write("st key touch click 40 40\n");
  }

  void touchFocus(int x, int y) {
    if (DEBUG) println("touchFocus x="+x + " y="+y);
    //udpClient.write("st key touch click "+x +" "+ y+"\n");
  }

  void function() {
    //udpClient.write("st key click fn\n");
  }

  void home() {
    useTimeStamp = !useTimeStamp;
    if (useTimeStamp) {
      gui.displayMessage("Using Date-Time Filename Prefix", 45);
    } else {
      gui.displayMessage("Using Counter Number Filename Prefix",45);
    }
  }

  void playback() {
    //udpClient.write("st key click pb\n");
  }

  boolean toggleEv = false;
  void ev() {
    toggleEv = !toggleEv;
    if (toggleEv) {
      //udpClient.write("st key push ev\n");
    } else {
      //udpClient.write("st key release ev\n");
    }
  }

  void shutterPushRelease() {
    //udpClient.send("S"+getFilename(UPDATE, PHOTO_MODE));
    //gui.displayMessage(lastFilename, 45);
  }

  void takePhoto() {
    //udpClient.send("C"+getFilename(UPDATE, PHOTO_MODE));
    getFilename();
    gui.displayMessage(lastFilename, 45);
  }

  void sendMsg(String msg) {
    //    if (udpClient.active()) {
    //      udpClient.write(msg);
    //    }
  }

  void jogcw() {
    //udpClient.write("st key jog jog1_cw\n");
  }

  void jogccw() {
    //udpClient.write("st key jog jog1_ccw\n");
  }

  void screenshot(String filename) {
    if (DEBUG) println("screenshot("+filename+")");
    //if (udpClient.active()) {
    //  udpClient.write("/mnt/mmc/screenshot.sh\n");
    //}
  }

  boolean screenshot() {
    if (DEBUG) println("screenshot()");
    //if (!udpClient.active()) {
    //  return false;
    //}
    //udpClient.write("/mnt/mmc/screenshot.sh\n");
    return true;
  }

  void getFilename() {
    String aFilename = "IMG_"+ getFilename(SAME, PHOTO_MODE)+ "_"+suffix+".jpg";
    filename = aFilename;
    String afilenameUrl = "http://"+ipAddr + "/capture";
    afilenameUrl.trim();
    afilenameUrl = afilenameUrl.replaceAll("(\\r|\\n)", "");
    String afilename = filename.replaceAll("(\\r|\\n)", "");
    if (DEBUG) println("result filename = " + afilename + " filenameURL= "+afilenameUrl);
    //if (!afilenameUrl.equals(filenameUrl)) {
    //if ( lastPhoto == null || lastPhoto.width <= 0 || lastPhoto.height <=0) {
      filename = afilename.substring(afilename.lastIndexOf('/')+1);
      filenameUrl = afilenameUrl;
      lastPhoto = loadImage(filenameUrl, "jpg");
      if (DEBUG) println("TMC getFilename loadImage "+filenameUrl);
      if (lastPhoto == null || lastPhoto.width == -1 || lastPhoto.height == -1) {
        showPhoto = false;
        gui.displayMessage("Photo Missing or Read Error\n"+ filenameUrl, 60);
      } else {
        showPhoto = true;
      }
    //} else {
    //  //gui.displayMessage("Duplicate Photo \n"+ filenameUrl, 60);
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

  String number(int index) {
    // fix size of index number at 4 characters long
    if (index == 0)
      return "";
    else if (index < 10)
      return ("000" + String.valueOf(index));
    else if (index < 100)
      return ("00" + String.valueOf(index));
    else if (index < 1000)
      return ("0" + String.valueOf(index));
    return String.valueOf(index);
  }
}
