
// List of camera IP addresses to access
String[] ip = { 
  //"192.168.216.56"
  // "10.0.0.245",
  "10.0.0.25", 
  //"10.0.0.180", 
  //  "10.0.0.30"
  //, "10.0.0.58"
  //, "10.0.0.41"
};

int NumCameras = ip.length;

String prompt = "nx2000:/# ";// get Camera state
int screenshotCounter = 1;
String screenshotFilename = "screenshot";
//int GET_NONE = 0;
//int GET_ISO = 1;
//int GET_SS = 2;
//int GET_FN = 3;

class NX2000Camera {
  static final int screenWidth = 800;
  static final int screenHeight = 480;
  int iso;
  int shutterSpeed;
  int fn;
  int ev;
  Client client;
  boolean connected;
  String ipAddr;
  int shutterCount;
  int[] result;

  NX2000Camera(String ipAddr, Client client) {
    this.ipAddr = ipAddr;
    this.client = client;
    connected = false;
  }

  int[] getCameraResult() {
    if (client.available() == 0) {
      return null;
    }
    String inString = "";
    while (!inString.endsWith(prompt)) {
      if (client.available() > 0) { 
        inString += client.readString(); 
        println("inString="+inString);
        if (inString.startsWith("exit")) {
          return null;
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
              println("result="+result[i]);
            }
            fn = result[0];
            gui.fnTable.setFn(fn);

            shutterSpeed = result[1];
            gui.fnTable.setShutter(shutterSpeed);

            iso = result[2];
            gui.fnTable.setIso(iso);
            
            ev = result[3];
            lastKeyCode = 501;
          } else if (count == 1) {
            if (decodeLong(inString, result)) {
              println("result="+result[0]);
              if (inString.indexOf("system_rw")>0) {
                shutterCount = result[0];
              }
            }
          } else if (count > 4) {
            if (decodeLongSequence(inString, result)) {
              for (int j=0 ; j<count; j++)
                println("result="+result[j]);
            }
          }
          break;
        }
      }
    }
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

  void getCameraFnShutterISO() {
    client.write(  
      "prefman get 1 " +APPPREF_FNO_INDEX + " l" + 
      ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
      ";prefman get 1 " + APPPREF_ISO_PAS + " l" +
      "\n");
  }

  void getCameraFnShutterEvISO() {
    client.write(  
      "prefman get 1 " +APPPREF_FNO_INDEX + " l" + 
      ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
      ";prefman get 1 " + APPPREF_ISO_PAS + " l" +
      ";prefman get 1 " + APPPREF_EVC + " l" +
      "\n");
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

  //void setCameraISO(int value) {
  //  iso = value;
  //  client.write("prefman set 1 " + APPPREF_ISO_PAS + " l " + iso + "\n");
  //}

  void setCameraFnShutterISO(int fnId, int shutterId, int isoId) {
    this.shutterSpeed = shutterValue[shutterId];
    this.fn = fnValue[fnId];
    this.iso = isoId;
    println("prefman set 1 " +APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set 1 " + APPPREF_ISO_PAS + " l " + iso +
      "\n");
    client.write(
      "prefman set 1 " + APPPREF_FNO_INDEX + " l " + this.fn +
      ";prefman set 1 " + APPPREF_SHUTTER_SPEED_INDEX + " l " + this.shutterSpeed +
      ";prefman set 1 " + APPPREF_ISO_PAS + " l " + iso +
      ";st key mode "+ cameraModes[SMART_MODE]+
    // ";sleep 1"+
      ";st key mode "+ cameraModes[MANUAL_MODE]+
      "\n");
  }

  int getShutterSpeed () {
    return shutterSpeed;
  }

  int getFn() {
    return fn;
  }

  void save() {
    client.write("prefman save 1\n");
    println("prefman save 1");
  }
  
  boolean isConnected() {
    return connected;
  }

  void setConnected(boolean value) {
    connected = value;
  }

  void focusPush() {
    client.write("st key push s1\n");
  }

  void focusRelease() {
    client.write("st key release s1\n");
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
    println("st key mode "+ cameraModes[m]+"\n");
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

  void ev() {
    client.write("st key click ev\n");
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
    client.write(msg);
  }

  void startFtp() {
    client.write("tcpsvd -vE 0.0.0.0 21 ftpd /mnt/mmc/DCIM/100PHOTO\n");
  }

  void stopFtp() {
    client.write("\032\n");  // TODO need kill process
  }

  void sendDelay(int second) {
    client.write("sleep "+second+"\n");
  }

  void functionAndBack() {
    client.write("st key click fn;sleep 2;st key touch click 40 40\n");
  }

  void screenshot(String filename) {
    client.write("screenshot bmp /mnt/mmc/"+filename+convertCounter(screenshotCounter)+"\n");
  }

  void getShutterCount() {
    println("get shutter count");
    client.write("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
    println("prefman get "+SYSRWID + " "+ SYSRWPREF_SHUTTER_COUNT+" l\n");
    
  }

  void getPrefMem(int id, int offset, String type) {
    client.write("prefman get "+id+" "+offset+" "+ type+"\n");
  }

  void getPrefMemBlock(int id, int offset, int size) {
    client.write("prefman get "+id+" "+offset+" v="+size+"\n");
    //prefman get 1 8 v=96
  }
}
