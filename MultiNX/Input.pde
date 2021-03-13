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
    if (lastKeyCode == 0) {
      // touch focus
      if (mouseX >0 && mouseX<= width-320 && mouseY > 0 && mouseY < height-120) {
        for (int i=0; i<NumCameras; i++) {
          if (camera[i].isConnected()) {
            println("mouse x="+(mouseX) + " y="+mouseY);
            if (mouseX < 2*screen.width && mouseY<2*screen.height) {
              camera[i].touchFocus((2*screen.height-mouseY)/2, mouseX/2);
              //println("key touch click x="+(2*screen.height-mouseY)/2 + " y="+mouseX/2);
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
  println("key="+key + " keyCode="+keyCode);        
  //if (DEBUG) Log.d(TAG, "key=" + key + " keyCode=" + keyCode);
  lastKey = key;
  lastKeyCode = keyCode;
}

// Process key from main loop not in keyPressed()
boolean keyUpdate() {
  if (lastKey == 0 && lastKeyCode == 0) {
    return false;
  }
  println("keyUpdate lastKey="+lastKey + " lastKeyCode="+lastKeyCode);

  //if ( lastKeyCode == KEYCODE_ESCAPE ) {
  //  getActivity().finish();
  //}


  if (lastKey==' ') {
  } else if (lastKey >= '1' && lastKey <= '9') {
    int ic = lastKey-'0';
    if (ic <= NumCameras) {
      if (camera[ic-1].isConnected()) {
        camera[ic-1].takePhoto();
      }
    }
  } else if (lastKeyCode == 111 || lastKeyCode == KEYCODE_ESCAPE || lastKey == 'q' || lastKey == 'Q') {  // quit/ESC key
    println("QUIT");
    gui.horzMenuBar.backKey.setHighlight(true);
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].sendMsg("exit\n");
      }
    }
    delay(1000); // delay draw();
    doExit = true;
  } else if (lastKeyCode == KEYCODE_F || lastKey == 'f' || lastKey == 'F') { // Focus
    // focus
    if (!focus) {
      println("FOCUS");
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].focusPush();
        }
      }
      focus = true;
    } else {
      println("FOCUS RELEASE");
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
    println("FOCUS RELEASE");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].focusRelease();
      }
    }
  } else if (lastKeyCode == KEYCODE_S || lastKey == 's' || lastKey == 'S') { // Shutter
    // shutter
    println("SHUTTER");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].shutterPushRelease();
      }
    }
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
    println("RECORD");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].record();
      }
    }
  } else if (lastKey == 'd' || lastKey == 'D') {
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].end();
      }
    }
  } else if (lastKeyCode == KEYCODE_H || lastKey == 'h' || lastKey == 'H') {
    println("HOME");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].home();
      }
    }
  } else if (lastKeyCode == KEYCODE_M || lastKey == 'm' || lastKey == 'M') {
    println("MENU");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].menu();
      }
    }
  } else if (lastKeyCode == KEYCODE_W || lastKey == 'w' || lastKey == 'W') {
    println("Camera MODE");
    modeSelection =! modeSelection;
    selectedCameraMode = cameraMode;
  } else if (lastKeyCode == KEYCODE_I || lastKey == 'i' || lastKey == 'I') {
    println("Camera INFO");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraInfo();
      }
    }
  } else if (lastKeyCode == KEYCODE_K || lastKey == 'k' || lastKey == 'K') {
    println("Camera OK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].cameraOk();
      }
    }
  } else if (lastKeyCode == KEYCODE_B || lastKey == 'b' || lastKey == 'B') {
    println("Camera Screenshot");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].screenshot(screenshotFilename);
      }
    }
  } else if (lastKeyCode == KEYCODE_N || lastKey == 'n' || lastKey == 'N') {
    println("FN");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].function();
      }
    }
  } else if (lastKeyCode == KEYCODE_P || lastKey == 'p' || lastKey == 'P') {
    println("PLAYBACK");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].playback();
      }
    }
  } else if (lastKeyCode == KEYCODE_E || lastKey == 'e' || lastKey == 'E') {
    println("EV");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].ev();
      }
    }
  } else if (lastKeyCode == KEYCODE_J || lastKey == 'j' || lastKey == 'J') {
    println("JOG CW");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogcw();
      }
    }
  } else if (lastKeyCode == KEYCODE_L || lastKey == 'l' || lastKey == 'L') {
    println("JOG CCW");
    for (int i=0; i<NumCameras; i++) {
      if (camera[i].isConnected()) {
        camera[i].jogccw();
      }
    }
  } else if (lastKeyCode >= 1000 && lastKeyCode <= 1012) {
    if (lastKeyCode == 1012) {
      modeSelection = false;
      cameraMode = selectedCameraMode;
      println("Set Mode "+ cameraModes[cameraMode]);
      for (int i=0; i<NumCameras; i++) {
        if (camera[i].isConnected()) {
          camera[i].cameraMode(cameraMode);
        }
      }
    } else {
      selectedCameraMode = lastKeyCode-1000;
      println("Set Mode "+ cameraModes[selectedCameraMode]);
    }
  } else if (lastKey == 'z' || lastKey == 'Z') {
    camera[0].getPrefMem(APPID, APPPREF_ISO_PAS, "l");
    ///prefman get 1 8 v=96
  } else if (lastKey == 'x' || lastKey == 'X') {
    camera[0].getPrefMemBlock(APPID, APPPREF_FNO_INDEX, 96);
    ///prefman get 1 8 v=96
  }
  lastKey = 0;
  lastKeyCode = 0;
  return true;
}
