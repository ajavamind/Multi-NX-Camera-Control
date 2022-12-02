// Andy Modla
// Copyright 2021-2022 Andrew Modla All Rights Reserved
// Java sketch for simultaneous telnet/ssh control of compatible multiple Samsung NX cameras, or
// multiple phones running the Android Multi Remote Camera (MRC) Apps, or Raspberry PI cameras.

// The SD memory card root folder in each Samsung camera requires the following files present
// depending on the camera for starting telnet, http and ftp servers:
// autoexec.sh and inetd.conf

/* autoexec.sh contents for the NX2000:
 
 #!/bin/sh
 
 mkdir -p /dev/pts
 mount -t devpts none /dev/pts
 httpd -h /mnt/mmc
 inetd /mnt/mmc/inetd.conf
 
 */
/* inetd.conf contents for the NX2000:
 
 
 21  stream  tcp  nowait  root  ftpd  ftpd -w /mnt/mmc/
 23  stream  tcp  nowait  root  telnet  telnetd -i -l /bin/bash
 
 */

//  port 22  ssh not used with Samsung NX cameras or MRC, needed for Raspberry Pi based cameras

// ftpd is optional you can add comment character # to prevent the FTP server from starting
// make sure autoexec.sh has UNIX line ending x0a only, no x0dx0a line ending characters (windows)
// Use email WiFi cofiguration on NX2000 to connect to a local network.
// Exit email screen on NX camera to shoot photos and videos after connection to your local WiFi network.

static final String VERSION = "Version 1.3";
static final String VERSION_DEBUG = "Version 1.3 DEBUG";
static final String TITLE = "MultiNX";
static final String SUBTITLE = "Control Multiple NX/MRC/RPI Cameras";
static final String CREDITS = "Written by Andy Modla";

static final boolean testGui = false;
static final boolean DEBUG = true;
//static final boolean DEBUG = false;

// Configuration file parsed settings for cameras
String[] ip = null; // List of camera IP addresses to access
String[] cameraName;  // Camera name, location, or identifier - no spaces, use underscore
String[] cameraSType; // NX2000, NX300, NX500, MRC, RPI
String[] cameraOrientation;  // default 0 otherwise use 90, 180, or 270 degree rotation of camera
String[] cameraUserId; // Raspberry PI user id
String[] cameraPassword; // Raspberry PI password

// TODO
String[] photoFnPrefix; // default IMG_
String[] photoFnSuffix; // default "" empty string
String[] videoFnPrefix; // default VID_
String[] vodepFnSuffix; // default "" empty string

int NumCameras = 0;
int mainCamera = 0;  // current display camera
int currentCamera = 0;  // all synced

// The graphic interface intializes based on first camera type specified in configuration
int cameraType = NX2000;  // default
boolean allCameras = true;  // synchronize all cameras to same settings as mainCamera
String saveFolderPath;
String defaultFilename = "default.txt";
String configFilename;

RCamera[] camera;
PImage lcdScreen;  // camera LCD screen image
PImage cameraImage;
PImage screenshot;
Gui gui;

int INTRODUCTION_STATE = 0;
int CONFIGURATION_STATE = 1;
int CONFIGURATION_DIALOG_STATE = 2;
int PRE_CONNECT_STATE = 3;
int CONNECT_STATE = 4;
int RUN_STATE = 5;
int PRE_SAVE_STATE = 6;
int SAVE_STATE = 7;
int EXIT_STATE = 9;
int state = INTRODUCTION_STATE;
String[] stateName = {
  "INTRODUCTION_STATE",
  "CONFIGURATION_STATE",
  "CONFIGURATION_DIALOG_STATE",
  "PRE_CONNECT_STATE",
  "CONNECT_STATE",
  "RUN_STATE",
  "PRE_SAVE_STATE",
  "SAVE_STATE",
  "UNDEFINED STATE",
  "UNDEFINED STATE",
  "EXIT_STATE"
};

