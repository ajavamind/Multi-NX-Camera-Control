// Camera parameters and control

// Camera types supported
static final int NX2000 = 0;
static final int NX300 = 1;
static final int NX500 = 2;

// Camera modes
int MANUAL_MODE = 9;
int SMART_MODE = 5;
int cameraMode = MANUAL_MODE;
int selectedCameraMode = MANUAL_MODE;
String[] cameraModes ={"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m", "", ""};
String[] cameraKeyModes ={"Lens", "Magic", "WiFi", "Scene", "Movie", "Auto", "P", "A", "S", "M", "", ""};
// setting "movie" mode does not function in NX2000 with "st key mode"

// ISO common to NX2000, NX300, NX500
String[] isoName = { "AUTO", "100", "200", "400", "800", "1600", "3200", "6400", "12800", "25600" };
String[] isoName3 = { "AUTO", "100", "125", "160", "200", "250", "320", "400", "500", "640", "800", "1000", 
  "1250", "1600", "2000", "2500", "3200", "4000", "5000", "6400", "8000", "10000", "12800", "16000", "20000", "25600" };
int isoId = 1;

interface NXCommand {
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
  void getCameraFnShutter();
  void screenshot(String filename);
  boolean screenshot();
  void getShutterCount();
  void cameraOk();
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
  void getFilename();
  int getISO();
  int getEv();
  String getEvName();
  void updateFn();
  void setCameraFnShutterISO(int fnId, int shutterId, int isoId);
  void getCameraEv();
  void getPrefMem(int id, int offset, String type);
  void getPrefMemBlock(int id, int offset, int size);
}

abstract class NXCamera implements NXCommand {
  int iso;
  int shutterSpeed;
  int fn;
  int ev;
  Client client;
  boolean connected;
  String ipAddr;
  int shutterCount;
  int[] result;
  String name;
  String filename = "";
  String filenameUrl = "";
  PImage lastPhoto;
  String inString;
  String prompt;
  String prefix;
  float focusOffset;
  int type; // NX2000, NX500
  int screenWidth;
  int screenHeight;
  int shutterId;
  int fnId;

  boolean isConnected() {
    return connected;
  }

  void setConnected(boolean value) {
    connected = value;
  }

  void setName(String name) {
    this.name = name;
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
}

class NX2000Camera extends NXCamera {
  /**
   0 : system
   1 : application
   2 : line
   3 : system_rw
   */

  static final int SYSID = 0;
  static final int APPID = 1;
  static final int LINEID = 2;
  static final int SYSRWID = 3;

  // application
  static final int APPPREF_FNO_INDEX = 0x00000008;
  static final int APPPREF_FNO_INDEX_OTHER_MODE = 0x0000000C;
  static final int APPPREF_SHUTTER_SPEED_INDEX = 0x00000010; 
  static final int APPPREF_SHUTTER_SPEED_INDEX_OTHER_MODE = 0x00000014;
  static final int APPPREF_EVC = 0x00000018 ;
  static final int APPPREF_ISO_PAS = 0x00000064;
  static final int APPPREF_B_DISABLE_MOVIE_REC_LIMIT =  0x00000308; 
  static final int APPPREF_B_ENABLE_NO_LENS_RELEASE = 0x0000030c;

  // System rw
  static final int SYSRWPREF_SHUTTER_COUNT = 0x00000008;  

  // LCD screen dimensions
  static final int SCREEN_WIDTH = 800;
  static final int SCREEN_HEIGHT = 480;
  static final float offsetPercent = 3.0; //6.5;

  final String[] shutterName = { "Bulb", "30\"", "25\"", "20\"", "15\"", "13\"", "10\"", "8\"", "6\"", "5\"", 
    "4\"", "3\"", "2.5\"", "2\"", "1.6\"", "1.3\"", "1\"", "0.8\"", "0.6\"", "0.5\"", 
    "0.4\"", "0.3\"", "1/4", "1/5", "1/6", "1/8", "1/10", "1/13", "1/15", "1/20", 
    "1/25", "1/30", "1/40", "1/50", "1/60", "1/80", "1/100", "1/125", "1/160", "1/200", 
    "1/250", "1/320", "1/400", "1/500", "1/640", "1/800", "1/1000", "1/1250", "1/1600", "1/2000", 
    "1/2500", "1/3200", "1/4000"
    , "1/5000", "1/6000"
  };
  final int[] shutterValue = { -80, -80, -75, -69, -64, -59, -53, -48, -43, -37, 
    -32, -27, -21, -16, -11, -5, 0, 5, 11, 16, 
    21, 27, 32, 37, 43, 48, 53, 59, 64, 69, 
    75, 80, 85, 91, 96, 101, 107, 112, 117, 123, 
    128, 133, 139, 144, 149, 155, 160, 165, 171, 176, 
    181, 187, 192
    , 192, 192
//    , 197, 202
};

// other lens available may have minimum F-stops: F1.4 F1.8 F2 

  final String[] fnName = { "F2.4", "F2.8", "F3.2", "F3.5", "F4.0", "F4.5", "F5.0", 
    "F5.6", "F6.3", "F7.1", "F8.0", 
    "F9.0", "F10", "F11", "F13", 
    "F14", "F16", "F18", "F20", "F22" };
    
  final int[] fnValue = {58, 58, 58, 58, 64, 69, 75, 
    80, 85, 91, 96, 
    101, 107, 112, 117, 
    123, 128, 133, 139, 144 };

  final String[] evName = { "-3.0", "-2.6", "-2.3", "-2.0", "-1.6", "-1.3", "-1.0", "-0.6", "-0.3", 
    "0.0", "+0.3", "+0.6", "+1.0", "+1.3", "+1.6", "+2.0", "+2.3", "+2.6", "+3.0" };
  //int evId = 9;

  NX2000Camera(String ipAddr, Client client) {
    this.ipAddr = ipAddr;
    this.client = client;
    connected = false;
    name = "";
    inString = "";
    prompt = "nx2000:/# ";
    prefix = "nx2000";
    focusOffset = screenWidth*(offsetPercent/100);
    type = NX2000;
    shutterId = 1;
    fnId = 10;
    screenWidth = SCREEN_WIDTH;
    screenHeight = SCREEN_HEIGHT;
  }

