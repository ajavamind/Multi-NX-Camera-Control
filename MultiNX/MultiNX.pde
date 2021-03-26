// Andy Modla
// Copyright 2021 Andrew Modla
// Java sketch for telnet control of multiple Samsung NX2000 cameras
// SD memory card root folder in the camera needs the following file
// for starting telnet and ftp:
// autoexec.sh

/* autoexec.sh contents:
 
 #!/bin/sh
 
 mkdir -p /dev/pts
 mount -t devpts none /dev/pts
 
 telnetd -l /bin/bash -F > /mnt/mmc/telnetd.log 2>&1 &
 #tcpsvd -u root -vE 0.0.0.0 21 ftpd -w  /mnt/mmc & 
 
 */


// ftpd is optional you can remove comment character # to start the FTP server
// make sure autoexec.sh has UNIX line ending x0a only, no x0dx0a (windows)
// Use email WiFi cofiguration on NX2000 to connect to a local network.
// Exit email to shoot photos and videos after connection to your local WiFi network.

//import processing.net.*; 
//boolean testGui = true;
boolean testGui = false;
final static boolean DEBUG = true;
//final static boolean DEBUG = false;

int telnetPort = 23; // telnet port

// List of camera IP addresses to access
String[] ip = null;
String[] cameraName = {"LL", "LM", "RM", "RR"};
int NumCameras = 0;
int mainCamera = 0;
String saveFolderPath;
//String defaultFilename = "camera_noname.txt";
String defaultFilename = "default.txt";

//{ 
//  //"192.168.216.56"
//  "192.168.0.102", 
//  "192.168.0.103"
//  // "10.0.0.245",
//  //  "10.0.0.25", 
//  //  "10.0.0.180", 
//  //  "10.0.0.30"
//  //, "10.0.0.58"
//  //, "10.0.0.41"
//};

NX2000Camera[] camera;
PImage screen;  // camera LCD screen image
PImage screenshot;
Gui gui;
int FONT_SIZE = 48;
int MEDIUM_FONT_SIZE =  72;
int LARGE_FONT_SIZE = 96;
int GIANT_FONT_SIZE = 128;

