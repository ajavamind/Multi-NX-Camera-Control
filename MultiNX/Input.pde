// Keyboard and mouse input handling

int KEYCODE_0 = 48;
int KEYCODE_1 = 49;
int KEYCODE_9 = 57;
int KEYCODE_DEL = 127;
int KEYCODE_A = 65;
int KEYCODE_B = 66;
int KEYCODE_C = 67;
int KEYCODE_D = 68;
int KEYCODE_E = 69;
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
int KEYCODE_P = 80;
int KEYCODE_Q = 81;
int KEYCODE_R = 82;
int KEYCODE_S = 83;
int KEYCODE_T = 84;
int KEYCODE_U = 85;
int KEYCODE_V = 86;
int KEYCODE_W = 87;
int KEYCODE_X = 88;
int KEYCODE_Y = 89;
int KEYCODE_Z = 90;
int KEYCODE_MEDIA_NEXT;
int KEYCODE_MEDIA_PLAY_PAUSE = 80;
int KEYCODE_MEDIA_PREVIOUS;
int KEYCODE_PAGE_DOWN;
int KEYCODE_PAGE_UP;
int KEYCODE_MEDIA_STOP;
int KEYCODE_ESCAPE = 27;
int KEYCODE_BACKSPACE = 8;
int KEYCODE_MOVE_HOME       = 122;
int KEYCODE_MOVE_END       = 123;
int KEYCODE_FN_ZONE = 500;
int KEYCODE_FN_ZONE_UPDATE = 501;
int KEYCODE_FN_ZONE_REFRESH = 502;
int KEYCODE_LOAD_SCREENSHOT = 503;
int KEYCODE_NEW_CONFIG = 504;
int KEYCODE_CURRENT_CONFIG = 505;
int KEYCODE_MODE_TABLE = 1000;
int KEYCODE_FN_UPDATE = 2000;
int KEYCODE_FN_UPDATE_SYNC = 2012;
int KEYCODE_FN_UPDATE_PREV = 2013;
int KEYCODE_FN_UPDATE_OK = 2014;
int KEYCODE_FN_UPDATE_NEXT = 2015;
int KEYCODE_SHOW = 3000;
int KEYCODE_SAVE = 3001;

int lastKey;
int lastKeyCode;

boolean focus = false;
boolean ftp = false;

