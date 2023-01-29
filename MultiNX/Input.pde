// Keyboard and Mouse input handling
// These codes (ASCII) are for Java applications
// Android codes (not implemented) differ with some keys

static final int KEYCODE_NOP = 0;
static final int KEYCODE_BACK = 4;
static final int KEYCODE_BACKSPACE = 8;
static final int KEYCODE_TAB = 9;
static final int KEYCODE_ENTER = 10;
static final int KEYCODE_ESC = 27;
static final int KEYCODE_SPACE = 32;
static final int KEYCODE_COMMA = 44;
static final int KEYCODE_MINUS = 45;
static final int KEYCODE_PERIOD = 46;
static final int KEYCODE_SLASH = 47;
static final int KEYCODE_QUESTION_MARK = 47;
static final int KEYCODE_0 = 48;
static final int KEYCODE_1 = 49;
static final int KEYCODE_2 = 50;
static final int KEYCODE_3 = 51;
static final int KEYCODE_4 = 52;
static final int KEYCODE_5 = 53;
static final int KEYCODE_6 = 54;
static final int KEYCODE_7 = 55;
static final int KEYCODE_8 = 56;
static final int KEYCODE_9 = 57;
static final int KEYCODE_SEMICOLON = 59;
static final int KEYCODE_PLUS = 61;
static final int KEYCODE_EQUAL = 61;
static final int KEYCODE_A = 65;
static final int KEYCODE_B = 66;
static final int KEYCODE_C = 67;
static final int KEYCODE_D = 68;
static final int KEYCODE_E = 69;
static final int KEYCODE_F = 70;
static final int KEYCODE_G = 71;
static final int KEYCODE_H = 72;
static final int KEYCODE_I = 73;
static final int KEYCODE_J = 74;
static final int KEYCODE_K = 75;
static final int KEYCODE_L = 76;
static final int KEYCODE_M = 77;
static final int KEYCODE_N = 78;
static final int KEYCODE_O = 79;
static final int KEYCODE_P = 80;
static final int KEYCODE_Q = 81;
static final int KEYCODE_R = 82;
static final int KEYCODE_S = 83;
static final int KEYCODE_T = 84;
static final int KEYCODE_U = 85;
static final int KEYCODE_V = 86;
static final int KEYCODE_W = 87;
static final int KEYCODE_X = 88;
static final int KEYCODE_Y = 89;
static final int KEYCODE_Z = 90;
static final int KEYCODE_LEFT_BRACKET = 91;
static final int KEYCODE_BACK_SLASH = 92;
static final int KEYCODE_RIGHT_BRACKET = 93;
static final int KEYCODE_DEL = 127;
//static final int KEYCODE_MEDIA_NEXT = 87;
//static final int KEYCODE_MEDIA_PLAY_PAUSE = 85;
//static final int KEYCODE_MEDIA_PREVIOUS = 88;
static final int KEYCODE_PAGE_DOWN = 93;
static final int KEYCODE_PAGE_UP = 92;
static final int KEYCODE_PLAY = 126;
static final int KEYCODE_MEDIA_STOP = 86;
static final int KEYCODE_MEDIA_REWIND = 89;
static final int KEYCODE_MEDIA_RECORD = 130;
static final int KEYCODE_MEDIA_PAUSE = 127;
static final int KEYCODE_VOLUME_UP = 0;  // TODO
static final int KEYCODE_VOLUME_DOWN = 0; // TODO
static final int KEYCODE_MOVE_HOME = 122;
static final int KEYCODE_MOVE_END  = 123;
static final int KEYCODE_TILDE_QUOTE = 192;
static final int KEYCODE_SINGLE_QUOTE = 222;