int INTRODUCTION_STATE = 0;
int CONFIGURATION_STATE = 1;
int CONFIGURATION_DIALOG_STATE = 2;
int CONNECT_STATE = 3;
int RUN_STATE = 4;
int PRE_SAVE_STATE = 5;
int SAVE_STATE = 6;
int EXIT_STATE = 9;
int state = INTRODUCTION_STATE;
String[] stateName = {
  "INTRODUCTION_STATE", 
  "CONFIGURATION_STATE", 
  "CONFIGURATION_DIALOG_STATE", 
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
boolean showPhoto = true;
String configFilename;

void settings() {
  size(1920, 1080);
  smooth();
  gui = new Gui();
  gui.create(this);
}

void setup() { 
  // set Landscape orientation
  orientation(LANDSCAPE); 

  textSize(FONT_SIZE);

  //screen = loadImage("screenshot/nx2000/readytoshoot.png");
  screen = loadImage("screenshot/nx2000/readyfocustoshootmin.png");

  if (DEBUG) println("width="+width + " height="+height);
  //println("screen.width="+screen.width + " screen.height="+screen.height);
} 

void draw() { 
  int[] result = null;

  // update message display visible counter
  // 
  if (frameCounter > 0) {
    frameCounter--;
  } else {
    message = null;
  }

  if (state == PRE_SAVE_STATE) {
    state = SAVE_STATE;
    return;
  }  
  if (state == SAVE_STATE) {
    if (DEBUG) println(state);
    savePhoto();
    message = null;
    state = RUN_STATE;
  }
  background(128);
  if (screenshot != null) {
    imageMode(CENTER);
    pushMatrix();
    translate(screen.width, screen.height);
    rotate(3*PI/2.0);
    image(screenshot, 0, 0, 2*screenshot.width, 2*screenshot.height);
    popMatrix();
    imageMode(CORNER);
  } else {
    image(screen, 0, 0, 2*screen.width, 2*screen.height);
  }
  if (state == INTRODUCTION_STATE || state == CONFIGURATION_STATE) {
    if (state == INTRODUCTION_STATE) {
      openFileSystem();
      gui.displayConfigZone();
    }
    if (state == CONFIGURATION_STATE) {

      //gui.removeConfigZone();
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
  } else if (state == CONNECT_STATE) {
    gui.removeConfigZone();
    String[] config = null;
    if (configFilename == null) {
      if (DEBUG) println("configFilename="+configFilename);
      config = loadStrings(defaultFilename);
      //config = loadStrings("multicameras.txt");
      //String[] config = loadStrings("twincameras.txt");
      //String[] config = loadStrings("camera.txt");
    } else {
      if (DEBUG) println("configFilename="+configFilename);
      config = loadStrings(configFilename);
      saveStrings("data/"+defaultFilename, config);
    }
    if (DEBUG) println("number of cameras "+config.length);
    NumCameras = config.length;
    ip = new String[NumCameras];
    for (int i=0; i<config.length; i++) {
      if (DEBUG) println(config[i]);
      int iv = config[i].indexOf(" ");
      if (iv > 0) {
        ip[i] = config[i].substring(0, iv);
      }
      int in = config[i].indexOf(" ", iv+1);
      if (in > 0) {
        cameraName[i] = config[i].substring(iv+1, in);
      }
    }

    // Create telnet clients to connect to Samsung NX2000 cameras.
    camera = new NX2000Camera[NumCameras];
    for (int i=0; i<NumCameras; i++) {
      Client client = null;
      if (!testGui) {
        client = new Client(this, ip[i], telnetPort);
        if (DEBUG) println("client="+client);
        if (DEBUG) println("active="+client.active());
      }
      camera[i] = new NX2000Camera(ip[i], client);
      camera[i].setName(cameraName[i]);
    }
  }
  state = RUN_STATE;


  keyUpdate();

  if (state == EXIT_STATE) {
    for (int i=0; i<NumCameras; i++) {
      camera[i].client.stop();
    }
    exit();
  }

  for (int i=0; i<NumCameras; i++) {
    String inString = "";
    if (!camera[i].isConnected()) {
      if (camera[i].client != null && camera[i].client.active()) {
        while (!inString.endsWith(prompt)) {
          if (camera[i].client.available() > 0) { 
            inString += camera[i].client.readString(); 
            if (DEBUG) println(inString); 
            if (inString.endsWith(prompt)) {
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
    if (!camera[i].client.active() ) {
      camera[i].setConnected(false);
    }

    // ---------------------------------------------------------------------
    // displayPhoto
    if (camera[i].isConnected()) {
      if (camera[i].lastPhoto != null && showPhoto) {
        float w = camera[i].lastPhoto.width;
        float h = camera[i].lastPhoto.height;
        float ar = w/h;
        float div = 8.0; 
        if (w <= 1728) {
          div = 3.0;
        }
        if (w > 0 && h > 0) {
          if (NumCameras == 1) {
            float offset = (2*NX2000Camera.screenWidth-((2*NX2000Camera.screenHeight)*ar))/2;
            image(camera[i].lastPhoto, offset, 0, (2*NX2000Camera.screenHeight)*ar, 2*NX2000Camera.screenHeight);
          } else {
            image(camera[i].lastPhoto, 180+(i%2)*(w/div), 0+(i/2)*(h/div), w/div, h/div);
          }
        }
      } else
        if (camera[i].shutterCount == 0) {
          text("("+camera[i].name+") "+ip[i]+ " Connected.", 200, 110+i*50);
        } else {
          text("("+camera[i].name+") "+ip[i]+ " Shutter Count "+camera[i].shutterCount, 200, 110+i*50);
        }
    } else {
      text ("("+camera[i].name+") "+ip[i]+ " Not Connected.", 200, 110+i*50);
    }
  }
  gui.displayMenuBar();
  gui.modeTable.display();
  gui.fnTable.display();
  gui.displayMessage(message);


  // check for first connected camera
  for (int i=0; i<NumCameras; i++) {
    if (camera[i].isConnected()) {
      mainCamera = i;
      break;
    }
  }
} 
