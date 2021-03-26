// utility helper functionsPreference IDs:
/**
 0 : system
 1 : application
 2 : line
 3 : system_rw
 */

int SYSID = 0;
int APPID = 1;
int LINEID = 2;
int SYSRWID = 3;

// application
int APPPREF_FNO_INDEX = 0x00000008;
int APPPREF_FNO_INDEX_OTHER_MODE = 0x0000000C;
int APPPREF_SHUTTER_SPEED_INDEX = 0x00000010; 
int APPPREF_SHUTTER_SPEED_INDEX_OTHER_MODE = 0x00000014;
int APPPREF_EVC = 0x00000018 ;
int APPPREF_ISO_PAS = 0x00000064;
int APPPREF_B_DISABLE_MOVIE_REC_LIMIT =  0x00000308; 
int APPPREF_B_ENABLE_NO_LENS_RELEASE = 0x0000030c;

// System rw
int SYSRWPREF_SHUTTER_COUNT = 0x00000008;  

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