  int[] getCameraResult() {
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
      }
    }
    if (inString.startsWith("FILENAME=")) {
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
          showPhoto = true;
        } else {
          if (DEBUG) println("same filename "+ afilenameUrl + " "+ filenameUrl);
        }
      }
      inString = "";
      return null;
    } else if (inString.startsWith("screenshot")) {
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
          if (inString.indexOf("system_rw")>0) {
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

  void getCameraFnShutterEvISO() {
    if (client.active()) {
      client.write(  
        "prefman get 1 " +APPPREF_FNO_INDEX + " l" + 
        ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
        ";prefman get 1 " + APPPREF_ISO_PAS + " l" +
        ";prefman get 1 " + APPPREF_EVC + " l" +
        "\n");
    }
  }

  void getCameraFnShutter() {
    client.write(  
      "prefman get 1 " +APPPREF_FNO_INDEX + " l" + 
      ";prefman get 1 " +APPPREF_FNO_INDEX_OTHER_MODE + " l" + 
      ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
      ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX_OTHER_MODE + " l" +
      "\n");
  }

  void getCameraEv() {
    client.write(  
      "prefman get 1 " + APPPREF_EVC + " l" +
      "\n");
  }

  int getISO () {
    return iso;
  }

  int getEv () {
    return ev;
  }

  String getEvName() {
    return evName[getEv()];
  }

  //void setCameraISO(int value) {
  //  iso = value;
  //  client.write("prefman set 1 " + APPPREF_ISO_PAS + " l " + iso + "\n");
  //}

  void setCameraFnShutterISO(int fnId, int shutterId, int isoId) {
    this.shutterSpeed = shutterValue[shutterId];
    this.fn = fnValue[fnId];
    this.iso = isoId;
    if (DEBUG) println("prefman set 1 " +APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set 1 " + APPPREF_ISO_PAS + " l " + iso +
      //      ";prefman get 1 " + APPPREF_EVC + " l" +
      "\n");
    client.write(
      "prefman set 1 " + APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set 1 " + APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set 1 " + APPPREF_ISO_PAS + " l " + iso +
      //      ";prefman get 1 " + APPPREF_EVC + " l" +
      ";st key mode "+ cameraModes[SMART_MODE]+
      ";sleep 1"+
      ";st key mode "+ cameraModes[MANUAL_MODE]+
      "\n");
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

  int getFn() {
    return fn;
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
    client.write("prefman save 1\n");
    if (DEBUG) println("prefman save 1");
  }

  void getFilename() {
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

  void jogcw() {
    client.write("st key jog cw\n");
  }

  void jogccw() {
    client.write("st key jog ccw\n");
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

  void screenshot(String filename) {
    client.write("screenshot bmp /mnt/mmc/"+filename+convertCounter(screenshotCounter)+"_"+name+".bmp\n");
  }

  boolean screenshot() {
    if (!client.active()) {
      return false;
    }
    client.write("screenshot bmp /mnt/mmc/screenshot.bmp\n");
    return true;
  }

  void getShutterCount() {
    if (DEBUG) println("get shutter count");
    client.write("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
    if (DEBUG) println("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
  }

  void getPrefMem(int id, int offset, String type) {
    client.write("prefman get "+id+" "+offset+" "+ type+"\n");
  }

  void getPrefMemBlock(int id, int offset, int size) {
    client.write("prefman get "+id+" "+offset+" v="+size+"\n");
    //prefman get 1 8 v=96
  }

  void updateFn() {
    if (DEBUG) println("updateFn()");
    int currentFnId = getFnId(getFn());
    int nextFnId = fnId;
    int count = nextFnId - currentFnId;
    if (DEBUG) println("jog count="+count);
    if (count == 0) {
      return;
    }
    String jog = "ccw";
    if (count < 0) {
      count = -count;
      jog = "cw";
    }
    String cmd = "st key click ev" +
      ";st key click ev";
    for (int i=0; i<count; i++) {
      cmd += ";st key jog "+jog;
    }
    cmd += ";st key click ev;st key click ev\n";
    client.write(cmd);
  }
}


class NX500Camera extends NXCamera {
  /**
   0 : app
   1 : app_restore
   2 : line
   3 : sysrw
   */

  static final int APPID = 0;
  static final int APP_RESTOREID = 1;
  static final int LINEID = 2;
  static final int SYSRWID = 3;

  /* application
   ------------------------------------------------
   Offset    Size    Name    [app]
   ------------------------------------------------
   0x00000200    0004    APPPREF_LANGUAGE
   0x00000204    0004    APPPREF_FILE_NAME
   0x00000208    0004    APPPREF_FILE_NO
   0x0000020c    0004    APPPREF_FOLDER_TYPE
   0x00000210    0004    APPPREF_Q_VIEW
   0x00000214    0004    APPPREF_DISP_ADJUST
   0x00000218    0004    APPPREF_DISP_BRIGHT_LEVEL
   0x0000021c    0004    APPPREF_DISP_BRIGHT_LEVEL_EVF
   0x00000220    0004    APPPREF_DISP_AUTO_BRIGHT
   0x00000224    0004    APPPREF_DISP_COLOR_XY
   0x00000228    0004    APPPREF_DISP_COLOR_XY_EVF
   0x0000022c    0004    APPPREF_DISPLAY_SAVE
   0x00000230    0004    APPPREF_POWER_SAVE
   0x00000234    0004    APPPREF_TIMEZONE
   0x00000238    0004    APPPREF_SUMMER_TIME
   0x0000023c    0004    APPPREF_DATE_TYPE
   0x00000240    0004    APPPREF_TIME_TYPE
   0x00000244    0004    APPPREF_IMPRINT
   0x00000248    0004    APPPREF_HELP_DISPLAY
   0x0000024c    0004    APPPREF_HELP_DISPLAY_CE_SHOW
   0x00000250    0004    APPPREF_SOUND_VOLUME
   0x00000254    0004    APPPREF_AF_SOUND
   0x00000258    0004    APPPREF_BUTTON_SOUND
   0x0000025c    0004    APPPREF_SENSOR_CLEANING_POWER_ON
   0x00000260    0004    APPPREF_VIDEO_OUT
   0x00000264    0004    APPPREF_ANYNET
   0x00000268    0004    APPPREF_HDMI_SIZE
   0x0000026c    0004    APPPREF_E_3D_HDMI_OUTPUT
   0x00000270    0004    APPPREF_MODEDIAL_BG_ONOFF
   0x00000274    0004    APPPREF_SENSOR_CLEANING_END
   0x00000278    0004    APPPREF_QUICK_PANEL_DISPLAY
   0x0000027c    0004    APPPREF_E_SHUTTER_SHOUND
   0x00000280    0004    APPPREF_WIFI_SENDING_SIZE
   0x00000284    0004    APPPREF_DUAL_BAND_MOBILE_AP
   0x00000288    0004    APPPREF_BLUETOOTH_AUTO_TIME_SET
   0x0000028c    0004    APPPREF_WIFI_PRIVACY_LOCK
   0x00000290    0004    APPPREF_RESET_TYPE
   0x00000294    0004    APPPREF_MY_SMART_PHONE
   0x00000298    0004    APPPREF_BATTERY_SELECTION
   0x0000029c    0004    APPPREF_EVF_KEY_INTERACTION
   0x000002a0    0004    APPPREF_BLUETOOTH_ON_OFF
   0x000002a4    0004    APPPREF_UD_CLEAN_OUT
   0x000002a8    0004    APPPREF_KEY_MAPPING_PREVIEW
   0x000002ac    0004    APPPREF_KEY_MAPPING_AEL
   0x000002b0    0004    APPPREF_KEY_MAPPING_AFON
   0x000002b4    0004    APPPREF_KEY_MAPPING_LEFT
   0x000002b8    0004    APPPREF_KEY_MAPPING_RIGHT
   0x000002bc    0004    APPPREF_KEY_MAPPING_DOWN
   0x000002c0    0004    APPPREF_KEY_MAPPING_COMMAND1
   0x000002c4    0004    APPPREF_KEY_MAPPING_COMMAND2
   0x000002c8    0004    APPPREF_KEY_MAPPING_WHEEL
   0x000002cc    0004    APPPREF_KEY_MAPPING_HALF_SHUTTER
   0x000002d0    0004    APPPREF_KEY_MAPPING_CUSTOM
   0x000002d4    0004    APPPREF_KEY_MAPPING_EV
   0x000002d8    0004    APPPREF_CUSTOM_MODE_1_PRESET
   0x000002dc    0004    APPPREF_CUSTOM_MODE_2_PRESET
   0x000002e0    0004    APPPREF_CMODE_PRESET_ID
   0x000002e4    1000    APPPREF_USER_MODE_SETTING0
   0x000006cc    1000    APPPREF_USER_MODE_SETTING1
   0x00000ab4    1000    APPPREF_USER_MODE_SETTING2
   0x00000e9c    1000    APPPREF_USER_MODE_SETTING3
   0x00001284    1000    APPPREF_USER_MODE_SETTING4
   0x0000166c    1000    APPPREF_USER_MODE_SETTING5
   0x00001a54    1000    APPPREF_USER_MODE_SETTING6
   0x00001e3c    1000    APPPREF_USER_MODE_SETTING7
   0x00002224    1000    APPPREF_USER_MODE_SETTING8
   0x0000260c    1000    APPPREF_USER_MODE_SETTING9
   0x000029f4    1000    APPPREF_USER_MODE_SETTING10
   0x00002ddc    1000    APPPREF_USER_MODE_SETTING11
   0x000031c4    1000    APPPREF_USER_MODE_SETTING12
   0x000035ac    1000    APPPREF_USER_MODE_SETTING13
   0x00003994    1000    APPPREF_USER_MODE_SETTING14
   0x00003d7c    1000    APPPREF_USER_MODE_SETTING15
   0x00004164    1000    APPPREF_USER_MODE_SETTING16
   0x0000454c    1000    APPPREF_USER_MODE_SETTING17
   0x00004934    1000    APPPREF_USER_MODE_SETTING18
   0x00004d1c    1000    APPPREF_USER_MODE_SETTING19
   0x00005104    1000    APPPREF_USER_MODE_SETTING20
   0x000054ec    1000    APPPREF_USER_MODE_SETTING21
   0x000058d4    1000    APPPREF_USER_MODE_SETTING22
   0x00005cbc    1000    APPPREF_USER_MODE_SETTING23
   0x000060a4    1000    APPPREF_USER_MODE_SETTING24
   0x0000648c    1000    APPPREF_USER_MODE_SETTING25
   0x00006874    1000    APPPREF_USER_MODE_SETTING26
   0x00006c5c    1000    APPPREF_USER_MODE_SETTING27
   0x00007044    1000    APPPREF_USER_MODE_SETTING28
   0x0000742c    1000    APPPREF_USER_MODE_SETTING29
   0x00007814    1000    APPPREF_USER_MODE_SETTING30
   0x00007bfc    1000    APPPREF_USER_MODE_SETTING31
   0x00007fe4    1000    APPPREF_USER_MODE_SETTING32
   0x000083cc    1000    APPPREF_USER_MODE_SETTING33
   0x000087b4    1000    APPPREF_USER_MODE_SETTING34
   0x00008b9c    1000    APPPREF_USER_MODE_SETTING35
   0x00008f84    1000    APPPREF_USER_MODE_SETTING36
   0x0000936c    1000    APPPREF_USER_MODE_SETTING37
   0x00009754    1000    APPPREF_USER_MODE_SETTING38
   0x00009b3c    1000    APPPREF_USER_MODE_SETTING39
   0x00009f24    1000    APPPREF_USER_MODE_SETTING_TEMP
   0x0000a30c    0004    APPPREF_PB_VOLUME
   0x0000a310    0004    APPPREF_PB_OVER_EXPOSURE_GUIDE
   0x0000a314    0004    APPPREF_PB_AUTO_ROTATE
   0x0000a318    0004    APPPREF_PB_DISPLAY_SET
   0x0000a31c    0004    APPPREF_PB_SHARE
   0x0000a320    0004    APPPREF_PB_MENU_SLIDESHOW_PLAY_MODE
   0x0000a324    0004    APPPREF_PB_MENU_SLIDESHOW_INTERVAL
   0x0000a328    0004    APPPREF_PB_MENU_SLIDEHSOW_MUSIC
   0x0000a32c    0004    APPPREF_PB_MENU_SLIDEHSOW_EFFECT
   0x0000a330    0004    APPPREF_PB_MENU_SORT_FLIE
   0x0000a334    0004    APPPREF_PB_MENU_VIEW_FOLDER
   0x0000a338    0004    APPPREF_FNO_INDEX
   0x0000a33c    0004    APPPREF_I_DEPTH_AV
   0x0000a340    0004    APPPREF_SHUTTER_SPEED_INDEX
   0x0000a344    0004    APPPREF_EVC
   0x0000a348    0004    APPPREF_DISPLAY_SET
   0x0000a34c    0004    APPPREF_SMART_MODE
   0x0000a350    0004    APPPREF_PHOTO_SIZE
   0x0000a354    0004    APPPREF_PHOTO_SIZE_3D
   0x0000a358    0004    APPPREF_PHOTO_SIZE_BEST_FACE
   0x0000a35c    0004    APPPREF_PHOTO_SIZE_WIFI_RVF
   0x0000a360    0004    APPPREF_MOV_SIZE
   0x0000a364    0004    APPPREF_MOV_SIZE_3D
   0x0000a368    0004    APPPREF_MOV_QUALITY
   0x0000a36c    0004    APPPREF_MOV_MULTI_MOTION
   0x0000a370    0004    APPPREF_MOV_MULTI_MOTION_MINI
   0x0000a374    0004    APPPREF_MOV_FADER
   0x0000a378    0004    APPPREF_MOV_VOICE
   0x0000a37c    0004    APPPREF_MOV_WIND_CUT
   0x0000a380    0004    APPPREF_MOV_SMART_RANGE
   0x0000a384    0004    APPPREF_QUALITY
   0x0000a388    0004    APPPREF_ISO_PAS
   0x0000a38c    0004    APPPREF_ISO_PAS_1_3
   0x0000a390    0004    APPPREF_WB_TYPE
   0x0000a394    0004    APPPREF_WB_K_VALUE
   0x0000a398    0004    APPPREF_WB_AUTO_DETAIL_BA_XY
   0x0000a39c    0004    APPPREF_WB_AUTO_TUNGSTEN_BA_XY
   0x0000a3a0    0004    APPPREF_WB_DAYLIGHT_DETAIL_BA_XY
   0x0000a3a4    0004    APPPREF_WB_CLODY_DETAIL_BA_XY
   0x0000a3a8    0004    APPPREF_WB_FLUORESCNTW_DETAIL_BA_XY
   0x0000a3ac    0004    APPPREF_WB_FLUORESCNTN_DETAIL_BA_XY
   0x0000a3b0    0004    APPPREF_WB_FLUORESCNTD_DETAIL_BA_XY
   0x0000a3b4    0004    APPPREF_WB_TUNGSTEN_DETAIL_BA_XY
   0x0000a3b8    0004    APPPREF_WB_FLASH_DETAIL_BA_XY
   0x0000a3bc    0004    APPPREF_WB_CUSTOM_DETAIL_BA_XY
   0x0000a3c0    0004    APPPREF_WB_K_DETAIL_BA_XY
   0x0000a3c4    0004    APPPREF_CWB_RED
   0x0000a3c8    0004    APPPREF_CWB_GREEN
   0x0000a3cc    0004    APPPREF_CWB_BLUE
   0x0000a3d0    0004    APPPREF_EFFECT_SMART_FILTER
   0x0000a3d4    0004    APPPREF_EFFECT_PW_TYPE
   0x0000a3d8    0004    APPPREF_EFFECT_OFF_COLOR
   0x0000a3dc    0004    APPPREF_EFFECT_OFF_SATURATION
   0x0000a3e0    0004    APPPREF_EFFECT_OFF_SHARPNESS
   0x0000a3e4    0004    APPPREF_EFFECT_OFF_CONTRAST
   0x0000a3e8    0004    APPPREF_EFFECT_OFF_HUE
   0x0000a3ec    0004    APPPREF_EFFECT_STANDARD_R_COLOR
   0x0000a3f0    0004    APPPREF_EFFECT_VIVID_R_COLOR
   0x0000a3f4    0004    APPPREF_EFFECT_PORTRAIT_R_COLOR
   0x0000a3f8    0004    APPPREF_EFFECT_LANDSCAPE_R_COLOR
   0x0000a3fc    0004    APPPREF_EFFECT_FOREST_R_COLOR
   0x0000a400    0004    APPPREF_EFFECT_RETRO_R_COLOR
   0x0000a404    0004    APPPREF_EFFECT_COOL_R_COLOR
   0x0000a408    0004    APPPREF_EFFECT_CALM_R_COLOR
   0x0000a40c    0004    APPPREF_EFFECT_CLASSIC_R_COLOR
   0x0000a410    0004    APPPREF_EFFECT_CUSTOM_1_R_COLOR
   0x0000a414    0004    APPPREF_EFFECT_CUSTOM_2_R_COLOR
   0x0000a418    0004    APPPREF_EFFECT_CUSTOM_3_R_COLOR
   0x0000a41c    0004    APPPREF_EFFECT_CUSTOM_4_R_COLOR
   0x0000a420    0004    APPPREF_EFFECT_STANDARD_G_COLOR
   0x0000a424    0004    APPPREF_EFFECT_VIVID_G_COLOR
   0x0000a428    0004    APPPREF_EFFECT_PORTRAIT_G_COLOR
   0x0000a42c    0004    APPPREF_EFFECT_LANDSCAPE_G_COLOR
   0x0000a430    0004    APPPREF_EFFECT_FOREST_G_COLOR
   0x0000a434    0004    APPPREF_EFFECT_RETRO_G_COLOR
   0x0000a438    0004    APPPREF_EFFECT_COOL_G_COLOR
   0x0000a43c    0004    APPPREF_EFFECT_CALM_G_COLOR
   0x0000a440    0004    APPPREF_EFFECT_CLASSIC_G_COLOR
   0x0000a444    0004    APPPREF_EFFECT_CUSTOM_1_G_COLOR
   0x0000a448    0004    APPPREF_EFFECT_CUSTOM_2_G_COLOR
   0x0000a44c    0004    APPPREF_EFFECT_CUSTOM_3_G_COLOR
   0x0000a450    0004    APPPREF_EFFECT_CUSTOM_4_G_COLOR
   0x0000a454    0004    APPPREF_EFFECT_STANDARD_B_COLOR
   0x0000a458    0004    APPPREF_EFFECT_VIVID_B_COLOR
   0x0000a45c    0004    APPPREF_EFFECT_PORTRAIT_B_COLOR
   0x0000a460    0004    APPPREF_EFFECT_LANDSCAPE_B_COLOR
   0x0000a464    0004    APPPREF_EFFECT_FOREST_B_COLOR
   0x0000a468    0004    APPPREF_EFFECT_RETRO_B_COLOR
   0x0000a46c    0004    APPPREF_EFFECT_COOL_B_COLOR
   0x0000a470    0004    APPPREF_EFFECT_CALM_B_COLOR
   0x0000a474    0004    APPPREF_EFFECT_CLASSIC_B_COLOR
   0x0000a478    0004    APPPREF_EFFECT_CUSTOM_1_B_COLOR
   0x0000a47c    0004    APPPREF_EFFECT_CUSTOM_2_B_COLOR
   0x0000a480    0004    APPPREF_EFFECT_CUSTOM_3_B_COLOR
   0x0000a484    0004    APPPREF_EFFECT_CUSTOM_4_B_COLOR
   0x0000a488    0004    APPPREF_EFFECT_STANDARD_HUE
   0x0000a48c    0004    APPPREF_EFFECT_VIVID_HUE
   0x0000a490    0004    APPPREF_EFFECT_PORTRAIT_HUE
   0x0000a494    0004    APPPREF_EFFECT_LANDSCAPE_HUE
   0x0000a498    0004    APPPREF_EFFECT_FOREST_HUE
   0x0000a49c    0004    APPPREF_EFFECT_RETRO_HUE
   0x0000a4a0    0004    APPPREF_EFFECT_COOL_HUE
   0x0000a4a4    0004    APPPREF_EFFECT_CALM_HUE
   0x0000a4a8    0004    APPPREF_EFFECT_CLASSIC_HUE
   0x0000a4ac    0004    APPPREF_EFFECT_CUSTOM_1_HUE
   0x0000a4b0    0004    APPPREF_EFFECT_CUSTOM_2_HUE
   0x0000a4b4    0004    APPPREF_EFFECT_CUSTOM_3_HUE
   0x0000a4b8    0004    APPPREF_EFFECT_CUSTOM_4_HUE
   0x0000a4bc    0004    APPPREF_EFFECT_STANDARD_SATURATION
   0x0000a4c0    0004    APPPREF_EFFECT_VIVID_SATURATION
   0x0000a4c4    0004    APPPREF_EFFECT_PORTRAIT_SATURATION
   0x0000a4c8    0004    APPPREF_EFFECT_LANDSCAPE_SATURATION
   0x0000a4cc    0004    APPPREF_EFFECT_FOREST_SATURATION
   0x0000a4d0    0004    APPPREF_EFFECT_RETRO_SATURATION
   0x0000a4d4    0004    APPPREF_EFFECT_COOL_SATURATION
   0x0000a4d8    0004    APPPREF_EFFECT_CALM_SATURATION
   0x0000a4dc    0004    APPPREF_EFFECT_CLASSIC_SATURATION
   0x0000a4e0    0004    APPPREF_EFFECT_CUSTOM_1_SATURATION
   0x0000a4e4    0004    APPPREF_EFFECT_CUSTOM_2_SATURATION
   0x0000a4e8    0004    APPPREF_EFFECT_CUSTOM_3_SATURATION
   0x0000a4ec    0004    APPPREF_EFFECT_CUSTOM_4_SATURATION
   0x0000a4f0    0004    APPPREF_EFFECT_STANDARD_SHARPNESS
   0x0000a4f4    0004    APPPREF_EFFECT_VIVID_SHARPNESS
   0x0000a4f8    0004    APPPREF_EFFECT_PORTRAIT_SHARPNESS
   0x0000a4fc    0004    APPPREF_EFFECT_LANDSCAPE_SHARPNESS
   0x0000a500    0004    APPPREF_EFFECT_FOREST_SHARPNESS
   0x0000a504    0004    APPPREF_EFFECT_RETRO_SHARPNESS
   0x0000a508    0004    APPPREF_EFFECT_COOL_SHARPNESS
   0x0000a50c    0004    APPPREF_EFFECT_CALM_SHARPNESS
   0x0000a510    0004    APPPREF_EFFECT_CLASSIC_SHARPNESS
   0x0000a514    0004    APPPREF_EFFECT_CUSTOM_1_SHARPNESS
   0x0000a518    0004    APPPREF_EFFECT_CUSTOM_2_SHARPNESS
   0x0000a51c    0004    APPPREF_EFFECT_CUSTOM_3_SHARPNESS
   0x0000a520    0004    APPPREF_EFFECT_CUSTOM_4_SHARPNESS
   0x0000a524    0004    APPPREF_EFFECT_STANDARD_CONTRAST
   0x0000a528    0004    APPPREF_EFFECT_VIVID_CONTRAST
   0x0000a52c    0004    APPPREF_EFFECT_PORTRAIT_CONTRAST
   0x0000a530    0004    APPPREF_EFFECT_LANDSCAPE_CONTRAST
   0x0000a534    0004    APPPREF_EFFECT_FOREST_CONTRAST
   0x0000a538    0004    APPPREF_EFFECT_RETRO_CONTRAST
   0x0000a53c    0004    APPPREF_EFFECT_COOL_CONTRAST
   0x0000a540    0004    APPPREF_EFFECT_CALM_CONTRAST
   0x0000a544    0004    APPPREF_EFFECT_CLASSIC_CONTRAST
   0x0000a548    0004    APPPREF_EFFECT_CUSTOM_1_CONTRAST
   0x0000a54c    0004    APPPREF_EFFECT_CUSTOM_2_CONTRAST
   0x0000a550    0004    APPPREF_EFFECT_CUSTOM_3_CONTRAST
   0x0000a554    0004    APPPREF_EFFECT_CUSTOM_4_CONTRAST
   0x0000a558    0004    APPPREF_AF_MODE_SMART_AUTO
   0x0000a55c    0004    APPPREF_AF_MODE_MOV
   0x0000a560    0004    APPPREF_AF_MODE_P
   0x0000a564    0004    APPPREF_AF_MODE_SCENE1
   0x0000a568    0004    APPPREF_AF_MODE_SCENE2
   0x0000a56c    0004    APPPREF_AF_AREA_P
   0x0000a570    0004    APPPREF_AF_AREA_SCENE1
   0x0000a574    0004    APPPREF_AF_AREA_SCENE2
   0x0000a578    0004    APPPREF_SELECTION_AF_POS_X
   0x0000a57c    0004    APPPREF_SELECTION_AF_POS_Y
   0x0000a580    0004    APPPREF_SELECTION_AF_WIDTH
   0x0000a584    0004    APPPREF_SELECTION_AF_HEIGHT
   0x0000a588    0004    APPPREF_SELECTION_AF_BOX_SIZE
   0x0000a58c    0004    APPPREF_SELECTION_AE_POS_X
   0x0000a590    0004    APPPREF_SELECTION_AE_POS_Y
   0x0000a594    0004    APPPREF_SELECTION_AE_WIDTH
   0x0000a598    0004    APPPREF_SELECTION_AE_HEIGHT
   0x0000a59c    0004    APPPREF_TOUCH_AF
   0x0000a5a0    0004    APPPREF_MF_ASSIST
   0x0000a5a4    0004    APPPREF_FOCUS_PEAKING_COLOR
   0x0000a5a8    0004    APPPREF_LINK_AE_TO_AF
   0x0000a5ac    0004    APPPREF_FRAMING_MODE
   0x0000a5b0    0004    APPPREF_OIS
   0x0000a5b4    0004    APPPREF_DRIVE_SMART_AUTO
   0x0000a5b8    0004    APPPREF_DRIVE_P
   0x0000a5bc    0004    APPPREF_DRIVE_BULB
   0x0000a5c0    0004    APPPREF_DRIVE_MOVIE
   0x0000a5c4    0004    APPPREF_DRIVE_SCENE1
   0x0000a5c8    0004    APPPREF_DRIVE_SCENE2
   0x0000a5cc    0004    APPPREF_DRIVE_SCENE3
   0x0000a5d0    0004    APPPREF_DRIVE_SELF
   0x0000a5d4    0004    APPPREF_DRIVE_BURST_FRAME
   0x0000a5d8    0004    APPPREF_DRIVE_SET_CONTINOUS
   0x0000a5dc    0004    APPPREF_DRIVE_SET_CONTI_H_FRAME
   0x0000a5e0    0004    APPPREF_DRIVE_SET_CONTI_N_FRAME
   0x0000a5e4    0004    APPPREF_DRIVE_SET_TIMER
   0x0000a5e8    0004    APPPREF_DRIVE_SET_TIMER_SELF
   0x0000a5ec    0004    APPPREF_DRIVE_SET_BKT
   0x0000a5f0    0004    APPPREF_PANORAMA_TYPE
   0x0000a5f4    0004    APPPREF_BRK_AF_STEP
   0x0000a5f8    0004    APPPREF_BRK_AE_STEP
   0x0000a5fc    0004    APPPREF_BRK_WB_SET
   0x0000a600    0004    APPPREF_BRK_PW_TYPE
   0x0000a604    0004    APPPREF_BRK_DEPTH_TYPE
   0x0000a608    0004    APPPREF_FLASH_SMART_AUTO
   0x0000a60c    0004    APPPREF_FLASH_COMMON
   0x0000a610    0004    APPPREF_FLASH_SCENE1
   0x0000a614    0004    APPPREF_FLASH_SCENE2
   0x0000a618    0004    APPPREF_FLASH_WIFI
   0x0000a61c    0004    APPPREF_FLASH_FLASH_EV
   0x0000a620    0004    APPPREF_METERING
   0x0000a624    0004    APPPREF_DYNAMIC_RANGE
   0x0000a628    0004    APPPREF_HDR_LEVEL
   0x0000a62c    0004    APPPREF_COLOR_MODE
   0x0000a630    0004    APPPREF_ISO_STEP
   0x0000a634    0004    APPPREF_AUTO_ISO_RANGE
   0x0000a638    0004    APPPREF_AUTO_ISO_RANGE_1_3
   0x0000a63c    0004    APPPREF_HIGH_ISO_NR
   0x0000a640    0004    APPPREF_LONG_TERM_NR
   0x0000a644    0004    APPPREF_AF_RELEASE_PRIORITY
   0x0000a648    0004    APPPREF_AF_RELEASE_PRIORITY_FOCUS
   0x0000a64c    0004    APPPREF_DISTORTION_CORRECT
   0x0000a650    0004    APPPREF_IFN_APERTURE
   0x0000a654    0004    APPPREF_IFN_SHUTTER_SPEED
   0x0000a658    0004    APPPREF_IFN_EV
   0x0000a65c    0004    APPPREF_IFN_ISO
   0x0000a660    0004    APPPREF_IFN_WB
   0x0000a664    0004    APPPREF_IFN_I_ZOOM
   0x0000a668    0004    APPPREF_CUSTOM_MENU
   0x0000a66c    0004    APPPREF_USER_DISPLAY_ICON
   0x0000a670    0004    APPPREF_USER_DISPLAY_DATE_TIME
   0x0000a674    0004    APPPREF_USER_DISPLAY_HISTOGRAM
   0x0000a678    0004    APPPREF_USER_DISPLAY_DISTANCE_SCALE
   0x0000a67c    0004    APPPREF_USER_DISPLAY_BUTTONS
   0x0000a680    0004    APPPREF_GRID_LINE
   0x0000a684    0004    APPPREF_AF_LAMP
   0x0000a688    0004    APPPREF_BULB
   0x0000a68c    0004    APPPREF_DMF
   0x0000a690    0004    APPPREF_TOUCH_OPERATION
   0x0000a694    0004    APPPREF_AUTO_3D_MODE
   0x0000a698    0004    APPPREF_I_ZOOM_STEP
   0x0000a69c    0004    APPPREF_E_3D_REC_MODE
   0x0000a6a0    0004    APPPREF_WIFI_SUB_MODE
   0x0000a6a4    0004    APPPREF_WB_TYPE_3D
   0x0000a6a8    0004    APPPREF_FOCUS_PEAKING_LEVEL
   0x0000a6ac    0004    APPPREF_I_DEPTH
   0x0000a6b0    0004    APPPREF_BRIGHTNESS_ADJUST_GUIDE
   0x0000a6b4    0004    APPPREF_OVER_EXPOSURE
   0x0000a6b8    0004    APPPREF_MIC_LEVEL
   0x0000a6bc    0004    APPPREF_SHUTTER_SPEED_MIN_INDEX
   0x0000a6c0    0004    APPPREF_SHUTTER_SPEED_MIN_AUTO
   0x0000a6c4    0004    APPPREF_IFN_SET
   0x0000a6c8    0004    APPPREF_IFN_CUSTOM_METERING
   0x0000a6cc    0004    APPPREF_IFN_CUSTOM_EV
   0x0000a6d0    0004    APPPREF_IFN_CUSTOM_AEL
   0x0000a6d4    0004    APPPREF_TAG_AND_GO
   0x0000a6d8    0004    APPPREF_DISPLAY_SELECT
   0x0000a6dc    0004    APPPREF_MOV_DIS
   0x0000a6e0    0004    APPPREF_E_SHUTTER
   0x0000a6e4    0004    APPPREF_AUTO_CAPTURE_LEVEL
   0x0000a6e8    0004    APPPREF_MULTI_EXPOSURE_NUMBER
   0x0000a6ec    0004    APPPREF_MULTI_EXPOSURE_SAVE_TYPE
   0x0000a6f0    0004    APPPREF_LENS_BUTTON_SET
   0x0000a6f4    0004    APPPREF_LENS_BUTTON_SPEED
   0x0000a6f8    0004    APPPREF_DRIVE_SET_TIMER_COUNT
   0x0000a6fc    0004    APPPREF_DRIVE_SET_TIMER_INTERVAL
   0x0000a700    0004    APPPREF_DMF_RESP
   0x0000a704    0004    APPPREF_OLED_COLOR
   0x0000a708    0004    APPPREF_MIC_MANUAL_VALUE
   0x0000a70c    0004    APPPREF_NFC_SELECTION
   0x0000a710    0004    APPPREF_RVF_FILE_SAVE_OPTION
   0x0000a714    0004    APPPREF_RVF_DRIVE_OPTION
   0x0000a718    0004    APPPREF_RVF_STREAM_QUALITY
   0x0000a71c    0004    APPPREF_QUICK_AF_POINT
   0x0000a720    0004    APPPREF_ISO_EXPANSION
   0x0000a724    0004    APPPREF_FACE_RETOUCH_LEVEL
   0x0000a728    0004    APPPREF_AUTO_SHUTTER_CONTINUOUS
   0x0000a72c    0004    APPPREF_MULTI_AF_POS_X
   0x0000a730    0004    APPPREF_MULTI_AF_POS_Y
   0x0000a734    0004    APPPREF_MULTI_AF_WIDTH
   0x0000a738    0004    APPPREF_MULTI_AF_HEIGHT
   0x0000a73c    0004    APPPREF_MULTI_AF_BOX_SIZE
   0x0000a740    0004    APPPREF_AUTO_SELF_SHOT
   0x0000a744    0004    APPPREF_FACE_DETECTION_P
   0x0000a748    0004    APPPREF_FACE_DETECTION_SCENE
   0x0000a74c    0004    APPPREF_FACE_RETOUCH_BRIGHTENING
   0x0000a750    0004    APPPREF_FACE_RETOUCH_SOFTENING
   0x0000a754    0004    APPPREF_TOUCH_AF_SELF
   0x0000a758    0004    APPPREF_FLASH_SELF
   0x0000a75c    0004    APPPREF_FACE_DETECTION_SET
   0x0000a760    0004    APPPREF_RAW_QUALITY
   0x0000a764    0004    APPPREF_AUTO_CAPTURE_SUB_MODE
   0x0000a768    0004    APPPREF_AUTO_SHUTTER_IMPACT_LINE
   0x0000a76c    0004    APPPREF_INTERVAL_CAPTURE_SET
   0x0000a770    0004    APPPREF_INTERVAL_CAPTURE_TIME_HOUR
   0x0000a774    0004    APPPREF_INTERVAL_CAPTURE_TIME_MIN
   0x0000a778    0004    APPPREF_INTERVAL_CAPTURE_TIME_SEC
   0x0000a77c    0004    APPPREF_INTERVAL_CAPTURE_TIME_NUM
   0x0000a780    0004    APPPREF_PLAY_INTERVAL_SHOT
   0x0000a784    0004    APPPREF_INTERVAL_TIMER_COUNT
   0x0000a788    0004    APPPREF_INTERVAL_CAPTURE_POWEROFF_TYPE
   0x0000a78c    0004    APPPREF_INTERVAL_CAPTURE_SAVE_HOUR_PASSED
   0x0000a790    0004    APPPREF_INTERVAL_CAPTURE_SAVE_MIN_PASSED
   0x0000a794    0004    APPPREF_INTERVAL_CAPTURE_SAVE_SEC_PASSED
   0x0000a798    0004    APPPREF_INTERVAL_CAPTURE_SAVE_HOUR_START
   0x0000a79c    0004    APPPREF_INTERVAL_CAPTURE_SAVE_MIN_START
   0x0000a7a0    0004    APPPREF_INTERVAL_CAPTURE_SAVE_SEC_START
   0x0000a7a4    0004    APPPREF_INTERVAL_CAPTURE_SAVE_HOUR_POWEROFF
   0x0000a7a8    0004    APPPREF_INTERVAL_CAPTURE_SAVE_MIN_POWEROFF
   0x0000a7ac    0004    APPPREF_INTERVAL_CAPTURE_SAVE_SEC_POWEROFF
   0x0000a7b0    0004    APPPREF_INTERVAL_CAPTURE_SAVE_HOUR_PAUSE_START
   0x0000a7b4    0004    APPPREF_INTERVAL_CAPTURE_SAVE_MIN_PAUSE_START
   0x0000a7b8    0004    APPPREF_INTERVAL_CAPTURE_SAVE_SEC_PAUSE_START
   0x0000a7bc    0004    APPPREF_INTERVAL_CAPTURE_SAVE_HOUR_PAUSE_HOLD
   0x0000a7c0    0004    APPPREF_INTERVAL_CAPTURE_SAVE_MIN_PAUSE_HOLD
   0x0000a7c4    0004    APPPREF_INTERVAL_CAPTURE_SAVE_SEC_PAUSE_HOLD
   0x0000a7c8    0004    APPPREF_INTERVAL_LENS_INFO_FOCUS
   0x0000a7cc    0004    APPPREF_INTERVAL_LENS_INFO_FOCUS_D
   0x0000a7d0    0004    APPPREF_INTERVAL_LENS_INFO_ZOOM
   0x0000a7d4    0004    APPPREF_INTERVAL_LENS_INFO_ZOOM_D
   0x0000a7d8    0004    APPPREF_INTERVAL_SET_LENS_INFO
   0x0000a7dc    0004    APPPREF_INTERVAL_CAP_START_MODE
   0x0000a7e0    0004    APPPREF_INTERVAL_CAPTURE_CURR_COUNT
   0x0000a7e4    0004    APPPREF_INTERVAL_CAPTURE_TIME_LABS
   0x0000a7e8    0004    APPPREF_INTERVAL_CAPTURE_BOOT_FOR_RTC
   0x0000a7ec    0004    APPPREF_INTERVAL_CAPTURE_PAUSE_HOLD
   0x0000a7f0    0004    APPPREF_INTERVAL_CAPTURE_TIME_BEGIN_HOUR
   0x0000a7f4    0004    APPPREF_INTERVAL_CAPTURE_TIME_BEGIN_MIN
   0x0000a7f8    0004    APPPREF_INTERVAL_CAPTURE_TIME_BEGIN_SEC
   0x0000a7fc    0004    APPPREF_INTERVAL_CAPTURE_TIME_BEGIN_USE
   0x0000a800    0004    APPPREF_INTERVAL_CAPTURE_TIME_BEGIN_REMAIN_TIME
   0x0000a804    0004    APPPREF_MENU_FLASH_MODE
   0x0000a808    0004    APPPREF_MENU_FLASH_EX_EV
   0x0000a80c    0004    APPPREF_MENU_FLASH_OUTPUT
   0x0000a810    0004    APPPREF_MENU_FLASH_MULTI_COUNT
   0x0000a814    0004    APPPREF_MENU_FLASH_MULTI_COUTPUT
   0x0000a818    0004    APPPREF_MENU_FLASH_MULTI_FREQUENCY
   0x0000a81c    0004    APPPREF_MENU_IN_USE_WIRELESS_FLASH
   0x0000a820    0004    APPPREF_MENU_IN_CHANNEL
   0x0000a824    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE
   0x0000a828    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_MASTER
   0x0000a82c    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_MASTER_ATTL
   0x0000a830    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_MASTER_MANUAL
   0x0000a834    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_A
   0x0000a838    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_A_ATTL
   0x0000a83c    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_A_MANUAL
   0x0000a840    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_B
   0x0000a844    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_B_ATTL
   0x0000a848    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_B_MANUAL
   0x0000a84c    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_C
   0x0000a850    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_C_ATTL
   0x0000a854    0004    APPPREF_MENU_IN_GROUP_FLASH_MODE_C_MANUAL
   0x0000a858    0004    APPPREF_MENU_EX_USE_WIRELESS_FLASH
   0x0000a85c    0004    APPPREF_MENU_EX_CHANNEL
   0x0000a860    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE
   0x0000a864    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_MASTER
   0x0000a868    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_MASTER_ATTL
   0x0000a86c    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_MASTER_MANUAL
   0x0000a870    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_A
   0x0000a874    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_A_ATTL
   0x0000a878    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_A_MANUAL
   0x0000a87c    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_B
   0x0000a880    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_B_ATTL
   0x0000a884    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_B_MANUAL
   0x0000a888    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_C
   0x0000a88c    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_C_ATTL
   0x0000a890    0004    APPPREF_MENU_EX_GROUP_FLASH_MODE_C_MANUAL
   0x0000a894    0004    APPPREF_MENU_FLASH_MULTI_COUTPUT_MAX
   0x0000a898    0004    APPPREF_FLASH_INIT_DONE
   0x0000a89c    0004    APPPREF_SMART_PRO_VIEW_TYPE
   0x0000a8a0    0004    APPPREF_MOV_AF_RESPONSIVENESS
   0x0000a8a4    0004    APPPREF_MOV_AF_SHIFT_SPEED
   0x0000a8a8    0004    APPPREF_MOV_AF_MODE
   0x0000a8ac    0004    APPPREF_B_REBOOT_SNAPSHOT
   0x0000a8b0    0004    APPPREF_B_RTC_RESET_STATE
   0x0000a8b4    0512    APPPREF_GOLD_VER_NAME
   0x0000aab4    0004    APPPREF_EFS_INFO_BOOT_CAPTURE
   0x0000aab8    0004    APPPREF_SET_HDR_FIRST
   0x0000aabc    0004    APPPREF_CONFIRM_WIFIMODE_GUIDE
   0x0000aac0    0004    APPPREF_FW_UPGRADE_CHECK
   0x0000aac4    0004    APPPREF_B_IS_CES_VERSION
   0x0000aac8    0004    APPPREF_DIRECTKEY_SELECTION
   0x0000aacc    0004    APPPREF_BT_MANUAL_OFF
   0x0000aad0    0004    APPPREF_BT_FIRST_CONNECT
   0x0000aad4    0004    APPPREF_IOS_FIRST_CONNECT
   0x0000aad8    0800    APPPREF_BT_PAIRED_DEVICE
   0x0000adf8    0256    APPPREF_BT_NICKNAME
   0x0000aef8    0004    APPPREF_WIFI_COUNTRY_CODE
   0x0000aefc    0004    APPPREF_AUTO_TIME_SET
   0x0000af00    0004    APPPREF_PRIVACY_LOCK_SET_CHECK
   0x0000af04    0256    APPPREF_PHONE_NAME
   0x0000b004    0004    APPPREF_SUPPORT_WIFIDIRECT
   0x0000b008    0004    APPPREF_PAIRED_DEVICE
   0x0000b00c    0004    APPPREF_NFC_HW_ERROR
   0x0000b010    0004    APPPREF_PAIRED_DEVICE_LIST_NUM
   0x0000b014    4000    APPPREF_PAIRED_DEVICE_LIST_NAME
   0x0000bfb4    0480    APPPREF_PAIRED_DEVICE_LIST_MAC
   0x0000c194    0004    APPPREF_MOV_TIME_CODE
   0x0000c198    0004    APPPREF_MOV_TIME_NOTATION
   0x0000c19c    0004    APPPREF_MOV_TIME_NOTATION_MANUAL_HOUR
   0x0000c1a0    0004    APPPREF_MOV_TIME_NOTATION_MANUAL_MIN
   0x0000c1a4    0004    APPPREF_MOV_TIME_NOTATION_MANUAL_SEC
   0x0000c1a8    0004    APPPREF_MOV_TIME_NOTATION_MANUAL_FRAME
   0x0000c1ac    0004    APPPREF_MOV_TIME_CODE_MODE
   0x0000c1b0    0004    APPPREF_USB_PC_CONNECT
   0x0000c1b4    0004    APPPREF_CENTER_MARKER_DISPLAY
   0x0000c1b8    0004    APPPREF_CENTER_MARKER_SIZE
   0x0000c1bc    0004    APPPREF_CENTER_MARKER_TRANSPARENCY
   0x0000c1c0    0004    APPPREF_SAVE_SELECTION_AF_POS
   0x0000c1c4    0004    APPPREF_KEY_MAPPING_COMMAND_P
   0x0000c1c8    0004    APPPREF_KEY_MAPPING_COMMAND_A
   0x0000c1cc    0004    APPPREF_KEY_MAPPING_COMMAND_S
   0x0000c1d0    0004    APPPREF_KEY_MAPPING_COMMAND_M
   0x0000c1d4    0004    APPPREF_TRAP_SHOT_IMPACT_LINE
   0x0000c1d8    0004    APPPREF_EXP_FOCUS_SEPARATION
   0x0000c1dc    0004    APPPREF_KEYMAP_C_DIRECTION
   0x0000c1e0    0004    APPPREF_GOLF_SHOT_REVERSE
   0x0000c1e4    0004    APPPREF_GOLF_SHOT_IMPACT_LINE
   0x0000c1e8    0004    APPPREF_SAVE_AS_FLIPPED
   0x0000c1ec    0004    APPPREF_DCF_SEED
   0x0000c1f0    0004    APPPREF_SMART_LINK
   0x0000c1f4    0004    APPPREF_RVFAPP_DOWNLOADFLAG
   0x0000c1f8    0004    APPPREF_STLAPP_DOWNLOADFLAG
   0x0000c1fc    0004    APPPREF_HMAPP_DOWNLOADFLAG
   0x0000c200    0180    APPPREF_STLAPP_CLIENT
   0x0000c2b4    0004    APPPREF_VAR_EVC
   0x0000c2b8    0004    APPPREF_AF_FAILED_RELEASE_ENABLE
   0x0000c2bc    0004    APPPREF_STORAGE_SELECT
   0x0000c2c0    0004    APPPREF_WAKEUP_ALARM_SET
   0x0000c2c4    0001    APPPREF_CAP_POWER_OFF_STATUS
   0x0000c2c5    0004    APPPREF_B_FACTORY_RESET
   0x0000c2c9    0004    APPPREF_I_OFF_TEMPERATURE
   0x0000c2cd    0004    APPPREF_B_DISABLE_CHINESE_LANGUAGE
   0x0000c2d1    0004    APPPREF_B_DISABLE_DISPLAY_SAVE
   0x0000c2d5    0004    APPPREF_B_DISABLE_POWER_SAVE
   0x0000c2d9    0004    APPPREF_B_DISABLE_MOVIE_REC_LIMIT
   0x0000c2dd    0004    APPPREF_B_ENABLE_NO_LENS_RELEASE
   0x0000c2e1    0004    APPPREF_B_ENABLE_INT_ERROR_POWER_OFF
   0x0000c2e5    0004    APPPREF_B_DISABLE_WATCH_DOG
   0x0000c2e9    0004    APPPREF_UI_CAPTURE_RELEASE_COUNT
   0x0000c2ed    0004    APPPREF_B_DISABLE_ADJ_AUTO_START
   0x0000c2f1    0004    APPPREF_B_IS_MARKETING_SAMPLE
   0x0000c2f5    0004    APPPREF_LEVELER_ADJ_DATA_ROLL
   0x0000c2f9    0004    APPPREF_LEVELER_ADJ_DATA_PITCH
   0x0000c2fd    0004    APPPREF_LEVELER_ADJ_DATA_X
   0x0000c301    0004    APPPREF_LEVELER_ADJ_DATA_Y
   0x0000c305    0004    APPPREF_LEVELER_ADJ_DATA_Z
   0x0000c309    0004    APPPREF_B_ENABLE_ADJ_PTP_AUTO
   0x0000c30d    0004    APPPREF_AF_LOG_SAVE_ENABLE
   0x0000c311    0004    APPPREF_ZONE_AF_POS_X
   0x0000c315    0004    APPPREF_ZONE_AF_POS_Y
   0x0000c319    0004    APPPREF_ZONE_AF_WIDTH
   0x0000c31d    0004    APPPREF_ZONE_AF_HEIGHT
   0x0000c321    0004    APPPREF_ZONE_AF_BOX_SIZE
   0x0000c325    0064    APPPREF_FACEBOOK_ID
   0x0000c365    0016    APPPREF_FACEBOOK_WEBSITE_NAME
   0x0000c375    0064    APPPREF_FACEBOOK_KEYSPEC
   0x0000c3b5    0064    APPPREF_FACEBOOK_SESSIONKEY
   0x0000c3f5    0064    APPPREF_FACEBOOK_PERSISTKEY
   0x0000c435    0064    APPPREF_FACEBOOK_PEOPLEID
   0x0000c475    0064    APPPREF_PICASA_ID
   0x0000c4b5    0016    APPPREF_PICASA_WEBSITE_NAME
   0x0000c4c5    0064    APPPREF_PICASA_KEYSPEC
   0x0000c505    0064    APPPREF_PICASA_SESSIONKEY
   0x0000c545    0064    APPPREF_PICASA_PERSISTKEY
   0x0000c585    0064    APPPREF_PICASA_PEOPLEID
   0x0000c5c5    0064    APPPREF_YOUTUBE_ID
   0x0000c605    0016    APPPREF_YOUTUBE_WEBSITE_NAME
   0x0000c615    0064    APPPREF_YOUTUBE_KEYSPEC
   0x0000c655    0064    APPPREF_YOUTUBE_SESSIONKEY
   0x0000c695    0064    APPPREF_YOUTUBE_PERSISTKEY
   0x0000c6d5    0064    APPPREF_YOUTUBE_PEOPLEID
   0x0000c715    0064    APPPREF_PHOTOBUCKET_ID
   0x0000c755    0016    APPPREF_PHOTOBUCKET_WEBSITE_NAME
   0x0000c765    0064    APPPREF_PHOTOBUCKET_KEYSPEC
   0x0000c7a5    0064    APPPREF_PHOTOBUCKET_SESSIONKEY
   0x0000c7e5    0064    APPPREF_PHOTOBUCKET_PERSISTKEY
   0x0000c825    0064    APPPREF_PHOTOBUCKET_PEOPLEID
   0x0000c865    0064    APPPREF_ALLSHAREPLAY_ID
   0x0000c8a5    0016    APPPREF_ALLSHAREPLAY_WEBSITE_NAME
   0x0000c8b5    0064    APPPREF_ALLSHAREPLAY_KEYSPEC
   0x0000c8f5    0064    APPPREF_ALLSHAREPLAY_SESSIONKEY
   0x0000c935    0064    APPPREF_ALLSHAREPLAY_PERSISTKEY
   0x0000c975    0064    APPPREF_ALLSHAREPLAY_PEOPLEID
   0x0000c9b5    0064    APPPREF_ME2DAY_ID
   0x0000c9f5    0016    APPPREF_ME2DAY_WEBSITE_NAME
   0x0000ca05    0064    APPPREF_ME2DAY_KEYSPEC
   0x0000ca45    0064    APPPREF_ME2DAY_SESSIONKEY
   0x0000ca85    0064    APPPREF_ME2DAY_PERSISTKEY
   0x0000cac5    0064    APPPREF_ME2DAY_PEOPLEID
   0x0000cb05    0064    APPPREF_WEIBO_ID
   0x0000cb45    0016    APPPREF_WEIBO_WEBSITE_NAME
   0x0000cb55    0064    APPPREF_WEIBO_KEYSPEC
   0x0000cb95    0064    APPPREF_WEIBO_SESSIONKEY
   0x0000cbd5    0064    APPPREF_WEIBO_PERSISTKEY
   0x0000cc15    0064    APPPREF_WEIBO_PEOPLEID
   0x0000cc55    0064    APPPREF_RENREN_ID
   0x0000cc95    0016    APPPREF_RENREN_WEBSITE_NAME
   0x0000cca5    0064    APPPREF_RENREN_KEYSPEC
   0x0000cce5    0064    APPPREF_RENREN_SESSIONKEY
   0x0000cd25    0064    APPPREF_RENREN_PERSISTKEY
   0x0000cd65    0064    APPPREF_RENREN_PEOPLEID
   0x0000cda5    0064    APPPREF_POCO_ID
   0x0000cde5    0016    APPPREF_POCO_WEBSITE_NAME
   0x0000cdf5    0064    APPPREF_POCO_KEYSPEC
   0x0000ce35    0064    APPPREF_POCO_SESSIONKEY
   0x0000ce75    0064    APPPREF_POCO_PERSISTKEY
   0x0000ceb5    0064    APPPREF_POCO_PEOPLEID
   0x0000cef5    0064    APPPREF_VK_ID
   0x0000cf35    0016    APPPREF_VK_WEBSITE_NAME
   0x0000cf45    0064    APPPREF_VK_KEYSPEC
   0x0000cf85    0064    APPPREF_VK_SESSIONKEY
   0x0000cfc5    0064    APPPREF_VK_PERSISTKEY
   0x0000d005    0064    APPPREF_VK_PEOPLEID
   0x0000d045    0016    APPPREF_SKYDRIVE_WEBSITE_NAME
   0x0000d055    0064    APPPREF_SKYDRIVE_KEYSPEC
   0x0000d095    0064    APPPREF_SKYDRIVE_SESSIONKEY
   0x0000d0d5    0064    APPPREF_SKYDRIVE_PERSISTKEY
   0x0000d115    0064    APPPREF_ODNOKLA_ID
   0x0000d155    0016    APPPREF_ODNOKLA_WEBSITE_NAME
   0x0000d165    0064    APPPREF_ODNOKLA_KEYSPEC
   0x0000d1a5    0064    APPPREF_ODNOKLA_SESSIONKEY
   0x0000d1e5    0064    APPPREF_ODNOKLA_PERSISTKEY
   0x0000d225    0064    APPPREF_ODNOKLA_PEOPLEID
   0x0000d265    0064    APPPREF_KAKAO_ID
   0x0000d2a5    0016    APPPREF_KAKAO_WEBSITE_NAME
   0x0000d2b5    0064    APPPREF_KAKAO_KEYSPEC
   0x0000d2f5    0064    APPPREF_KAKAO_SESSIONKEY
   0x0000d335    0064    APPPREF_KAKAO_PERSISTKEY
   0x0000d375    0064    APPPREF_KAKAO_PEOPLEID
   0x0000d3b5    0128    APPPREF_KAKAO_ACCESSTOKEN
   0x0000d435    0128    APPPREF_KAKAO_REFRESHTOKEN
   0x0000d4b5    0064    APPPREF_DROPBOX_ID
   0x0000d4f5    0016    APPPREF_DROPBOX_WEBSITE_NAME
   0x0000d505    0064    APPPREF_DROPBOX_KEYSPEC
   0x0000d545    0064    APPPREF_DROPBOX_SESSIONKEY
   0x0000d585    0064    APPPREF_DROPBOX_PERSISTKEY
   0x0000d5c5    0064    APPPREF_DROPBOX_PEOPLEID
   0x0000d605    0128    APPPREF_DROPBOX_ACCESSTOKEN
   0x0000d685    0128    APPPREF_DROPBOX_REFRESHTOKEN
   0x0000d705    0064    APPPREF_FLICKR_ID
   0x0000d745    0016    APPPREF_FLICKR_WEBSITE_NAME
   0x0000d755    0064    APPPREF_FLICKR_KEYSPEC
   0x0000d795    0064    APPPREF_FLICKR_SESSIONKEY
   0x0000d7d5    0064    APPPREF_FLICKR_PERSISTKEY
   0x0000d815    0064    APPPREF_FLICKR_PEOPLEID
   0x0000d855    0128    APPPREF_FLICKR_ACCESSTOKEN
   0x0000d8d5    0128    APPPREF_FLICKR_REFRESHTOKEN
   0x0000d955    0032    APPPREF_WEBSTORAGE_ID
   0x0000d975    0032    APPPREF_WEBSTORAGE_PW
   0x0000d995    0064    APPPREF_WEBSTORAGE_USERID
   0x0000d9d5    0064    APPPREF_WEBSTORAGE_AUTHTOKEN
   0x0000da15    0064    APPPREF_WEBSTORAGE_AUTHTOKENSECRET
   0x0000da55    0064    APPPREF_WEBSTORAGE_ACCESSTOKEN
   0x0000da95    0064    APPPREF_WEBSTORAGE_ACCESSTOKENSECRET
   0x0000dad5    0128    APPPREF_EMAIL_SNDEMAILADDR
   0x0000db55    3840    APPPREF_EMAIL_RCVEMAILADDR
   0x0000ea55    0512    APPPREF_EMAIL_USERNAME
   0x0000ec55    0128    APPPREF_EMAIL_USEREMAIL
   0x0000ecd5    0004    APPPREF_EMAIL_PW_ONOFF
   0x0000ecd9    0004    APPPREF_EMAIL_SAVEDRCVEMAILNUM
   0x0000ecdd    0004    APPPREF_EMAIL_EMAILPASSWORD
   0x0000ece1    0004    APPPREF_EMAIL_SAVEDSNDLISTNUM
   0x0000ece5    0640    APPPREF_EMAIL_LASTESTSENDER
   0x0000ef65    0001    APPPREF_FIRMNOTI_OK
   0x0000ef66    0001    APPPREF_FIRMNOTI_NOTSHOW
   0x0000ef67    0004    APPPREF_SAVEDIDNUM
   0x0000ef6b    3200    APPPREF_LASTESTID
   0x0000fbeb    0001    APPPREF_ALLSHARETVLINKNOTFIRSTRUN
   0x0000fbec    0001    APPPREF_PCBACKUPNOTFIRSTRUN
   0x0000fbed    0001    APPPREF_DROPBOXUPLOADSIZE
   0x0000fbee    0001    APPPREF_FLICKRUPLOADSIZE
   0x0000fbef    0001    APPPREF_SMARTPHONELINKNOTFIRSTRUN
   0x0000fbf0    0006    APPPREF_SMARTPHONELINKMOBILEMACADDR
   0x0000fbf6    0128    APPPREF_FOLDERNAME
   0x0000fc76    0064    APPPREF_WEBSTORAGESERVERNAME
   0x0000fcb6    0001    APPPREF_CLOUDUPLOADSIZE
   0x0000fcb7    0001    APPPREF_DLNAACCESSCONTROL
   0x0000fcb8    0004    APPPREF_SIGNATURE
   0x0000fcbc    0004    APPPREF_CHECKSUM
   0x0000fcc0    0001    APPPREF_DATACOLLECTIONTERMSCHECK
   0x0000fcc1    0129    APPPREF_LAST_AP
   0x0000fd42    0129    APPPREF_LAST_AUTOBACKUP_AP
   0x0000fdc3    2048    APPPREF_TVLINKALLOWEDDEVICELIST_NAME
   0x000105c3    0288    APPPREF_TVLINKALLOWEDDEVICELIST_MACADDR
   0x000106e3    0009    APPPREF_SECURITY_PASSWORD
   0x000106ec    0032    APPPREF_WIFI_NEW_FW_VERSION
   */
  static final int APPPREF_FNO_INDEX = 0x0000a338;
  //static final int APPPREF_FNO_INDEX_OTHER_MODE = 0x0000000C;
  static final int APPPREF_SHUTTER_SPEED_INDEX = 0x0000a340; 
  //static final int APPPREF_SHUTTER_SPEED_INDEX_OTHER_MODE = 0x00000014;
  static final int APPPREF_EVC = 0x0000a344;
  static final int APPPREF_VAR_EVC = 0x0000c2b4;  
  static final int APPPREF_IFN_EV = 0x0000a658;
  static final int APPPREF_ISO_PAS = 0x0000a388;
  static final int APPPREF_B_DISABLE_MOVIE_REC_LIMIT =  0x0000c2d9; 
  static final int APPPREF_B_ENABLE_NO_LENS_RELEASE = 0x0000c2dd;

  /* System rw
   ------------------------------------------------
   Offset    Size    Name    [sysrw]
   ------------------------------------------------
   0x00000200    0004    SYSRWPREF_DCF_SEED
   0x00000204    0004    SYSRWPREF_DU_SHUTTER_COUNT
   0x00000208    0004    SYSRWPREF_SHUTTER_COUNT
   0x0000020c    0004    SYSRWPREF_SHUTTER_COMPENSATION_TIME
   0x00000210    0040    SYSRWPREF_SHUTTER_COMPENSATION_BUFFER
   0x00000238    0004    SYSRWPREF_SHUTTER_COMPENSATION_BUFFER_SIZE
   0x0000023c    0004    SYSRWPREF_SHUTTER_ERR81_COUNT
   0x00000240    0004    SYSRWPREF_SHUTTER_ERR91_COUNT
   0x00000244    0004    SYSRWPREF_POWER_ON_COUNT
   0x00000248    0004    SYSRWPREF_FLASH_INT_COUNT
   0x0000024c    0004    SYSRWPREF_FLASH_EXT_COUNT
   */
  static final int SYSRWPREF_SHUTTER_COUNT = 0x00000208;  

  // LCD screen dimensions
  static final int SCREEN_WIDTH = 720;
  static final int SCREEN_HEIGHT = 480;
  static final float offsetPercent = 3.0; //6.5;

  final String[] shutterName = { "Bulb", "30\"", "25\"", "20\"", "15\"", "13\"", "10\"", "8\"", "6\"", "5\"", 
    "4\"", "3\"", "2.5\"", "2\"", "1.6\"", "1.3\"", "1\"", "0.8\"", "0.6\"", "0.5\"", 
    "0.4\"", "0.3\"", "1/4", "1/5", "1/6", "1/8", "1/10", "1/13", "1/15", "1/20", 
    "1/25", "1/30", "1/40", "1/50", "1/60", "1/80", "1/100", "1/125", "1/160", "1/200", 
    "1/250", "1/320", "1/400", "1/500", "1/640", "1/800", "1/1000", "1/1250", "1/1600", "1/2000", 
    "1/2500", "1/3200", "1/4000", "1/5000", "1/6000"
  };
  
  final int[] shutterValue = { -80, -80, -75, -69, -64, -59, -53, -48, -43, -37, 
    -32, -27, -21, -16, -11, -5, 0, 5, 11, 16, 
    21, 27, 32, 37, 43, 48, 53, 59, 64, 69, 
    75, 80, 85, 91, 96, 101, 107, 112, 117, 123, 
    128, 133, 139, 144, 149, 155, 160, 165, 171, 176, 
    181, 187, 192, 197, 202};
    
  final String[] fnName = { "F2.4", "F2.8", "F3.2", "F3.5", "F4.0", "F4.5", "F5.0", 
    "F5.6", "F6.3", "F7.1", "F8.0", 
    "F9.0", "F10", "F11", "F13", 
    "F14", "F16", "F18", "F20", "F22" };
    
  final int[] fnValue = {41, 48, 53, 59, 64, 69, 75, 
    80, 85, 91, 96, 
    101, 107, 112, 117, 
    123, 128, 133, 139, 144 };

  final String[] evName = { "-5.0", "-4.6", "-4.3", "-4.0", "-3.6", "-3.3", "-3.0", "-2.6", "-2.3", "-2.0", "-1.6", "-1.3", "-1.0", "-0.6", "-0.3", 
    "0.0", "+0.3", "+0.6", "+1.0", "+1.3", "+1.6", "+2.0", "+2.3", "+2.6", "+3.0", "+3.3", "+3.6", "+4.0", "+4.3", "+4.6", "+5.0" };
  //int evId = 9;

  NX500Camera(String ipAddr, Client client) {
    this.ipAddr = ipAddr;
    this.client = client;
    connected = false;
    name = "";
    inString = "";
    prompt = "]# ";
    prefix = "[root";
    focusOffset = screenWidth*(offsetPercent/100);
    type = NX500;
    shutterId = 1;
    fnId = 10;

    screenWidth = SCREEN_WIDTH;
    screenHeight = SCREEN_HEIGHT;
  }

  int[] getCameraResult() {
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
          lastPhoto = loadImage(filenameUrl, "jpg");
          if (DEBUG) println("loadImage "+filenameUrl);
          showPhoto = true;
        } else {
          if (DEBUG) println("same filename "+ afilenameUrl + " "+ filenameUrl);
        }
      }
      inString = "";
      return null;
    } else if (inString.startsWith("/mnt/mmc/screenshot")) {
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
      } else if (count == 3) {
        lastKeyCode = KEYCODE_FN_ZONE_REFRESH;
      } else if (count == 1) {
        if (decodeLong(inString, result)) {
          if (DEBUG) println("result="+result[0]);
          if (inString.indexOf("sysrw")>0) {
            shutterCount = result[0];
          }
        }
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

  void getCameraFnShutterEvISO() {
    if (client.active()) {
      client.write(  
        "prefman get " + APPID + " " +APPPREF_FNO_INDEX + " l" + 
        ";prefman get " + APPID + " " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
        ";prefman get "+ APPID + " " + APPPREF_ISO_PAS + " l" +
        ";prefman get "+ APPID + " " + APPPREF_EVC + " l" +
        "\n");
    }
  }

  void getCameraFnShutter() {
    client.write(  
      "prefman get " + APPID + " "  +APPPREF_FNO_INDEX + " l" + 
      ";prefman get "+ APPID + " "  +APPPREF_SHUTTER_SPEED_INDEX + " l" +
      "\n");
  }

  void getCameraEv() {
    client.write(  
      "prefman get "+ APPID + " "  + APPPREF_VAR_EVC + " l" +
      "\n");
  }

  int getISO () {
    return iso;
  }

  int getEv () {
    return ev;
  }

  String getEvName() {
    return evName[getEv()];
  }

  //void setCameraISO(int value) {
  //  iso = value;
  //  client.write("prefman set "+ APPID + " "  + APPPREF_ISO_PAS + " l " + iso + "\n");
  //}

  void setCameraFnShutterISO(int fnId, int shutterId, int isoId) {
    this.shutterSpeed = shutterValue[shutterId];
    this.fn = fnValue[fnId];
    this.iso = isoId;
    if (DEBUG) println("prefman set "+ APPID + " "  +APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set "+ APPID + " "  +APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set "+ APPID + " "  + APPPREF_ISO_PAS + " l " + iso +
      //      ";prefman get "+ APPID + " "  + APPPREF_EVC + " l" +
      "\n");
    client.write(
      "prefman set "+ APPID + " "  + APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set "+ APPID + " "  + APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set "+ APPID + " "  + APPPREF_ISO_PAS + " l " + iso +
      //      ";prefman get "+ APPID + " "  + APPPREF_EVC + " l" +
      ";st key mode "+ cameraModes[SMART_MODE]+
      ";sleep 1"+
      ";st key mode "+ cameraModes[MANUAL_MODE]+
      "\n");
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

  int getFn() {
    return fn;
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
    client.write("prefman save "+ APPID + "\n");
    if (DEBUG) println("prefman save "+ APPID + " ");
  }

  void getFilename() {
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

  void jogcw() {
    client.write("st key jog jog1_cw\n");
  }

  void jogccw() {
    client.write("st key jog jog1_ccw\n");
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

  void screenshot(String filename) {
    if (DEBUG) println("screenshot("+filename+")");
    if (client.active()) {
      //client.write("screenshot bmp /mnt/mmc/"+filename+convertCounter(screenshotCounter)+"_"+name+".bmp\n");
      client.write("/mnt/mmc/screenshot.sh\n");
    }
  }

  boolean screenshot() {
    if (DEBUG) println("screenshot()");
    if (!client.active()) {
      return false;
    }
    //   client.write("screenshot bmp /mnt/mmc/screenshot.bmp\n");
    //   printf "%b" '\x01\x00' > save_screen_enable.txt
    //   client.write("printf \"%b\" \'\\x01\\x00\' > /mnt/mmc/save_screen_enable.txt\n");
    client.write("/mnt/mmc/screenshot.sh\n");
    return true;
  }

  void getShutterCount() {
    if (DEBUG) println("get shutter count");
    client.write("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
    if (DEBUG) println("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
  }

  void getPrefMem(int id, int offset, String type) {
    client.write("prefman get "+id+" "+offset+" "+ type+"\n");
  }

  void getPrefMemBlock(int id, int offset, int size) {
    client.write("prefman get "+id+" "+offset+" v="+size+"\n");
  }

  void updateFn() {
    if (DEBUG) println("updateFn()");
    //  int currentFnId = getFnId(getFn());
    //  int nextFnId = fnId;
    //  int count = nextFnId - currentFnId;
    //  if (DEBUG) println("jog count="+count);
    //  if (count == 0) {
    //    return;
    //  }
    //  String jog = "ccw";
    //  if (count < 0) {
    //    count = -count;
    //    jog = "cw";
    //  }
    //  String cmd = "st key click ev" +
    //    ";st key click ev";
    //  for (int i=0; i<count; i++) {
    //    cmd += ";st key jog "+jog;
    //  }
    //  cmd += ";st key click ev;st key click ev\n";
    //  client.write(cmd);
  }
}
