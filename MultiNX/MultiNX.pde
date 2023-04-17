// Andy Modla
// Copyright 2021-2023 Andrew Modla All Rights Reserved
// Github:
// Java sketch for simultaneous WiFi telnet/ssh/UDP broadcast control of compatible multiple cameras
// 1) Samsung NX cameras
// 2) Android devices and phones running the  Multi Remote Camera (MRC) App
// 3) Raspberry PI cameras.
// 4) M5Stack.com Timer camera
//

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

static final boolean DEBUG = true;
static final boolean testGui = false;

static final String VERSION_NAME = "2.4";
static final String VERSION_CODE = "12";
static final String TITLE = "MultiNX - Multi Camera Controller";
static final String SUBTITLE = "Control Multiple NX/MRC/RPI Cameras";
static final String CREDITS = "Written by Andy Modla";
static final String COPYRIGHT = "Copyright 2021-2023 Andrew Modla";
static String version;

// Configuration file parsed settings for cameras
String camera_rig = "multiple";

// TODO
String[] photoFnPrefix; // default IMG_
String[] photoFnSuffix; // default "" empty string
String[] videoFnPrefix; // default VID_
String[] videoFnSuffix; // default "" empty string

int numCameras = 0;
int mainCamera = 0;  // current display camera
int currentCamera = 0;  // all synced

// The graphic interface intializes based on first camera type specified in configuration
int cameraType = NX2000;  // default
boolean allCameras = true;  // synchronize all cameras to same settings as mainCamera
String saveFolderPath;
String defaultFilename = "config.json";
String lastFilename = "last.txt";
String configFilename;
String titleText = TITLE;
String NOT_IMPLEMENTED = "Not Implemented";

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
  "EXIT_STATE"
};

String message=null;
int messagePosition = 0;
int frameCounter = 0;
boolean showPhoto = false;
int screenshotCounter = 1;
String screenshotFilename = "screenshot";
boolean screenshotRequest = false;
boolean requestScreenshot = false;
boolean displayAnaglyph = false;
boolean forceExit = false;
boolean cameraStatus = false;

// repeat function variables // milliseconds using System.currentTimeMillis();
boolean repeat_enabled = false;
volatile long repeat_start_delay = 0;
volatile long repeat_interval = 0;  // milliseconds
volatile long repeat_time = 0;
volatile long repeat_endtime = 0;
volatile long repeat_counter;

void settings() {
  size(1920, 1080);  // TODO fullscreen and adjust GUI for various sizes and aspect ratio
  // the GUI layout is requires 1920x1080
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
  frameRate(30.0);
  version = "Version "+ VERSION_NAME + " Build "+ VERSION_CODE;
  if (DEBUG) {
    version = version + " DEBUG";
    println("version="+version);
  }

  setTitle(titleText);

  textSize(FONT_SIZE);
  if (DEBUG) println("load images");
  // get data folder images for the app
  lcdScreen = loadImage("screenshot/nx2000/blankscreen.png");
  cameraImage = loadImage("images/nx2000_topview_270x270.jpg");

  // java.lang.IllegalArgumentException: File /data/data/com.andymodla.apps.multinx/files/screenshot/nx2000/blankscreen.png contains a path separator
  //lcdScreen = loadImage(sketchPath("screenshot") + File.separator +"nx2000"+File.separator+ "blankscreen.png");
  //cameraImage = loadImage(sketchPath("images")+ File.separator + "nx2000_topview_270x270.jpg");

  if (DEBUG) println("setup width="+width + " height="+height);

  loadPhotoNumber();
  if (DEBUG) println("setup() completed");
}

