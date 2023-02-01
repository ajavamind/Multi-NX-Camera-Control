// Configuration from JSON file
// config.json is the default file - do not change config.json

int screenWidth = 1920; // default
int screenHeight = 1080;  // default
float screenAspectRatio;

int cameraWidth = 1920;
int cameraHeight = 1080;
float cameraAspectRatio;
boolean doubleTrigger = false;
int doubleTriggerDelayMax = 1000;
int doubleTriggerDelayMin = 200;
int doubleTriggerDelay = doubleTriggerDelayMin;

String OUTPUT_FOLDER_PATH="output";  // where to store photos
String fileType = "jpg"; //  other file types "png" "bmp"

float printWidth;
float printHeight;
float printAspectRatio = 4.0/6.0;  // default 4x6 inch print portrait orientation

int countdownStart = 3;  // seconds
String ipAddress;  // this MultiNX app device IP Address
JSONObject configFile;
JSONObject configuration;
JSONObject display;
JSONArray cameras;
JSONObject printer;
JSONObject repeat;
int repeatStartDelay;
int repeatInterval;
int repeatCount;

void initConfig() {
  readConfig(configFilename);
}

void readConfig(String filenamePath) {
  //String filenamePath = sketchPath("config")+File.separator+"my_config.json";
  if (!fileExists(filenamePath)) {
    filenamePath = "config.json"; // default for development code test
  }
  configFile = loadJSONObject(filenamePath);
  configuration = configFile.getJSONObject("configuration");
  DEBUG = configFile.getBoolean("debug");

  camera_rig = configFile.getString("camera_rig");
  OUTPUT_FOLDER_PATH = configuration.getString("outputFolderPath");
  ipAddress = configuration.getString("IPaddress");
  if (DEBUG) println("broadcast ipAddress="+ipAddress);

  display = configFile.getJSONObject("display");
  if (display != null) {
    screenWidth = display.getInt("width");
    screenHeight = display.getInt("height");
  }
  screenAspectRatio = (float)screenWidth/(float)screenHeight;
  printer = configFile.getJSONObject("printer");
  if (printer != null) {
    printWidth = printer.getFloat("printWidth");
    printHeight = printer.getFloat("printHeight");
    printAspectRatio = printWidth/printHeight;
    if (DEBUG) println("printAspectRatio="+printAspectRatio);
  }
  repeat = configFile.getJSONObject("repeat");
  if (repeat != null) {
    repeatStartDelay = repeat.getInt("start_delay");
    repeatInterval = repeat.getInt("interval");
    repeatCount = repeat.getInt("count");
    if (DEBUG) println("repeatStartDelay="+repeatStartDelay+" repeatInterval="+repeatInterval+" repeatCount="+repeatCount);
  }
  if (DEBUG) println("Debug force repeatStartDelay="+repeatStartDelay+" repeatInterval="+repeatInterval+" repeatCount="+repeatCount);

  cameras = configFile.getJSONArray("cameras");
  numCameras = cameras.size();
  if (DEBUG) println("number of cameras "+numCameras);
  // Create camera instances
  camera = new RCamera[numCameras];

  for (int i=0; i<numCameras; i++) {
    JSONObject jCamera = cameras.getJSONObject(i);
    String cType = jCamera.getString("type");
    String cIP = jCamera.getString("IPaddress");
    int cOrientation = jCamera.getInt("orientation");
    String cName = jCamera.getString("name");
    String cSuffix = jCamera.getString("suffix");
    int cHorz = jCamera.getInt("horizontalOffset");
    int cVert = jCamera.getInt("verticalOffset");
    String cUserId = jCamera.getString("userId");
    String cPassword = jCamera.getString("password");
    if (cType.equals(NX2000S)) {
      camera[i] = new NX2000Camera(this, cIP);
    } else if (cType.equals(NX500S)) {
      camera[i] = new NX500Camera(this, cIP);
    } else if (cType.equals(NX300S)) {
      camera[i] = new NX300Camera(this, cIP);
    } else if (cType.equals(NX30S)) {
      camera[i] = new NX30Camera(this, cIP);
    } else if (cType.equals(MRCS)) {
      camera[i] = new MRCCamera(this, cIP);
    } else if (cType.equals(RPIS)) {
      camera[i] = new RPICamera(this, cIP, cUserId, cPassword);
    } else if (cType.equals(TMCS)) {
      camera[i] = new TMCCamera(this, cIP);
    } else {
      if (DEBUG) println(cIP + " Configuration Error!");
      numCameras = 0;
      message = cIP + " Configuration Error! "+ "index="+i+ " "+cType;
      return;
    }
    camera[i].setName(cName);
    camera[i].setSuffix(cSuffix);
    camera[i].setOrientation(cOrientation);
    camera[i].setHorizontalOffset(cHorz);
    camera[i].setVerticalOffset(cVert);
  }
}

// Check if file exists
boolean fileExists(String filenamePath) {
  File newFile = new File (filenamePath);
  if (newFile.exists()) {
    if (DEBUG) println("File "+ filenamePath+ " exists");
    return true;
  }
  return false;
}
