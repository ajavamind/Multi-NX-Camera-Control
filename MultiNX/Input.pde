// Keyboard and mouse input handling

int KEYCODE_0 = 48;
int KEYCODE_1 = 49;
int KEYCODE_DEL = 127;
int KEYCODE_B = 66;
int KEYCODE_E = 69;
int KEYCODE_S = 83;
int KEYCODE_T = 84;
int KEYCODE_F = 70;
int KEYCODE_G = 71;
int KEYCODE_H = 72;
int KEYCODE_I = 73;
int KEYCODE_J = 74;
int KEYCODE_K = 75;
int KEYCODE_L = 76;
int KEYCODE_M = 77;
int KEYCODE_N = 78;
int KEYCODE_O = 79;
int KEYCODE_MEDIA_NEXT;
int KEYCODE_MEDIA_PLAY_PAUSE = 80;
int KEYCODE_MEDIA_PREVIOUS;
int KEYCODE_PAGE_DOWN;
int KEYCODE_PAGE_UP;
int KEYCODE_MEDIA_STOP;
int KEYCODE_R = 82;
int KEYCODE_P = 80;
int KEYCODE_V = 86;
int KEYCODE_W = 87;
int KEYCODE_ESCAPE = 27;
int KEYCODE_MOVE_HOME       = 122;
int KEYCODE_MOVE_END       = 123;
int KEYCODE_FN_ZONE = 500;
int KEYCODE_FN_ZONE_UPDATE = 501;
int KEYCODE_MODE_TABLE = 1000;
int KEYCODE_SHOW = 3000;
int KEYCODE_FN_UPDATE = 2000;
int KEYCODE_SAVE = 3001;

int lastKey;
int lastKeyCode;

boolean focus = false;

void mousePressed() {

  lastKeyCode = gui.vertMenuBar.mousePressed(mouseX, mouseY);
  if (lastKeyCode == 0) {
    lastKeyCode = gui.horzMenuBar.mousePressed(mouseX, mouseY);
    if (lastKeyCode == 0 && modeSelection) {
      lastKeyCode = gui.modeTable.mousePressed(mouseX, mouseY);
    }
    if (lastKeyCode == 0 && fnSelection) {
      lastKeyCode = gui.fnTable.mousePressed(mouseX, mouseY);
    }
    if (lastKeyCode == 0) {
      lastKeyCode = gui.fnZone.mousePressed(mouseX, mouseY);
      // touch focus
      if (lastKeyCode == 0) {
        if (mouseX >0 && mouseX<= width-320 && mouseY > 0 && mouseY < height-120) {
          for (int i=0; i<NumCameras; i++) {
            if (camera[i].isConnected()) {
              if (DEBUG) println("mouse x="+(mouseX) + " y="+mouseY);
              if (mouseX < 2*screen.width && mouseY<2*screen.height) {
                camera[i].touchFocus((2*screen.height-mouseY)/2, mouseX/2);
                //println("key touch click x="+(2*screen.height-mouseY)/2 + " y="+mouseX/2);
              }
            }
          }
        }
      }
    }
  }
  lastKey = 0;
}


void mousePressedm() {
  // shoot multiple cameras photo
  focusMultiPhoto(camera);
}

void keyReleased() {
}

void keyPressed() {
  if (DEBUG) println("key="+key + " keyCode="+keyCode);        
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);
  lastKey = key;
  lastKeyCode = keyCode;
}

