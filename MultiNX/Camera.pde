// Camera parameters and control

// Raspberry Pi Camera support uses libcamera library
// Camera types supported
static final int NX2000 = 0; // Samsung NX2000 Camera
static final int NX300 = 1; // Samsung NX300 Camera
static final int NX30 = 2; // Samsung NX30 Camera
static final int NX500 = 3; // Samsung NX500 Camera
static final int MRC = 4; // Multi Remmote Camera (Android Camera App)
//static final int IMX230 = 5; // Raspberry PI Arducam Pivariety 21 MP IMX230 Camera
static final int RPI = 5; // Raspberry PI Computer Camera: Tested with Arducam Pivariety 21 MP IMX230 Camera
static final int TMC = 6; // M5Stack Timer Camera
// Raspberry PI requires libcamera stack and web server at port 8080

static final String NX2000S = "NX2000"; // Samsung NX2000 Camera
static final String NX300S = "NX300"; // Samsung NX300 Camera
static final String NX30S = "NX30"; // Samsung NX30 Camera
static final String NX500S = "NX500"; // Samsung NX500 Camera
static final String MRCS = "MRC"; // Multi Remmote Camera (Android Camera App)
//static final String IMX230S = "IMX230"; // Raspberry PI Arducam Pivariety 21 MP IMX230 Camera
static final String RPIS = "RPI"; // Raspberry PI Computer Camera: Tested with Arducam Pivariety 21 MP IMX230 Camera
static final String TMCS = "TMC"; // M5Stack Timer Camera

static final int TelnetPort = 23; // telnet port
static final int SSHport = 22; // SSH port
static final int UDPport = 8000;  // UDP port for Multi Remmote Camera (Android Camera App)
static final String HTTPport = "8080";

// Camera modes
int MANUAL_MODE = 9;
int SMART_MODE = 5;
int cameraMode = MANUAL_MODE;
int selectedCameraMode = MANUAL_MODE;
String[] cameraModes ={"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m", "", ""};
String[] cameraKeyModes ={"Lens", "Magic", "WiFi", "Scene", "Movie", "Auto", "P", "A", "S", "M", "", ""};
String[] cameraKeyMRCModes ={"Photo", "Video", "", "", "", "", "", "", "", "", "", ""};
// setting "movie" mode does not function in NX2000 with shell command "st key mode"

// ISO common to NX2000, NX300, NX500
// iso index
String[] isoName = { "AUTO", "100", "200", "400", "800", "1600", "3200", "6400", "12800", "25600" };
String[] isoName3 = { "AUTO", "100", "125", "160", "200", "250", "320", "400", "500", "640", "800", "1000",
  "1250", "1600", "2000", "2500", "3200", "4000", "5000", "6400", "8000", "10000", "12800", "16000", "20000", "25600" };
int isoId = 1; // ISO 100

interface NXCommand {
  boolean isActive();
  int[] getCameraResult();
  void getCameraFnShutterEvISO();
  void touchFocus(int x, int y);
  void takePhoto();
  void sendMsg(String msg);
  void focusPush();
  void focusRelease();
  void shutterPushRelease();
  void touchBack();
  void record();
  void function();
  void home();
  void menu();
  void end();
  void playback();
  void ev();
  void jogcw();
  void jogccw();
  //void getCameraFnShutter();
  void screenshot(String filename);
  boolean screenshot();
  void getShutterCount();
  void cameraOk();
  void cameraLeft();
  void cameraRight();
  void cameraUp();
  void cameraDown();
  void cameraMode(int m);
  int getShutterSpeed();
  int getSsId(int value);
  int getSsId();
  String getSsName(int i);
  String getShutterName(int id);
  int getShutterNameLength();
  int getFn();
  String getFn(int id);
  String getFnName(int value);
  int getFnId(int value);
  int getFnId();
  int getFnLength();
  void save();
  void getPhotoFile();
  int getISO();
  int getEv();
  String getEvName();
  void updateFn();
  void updateSs();
  void updateIso();
  void setCameraFnShutterISO(int fnId, int shutterId, int isoId);
  void getCameraEv();
  void getPrefMem(int id, int offset, String type);
  void getPrefMemBlock(int id, int offset, int size);
  void toggleFilenamePrefix(String data);
}

abstract class RCamera implements NXCommand {
  int iso;
  int shutterSpeed;
  int fn;
  int ev;
  int port;
  boolean connected;
  String ipAddr;
  int shutterCount;
  int[] result;
  String name; // camera name
  String suffix; // camera name
  String filename = "";
  String filenameUrl = "";
  PImage lastPhoto;
  boolean needsRotation = false;
  int orientation;
  int horizontalOffset;
  int verticalOffset;
  String inString;
  String prompt;
  String prefix;
  String systemrw;
  String screenShot;
  float focusOffset;
  int type; // NX2000, NX500, NX300. MRC, RPI
  int screenWidth;
  int screenHeight;
  int shutterId;
  int fnId;
  int appId;
  int sysrwId;
  int appFnoIndex;
  int appShutterSpeedIndex;
  int appIsoPas;
  int appEvc;
  int sysrwShutterCount;
  String[] evName;
  int[] shutterValue;
  String[] shutterName;
  String[] fnName;
  int[] fnValue;
  Client client;

