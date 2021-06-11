class NX500Camera extends NXCamera {

  static final int APPID = 0;
  static final int APP_RESTOREID = 1;
  static final int LINEID = 2;
  static final int SYSRWID = 3;

  static final int APPPREF_FNO_INDEX = 0x0000a338;
  static final int APPPREF_SHUTTER_SPEED_INDEX = 0x0000a340; 
  static final int APPPREF_EVC = 0x0000a344;
  static final int APPPREF_VAR_EVC = 0x0000c2b4;  
  static final int APPPREF_IFN_EV = 0x0000a658;
  static final int APPPREF_ISO_PAS = 0x0000a388;
  static final int APPPREF_B_DISABLE_MOVIE_REC_LIMIT =  0x0000c2d9; 
  static final int APPPREF_B_ENABLE_NO_LENS_RELEASE = 0x0000c2dd;

  static final int SYSRWPREF_SHUTTER_COUNT = 0x00000208;  

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

  NX500Camera(PApplet app, String ipAddr) {
    this.ipAddr = ipAddr;
    client = null;
    port = TelnetPort;
    if (!testGui) {
      client = new Client(app, ipAddr, port);
      if (DEBUG) println("Client "+ ipAddr + " active="+client.active());
    }
    
    connected = false;
    name = "";
    inString = "";
    prompt = "]# ";
    prefix = "[root";
    systemrw = "sysrw";
    screenShot = "/mnt/mmc/screenshot";
    focusOffset = screenWidth*(offsetPercent/100);
    type = NX500;
    shutterId = 1;
    fnId = 10;
    appId = APPID;
    sysrwId = SYSRWID;
    appFnoIndex = APPPREF_FNO_INDEX;
    appShutterSpeedIndex = APPPREF_SHUTTER_SPEED_INDEX;
    appIsoPas = APPPREF_ISO_PAS;
    appEvc = APPPREF_EVC;
    sysrwShutterCount = SYSRWPREF_SHUTTER_COUNT;
    evName = EV_NAME;
    shutterName = SHUTTER_NAME;
    shutterValue = SHUTTER_VALUE;
    fnName = FN_NAME;
    fnValue = FN_VALUE;

    screenWidth = SCREEN_WIDTH;
    screenHeight = SCREEN_HEIGHT;
  }

  void jogcw() {
    client.write("st key jog jog1_cw\n");
  }

  void jogccw() {
    client.write("st key jog jog1_ccw\n");
  }

  void screenshot(String filename) {
    if (DEBUG) println("screenshot("+filename+")");
    if (client.active()) {
      client.write("/mnt/mmc/screenshot.sh\n");
    }
  }

  boolean screenshot() {
    if (DEBUG) println("screenshot()");
    if (!client.active()) {
      return false;
    }
    client.write("/mnt/mmc/screenshot.sh\n");
    return true;
  }

  void updateFn() {
    if (DEBUG) println("updateFn()");
  }
  
  void updateSs() {
  }
  
  void updateIso() {
  }

}
