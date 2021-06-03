// utility helper functionsPreference IDs:

//boolean decoded = false;
int NO_TYPE = 0;
int LONG_TYPE = 1;
int BLOCK_TYPE = 2;
int resultType = NO_TYPE;

//void decodeResult(String s) {
//  if (resultType == LONG_TYPE) {
//    decodeLong(s);
//  } else if (resultType == BLOCK_TYPE) {
//    decodeBlock(s);
//  }
//}


//void decodeBlock(String s) {
//  String block = s.replaceAll("\\s", "");
//  int index = block.indexOf(']');
//  if (index >= 0) {
//    if (DEBUG) println(s.substring(index+1, index+9));
//    result = unhex(s.substring(index+1, index+9));
//    if (DEBUG) println("result="+result);
//    decoded = true;
//  }
//}

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

String convertCounter(int value) {
  if (value <10) {
    return ("000"+value);
  } else if (value <100) {
    return ("00"+value);
  } else if (value <1000)
    return ("0"+value);
  return str(value);
}

//..........................................................................
// common to android and java platforms

void folderSelected(File selection) {
  if (selection == null) {
    if (DEBUG) println("Window closed or canceled.");
    gui.displayMessage("Canceled", 30);
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    saveFolderPath = selection.getAbsolutePath();
    state = PRE_SAVE_STATE;
    gui.displayMessage("Save Photos", 40);
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Selection window was closed or the user hit cancel.");
    //showMsg("Selection window was closed or canceled.");
    configFilename = null;
    state = CONNECT_STATE;
  } else {
    println("User selected " + selection.getAbsolutePath());
    configFilename = selection.getAbsolutePath();
    state = CONNECT_STATE;
  }
}