  boolean isConnected() {
    //println("Camera Client isConnected()="+connected);
    return connected;
  }

  boolean isActive() {
    if (client != null && client.active()) {
      return true;
    }
    return false;
  }

  void stop() {
    if (client != null && client.active()) {
      client.stop();
    }
  }

  void setConnected(boolean value) {
    connected = value;
  }

  void setName(String name) {
    this.name = name;
  }

  void setSuffix(String suffix) {
    this.suffix = suffix;
  }

  void setOrientation(int orientation) {
    this.orientation = orientation;
  }

  void setHorizontalOffset(int offset) {
    this.horizontalOffset = offset;
  }

  void setVerticalOffset(int offset) {
    this.verticalOffset = offset;
  }

  void jogccw() {
  }

  String getName() {
    return this.name;
  }

  int getSsId() {
    return shutterId;
  }

  int getFnId() {
    return fnId;
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
      } else {  // TODO retest for NX cameras and MRC
        return null;
      }
    }
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
          if (!filenameUrl.endsWith("/")) {
            //lastPhoto = loadImage(filenameUrl, "jpg");
            lastPhoto = requestImage(filenameUrl);
            if (DEBUG) println("requestImage "+filenameUrl);
            gui.displayMessage("Loading Photo ... "+ filenameUrl, 60);
            showPhoto = true;
          } else {
            if (DEBUG) println("Image url ends with / " + filenameUrl);
            showPhoto = false;
            gui.displayMessage("No Image File", 90);
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

  boolean decodeLong(String s, int[] result) {
    boolean decoded = false;
    int index = s.lastIndexOf("(0x");
    if (index >= 0) {
      //println(s.substring(index+3, index+11));
      result[0] = unhex(s.substring(index+3, index+11));
      decoded = true;
    }
    return decoded;
  }

  boolean decodeLongSequence(String s, int[] value ) {
    boolean decoded = true;
    int index = 0;
    for (int i=0; i<value.length; i++) {
      index = s.indexOf("(0x", index);
      if (index >= 0) {
        //println(s.substring(index+3, index+11));
        value[i] = unhex(s.substring(index+3, index+11));
        index += 8;
      } else {
        decoded = false;
        break;
      }
    }
    return decoded;
  }

  int getISO () {
    return iso;
  }

  int getEv () {
    return ev;
  }

  void setFnUpdate() {
    client.write(
      "st key mode "+ cameraModes[SMART_MODE]+
      ";sleep 1"+
      ";st key mode "+ cameraModes[MANUAL_MODE]+
      "\n");
  }

  int getShutterSpeed () {
    return shutterSpeed;
  }

  int getFn() {
    return fn;
  }

  void getPhotoFile() {
    if (client.active()) {
      client.write("FILENAME=`ls -t /mnt/mmc/DCIM/100PHOTO | head -1`;echo \"FILENAME=/DCIM/100PHOTO/$FILENAME\"\n");
    }
  }

  void focusPush() {
    client.write("st key push s1\n");
  }

  void focusRelease() {
    focus = false;
    if (client.active()) {
      client.write("st key release s1\n");
    }
  }

  void shutterPush() {
    client.write("st key push s2\n");
  }

  void shutterRelease() {
    client.write("st key release s2\n");
  }

  void record() {
    if (DEBUG) println("record()");
    client.write("st key click rec\n");
  }

  void end() {
    client.write("st key click end\n");
  }

  void menu() {
    client.write("st key click menu\n");
  }

  void cameraMode(int m) {
    client.write("st key mode "+ cameraModes[m]+";sleep 1\n");
    if (DEBUG) println("st key mode "+ cameraModes[m]+"\n");
  }

  void cameraInfo() {
    client.write("st key "+"\n");
  }

  void cameraOk() {
    client.write("st key click ok\n");
  }

  void cameraLeft() {
    client.write("st key click left\n");
  }

  void cameraRight() {
    client.write("st key click right\n");
  }

  void cameraUp() {
    client.write("st key click up\n");
  }

  void cameraDown() {
    client.write("st key click down\n");
  }

  void touchBack() {
    client.write("st key touch click 40 40\n");
  }

  void touchFocus(int x, int y) {
    if (DEBUG) println("touchFocus x="+x + " y="+y);
    client.write("st key touch click "+x +" "+ y+"\n");
  }

  void function() {
    client.write("st key click fn\n");
  }

  void home() {
    client.write("st key click scene\n");
  }

  void playback() {
    client.write("st key click pb\n");
  }

  boolean toggleEv = false;
  void ev() {
    toggleEv = !toggleEv;
    if (toggleEv) {
      client.write("st key push ev\n");
    } else {
      client.write("st key release ev\n");
    }
  }

  void shutterPushRelease() {
    client.write("st key push s2;st key release s2;st key release s1\n");
  }

  void takePhoto() {
    client.write("st key push s1;st key push s2;st key release s2;st key release s1\n");
  }

  void sendMsg(String msg) {
    if (client.active()) {
      client.write(msg);
    }
  }


  void getCameraFnShutterEvISO() {
    // common for NX2000, NX300, NX500
    if (client.active()) {
      client.write(
        "prefman get " + appId + " " +appFnoIndex + " l" +
        ";prefman get " + appId + " " +appShutterSpeedIndex + " l" +
        ";prefman get "+ appId + " " + appIsoPas + " l" +
        ";prefman get "+ appId + " " + appEvc + " l" +
        "\n");
    }
  }

  //void getCameraFnShutter() {
  //  client.write(
  //    "prefman get " + appId + " "  +appFnoIndex + " l" +
  //    ";prefman get "+ appId + " "  +appShutterSpeedIndex + " l" +
  //    "\n");
  //}

  void getCameraEv() {
    client.write(
      "prefman get "+ appId + " "  + appEvc + " l" +
      "\n");
  }

  String getEvName() {
    return evName[getEv()];
  }

  //void setCameraISO(int value) {
  //  iso = value;
  //  client.write("prefman set "+ appId + " "  + appIsoPas + " l " + iso + "\n");
  //}

  void setCameraFnShutterISO(int fnId, int shutterId, int isoId) {
    this.shutterSpeed = shutterValue[shutterId];
    this.fn = fnValue[fnId];
    this.iso = isoId;
    if (DEBUG) println(" setCameraFnShutter prefman set " + appId +" " +appFnoIndex + " l " + this.fn +
      ";prefman set "+ appId + " "  +appShutterSpeedIndex + " l " + this.shutterSpeed +
      ";prefman set "+ appId + " "  + appIsoPas + " l " + iso +
      //      ";prefman get "+ appId + " "  + appEvc + " l" +
      "\n");
    client.write(
      "prefman set "+ appId + " "  + appFnoIndex + " l " + this.fn +
      ";prefman set "+ appId + " "  + appShutterSpeedIndex + " l " + this.shutterSpeed +
      ";prefman set "+ appId + " "  + appIsoPas + " l " + iso +
      //      ";prefman get "+ appId + " "  + appEvc + " l" +
      ";st key mode "+ cameraModes[SMART_MODE]+
      ";sleep 1"+
      ";st key mode "+ cameraModes[MANUAL_MODE]+
      "\n");
  }

  int getSsId(int value) {
    int id = 0;
    for (int i=0; i<shutterValue.length; i++) {
      if (shutterValue[i] == value) {
        id = i;
        break;
      }
    }
    return id;
  }

  String getSsName(int value) {
    String name = "";
    for (int i=0; i<shutterValue.length; i++) {
      if (shutterValue[i] == value) {
        name = shutterName[i];
        break;
      }
    }
    return name;
  }

  String getShutterName( int id) {
    return shutterName[id];
  }

  int getShutterNameLength() {
    return shutterName.length;
  }

  String getFn(int id) {
    return fnName[id];
  }

  String getFnName(int value) {
    String name = "";
    for (int i=0; i<fnValue.length; i++) {
      if (fnValue[i] == value) {
        name = fnName[i];
        break;
      }
    }
    return name;
  }

  int getFnId(int value) {
    for (int i=0; i<fnValue.length; i++) {
      if (fnValue[i] == value) {
        return i;
      }
    }
    return 0;
  }

  int getFnLength() {
    return fnValue.length;
  }

  void save() {
    client.write("prefman save "+ appId + "\n");
    if (DEBUG) println("prefman save "+ appId + " ");
  }

  void getShutterCount() {
    if (DEBUG) println("get shutter count");
    client.write("prefman get "+sysrwId + " "+ sysrwShutterCount+" l\n");
    if (DEBUG) println("prefman get "+sysrwId + " "+ sysrwShutterCount+" l\n");
  }

  //void startFtp() {
  //  client.write("tcpsvd -vE 0.0.0.0 21 ftpd /mnt/mmc &\n");
  //}

  //void stopFtp() {
  //  client.write("\032\n");  // TODO need kill process
  //}

  //void startHttp() {
  //  client.write("httpd -h /mnt/mmc\n");
  //}

  //void stopHttp() {
  //  client.write("\n");  // TODO need kill process
  //}

  void sendDelay(int second) {
    client.write("sleep "+second+"\n");
  }

  void functionAndBack() {
    client.write("st key click fn;sleep 2;st key touch click 40 40\n");
  }

  void getPrefMem(int id, int offset, String type) {
    client.write("prefman get "+id+" "+offset+" "+ type+"\n");
  }

  void getPrefMemBlock(int id, int offset, int size) {
    client.write("prefman get "+id+" "+offset+" v="+size+"\n");
  }
  
  void toggleFilenamePrefix(String data) {
  }
}