static final int KEYCODE_FN_ZONE = 500;
static final int KEYCODE_FN_ZONE_UPDATE = 501;
static final int KEYCODE_FN_ZONE_REFRESH = 502;
static final int KEYCODE_LOAD_SCREENSHOT = 503;
static final int KEYCODE_NEW_CONFIG = 504;
static final int KEYCODE_CURRENT_CONFIG = 505;
static final int KEYCODE_MODE_TABLE = 1000;
static final int KEYCODE_MODE_TABLE1 = 1001;
static final int KEYCODE_MODE_TABLE2 = 1002;
static final int KEYCODE_MODE_TABLE3 = 1003;
static final int KEYCODE_MODE_TABLE4 = 1004;
static final int KEYCODE_MODE_TABLE5 = 1005;
static final int KEYCODE_MODE_TABLE6 = 1006;
static final int KEYCODE_MODE_TABLE7 = 1007;
static final int KEYCODE_MODE_TABLE8 = 1008;
static final int KEYCODE_MODE_TABLE9 = 1009;
static final int KEYCODE_MODE_TABLE10 = 1010;
static final int KEYCODE_MODE_TABLE11 = 1011;
static final int KEYCODE_MODE_TABLE12 = 1012;
static final int KEYCODE_FN_UPDATE = 2000;
static final int KEYCODE_FN_UPDATE1 = 2001;
static final int KEYCODE_FN_UPDATE2 = 2002;
static final int KEYCODE_FN_UPDATE3 = 2003;
static final int KEYCODE_FN_UPDATE4 = 2004;
static final int KEYCODE_FN_UPDATE5 = 2005;
static final int KEYCODE_FN_UPDATE6 = 2006;
static final int KEYCODE_FN_UPDATE7 = 2007;
static final int KEYCODE_FN_UPDATE8 = 2008;
static final int KEYCODE_FN_UPDATE9 = 2009;
static final int KEYCODE_FN_UPDATE10 = 2010;
static final int KEYCODE_FN_UPDATE11 = 2011;
static final int KEYCODE_FN_UPDATE_SYNC = 2012;
static final int KEYCODE_FN_UPDATE_PREV = 2013;
static final int KEYCODE_FN_UPDATE_OK = 2014;
static final int KEYCODE_FN_UPDATE_NEXT = 2015;
static final int KEYCODE_NAV_UPDATE = 2500;
static final int KEYCODE_NAV_LEFT = 2501;
static final int KEYCODE_NAV_RIGHT = 2502;
static final int KEYCODE_NAV_UP = 2503;
static final int KEYCODE_NAV_DOWN = 2504;
static final int KEYCODE_NAV_OK = 2505;
static final int KEYCODE_SHOW = 3000;
static final int KEYCODE_SAVE = 3001;
static final int KEYCODE_REPEAT = 3002;

private static final int NOP = 0;
private static final int EXIT = 1;

// lastKey and lastKeyCode are handled in the draw loop
private int lastKey;
private int lastKeyCode;

boolean focus = false;
boolean ftp = false;