String message=null;
int frameCounter = 60;
boolean showPhoto = false;
//boolean showScreenshot = false;
int screenshotCounter = 1;
String screenshotFilename = "screenshot";
boolean screenshotRequest = false;

boolean forceExit = false;

void settings() {
  size(1920, 1080);
  //size(1280, 720);  // for testing on a smaller display TODO needs GUI refactor
  //size(960, 540);  // for testing on a smaller display TODO needs GUI refactor
  smooth();
  gui = new Gui();
  gui.createConfigZone();
  gui.create(this);
}

void setup() {
  // set Landscape orientation
  orientation(LANDSCAPE);

  textSize(FONT_SIZE);

  lcdScreen = loadImage("screenshot/nx2000/blankscreen.png");
  cameraImage = loadImage("images/nx2000_topview_270x270.jpg");
  if (DEBUG) println("width="+width + " height="+height);

  loadPhotoNumber();
}

void draw() {
  int[] result = null; // keep

  // update message display visible counter
  //
  if (frameCounter > 0) {
    frameCounter--;
  } else {
    message = null;
    if (forceExit) {
      lastKeyCode = KEYCODE_ESCAPE;
    }
  }

  if (state == PRE_SAVE_STATE) {
    state = SAVE_STATE;
    return;
  }
  if (state == SAVE_STATE) {
    if (DEBUG) println(stateName[state]);
    savePhoto(camera[mainCamera].filename.substring(0, camera[mainCamera].filename.lastIndexOf("_")) );
    message = null;
    state = RUN_STATE;
  }
  //background(128);
  background(0);
  if (screenshot != null) {
    if (camera[mainCamera].type == NX2000 || camera[mainCamera].type == NX300 || camera[mainCamera].type == NX30) {
      imageMode(CENTER);
      pushMatrix();
      translate(lcdScreen.width, lcdScreen.height);
      rotate(3*PI/2.0);
      image(screenshot, 0, 0, 2*screenshot.width, 2*screenshot.height);
      popMatrix();
      imageMode(CORNER);
    } else {
      image(screenshot, 0, 0, 2*screenshot.width, 2*screenshot.height);
    }
  } else {
    image(lcdScreen, 0, 0, 2*lcdScreen.width, 2*lcdScreen.height);
  }
  if (state == INTRODUCTION_STATE || state == CONFIGURATION_STATE) {
    if (state == INTRODUCTION_STATE) {
      openFileSystem();
      gui.displayConfigZone();
    }
    if (state == CONFIGURATION_STATE) {

      state = CONFIGURATION_DIALOG_STATE;
      selectConfigurationFile();
    }
    drawIntroductionScreen();
    keyUpdate();
    return;
  } else if (state == CONFIGURATION_DIALOG_STATE) {
    drawIntroductionScreen();
    keyUpdate();
    return;
  } else if (state == PRE_CONNECT_STATE) {
    gui.removeConfigZone();
    state = CONNECT_STATE;
    drawIntroductionScreen();
    gui.displayMessage("Using Last Configuration");
    return;
  } else if (state == CONNECT_STATE) {
    String[] cameraList = null;
    String[] cameraFile = null;
    if (configFilename == null) {
      if (DEBUG) println("configFilename="+configFilename);
      if (ANDROID_MODE) {
        configFilename = loadConfig();
      }
      if (configFilename == null) {
        configFilename = defaultFilename;
      }
      cameraFile = loadStrings(configFilename);
    } else {
      if (DEBUG) println("configFilename="+configFilename);
      cameraFile = loadStrings(configFilename);
      if (ANDROID_MODE) {
        saveConfig(configFilename);
      } else {
        saveStrings("data"+File.separator+defaultFilename, cameraFile);
      }
    }

    NumCameras =0;
    for (int i=0; i<cameraFile.length; i++) {
      if (DEBUG) println(cameraFile[i]);
      cameraFile[i].trim();
      if (!(cameraFile[i].startsWith("#") || cameraFile[i].equals(""))) {
        NumCameras += 1;
      }
    }

    if (DEBUG) println("number of cameras "+NumCameras);
    int j = 0;
    cameraList = new String[NumCameras];
    for (int i=0; i<cameraFile.length; i++) {

      if (!(cameraFile[i].startsWith("#") || cameraFile[i].equals(""))) {
        cameraList[j++] = cameraFile[i];
      }
    }

    ip = new String[NumCameras];
    cameraName = new String[NumCameras];
    cameraSType = new String[NumCameras];
    cameraOrientation = new String[NumCameras];
    cameraUserId = new String[NumCameras];
    cameraPassword = new String[NumCameras];

    for (int i=0; i<cameraList.length; i++) {
      if (DEBUG) println(cameraList[i]);

      String[] group = splitTokens(cameraList[i]);
      if (DEBUG) println("configuration line item group size="+group.length);
      ip[i] = group[0];
      cameraName[i] = group[1];
      cameraSType[i] = group[2];
      cameraOrientation[i] = group[3];
      if (group.length > 4 ) {
        cameraUserId[i] = group[4];
        cameraPassword[i] = group[5];
      }
    }

    // Create camera instances
    camera = new RCamera[NumCameras];
    for (int i=0; i<NumCameras; i++) {
      if (DEBUG) println("configuration: "+ i + " " + ip[i] + " " + cameraName[i] + " " + cameraSType[i] + " " + cameraOrientation[i]);
      if (cameraSType[i].equals(NX2000S)) {
        camera[i] = new NX2000Camera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(NX500S)) {
        camera[i] = new NX500Camera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(NX300S)) {
        camera[i] = new NX300Camera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(NX30S)) {
        camera[i] = new NX30Camera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(MRCS)) {
        camera[i] = new MRCCamera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(RPIS)) {
        camera[i] = new RPICamera(this, ip[i], cameraUserId[i], cameraPassword[i]);
        camera[i].setName(cameraName[i], i);
      } else if (cameraSType[i].equals(TMCS)) {
        camera[i] = new TMCCamera(this, ip[i]);
        camera[i].setName(cameraName[i], i);
      } else {
        if (DEBUG) println(ip[i] + " Configuration Error!");
        NumCameras = 0;
        message = ip[i] + " Configuration Error! "+cameraSType[i];
        forceExit = true;
      }
    }
    // initialze GUI when the configuration is OK
    // Configure GUI based on first camera type - cannot mix camera types.
    if (NumCameras > 0) {
      cameraType = camera[0].type;
      gui.createGui(cameraType);
    }
  }
  state = RUN_STATE;

  // process key and mouse inputs on this main sketch loop
  keyUpdate();

  if (state == EXIT_STATE) {
    for (int i=0; i<NumCameras; i++) {
      camera[i].stop();
    }
    exit();
  }

  if (NumCameras > 0) {
    //if (DEBUG) println("displayGrid");
    //gui.displayGrid(4);
  }

  for (int i=0; i<NumCameras; i++) {
    String inString = "";
    //println("MultiNX camera connected="+camera[i].isConnected());
    //if (camera[i].client != null) {
    //  println(" client active="+camera[i].client.active());
    //}
    if (!camera[i].isConnected()) {
      if (camera[i].client != null && camera[i].client.active()) {
        if (DEBUG) println("wait for prompt");
        while (!inString.endsWith(camera[i].prompt)) {
          if (camera[i].client.available() > 0) {
            inString += camera[i].client.readString();
            if (DEBUG) println(inString);
            // NX500 and NX30 needs login: root response
            if (inString.endsWith("login: ")) {
              camera[i].sendMsg("root\n");
              break;
            }

            if (inString.endsWith(camera[i].prompt)) {
              camera[i].setConnected(true);
              if (DEBUG) println("Camera "+camera[i].name+" "+ip[i]+" connected");
              camera[i].getCameraFnShutterEvISO();
              break;
            }
          }
        }
      }
    } else {
      result = camera[i].getCameraResult();
    }

    textSize(FONT_SIZE);
    fill(255);
    textAlign(LEFT);
    if (!camera[i].isActive() ) {
      camera[i].setConnected(false);
    }

    // ---------------------------------------------------------------------
    // displayPhoto
    if (camera[i].isConnected()) {
      if (camera[i].lastPhoto != null && showPhoto) {
        textSize(SMALL_FONT_SIZE);
        //if (DEBUG) println("show "+camera[i].filename + " " + camera[i].lastPhoto.width + " "+camera[i].lastPhoto.height);
        float w = camera[i].lastPhoto.width;
        float h = camera[i].lastPhoto.height;
        float ar = w/h;
        float div = 8.0;
        if (w <= 1728) {
          div = 3.0;
        }

        if (w > 0 && h > 0) {
          if (NumCameras == 1) {
            float offset = (2*camera[i].screenWidth-((2*camera[i].screenHeight)*ar))/2;
            image(camera[i].lastPhoto, offset, 0, (2*camera[i].screenHeight)*ar, 2*camera[i].screenHeight);
            text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, 10, 30);
          } else if (NumCameras == 2) {
            image(camera[i].lastPhoto, i*camera[i].screenWidth, 0, (camera[i].screenWidth), camera[i].screenWidth/ar);
            text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, i*camera[i].screenWidth+10, 30);
          } else {
            image(camera[i].lastPhoto, (i%2)*camera[i].screenWidth, (i/2)*(camera[i].screenHeight), (camera[i].screenHeight)*ar, camera[i].screenHeight);
            text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, (i%2)*camera[i].screenWidth+10, 30+ (i/2)*(camera[i].screenHeight));
          }
        }
      } else {
        textSize(FONT_SIZE);
        if (camera[i].shutterCount == 0) {
          text(camera[i].name+" "+ip[i]+ " Connected.", 200, 110+i*50);
        } else {
          text(camera[i].name+" "+ip[i]+ " Shutter Count "+camera[i].shutterCount, 200, 110+i*50);
        }
      }
    } else {
      text (camera[i].name+" "+ip[i]+ " Not Connected.", 200, 110+i*50);
    }
  }

  if (NumCameras > 0) {
    gui.displayFocusArea();
    gui.displayMenuBar();
    gui.modeTable.display();
    gui.fnTable.display();
  }
  gui.displayMessage(message);

  // set main camera index as first connected camera
  //for (int i=0; i<NumCameras; i++) {
  //  if (camera[i].isConnected()) {
  //    mainCamera = i;
  //    break;
  //  }
  //}

  // Drawing finished, check for screenshot request
  saveScreenshot();
}

void imageDraw(int i, int offset, float ar) {
  if (cameraOrientation[i].equals("180")) {
    pushMatrix();
    imageMode(CENTER);
    translate(camera[i].screenWidth/2, (camera[i].screenWidth/ar)/2);
    rotate(radians(180));
    image(camera[i].lastPhoto, 0, 0, (camera[i].screenWidth), camera[i].screenWidth/ar);
    imageMode(CORNER);
    popMatrix();
  }
}

// Save image of the composite screen
void saveScreen(String outputFolderPath, String outputFilename, String suffix, String filetype) {
  save(outputFolderPath + File.separator + outputFilename + suffix + "." + filetype);
}

void saveScreenshot() {
  if (screenshotRequest) {
    screenshotRequest = false;
    saveScreen(sketchPath()+File.separator+"screenshot", "screenshot_", number(screenshotCounter), "png");
    if (DEBUG) println("save "+ "screenshot_" + number(screenshotCounter));
    screenshotCounter++;
  }
}

// Add leading zeroes to number
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