void mousePressed() {
  if (state == RUN_STATE && NumCameras > 0) {
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
                if (DEBUG) println("screen width="+camera[i].screenWidth + " height="+camera[i].screenHeight);
                if (mouseX < 2*camera[i].screenWidth && mouseY<2*camera[i].screenHeight) {
                  // multiple cameras have focus shift to the right
                  //camera[i].touchFocus((2*NX2000Camera.screenHeight-mouseY)/2, int(mouseX+i*camera[i].focusOffset)/2);
                  camera[i].touchFocus((camera[i].screenHeight-(mouseY)/2), int(mouseX+i*camera[i].focusOffset)/2);
                  if (mouseX > 2*Gui.xoffset && mouseX < 2*camera[i].screenWidth && 
                    mouseY>0 && mouseY < 2*camera[i].screenHeight-120) {
                    gui.xFocusArea = mouseX;
                    gui.yFocusArea = mouseY;
                  }
                }
              }
            }
          }
        }
      }
    }
  } else {
    if (lastKeyCode == 0) {
      lastKeyCode = gui.configZone.mousePressed(mouseX, mouseY);
    }
  }
  lastKey = 0;
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
// returns false no key processed
// returns true when a key is processed
boolean keyUpdate() {
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }
  if (DEBUG) println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);

  if (lastKeyCode == KEYCODE_LOAD_SCREENSHOT) {
    if (DEBUG) println("KEYCODE_LOAD_SCREENSHOT");
    if (screenshot != null) {
      //screenshot.dispose();  //reclaim space TODO
      screenshot=null;
    }
    if (camera[mainCamera].type == NX2000) {
      screenshot = loadImage("http://"+camera[mainCamera].ipAddr+"/screenshot.bmp");
    } else if (camera[mainCamera].type == NX500) {
      delay(2000);  // wait for screenshot capture to finish
      screenshot = loadImage("http://"+camera[mainCamera].ipAddr+"/OSD0001.jpg");
    } else if (camera[mainCamera].type == NX300 || camera[mainCamera].type == NX30) {
      delay(2000);  // wait for screenshot capture to finish
      screenshot = loadImage("http://"+camera[mainCamera].ipAddr+"/screenshot.bmp");
    }
    //       if (showPhoto) {
    gui.fnZone.show(false, true);
    //    } else {
    //      gui.fnZone.show(true, true);
    //    }
  } else if (lastKey==' ') {
    if (allCameras) {
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].takePhoto();
        }
      }
    } else {
      camera[mainCamera].takePhoto();
    }
  } else if (lastKeyCode == KEYCODE_0 ) {  //|| lastKeyCode == KEYCODE_FN_UPDATE_SYNC) {
    mainCamera = 0;
    currentCamera = 0;
    allCameras = true;
    lastKeyCode = KEYCODE_FN_ZONE_UPDATE;
    return true;
  } else if (lastKeyCode >= KEYCODE_1 && lastKeyCode <= KEYCODE_9) {
    int ic = lastKeyCode-KEYCODE_0-1;
    if (ic < NumCameras) {
      mainCamera = ic;
    }
    allCameras = false;
    lastKeyCode = KEYCODE_FN_ZONE_UPDATE;
    return true;
  } else if (lastKeyCode == 111 || lastKeyCode == KEYCODE_ESCAPE || lastKey == 'q' || lastKey == 'Q') {  // quit/ESC key
    if (DEBUG) println("QUIT");
    if (NumCameras > 0) {
      gui.horzMenuBar.backKey.setHighlight(true);
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].sendMsg("exit\n");
        }
      }
    }
    delay(40); // delay draw();
    state = EXIT_STATE;
  } else if (lastKeyCode == KEYCODE_F) { // Focus
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
  } else if (lastKeyCode == KEYCODE_G) { // Focus release
    // focus
    if (DEBUG) println("FOCUS RELEASE");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].focusRelease();
      }
    }
  } else if (lastKeyCode == KEYCODE_S) { // Shutter
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
  } else if (lastKeyCode == KEYCODE_T) { // Take picture
    // take picture
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].takePhoto();
      }
    }
    // back
  } else if (lastKeyCode == KEYCODE_BACKSPACE) {
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].touchBack();
      }
    }
    // video start and pause if already recording
  } else if (lastKeyCode == KEYCODE_R ) {
    if (DEBUG) println("RECORD");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].record();
      }
    }
  } else if (lastKeyCode == KEYCODE_D) {
    if (DEBUG) println("State="+stateName[state]);
  } else if (lastKeyCode == KEYCODE_H) {
    if (DEBUG) println("HOME");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].home();
      }
    }
  } else if (lastKeyCode == KEYCODE_M) {
    if (DEBUG) println("MENU");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].menu();
      }
    }
    //} else if (lastKeyCode == KEYCODE_O ) {
    //  if (DEBUG) println("Application Fn Shutter values");
    //  for (int i=0; i<NumCameras; i++) {
    //    if (camera[i].isConnected()) {
    //      camera[i].getCameraFnShutter();
    //    }
    //  }
  } else if (lastKeyCode == KEYCODE_W) {
    if (DEBUG) println("Camera MODE");
    modeSelection =! modeSelection;
    selectedCameraMode = cameraMode;
  } else if (lastKeyCode == KEYCODE_I) {
    if (DEBUG) println("Camera INFO");
    camera[mainCamera].screenshot();
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        //camera[i].cameraInfo();
        camera[i].getShutterCount();
      }
    }
  } else if (lastKeyCode == KEYCODE_K) {
    if (DEBUG) println("Camera OK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraOk();
      }
    }
  } else if (lastKeyCode == KEYCODE_B) {
    if (DEBUG) println("Camera Screenshot");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].screenshot(screenshotFilename);
      }
    }
  } else if (lastKeyCode == KEYCODE_N) {
    if (DEBUG) println("FN");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].function();
      }
    }
  } else if (lastKeyCode == KEYCODE_P) {
    if (DEBUG) println("PLAYBACK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].playback();
      }
    }
  } else if (lastKeyCode == KEYCODE_E) {
    if (DEBUG) println("EV");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].ev();
      }
    }
  } else if (lastKeyCode == KEYCODE_J) {
    if (DEBUG) println("JOG CW");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogcw();
      }
    }
  } else if (lastKeyCode == KEYCODE_L) {
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
  } else if (lastKeyCode == KEYCODE_FN_ZONE_REFRESH) {
    if (DEBUG) println("Camera Fn refresh parameters");
    camera[mainCamera].getCameraFnShutterEvISO();
  } else if (lastKeyCode == KEYCODE_FN_ZONE_UPDATE) {
    String who = "Sync";
    if (!allCameras) {
      who = camera[mainCamera].name;
    }
    gui.fnZone.zoneKey.cap = who + ": " + camera[mainCamera].getSsName(camera[mainCamera].getShutterSpeed())
      +"    "+camera[mainCamera].getFnName(camera[mainCamera].getFn())+"    EV "+
      camera[mainCamera].getEvName()+"    ISO "+isoName[camera[mainCamera].getISO()];
    if (DEBUG) println("Camera state "+gui.fnZone.zoneKey.cap);
  } else if (lastKeyCode >= KEYCODE_FN_UPDATE && lastKeyCode <= KEYCODE_FN_UPDATE_NEXT) {
    if (lastKeyCode == KEYCODE_FN_UPDATE_OK) {
      fnSelection = false;
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusRelease();
          camera[i].updateFn();
          camera[i].updateSs();
          int currentIso = isoId;
          int nextIso = camera[i].getISO();
          int count = nextIso - currentIso;
          camera[i].setCameraFnShutterISO(camera[i].getFnId(), camera[i].getSsId(), isoId);
          if (count != 0) camera[i].updateIso();
        }
      }
    } else if (lastKeyCode == KEYCODE_FN_UPDATE_SYNC) {
      // handled by 0 key above
    } else if (lastKeyCode == KEYCODE_FN_UPDATE_PREV) {
      if (DEBUG) println("mainCamera="+mainCamera + " currentCamera="+currentCamera);
      currentCamera--;
      if (currentCamera < 1) {
        currentCamera = NumCameras;
      }
      lastKeyCode = KEYCODE_0 + currentCamera;
      return true;
    } else if (lastKeyCode == KEYCODE_FN_UPDATE_NEXT) {
      if (DEBUG) println("mainCamera="+mainCamera + " currentCamera="+currentCamera);
      currentCamera++;
      if (currentCamera > NumCameras) {
        currentCamera = 1;
      }
      lastKeyCode = KEYCODE_0 + currentCamera;
      return true;
    } else {
      int id = camera[mainCamera].getFnId();
      if (lastKeyCode == 2005) {// left Fn
        if (id > 0) {
          id--;
          gui.fnTable.setFnId(id);
        }
      } else if (lastKeyCode == 2007) {// right Fn
        if (id < camera[mainCamera].getFnLength()-1) {
          id++;
          gui.fnTable.setFnId(id);
        }
      }
      id = camera[mainCamera].getSsId();
      if (lastKeyCode == 2001) {// left Shutter
        if (id > 0) {
          id--;
          gui.fnTable.setShutterId(id);
        }
      } else if (lastKeyCode == 2003) {// right Shutter
        if (id < camera[mainCamera].getShutterNameLength()-1) {
          id++;
          gui.fnTable.setShutterId(id);
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
    showPhoto = !showPhoto;
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].getFilename();
      }
    }
    if (showPhoto) {
      gui.fnZone.show(false, false);
    } else {
      gui.fnZone.show(true, true);
    }
  } else if (lastKeyCode == KEYCODE_SAVE) {
    selectPhotoFolder();
  } else if (lastKeyCode == KEYCODE_NEW_CONFIG) {
    state = CONFIGURATION_STATE;
    gui.configZone.remove();
  } else if (lastKeyCode == KEYCODE_CURRENT_CONFIG) {
    gui.configZone.remove();
    state = PRE_CONNECT_STATE;
  } else if (lastKeyCode == KEYCODE_V) {
    camera[mainCamera].getCameraEv();
  } else if (lastKeyCode == KEYCODE_Y) {
    camera[mainCamera].getShutterCount();
  } else if (lastKeyCode == KEYCODE_Z) {
    if (camera[mainCamera].type == NX2000) {
      camera[mainCamera].getPrefMem(NX2000Camera.APPID, NX2000Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX500) {
      camera[mainCamera].getPrefMem(NX500Camera.APPID, NX500Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX300) {
      camera[mainCamera].getPrefMem(NX300Camera.APPID, NX300Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX30) {
      camera[mainCamera].getPrefMem(NX30Camera.APPID, NX300Camera.APPPREF_ISO_PAS, "l");
    } 
    ///prefman get 1 8 v=96
  } else if (lastKeyCode == KEYCODE_X) {
    if (camera[mainCamera].type == NX2000) {
      camera[mainCamera].getPrefMemBlock(NX2000Camera.APPID, NX2000Camera.APPPREF_FNO_INDEX, 96);
    } else if (camera[mainCamera].type == NX500) {
      camera[mainCamera].getPrefMem(NX500Camera.APPID, NX500Camera.APPPREF_FNO_INDEX, "l");
    } else if (camera[mainCamera].type == NX300) {
      camera[mainCamera].getPrefMem(NX300Camera.APPID, NX300Camera.APPPREF_FNO_INDEX, "l");
    } else if (camera[mainCamera].type == NX30) {
      camera[mainCamera].getPrefMem(NX30Camera.APPID, NX300Camera.APPPREF_FNO_INDEX, "l");
    }
  }
  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
