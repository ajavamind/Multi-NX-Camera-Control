// Raspberry Pi Computer Camera
// Tested with Arducam Pivariety IMX230 21 MP Camera
// Requires libCamera library framework on Raspberry PI OS - Buster legacy required tested with library from Arducam
// Does not invoke raspistill commands.

import netP5.*;
//import oscP5.*; // does not use this part of oscP5 library
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Locale;

import java.net.DatagramSocket;

class RPICamera extends RCamera {

  // LCD screen dimensions
  static final int SCREEN_WIDTH = 720;
  static final int SCREEN_HEIGHT = 480;
  static final float offsetPercent = 3.0; //6.5;

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
  SshClient sshClient; // SSH Client

  RPICamera(PApplet app, String ipAddr, String user, String password) {
    this.ipAddr = ipAddr;
    sshClient = null;
    port = SSHport;  // use SSH port with Raspberry Pi controlled cameras

    try {
      if (!testGui) {
        sshClient = new SshClient( app, ipAddr, port, user, password);
        if (DEBUG) println("SshClient host="+ ipAddr + " port=" + port);
      }
    }
    catch (Exception e) {
      if (DEBUG) println("Wifi problem");
      sshClient = null;
    }

    connected = false;
    if (sshClient != null) {
      connected = true;
    }

    client = sshClient;
    name = "";
    inString = "";
    prompt = "~$ "; // pi@raspberrypi:~$
    prefix = "pi@raspberrypi:";
    systemrw = "sysrw";
    screenShot = "/mnt/mmc/screenshot";
    focusOffset = screenWidth*(offsetPercent/100);
    type = RPI;
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

  Client getClient() {
    return sshClient;
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

  int[] getCameraResult() {
    //println("Camera getCameraResult "+ client.available());
    if (client.available() == 0) {
      return null;
    }

    while (!inString.endsWith(prompt)) {
      if (client.available() > 0) { 
        inString += client.readString(); 
        if (DEBUG) println("inString="+inString);
        if (inString.startsWith("exit")) {
          inString = "";
          return null;
        }
      } else {
        return null;
      }
    }

    // TODO update for RPI
    if (inString.startsWith("FILENAME=")) {
      if (DEBUG) println("FILENAME found");                       
      int fin = inString.lastIndexOf("FILENAME=");
      int lin = inString.lastIndexOf(prefix);
      if (fin > 0 && lin > 0) {
        String afilename = inString.substring(fin+9, lin);
        String afilenameUrl = "http://"+ipAddr+inString.substring(fin+9, lin);
        afilenameUrl.trim();
        afilenameUrl = afilenameUrl.replaceAll("(\\r|\\n)", "");
        afilename = afilename.replaceAll("(\\r|\\n)", "");
        if (DEBUG) println("result filename = " + afilename + " filenameURL= "+afilenameUrl);
        if (afilenameUrl.endsWith("SRW")) {
          afilenameUrl = afilenameUrl.replace("SRW", "JPG");
          afilename = afilename.replace("SRW", "JPG");
        }
        if (!afilenameUrl.equals(filenameUrl)) {
          filename = afilename.substring(afilename.lastIndexOf('/')+1);
          filenameUrl = afilenameUrl;
          lastPhoto = loadImage(filenameUrl, "jpg");
          if (DEBUG) println("loadImage "+filenameUrl);
          if (lastPhoto == null || lastPhoto.width == -1 || lastPhoto.height == -1) {
            showPhoto = false;
            gui.displayMessage("Photo Missing "+ filenameUrl, 60);
          } else {
            showPhoto = true;
          }
        } else {
          //gui.displayMessage("Duplicate Photo \n"+ filenameUrl, 60);
          if (DEBUG) println("same filename "+ afilenameUrl + " "+ filenameUrl);
        }
      }
      inString = "";
      return null;
    } else if (inString.startsWith(screenShot)) {
      lastKeyCode = KEYCODE_LOAD_SCREENSHOT;
    }
    if (inString.endsWith(prompt)) {
      String strFind = "memory:";
      int count = 0, fromIndex = 0;
      while ((fromIndex = inString.indexOf(strFind, fromIndex)) != -1 ) {
        count++;
        fromIndex++;
      }
      result = new int[count];
      if (count == 4 && decodeLongSequence(inString, result)) {
        for (int i=0; i<result.length; i++) {
          if (DEBUG) println("result="+result[i]);
        }
        fn = result[0];
        gui.fnTable.setFn(fn);

        shutterSpeed = result[1];
        gui.fnTable.setShutter(shutterSpeed);

        iso = result[2];
        gui.fnTable.setIso(iso);

        ev = result[3];
        lastKeyCode = KEYCODE_FN_ZONE_UPDATE;
      } else if (count == 1) {
        if (decodeLong(inString, result)) {
          if (DEBUG) println("result="+result[0]);
          if (inString.indexOf(systemrw)>0) {
            shutterCount = result[0];
          }
        }
      } else if (count == 3) {
        lastKeyCode = KEYCODE_FN_ZONE_REFRESH;
      } else if (count > 4) {
        if (decodeLongSequence(inString, result)) {
          for (int j=0; j<count; j++)
            if (DEBUG) println("result="+result[j]);
        }
      }
    }
    inString = "";
    return result;
  }

  /**
   * get filename for RPI
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
    if (client != null) {
      return true;
    }
    return false;
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
    client.write("libcamera-still -t 0 -n -k -o "+getFilename(UPDATE, PHOTO_MODE) + "\n");
    client.write("F\n");
    focus = true;
  }

  void focusRelease() {
    if (focus) {
      char ctrl_C = 0x03;
      client.write(Character.toString(ctrl_C));
    }
    focus = false;
  }

  void shutterPush() {
  }

  void shutterRelease() {
    focus = false;
  }

  void shutterPushRelease() {
    if (focus) {
      client.write("\n");
      gui.displayMessage(lastFilename, 45);
    }
  }

  void takePhoto() {
    client.write("libcamera-still -t 1 -n --autofocus -o "+"Media/IMG_"+getFilename(UPDATE, PHOTO_MODE) + "_"+name+".jpg" + "\n");
    gui.displayMessage(lastFilename, 45);
  }

  void record() {
    client.write("libcamera-vid -t 10000 -n --autofocus --width 1920 --height 1080 -o "+"Media/IMG_"+getFilename(UPDATE, PHOTO_MODE) + "_"+name+".h264" + "\n");
    gui.displayMessage(lastFilename, 45);
  }

  void end() {
  }

  void menu() {
  }

  void cameraMode(int m) {
    if (DEBUG) println("cameraModes[m]\n");
  }

  void cameraInfo() {
    if (DEBUG) println("cameraInfo\n");
  }

  void cameraOk() {
    if (DEBUG) println("OK\n");
    client.write("\n"); // pause in video mode
  }

  void touchBack() {
  }

  void touchFocus(int x, int y) {
    if (DEBUG) println("touchFocus x="+x + " y="+y);
  }

  void function() {
  }

  void home() {
    useTimeStamp = !useTimeStamp;
    if (useTimeStamp) {
      gui.displayMessage("Date-Time Filename Prefix", 45);
    } else {
      gui.displayMessage("Counter Number Filename Prefix", 45);
    }
  }

  void playback() {
  }

  boolean toggleEv = false;
  void ev() {
    toggleEv = !toggleEv;
    if (toggleEv) {
      //client.write("st key push ev\n");
    } else {
      //client.write("st key release ev\n");
    }
  }

  void sendMsg(String msg) {
    //    if (client.active()) {
    //      client.write(msg);
    //    }
  }

  void jogcw() {
  }

  void jogccw() {
  }

  void screenshot(String filename) {
    if (DEBUG) println("screenshot("+filename+")");
    //if (client.active()) {
    //  client.write("/mnt/mmc/screenshot.sh\n");
    //}
  }

  boolean screenshot() {
    if (DEBUG) println("screenshot()");
    //if (!client.active()) {
    //  return false;
    //}
    //client.write("/mnt/mmc/screenshot.sh\n");
    return true;
  }

  void getFilename() {
    String aFilename = getFilename(SAME, PHOTO_MODE)+ "_"+name+".jpg";
    String afilenameUrl = "http://"+ipAddr + ":" + HTTPport + "/" + "IMG_"+ aFilename;
    afilenameUrl.trim();
    afilenameUrl = afilenameUrl.replaceAll("(\\r|\\n)", "");
    String afilename = filename.replaceAll("(\\r|\\n)", "");
    if (DEBUG) println("result filename = " + afilename + " filenameURL= "+afilenameUrl);
    if (!afilenameUrl.equals(filenameUrl)) {
      filename = afilename.substring(afilename.lastIndexOf('/')+1);
      filenameUrl = afilenameUrl;
      lastPhoto = loadImage(filenameUrl, "jpg");
      if (DEBUG) println("OCR getFilename loadImage "+filenameUrl);
      if (lastPhoto == null || lastPhoto.width == -1 || lastPhoto.height == -1) {
        showPhoto = false;
        gui.displayMessage("Photo Missing \n"+ filenameUrl, 60);
      } else {
        showPhoto = true;
      }
    } else {
      //gui.displayMessage("Duplicate Photo \n"+ filenameUrl, 60);
      if (DEBUG) println("same filename "+ afilenameUrl + " "+ filenameUrl);
    }
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