// Process key from main loop not in keyPressed()
boolean keyUpdate() {
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }
  if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);

  //if ( lastKeyCode == KEYCODE_ESCAPE ) {
  //  getActivity().finish();
  //}


  if (lastKey==' ') {
    //camera[mainCamera].save();
    camera[mainCamera].screenshot();
    screenshot = loadImage("http://"+camera[mainCamera].ipAddr+"screenshot.bmp");
  } else if (lastKey >= '1' && lastKey <= '9') {
    int ic = lastKey-'0';
    if (ic <= NumCameras) {
      if (camera[ic-1].isConnected()) {
        camera[ic-1].takePhoto();
      }
    }
  } else if (lastKeyCode == 111 || lastKeyCode == KEYCODE_ESCAPE || lastKey == 'q' || lastKey == 'Q') {  // quit/ESC key
    if (DEBUG) println("QUIT");
    gui.horzMenuBar.backKey.setHighlight(true);
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].sendMsg("exit\n");
      }
    }
    delay(1000); // delay draw();
    state = EXIT_STATE;
  } else if (lastKeyCode == KEYCODE_F || lastKey == 'f' || lastKey == 'F') { // Focus
    // focus
    if (!focus) {
      if (DEBUG) println("FOCUS");
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusPush();
          camera[i].getCameraFnShutterEvISO();
        }
      }
      focus = true;
    } else {
      if (DEBUG) println("FOCUS RELEASE");
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusRelease();
        }
      }
      focus = false;
    }
    gui.highlightFocusKey(focus);
  } else if (lastKeyCode == KEYCODE_G || lastKey == 'g' || lastKey == 'G') { // Focus release
    // focus
    if (DEBUG) println("FOCUS RELEASE");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].focusRelease();
      }
    }
  } else if (lastKeyCode == KEYCODE_S || lastKey == 's' || lastKey == 'S') { // Shutter
    // shutter
    if (DEBUG) println("SHUTTER");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        if (focus) {
          camera[i].shutterPushRelease();
        } else {
          camera[i].takePhoto();
        }
      }
    }
    focus = false;
    gui.highlightFocusKey(focus);
  } else if (lastKey == 't' || lastKey == 'T') { // Take picture
    // take picture
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].takePhoto();
      }
    }
    // back
  } else if (lastKey == 'b' || lastKey == 'B') {
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].touchBack();
      }
    }
    // video start and pause if already recording
  } else if (lastKeyCode == KEYCODE_R || lastKey == 'r' || lastKey == 'R') {
    if (DEBUG) println("RECORD");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].record();
      }
    }
    //} else if (lastKey == 'd' || lastKey == 'D') {
    //  for (int i=0; i<NumCameras; i++) {
    //    if (camera[i].isConnected()) {
    //      camera[i].end();
    //    }
    //  }
  } else if (lastKey == 'd' || lastKey == 'D') {
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        // debug
      }
    }
  } else if (lastKeyCode == KEYCODE_H || lastKey == 'h' || lastKey == 'H') {
    if (DEBUG) println("HOME");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].home();
      }
    }
  } else if (lastKeyCode == KEYCODE_M || lastKey == 'm' || lastKey == 'M') {
    if (DEBUG) println("MENU");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].menu();
      }
    }
  } else if (lastKeyCode == KEYCODE_O || lastKey == 'o' || lastKey == 'O') {
    if (DEBUG) println("Application Fn Shutter values");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].getCameraFnShutter();
      }
    }
  } else if (lastKeyCode == KEYCODE_W || lastKey == 'w' || lastKey == 'W') {
    if (DEBUG) println("Camera MODE");
    modeSelection =! modeSelection;
    selectedCameraMode = cameraMode;
  } else if (lastKeyCode == KEYCODE_I || lastKey == 'i' || lastKey == 'I') {
    if (DEBUG) println("Camera INFO");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        //camera[i].cameraInfo();
        camera[i].getShutterCount();
      }
    }
    camera[mainCamera].screenshot();
    screenshot = loadImage("http://"+camera[mainCamera].ipAddr+"/screenshot.bmp");
  } else if (lastKeyCode == KEYCODE_K || lastKey == 'k' || lastKey == 'K') {
    if (DEBUG) println("Camera OK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraOk();
      }
    }
  } else if (lastKeyCode == KEYCODE_B || lastKey == 'b' || lastKey == 'B') {
    if (DEBUG) println("Camera Screenshot");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].screenshot(screenshotFilename);
      }
    }
  } else if (lastKeyCode == KEYCODE_N || lastKey == 'n' || lastKey == 'N') {
    if (DEBUG) println("FN");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].function();
      }
    }
  } else if (lastKeyCode == KEYCODE_P || lastKey == 'p' || lastKey == 'P') {
    if (DEBUG) println("PLAYBACK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].playback();
      }
    }
  } else if (lastKeyCode == KEYCODE_E || lastKey == 'e' || lastKey == 'E') {
    if (DEBUG) println("EV");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].ev();
      }
    }
  } else if (lastKeyCode == KEYCODE_J || lastKey == 'j' || lastKey == 'J') {
    if (DEBUG) println("JOG CW");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogcw();
      }
    }
  } else if (lastKeyCode == KEYCODE_L || lastKey == 'l' || lastKey == 'L') {
    if (DEBUG) println("JOG CCW");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogccw();
      }
    }
  } else if (lastKeyCode >= KEYCODE_MODE_TABLE && lastKeyCode <= 1012) {
    if (lastKeyCode == 1012) {
      modeSelection = false;
      cameraMode = selectedCameraMode;
      if (DEBUG) println("Set Mode "+ cameraModes[cameraMode]);
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].cameraMode(cameraMode);
        }
      }
    } else {
      selectedCameraMode = lastKeyCode-KEYCODE_MODE_TABLE;
      if (DEBUG) println("Set Mode "+ cameraModes[selectedCameraMode]);
    }
  } else if (lastKeyCode == KEYCODE_FN_ZONE) {
    if (DEBUG) println("Camera Fn parameters");
    fnSelection =! fnSelection;
    if (fnSelection) {
      camera[mainCamera].getCameraFnShutterEvISO();
    }
  } else if (lastKeyCode == KEYCODE_FN_ZONE_UPDATE) {
    gui.fnZone.zoneKey.cap = " "+ getSsName(camera[mainCamera].getShutterSpeed())+"    "+getFnName(camera[mainCamera].getFn())+"    EV "+
      evName[camera[mainCamera].getEv()]+"    ISO "+isoName[camera[mainCamera].getISO()];
    if (DEBUG) println("Camera state "+gui.fnZone.zoneKey.cap);
  } else if (lastKeyCode >= KEYCODE_FN_UPDATE && lastKeyCode <= 2012) {
    if (lastKeyCode == 2012) {
      fnSelection = false;
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].updateFn();
          camera[i].setCameraFnShutterISO(fnId, shutterId, isoId);
        }
      }
    } else {
      if (lastKeyCode == 2005) {// left Fn
        if (fnId > 0) {
          fnId--;
          gui.fnTable.setFn(fnId);
        }
      } else if (lastKeyCode == 2007) {// right Fn
        if (fnId < fnName.length-1) {
          fnId++;
          gui.fnTable.setFn(fnId);
        }
      }

      if (lastKeyCode == 2001) {// left Shutter
        if (shutterId > 0) {
          shutterId--;
          gui.fnTable.setShutterId(shutterId);
        }
      } else if (lastKeyCode == 2003) {// right Shutter
        if (shutterId < shutterName.length-1) {
          shutterId++;
          gui.fnTable.setShutterId(shutterId);
        }
      } else if (lastKeyCode == 2009) {// left ISO
        if (isoId > 0) {
          isoId--;
          gui.fnTable.setIso(isoId);
        }
      } else if (lastKeyCode == 2011) {// right ISO
        if (isoId < isoName.length-1) {
          isoId++;
          gui.fnTable.setIso(isoId);
        }
      }

      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
        }
      }
    }
  } else if (lastKeyCode == KEYCODE_SHOW) {
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].getFilename();
      }
    }
  } else if (lastKeyCode == KEYCODE_SAVE) {
    selectPhotoFolder();
  } else if (lastKey == 'v' || lastKey == 'V') {
    camera[mainCamera].getCameraEv();
  } else if (lastKey == 'y' || lastKey == 'Y') {
    camera[mainCamera].getShutterCount();
  } else if (lastKey == 'z' || lastKey == 'Z') {
    camera[mainCamera].getPrefMem(APPID, APPPREF_ISO_PAS, "l");
    ///prefman get 1 8 v=96
  } else if (lastKey == 'x' || lastKey == 'X') {
    camera[mainCamera].getPrefMemBlock(APPID, APPPREF_FNO_INDEX, 96);
    ///prefman get 1 8 v=96
  }
  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