void draw() {
  int[] result = null; // keep this line do not delete

  // update message display visible counter
  //
  if (frameCounter > 0) {
    frameCounter--;
    gui.displayMessage(message);
    return;
  } else {
    message = null;
    if (forceExit) {
      lastKeyCode = KEYCODE_ESC;
    }
  }

  if (state == PRE_SAVE_STATE) {
    state = SAVE_STATE;
    return;
  }
  if (state == SAVE_STATE) {
    if (DEBUG) println(stateName[state]+ " filename="+camera[mainCamera].filename);
    if (camera[mainCamera].filename.length() > 0) {
      savePhoto(camera[mainCamera].filename.substring(0, camera[mainCamera].filename.lastIndexOf("_")) );
    }
    message = null;
    state = RUN_STATE;
  }
  background(128);

  if (screenshot != null && screenshot.width>0 && screenshot.height>0) {
    if (camera[mainCamera].type == NX2000 || camera[mainCamera].type == NX300 || camera[mainCamera].type == NX30) {
      imageMode(CENTER);
      pushMatrix();
      translate(lcdScreen.width, lcdScreen.height);
      rotate(3*PI/2.0);
      if (camera[mainCamera].type == NX300 || camera[mainCamera].type == NX30) {
        image(screenshot, 0, -80, 2*screenshot.width, 2*720);
      } else {
        image(screenshot, 0, 0, 2*screenshot.width, 2*screenshot.height);
      }
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
    gui.displayConfigZone();
    keyUpdate();
    return;
  } else if (state == PRE_CONNECT_STATE) {
    gui.removeConfigZone();
    state = CONNECT_STATE;
    drawIntroductionScreen();
    gui.displayMessage("Using Last Configuration", 60);
    return;
  } else if (state == CONNECT_STATE) {
    if (configFilename == null) {
      if (DEBUG) println("configFilename="+configFilename);
      if (buildMode == ANDROID_MODE) {
        configFilename = loadConfig();
      }
      if (configFilename == null) {
        configFilename = defaultFilename;
      }
    } else {
      if (DEBUG) println("configFilename="+configFilename);
      if (buildMode == ANDROID_MODE) {
        saveConfig(configFilename);
      } else {
        String[] content = new String[1];
        content[0] = configFilename;
        saveStrings("data"+File.separator+lastFilename, content);
      }
    }
    int errorCode = initConfig();
    if (errorCode == -1) {
      gui.displayMessage("Configuration File Error "+configFilename, 180);
      state = INTRODUCTION_STATE;
      return;
    } else if (errorCode == -2) {
      gui.displayMessage(message, 180);
      state = INTRODUCTION_STATE;
      return;
    }

    // initialze GUI when the configuration is OK
    // Configure GUI based on first camera type - cannot mix camera types.
    if (numCameras > 0) {
      cameraType = camera[0].type;
      gui.createGui(cameraType);
    }
  }
  state = RUN_STATE;

  // process key and mouse inputs on this main sketch loop
  lastKeyCode = keyUpdate();

  if (state == EXIT_STATE) {
    for (int i=0; i<numCameras; i++) {
      camera[i].stop();
    }
    exit();
  }

  // check for repeat
  if (repeat_enabled && repeatCount > 0) {
    gui.highlightRepeatKey(true);  // set Repeat button highlight
    long currentTime = System.currentTimeMillis(); // current time in milliseconds
    if (Long.compareUnsigned(currentTime, repeat_time) >= 0 && (Long.compareUnsigned(currentTime, repeat_start_delay) >= 0 )) {
      repeat_time = repeat_time + repeat_interval;
      if (Long.compareUnsigned(repeat_time, repeat_endtime) < 0) {
        lastKeyCode = KEYCODE_T;  // take picture
        repeat_counter++;
        if (DEBUG) println("shutter at: "+currentTime+ " repeat_time="+repeat_time);
        if (repeat_counter >= repeatCount) {
          repeat_enabled = false;
          gui.highlightRepeatKey(false); // set repeat button white background
        }
      }
    }
  }

  if (displayAnaglyph) {
    if (DEBUG) println("Anaglyph display");
    if (lastAnaglyph == null) {
      displayAnaglyph = false;
    } else {
      //gui.displayMessage("anaglyph display", 40);
      float ar = (float)lastAnaglyph.width/(float)lastAnaglyph.height;
      float offset = (2*camera[0].screenWidth-((2*camera[0].screenHeight)*ar))/2;
      image(lastAnaglyph, offset, 0, (2*camera[0].screenHeight)*ar, 2*camera[0].screenHeight);
    }
  } else {
    for (int i=0; i<numCameras; i++) {
      String inString = "";
      //if (DEBUG) println("MultiNX camera connected="+camera[i].isConnected());
      //if (camera[i].client != null) {
      //  if (DEBUG) println(" client active="+camera[i].client.active());
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
                if (DEBUG) println("Camera "+ camera[i].name+" " + camera[i].ipAddr +" connected");
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
        if (camera[i].lastPhoto != null && camera[i].lastPhoto.width>0 && camera[i].lastPhoto.height> 0 && showPhoto) {
          textSize(SMALL_FONT_SIZE);
          //if (DEBUG) println("show "+camera[i].filename + " " + camera[i].lastPhoto.width + " "+camera[i].lastPhoto.height);
          float w = camera[i].lastPhoto.width;
          float h = camera[i].lastPhoto.height;
          if (w > 0 && h > 0 && camera[i].needsRotation) {
            if (camera[i].orientation != 0) {
              camera[i].lastPhoto = rotatePhoto(camera[i].lastPhoto, camera[i].orientation);
            }
            camera[i].needsRotation = false;
            showPhoto = true;
          }
          float ar = w/h;
          float div = 8.0;
          if (w <= 1728) {
            div = 3.0;
          }

          if (w > 0 && h > 0) {
            if (numCameras == 1) {
              float offset = (2*camera[i].screenWidth-((2*camera[i].screenHeight)*ar))/2;
              image(camera[i].lastPhoto, offset, 0, (2*camera[i].screenHeight)*ar, 2*camera[i].screenHeight);
              text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, 10, 30);
            } else if (numCameras == 2) {
              image(camera[i].lastPhoto, i*camera[i].screenWidth, 0, (camera[i].screenWidth), camera[i].screenWidth/ar);
              text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, i*camera[i].screenWidth+10, 30);
            } else {
              image(camera[i].lastPhoto, (i%2)*camera[i].screenWidth, (i/2)*(camera[i].screenHeight), (camera[i].screenHeight)*ar, camera[i].screenHeight);
              text(camera[i].name + " "+camera[i].ipAddr+" "+camera[i].filename, (i%2)*camera[i].screenWidth+10, 30+ (i/2)*(camera[i].screenHeight));
            }
          }
        } else {
          textSize(FONT_SIZE);
          if (screenshot == null || cameraStatus) {
            if (camera[i].shutterCount == 0) {
              text(camera[i].name + " " + CAMERA_TYPES[camera[i].type] + " " + camera[i].orientation + "\u00B0 " + camera[i].ipAddr + " Connected.", 200, 110+i*50);
            } else {
              text(camera[i].name + " " + CAMERA_TYPES[camera[i].type] + " " + camera[i].orientation + "\u00B0 " + camera[i].ipAddr + " Shutter Count " + camera[i].shutterCount, 200, 110+i*50);
            }
          }
        }
      } else {
        text (camera[i].name+" "+ camera[i].ipAddr + " Not Connected.", 200, 110+i*50);
      }
    }
  }
  // Display camera control buttons
  if (numCameras > 0) {
    gui.displayFocusArea();
    gui.displayMenuBar();
    gui.modeTable.display();
    gui.fnTable.display();
    gui.navTable.display();
  }

  if (cameraStatus) {
    fill(255);
    int i = 4;
    int offset = 790;
    text(version, offset, 110+i*50);
    i++;
    String date = "";
    if (repeatStartDateTime != null) date = repeatStartDateTime;

    if (repeat_enabled) {
      text("Repeat active " + date, offset, 110 + i*50);
      text("Repeat active " + " startDelay=" + repeatStartDelay + "  "+"Interval="+repeatInterval + " Count "+repeat_counter+" of " + repeatCount, offset, 160 + i*50);
    } else {
      text("Repeat off " + date, offset, 110 + i*50);
      text("Repeat off " + " startDelay=" + repeatStartDelay + "  "+"Interval=" + repeatInterval + " Count=" + repeatCount, offset, 160 + i*50);
    }
  }

  // Display information or error message
  gui.displayMessage(message);

  // set main camera index as first connected camera
  //for (int i=0; i<numCameras; i++) {
  //  if (camera[i].isConnected()) {
  //    mainCamera = i;
  //    break;
  //  }
  //}

  // Drawing finished, check for screenshot request
  saveScreenshot();
  if (requestScreenshot) {
    requestScreenshot = false;
    lastKeyCode = KEYCODE_I;
  }
} // draw()

// to be used
void imageDraw(int i, int offset, float ar) {
  if (camera[i].orientation != 0) {
    pushMatrix();
    imageMode(CENTER);
    translate(camera[i].screenWidth/2, (camera[i].screenWidth/ar)/2);
    rotate(radians((camera[i].orientation)));
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
    //if (ANDROID_MODE)
    saveScreen(sketchPath("screenshot")+File.separator, "screenshot_", number(screenshotCounter), "png");
    if (DEBUG) println("save "+ "screenshot_" + number(screenshotCounter));
    screenshotCounter++;
  }
}
