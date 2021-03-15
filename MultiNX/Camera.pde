
// List of camera IP addresses to access
String[] ip = { 
  //"192.168.216.56"
  // "10.0.0.245",
  // "10.0.0.25",
  "10.0.0.180", 
  //  "10.0.0.30"
  //, "10.0.0.58"
  //, "10.0.0.41"
};

int NumCameras = ip.length;

String prompt = "nx2000:/# ";// get Camera state
int screenshotCounter = 1;
String screenshotFilename = "screenshot";
int GET_NONE = 0;
int GET_ISO = 1;

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
  String inString;
  int inValue;
  int getType;
  
  NX2000Camera(String ipAddr, Client client) {
    this.ipAddr = ipAddr;
    this.client = client;
    connected = false;
  }

  void getResult() {
    if (client.available() > 0) { 
      inString = client.readString(); 
      if (decodeLong(inString)) {
        println("result="+inValue);
        if (getType == GET_ISO) {
          iso = inValue;
          getType = GET_NONE;
          isoId = iso;
          gui.fnTable.setIso(iso);
        }
      }
    }
  }

  boolean decodeLong(String s) {
    boolean decoded = false;
    int index = s.lastIndexOf("(0x");
    if (index >= 0) {
      println(s.substring(index+3, index+11));
      inValue = unhex(s.substring(index+3, index+11));
      decoded = true;
    }
    return decoded;
  }

  void getCameraISO() {
    getType = GET_ISO;
    client.write("prefman get 1 0x64 l\n");
  }
  
  int getISO () {
    return iso;
  }

  void setCameraISO(int value) {
    iso = value;
    client.write("prefman set 1 0x64 l "+iso+"\n");
  }
 

  int getShutterSpeed () {
    return shutterSpeed;
  }

  int getFn() {
    return fn;
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
    client.write("st key mode "+ cameraModes[m]+"\n");
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

  void screenshot(String filename) {
    client.write("screenshot bmp /mnt/mmc/"+filename+convertCounter(screenshotCounter)+"\n");
  }

  void getPrefMem(int id, int offset, String type) {
    client.write("prefman get "+id+" "+offset+" "+ type+"\n");
  }

  void getPrefMemBlock(int id, int offset, int size) {
    client.write("prefman get "+id+" "+offset+" v="+size+"\n");
    //prefman get 1 8 v=96
  }
}
