/**
 Java or Android platform build
 
 */

//// Android  Mode
//import select.files.*;
//boolean grantedRead = false;
//boolean grantedWrite = false;

//SelectLibrary files;

//void openFileSystem() {
//  requestPermissions();
//  files = new SelectLibrary(this);
//}

//public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
//    println("onRequestPermissionsResult "+ requestCode + " " + grantResults + " ");
//    for (int i=0; i<permissions.length; i++) {
//    println(permissions[i]);
//    }
//  }  


//void requestPermissions() {
//  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.READ_EXTERNAL_STORAGE", "handleRead");
//  }
//  if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
//    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "handleWrite");
//  }
//}

//void handleRead(boolean granted) {
//  if (granted) {
//    grantedRead = granted;
//    println("Granted read permissions.");
//  } else {
//    println("Does not have permission to read external storage.");
//  }
//}

//void handleWrite(boolean granted) {
//  if (granted) {
//    grantedWrite = granted;
//    println("Granted write permissions.");
//  } else {
//    println("Does not have permission to write external storage.");
//  }
//}

//void inputDialog() {
//  //if (!grantedRead || !grantedWrite) {
//  //  requestPermissions();
//  //}
//  files.selectInput("Select XML Configuration File:", "fileSelected");
//}

//void selectPhotoFolder() {
//  if (saveFolderPath == null) {
//    files.selectFolder("Select Photo Folder", "folderSelected");
//  }
//}

//void fileSelected(File selection) {
//  if (selection == null) {
//    println("Selection window was closed or the user hit cancel.");
//    //showMsg("Selection window was closed or canceled.");
//  } else {
//    println("User selected " + selection.getAbsolutePath());
//  }
//}

//..........................................................................

// Java mode
void openFileSystem() {
}

void inputDialog() {
  selectInput("Select XML Configuration File:", "fileSelected");
}

void selectPhotoFolder() {
  if (saveFolderPath == null) {
    selectFolder("Select Photo Folder", "folderSelected");
  }
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
    gui.displayMessage("Save Photos", 30);
  }
}
