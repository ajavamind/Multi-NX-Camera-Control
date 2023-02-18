// Java or Android platform build
// Code differences
//

private final static int JAVA_MODE = 0;
private final static int ANDROID_MODE = 1;
int buildMode = ANDROID_MODE;  // change manually for the build

// ***** Important Comment Out the unused platform code below 

// Android Platform Build Mode
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.app.Activity;
import select.files.*;

boolean grantedRead = false;
boolean grantedWrite = false;

SelectLibrary files;

void openFileSystem() {
  requestPermissions(); 
  files = new SelectLibrary(this);
}

void setTitle(String str) {
}

public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
  println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
  for (int i=0; i<permissions.length; i++) {
    println(permissions[i]);
  }
}  

void requestPermissions() {
  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
  }
  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
  }
}

void handleRead(boolean granted) {
  if (granted) {
    grantedRead = granted;
    println("Granted read permissions.");
  } else {
    println("Does not have permission to read external storage.");
  }
}

void handleWrite(boolean granted) {
  if (granted) {
    grantedWrite = granted;
    println("Granted write permissions.");
  } else {
    println("Does not have permission to write external storage.");
  }
}

void selectConfigurationFile() {
  //if (!grantedRead || !grantedWrite) {
  //  requestPermissions();
  //}
  files.selectInput("Select Configuration File:", "fileSelected");
}

void selectPhotoFolder() {
  if (saveFolderPath == null) {
    files.selectFolder("Select Photo Folder", "folderSelected");
    gui.displayMessage("Select Photo Folder", 30);
  } else {
    state = PRE_SAVE_STATE;
    if (DEBUG) println("saveFolderPath="+saveFolderPath);
    gui.displayMessage("Save Photo", 30);
  }
}

final String configKey = "ConfigFilename";
final String photoNumberKey = "photoNumber";
final String myAppPrefs = "MultiNX";

void saveConfig(String config) {
  if (DEBUG) println("saveConfig "+config);
  SharedPreferences sharedPreferences;
  SharedPreferences.Editor editor;
  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
  editor = sharedPreferences.edit();
  editor.putString(configKey, config );
  editor.commit();
}

String loadConfig() {
  SharedPreferences sharedPreferences;
  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
  String result = sharedPreferences.getString(configKey, null);
  if (DEBUG) println("loadConfig "+result);
  return result;
}

void savePhotoNumber(int number) {
  if (DEBUG) println("savePhotoNumber "+number);
  SharedPreferences sharedPreferences;
  SharedPreferences.Editor editor;
  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
  editor = sharedPreferences.edit();
  editor.putInt(photoNumberKey, number );
  editor.commit();
}

int loadPhotoNumber() {
  SharedPreferences sharedPreferences;
  sharedPreferences = getContext().getSharedPreferences(myAppPrefs, Context.MODE_PRIVATE);
  int result = sharedPreferences.getInt(photoNumberKey, 0);
  if (DEBUG) println("loadPhotoNumber "+result);
  return result;
}

private void destroy(PImage img) {
  if (img == null) return;
  Bitmap bitmap = (Bitmap) img.getNative();
  if (bitmap != null)
    bitmap.recycle();
  img.setNative(null);
  System.gc();
}

//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................


//// Java mode
//final static boolean ANDROID_MODE = false;
//void openFileSystem() {
//}

//void setTitle(String str) {
//  surface.setTitle(str);
//}

//void selectConfigurationFile() {
//  if (DEBUG) println("Select Configuration File state="+stateName[state]);
//  selectInput("Select Configuration File:", "fileSelected");
//}

//void selectPhotoFolder() {
//  if (saveFolderPath == null) {
//    selectFolder("Select Photo Folder", "folderSelected");
//  } else {
//    state = PRE_SAVE_STATE;
//    gui.displayMessage("Save Photos", 40);
//    if (DEBUG) println("Saving photo");
//  }
//}

//void saveConfig(String config) {
  
//}

//String loadConfig()
//{
//  return null;
//}

//void savePhotoNumber(int number) {
//  if (DEBUG) println("savePhotoNumber "+number);
//}

//int loadPhotoNumber() {
//  int result = 0;
//  if (DEBUG) println("loadPhotoNumber "+result);
//  return result;
//}

//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................
//..........................................................................


// Code common to Android and Java platforms
// do not comment out

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
    if (DEBUG) println("Selection window was closed or the user hit cancel.");
    //showMsg("Selection window was closed or canceled.");
    configFilename = null;
    state = CONFIGURATION_DIALOG_STATE;
  } else {
    if (DEBUG) println("User selected " + selection.getAbsolutePath());
    configFilename = selection.getAbsolutePath();
    gui.configZone.remove();
    state = CONNECT_STATE;
  }
}
