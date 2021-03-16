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
tcpsvd -u root -vE 0.0.0.0 21 ftpd -w  /mnt/mmc & 

*/

// ftp is optional you can comment out the line starting with tcpsvd by preceding with # character
// make sure autoexec.sh has UNIX line ending x0a only, no x0dx0a (windows)
// Use email WiFi cofiguration on NX2000 to connect to a local network
// exit email to shoot photos and videos after connection to your local WiFi network.

//import processing.net.*; 
boolean testGui = false;
boolean DEBUG = false;

int telnetPort = 23; // telnet port
boolean doExit = false;
NX2000Camera[] camera;
PImage screen;  // camera LCD screen image

Gui gui;
int FONT_SIZE = 48;

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
  
  screen = loadImage("screenshot/nx2000/readytoshoot.png");
  //screen = loadImage("screenshot/nx2000/readyfocustoshootmin.png");
  
  // Create telnet clients to connect to Samsung NX2000 cameras.
  camera = new NX2000Camera[NumCameras];
  for (int i=0; i<NumCameras; i++) {
    Client client = null;
    if (!testGui) {
      client = new Client(this, ip[i], telnetPort);
    }
    camera[i] = new NX2000Camera(ip[i], client);
  }
  
  //println("width="+width + " height="+height);
  //println("screen.width="+screen.width + " screen.height="+screen.height);
} 

void draw() { 
  background(128);
  keyUpdate();
  image(screen, 0, 0, 2*screen.width, 2*screen.height);
  //text("Connecting to cameras", 20, 100);

  if (doExit) {
    exit();
  }
  
  for (int i=0; i<NumCameras; i++) {
    if (!camera[i].isConnected()) {
      if (camera[i].client != null) {
        if (camera[i].client.available() > 0) { 
          String inString = camera[i].client.readString(); 
          println(inString); 
          if (inString.endsWith(prompt)) {
            camera[i].setConnected(true);
            println("Camera "+i+" "+ip[i]+" connected");
            camera[i].getCameraFnShutterISO();
          }
        }
      }
    } else {
      camera[i].getFnShutterIsoResult();
    }
    
    textSize(FONT_SIZE);
    fill(255);
    textAlign(LEFT);
    if (camera[i].isConnected()) {
      text("("+(i+1)+") "+ip[i]+ " Connected ", 300, 100+i*50);
    } else {
      text ("("+(i+1)+") "+ip[i]+ " Not Connected", 300, 100+i*50);
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
