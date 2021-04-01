// Camera parameters and control

String prompt = "nx2000:/# ";// get Camera state
int screenshotCounter = 1;
String screenshotFilename = "screenshot";
//int GET_NONE = 0;
//int GET_ISO = 1;
//int GET_SS = 2;
//int GET_FN = 3;

//most recent file
//FILENAME=`ls -t /mnt/mmc/DCIM/100PHOTO | head -1`;echo "filename=/DCIM/100PHOTO/$FILENAME"

class NX2000Camera {
  // screenshot dimensions
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
  String name;
  String filename = "";
  String filenameUrl = "";
  PImage lastPhoto;
  String inString;

  NX2000Camera(String ipAddr, Client client) {
    this.ipAddr = ipAddr;
    this.client = client;
    connected = false;
    name = "";
    inString = "";
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
      ;
      int fin = inString.lastIndexOf("FILENAME=");
      int lin = inString.lastIndexOf("nx2000");
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
          showPhoto = true;
        } else {
          
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

  //void getCameraFnShutterISO() {
  //  client.write(  
  //    "prefman get 1 " +APPPREF_FNO_INDEX + " l" + 
  //    ";prefman get 1 " +APPPREF_SHUTTER_SPEED_INDEX + " l" +
  //    ";prefman get 1 " + APPPREF_ISO_PAS + " l" +
  //    "\n");
  //}

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

  int getFn() {
    return fn;
  }

  void save() {
    client.write("prefman save 1\n");
    if (DEBUG) println("prefman save 1");
  }

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
    client.write("tcpsvd -vE 0.0.0.0 21 ftpd /mnt/mmc\n");
  }

  void stopFtp() {
    client.write("\032\n");  // TODO need kill process
  }

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
    client.write("screenshot bmp /mnt/mmc/"+filename+name+convertCounter(screenshotCounter)+"\n");
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

void takeMultiPhoto(NX2000Camera[] camera) {
  for (int i=0; i<NumCameras; i++) {
    camera[i].takePhoto();
  }
}

void focusMultiPhoto(NX2000Camera[] camera) {
  for (int i=0; i<NumCameras; i++) {
    camera[i].client.write("st key push s1;sleep 1;st key release s1\n"); // focus
  }
}
