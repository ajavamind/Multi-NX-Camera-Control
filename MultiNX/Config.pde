// Configuration from JSON file
// config.json is the default file - do not change config.json

import java.time.*;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.LocalDateTime;

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

// for stereo pair and anaglyph retification and stereo window adjustments
int verticalOffset; // twin camera vertical offset
int horizontalOffset; // twin camera horizontal offset

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
String repeatStartDateTime;
long repeatDateTime;
ZonedDateTime repeatStartZonedDateTime;

int initConfig() {
  int result = readConfig(configFilename);
  return result;
}

int readConfig(String filenamePath) {
  if (!fileExists(filenamePath)) {
    filenamePath = "config.json"; // default for development code test
  }
  try {
  configFile = loadJSONObject(filenamePath);
  configuration = configFile.getJSONObject("configuration");
  } catch (Exception e) {
    return -1;
  }

  camera_rig = configuration.getString("camera_rig");
  if (DEBUG) println("camera rig: " + camera_rig);

  try {
    verticalOffset = configuration.getInt("verticalOffset");
    horizontalOffset = configuration.getInt("horizontalOffset");
  }
  catch(Exception re) {
    verticalOffset = 0;
    horizontalOffset = 0;
    if (DEBUG) println("Missing verticalOffset or horizontalOffset");
  }
  if (DEBUG) println("verticalOffset="+verticalOffset+" horizontalOffset="+horizontalOffset);
  OUTPUT_FOLDER_PATH = configuration.getString("outputFolderPath");
  ipAddress = configuration.getString("IPaddress");
  if (DEBUG) println("broadcast ipAddress="+ipAddress);

  // display section
  display = configFile.getJSONObject("display");
  if (display != null) {
    screenWidth = display.getInt("width");
    screenHeight = display.getInt("height");
  }

  // print section - NOT USED
  screenAspectRatio = (float)screenWidth/(float)screenHeight;
  printer = configFile.getJSONObject("printer");
  if (printer != null) {
    printWidth = printer.getFloat("printWidth");
    printHeight = printer.getFloat("printHeight");
    printAspectRatio = printWidth/printHeight;
    if (DEBUG) println("printAspectRatio="+printAspectRatio);
  }

  // repeat section
  repeat = configFile.getJSONObject("repeat");
  if (repeat != null) {
    repeatStartDelay = repeat.getInt("start_delay");
    if (repeatStartDelay < 0) repeatStartDelay = 0; // do not allow negative delays
    repeatInterval = repeat.getInt("interval");
    repeatCount = repeat.getInt("count");
    repeatStartDateTime = repeat.getString("start_DateTime");
    if (repeatStartDateTime == null) {
      repeatDateTime = 0L;
    } else {
      LocalDateTime localDateTime = LocalDateTime.parse(repeatStartDateTime);
      repeatStartZonedDateTime = ZonedDateTime.of(localDateTime, ZoneId.systemDefault());
      Instant starttime = repeatStartZonedDateTime.toInstant();
      System.out.println("starttime ="+starttime.toEpochMilli());
      if (DEBUG) println("ZoneId.systemDefault(): " + ZoneId.systemDefault());
      //nowDateTime = nowInstantDateTime.toEpochMilli();
      repeatDateTime = starttime.toEpochMilli();
      if (DEBUG) println("repeat start date time="+repeatDateTime);
      if (DEBUG) println("repeatStartDelay="+repeatStartDelay+" repeatInterval="+repeatInterval+" repeatCount="+repeatCount+" repeatStartDateTime="+repeatStartDateTime);
      long currentTime = System.currentTimeMillis(); // current time in milliseconds
      if (Long.compareUnsigned(repeatDateTime, currentTime) <= 0) {  // do not allow past time
        repeatDateTime = 0;
        if (DEBUG) println("disallow start date time "+repeatStartDateTime);
      }
    }
  } else {
    if (DEBUG) println("No repeat config: repeatStartDelay="+repeatStartDelay+" repeatInterval="+repeatInterval+" repeatCount="+repeatCount);
  }

  // camera section
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
    // userId and password used for cameras accessed with SSH
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
      return -2;
    }
    camera[i].setName(cName);
    camera[i].setSuffix(cSuffix);
    camera[i].setOrientation(cOrientation);
  }
  return 0;
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