void mousePressed() {
  if (state == RUN_STATE && numCameras > 0) {
    lastKeyCode = gui.vertMenuBar.mousePressed(mouseX, mouseY);
    if (lastKeyCode == 0) {
      lastKeyCode = gui.horzMenuBar[gui.horzMenuBarIndex].mousePressed(mouseX, mouseY);
      if (lastKeyCode == 0 && modeSelection) {
        lastKeyCode = gui.modeTable.mousePressed(mouseX, mouseY);
      }
      if (lastKeyCode == 0 && fnSelection) {
        lastKeyCode = gui.fnTable.mousePressed(mouseX, mouseY);
      }
      if (lastKeyCode == 0 && navSelection) {
        lastKeyCode = gui.navTable.mousePressed(mouseX, mouseY);
      }
      if (lastKeyCode == 0) {
        // touch focus and selection
        if (mouseX >0 && mouseX<= width-320 && mouseY > 0 && mouseY < height-120) {
          for (int i=0; i<numCameras; i++) {
            if (camera[i].isConnected()) {
              if (DEBUG) println("mouse x="+(mouseX) + " y="+mouseY);
              if (DEBUG) println("screen width="+camera[i].screenWidth + " height="+camera[i].screenHeight);
              if (mouseX < 2*camera[i].screenWidth && mouseY<2*camera[i].screenHeight) {
                // multiple cameras have focus shift to the right
                //camera[i].touchFocus((2*NX2000Camera.screenHeight-mouseY)/2, int(mouseX+i*camera[i].focusOffset)/2);
                camera[i].touchFocus((camera[i].screenHeight-(mouseY)/2), int(mouseX+i*camera[i].focusOffset)/2);
                //requestScreenshot = true; // request screenshot

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
  if (DEBUG) println("key="+key + " keydecimal=" + int(key) + " keyCode="+keyCode);
  if (DEBUG) println("state "+ stateName[state]);
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);  // Android
  if (key==ESC) {
    key = 0;
    keyCode = KEYCODE_ESC;
  } else if (key == 65535 && keyCode == 0) { // special case all other keys
    // ignore key
    key = 0;
    keyCode = 0;
  }
  lastKey = key;
  lastKeyCode = keyCode;
}

// Process key from main loop not in keyPressed()
// returns false no key processed
// returns true when a key is processed
int keyUpdate() {
  int cmd = NOP;  // return code
  if (lastKey == 0 && lastKeyCode == 0) {
    return cmd;
  }

  switch(lastKeyCode) {
  case KEYCODE_BACK:
    if (DEBUG) println("KEYCODE_BACK state "+ stateName[state]);
    if (state == CONFIGURATION_DIALOG_STATE) {
      gui.configZone.setActive();
    }
    break;
  case KEYCODE_LOAD_SCREENSHOT:
    if (DEBUG) println("KEYCODE_LOAD_SCREENSHOT");
    if (screenshot != null) {
      //screenshot.dispose();  //reclaim space TODO
      screenshot=null;
    }
    if (camera[mainCamera].type == NX2000) {
      screenshot = requestImage("http://"+camera[mainCamera].ipAddr+"/screenshot.bmp");
    } else if (camera[mainCamera].type == NX500) {
      delay(2000);  // wait for screenshot capture to finish
      screenshot = requestImage("http://"+camera[mainCamera].ipAddr+"/OSD0001.jpg");
    } else if (camera[mainCamera].type == NX300 || camera[mainCamera].type == NX30) {
      delay(2000);  // wait for screenshot capture to finish
      screenshot = requestImage("http://"+camera[mainCamera].ipAddr+"/screenshot.bmp");
    }
    break;
  case KEYCODE_SPACE:
    if (allCameras) {
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].takePhoto();
        }
      }
    } else {
      camera[mainCamera].takePhoto();
    }
    break;
  case KEYCODE_0:
    mainCamera = 0;
    currentCamera = 0;
    allCameras = true;
    lastKeyCode = KEYCODE_FN_ZONE_UPDATE;
    break;
  case KEYCODE_1:
  case KEYCODE_2:
  case KEYCODE_3:
  case KEYCODE_4:
  case KEYCODE_5:
  case KEYCODE_6:
  case KEYCODE_7:
  case KEYCODE_8:
  case KEYCODE_9:
    int ic = lastKeyCode-KEYCODE_0-1;
    if (ic < numCameras) {
      mainCamera = ic;
    }
    allCameras = false;
    lastKeyCode = KEYCODE_FN_ZONE_UPDATE;
    break;
  case 111:
  case KEYCODE_ESC:
  case KEYCODE_Q:  // quit/ESC key
    if (DEBUG) println("QUIT");
    if (numCameras > 0) {
      //gui.horzMenuBar[gui.horzMenuBarIndex].backKey.setHighlight(true);  // TODO
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].sendMsg("exit\n");
        }
      }
    }
    delay(40); // delay draw();
    state = EXIT_STATE;
    break;
  case KEYCODE_F: // Focus
    // focus
    if (!focus) {
      if (DEBUG) println("FOCUS");
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusPush();
          camera[i].getCameraFnShutterEvISO();
        }
      }
      focus = true;
    } else {
      if (DEBUG) println("FOCUS RELEASE");
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusRelease();
        }
      }
      focus = false;
    }
    break;
  case KEYCODE_G: // Focus release
    // focus
    if (DEBUG) println("FOCUS RELEASE");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].focusRelease();
      }
    }
    break;
  case KEYCODE_S: // Shutter
    // shutter
    if (DEBUG) println("SHUTTER");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        if (focus) {
          camera[i].shutterPushRelease();
        } else {
          camera[i].takePhoto();
        }
      }
    }
    focus = false;
    break;
  case KEYCODE_T: // Take picture
    // take picture
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].takePhoto();
      }
    }
    break;
  case KEYCODE_BACKSPACE:  // back
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].touchBack();
      }
    }
    break;
    // video start and pause if already recording
  case KEYCODE_R:
    if (DEBUG) println("RECORD");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        if (i == 0 && camera[i].type == MRC) {
          camera[i].record();
        } else if (camera[i].type == MRC) {
          // do nothing for rest of MRC cameras
        } else {
          camera[i].record();  // not MRC
        }
      }
    }
    break;
  case KEYCODE_C: // Shift to alternate horizontal menu
    gui.altHorzMenuBar();
    gui.displayMenuBar();
    break;
  case KEYCODE_D: // debug informaton
    if (DEBUG) println("State="+stateName[state]);
    break;
  case KEYCODE_H:
    if (DEBUG) println("HOME");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].home();
      }
    }
    break;
  case KEYCODE_M:
    if (DEBUG) println("MENU");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].menu();
      }
    }
    break;
  case KEYCODE_O:  // available
    //} else if (lastKeyCode == KEYCODE_O ) {
    //  if (DEBUG) println("Application Fn Shutter values");
    //  for (int i=0; i<numCameras; i++) {
    //    if (camera[i].isConnected()) {
    //      camera[i].getCameraFnShutter();
    //    }
    //  }
    break;
  case KEYCODE_W:
    if (DEBUG) println("Camera MODE");
    modeSelection =! modeSelection;
    selectedCameraMode = cameraMode;
    break;
  case KEYCODE_A:
    displayAnaglyph = !displayAnaglyph;  // only applies to Multi Remote Camera displayAnaglyph ignored by other cameras for now
    break;
  case KEYCODE_I:
    if (DEBUG) println("Camera screenshot ");
    camera[mainCamera].screenshot();
    break;
  case KEYCODE_K:
    if (DEBUG) println("Camera OK");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraOk();
      }
    }
    break;
  case KEYCODE_B:
    if (DEBUG) println("All Camera Screenshot");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].screenshot(screenshotFilename);
      }
    }
    break;
  case KEYCODE_N:
    if (DEBUG) println("FN");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].function();
      }
    }
    break;
  case KEYCODE_P:
    if (DEBUG) println("PLAYBACK press on each camera");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].playback();
      }
    }
    break;
  case KEYCODE_E:
    if (DEBUG) println("EV");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].ev();
      }
    }
    break;
  case KEYCODE_J:
    if (DEBUG) println("JOG CW");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogcw();
      }
    }
    break;
  case KEYCODE_L:
    if (DEBUG) println("JOG CCW");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogccw();
      }
    }
    break;
  case KEYCODE_MODE_TABLE:
  case KEYCODE_MODE_TABLE1:
  case KEYCODE_MODE_TABLE2:
  case KEYCODE_MODE_TABLE3:
  case KEYCODE_MODE_TABLE4:
  case KEYCODE_MODE_TABLE5:
  case KEYCODE_MODE_TABLE6:
  case KEYCODE_MODE_TABLE7:
  case KEYCODE_MODE_TABLE8:
  case KEYCODE_MODE_TABLE9:
  case KEYCODE_MODE_TABLE10:
  case KEYCODE_MODE_TABLE11:
  case KEYCODE_MODE_TABLE12:
    if (lastKeyCode == KEYCODE_MODE_TABLE12) {
      modeSelection = false;
      cameraMode = selectedCameraMode;
      if (DEBUG) println("Set Mode "+ cameraModes[cameraMode]);
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].cameraMode(cameraMode);
        }
      }
    } else {
      selectedCameraMode = lastKeyCode-KEYCODE_MODE_TABLE;
      if (DEBUG) println("Set Mode "+ cameraModes[selectedCameraMode]);
    }
    break;
  case KEYCODE_FN_ZONE:
    if (DEBUG) println("Camera Fn parameters");
    fnSelection =! fnSelection;
    if (fnSelection) {
      camera[mainCamera].getCameraFnShutterEvISO();
    }
    break;
  case KEYCODE_FN_ZONE_REFRESH:
    if (DEBUG) println("Camera Fn refresh parameters");
    camera[mainCamera].getCameraFnShutterEvISO();
    break;
  case KEYCODE_FN_ZONE_UPDATE:
    String who = "Sync";
    if (!allCameras) {
      who = camera[mainCamera].suffix;
    }
    gui.fnTable.zoneKey.cap = who + ": " + camera[mainCamera].getSsName(camera[mainCamera].getShutterSpeed())
      +"    "+camera[mainCamera].getFnName(camera[mainCamera].getFn())+"    EV "+
      camera[mainCamera].getEvName()+"    ISO "+isoName[camera[mainCamera].getISO()];
    if (DEBUG) println("Camera state "+gui.fnTable.zoneKey.cap);
    break;
  case KEYCODE_FN_UPDATE:
  case KEYCODE_FN_UPDATE1:
  case KEYCODE_FN_UPDATE2:
  case KEYCODE_FN_UPDATE3:
  case KEYCODE_FN_UPDATE4 :
  case KEYCODE_FN_UPDATE5:
  case KEYCODE_FN_UPDATE6:
  case KEYCODE_FN_UPDATE7:
  case KEYCODE_FN_UPDATE8:
  case KEYCODE_FN_UPDATE9:
  case KEYCODE_FN_UPDATE10:
  case KEYCODE_FN_UPDATE11:
  case KEYCODE_FN_UPDATE_SYNC:
  case KEYCODE_FN_UPDATE_PREV :
  case KEYCODE_FN_UPDATE_OK:
  case KEYCODE_FN_UPDATE_NEXT:
    if (lastKeyCode == KEYCODE_FN_UPDATE_OK) {
      fnSelection = false;
      for (int i=0; i<numCameras; i++) {
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
        currentCamera = numCameras;
      }
      lastKeyCode = KEYCODE_0 + currentCamera;
      break;
    } else if (lastKeyCode == KEYCODE_FN_UPDATE_NEXT) {
      if (DEBUG) println("mainCamera="+mainCamera + " currentCamera="+currentCamera);
      currentCamera++;
      if (currentCamera > numCameras) {
        currentCamera = 1;
      }
      lastKeyCode = KEYCODE_0 + currentCamera;
      break;
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

      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
        }
      }
    }
    break;
  case KEYCODE_NAV_UPDATE:
    if (DEBUG) println("Navigation key parameters");
    navSelection =! navSelection;
    if (navSelection) {
      gui.navTable.display();
    }
    break;
  case KEYCODE_NAV_LEFT:
    if (DEBUG) println("cameraLeft()");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraLeft();
      }
    }
    break;
  case KEYCODE_NAV_RIGHT:
    if (DEBUG) println("cameraRight()");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraRight();
      }
    }
    break;
  case KEYCODE_NAV_UP:
    if (DEBUG) println("cameraUp()");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraUp();
      }
    }
    break;
  case KEYCODE_NAV_DOWN:
    if (DEBUG) println("cameraDown()");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraDown();
      }
    }
    break;
  case KEYCODE_NAV_OK:
    if (DEBUG) println("cameraOk()");
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraOk();
      }
    }
    break;
  case KEYCODE_SHOW:
    showPhoto = !showPhoto;
    for (int i=0; i<numCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].getPhotoFile();
      }
    }
    break;
  case KEYCODE_SAVE:
    selectPhotoFolder();
    break;
  case KEYCODE_NEW_CONFIG:
    state = CONFIGURATION_STATE;
    break;
  case KEYCODE_CURRENT_CONFIG:
    gui.configZone.remove();
    state = PRE_CONNECT_STATE;
    break;
  case KEYCODE_U:  // save screenshot file
    // save screenshot file
    screenshotRequest = true;
    break;
  case KEYCODE_V:
    camera[mainCamera].getCameraEv();
    break;
  case KEYCODE_Y:
    //camera[mainCamera].getShutterCount();
    if (cameraStatus) {
      cameraStatus = false;
    } else {
      cameraStatus = true;
    }
    if (cameraStatus) {
      for (int i=0; i<numCameras; i++) {
        if (camera[i].isConnected()) {
          //camera[i].cameraInfo();
          camera[i].getShutterCount();
        }
      }
    }
    break;
  case KEYCODE_Z:
    if (camera[mainCamera].type == NX2000) {
      camera[mainCamera].getPrefMem(NX2000Camera.APPID, NX2000Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX500) {
      camera[mainCamera].getPrefMem(NX500Camera.APPID, NX500Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX300) {
      camera[mainCamera].getPrefMem(NX300Camera.APPID, NX300Camera.APPPREF_ISO_PAS, "l");
    } else if (camera[mainCamera].type == NX30) {
      camera[mainCamera].getPrefMem(NX30Camera.APPID, NX300Camera.APPPREF_ISO_PAS, "l");
    }
    break;
    ///prefman get 1 8 v=96
  case KEYCODE_X:
    if (camera[mainCamera].type == NX2000) {
      camera[mainCamera].getPrefMemBlock(NX2000Camera.APPID, NX2000Camera.APPPREF_FNO_INDEX, 96);
    } else if (camera[mainCamera].type == NX500) {
      camera[mainCamera].getPrefMem(NX500Camera.APPID, NX500Camera.APPPREF_FNO_INDEX, "l");
    } else if (camera[mainCamera].type == NX300) {
      camera[mainCamera].getPrefMem(NX300Camera.APPID, NX300Camera.APPPREF_FNO_INDEX, "l");
    } else if (camera[mainCamera].type == NX30) {
      camera[mainCamera].getPrefMem(NX30Camera.APPID, NX300Camera.APPPREF_FNO_INDEX, "l");
    }
    break;
  default:
    break;
  } // switch

  lastKey = 0;
  lastKeyCode = 0;
  return cmd;
}
