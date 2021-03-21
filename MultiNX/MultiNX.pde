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
boolean DEBUG = false;

int telnetPort = 23; // telnet port

// List of camera IP addresses to access
String[] ip = null;
String[] cameraName = {"LL", "LM", "RM", "RR"};
int NumCameras = 0;

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

Gui gui;
int FONT_SIZE = 48;
int MEDIUM_FONT_SIZE =  72;
int LARGE_FONT_SIZE = 96;
int GIANT_FONT_SIZE = 128;

int INTRODUCTION_STATE = 0;
int CONNECT_STATE = 1;
int RUN_STATE = 2;
int EXIT_STATE = 9;
int state = INTRODUCTION_STATE;

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

  ip = loadStrings("twincameras.txt");
  //ip = loadStrings("multicameras.txt");
  //ip = loadStrings("camera.txt");
  for (int i=0; i<ip.length; i++) {
    println(ip[i]);
  }
  println("number of cameras "+ip.length);
  NumCameras = ip.length;

  println("width="+width + " height="+height);
  //println("screen.width="+screen.width + " screen.height="+screen.height);
} 

void draw() { 
  int[] result = null;
  background(128);
  image(screen, 0, 0, 2*screen.width, 2*screen.height);
  if (state == INTRODUCTION_STATE) {
    state++;
    fill(255);
    textAlign(LEFT);
    textSize(FONT_SIZE);

    text("Multi NX", 300, 60);
    text("Control Multiple NX2000 Cameras", 300, 60+50);
    text("Version 1.0", 300, 60+100);
    text("Written by Andy Modla", 300, 60+150);
    for (int i=0; i<ip.length; i++) {
      text ("("+(i+1)+") "+ip[i], 300, 60+250+i*50);
    }
    textSize(LARGE_FONT_SIZE);
    text("Connecting to NX2000", 300, 560);
    return;
  } else if (state == CONNECT_STATE) {
    // Create telnet clients to connect to Samsung NX2000 cameras.
    camera = new NX2000Camera[NumCameras];
    for (int i=0; i<NumCameras; i++) {
      Client client = null;
      if (!testGui) {
        client = new Client(this, ip[i], telnetPort);
        println("client="+client);
        println("active="+client.active());
      }
      camera[i] = new NX2000Camera(ip[i], client);
      camera[i].setName(cameraName[i]);
    }
    state++;
  }

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
            println(inString); 
            if (inString.endsWith(prompt)) {
              camera[i].setConnected(true);
              println("Camera "+camera[i].name+" "+ip[i]+" connected");
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
    if (camera[i].isConnected()) {
      if (camera[i].shutterCount == 0) {
        text("("+camera[i].name+") "+ip[i]+ " Connected.", 300, 60+i*50);
      } else {
        text("("+camera[i].name+") "+ip[i]+ " Connected. Shutter Count "+camera[i].shutterCount, 300, 60+i*50);
      }
    } else {
      text ("("+camera[i].name+") "+ip[i]+ " Not Connected.", 300, 60+i*50);
    }
  }
  gui.displayMenuBar();
  gui.modeTable.display();
  gui.fnTable.display();
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
