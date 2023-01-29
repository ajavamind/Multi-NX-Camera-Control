// Graphical User Interface

int SMALL_FONT_SIZE = 24;
int FONT_SIZE = 48;
int MEDIUM_FONT_SIZE =  72;
int LARGE_FONT_SIZE = 96;
int GIANT_FONT_SIZE = 128;

volatile boolean modeSelection = false;
volatile boolean fnSelection = false;
volatile boolean navSelection = false;

// The GUI assumes the camera screen image is at (0,0)
class Gui {
  MultiNX base;
  static final int NUM_HORZ_MENU_BAR = 2;
  HorzMenuBar[] horzMenuBar = new HorzMenuBar[NUM_HORZ_MENU_BAR];
  int horzMenuBarIndex;
  VertMenuBar vertMenuBar;
  ModeTable modeTable;
  FnTable fnTable;
  ConfigZone configZone;
  NavTable navTable;

  int xFocusArea;
  int yFocusArea;
  int focusSize=100;

  // an option to change focus point for stereo or lenticular cameras
  // change xoffset to shift focus point by a fixed amount for each camera
  static final int xoffset = 0;
  // static final int xoffset = 80;

  // information zone touch coordinates
  // screen boundaries for click zone use
  float WIDTH;
  float HEIGHT;
  float iX;
  float iY;
  float mX;
  float mY;


  final static String INFO_SYMBOL = "\u24D8";
  final static String CIRCLE_PLUS = "\u2295";
  final static String CIRCLE_MINUS = "\u2296";
  final static String CIRCLE_LT = "\u29c0";
  final static String CIRCLE_GT = "\u29c1";
  //final static String LEFT_TRIANGLE = "\u22B2";  // Android
  //final static String RIGHT_TRIANGLE = "\u22B3"; // Android
  final static String LEFT_TRIANGLE = "<";
  final static String RIGHT_TRIANGLE = ">";
  final static String BIG_TRIANGLE_UP = "\u25B3";
  final static String PLAY = "\u25BA";
  final static String STOP = "\u25AA";
  final static String PLUS_MINUS = "||"; //"\u00B1";  //  alternate plus minus 2213
  final static String RESET = "\u21BB";  // loop
  final static String LEFT_ARROW_EXIT = "\u2190";  // Left arrow for exit
  final static String LEFT_ARROW = "\u02FF";
  final static String LEFT_ARROWHEAD = "\u02C2";
  final static String RIGHT_ARROWHEAD = "\u02C3";
  final static String CHECK_MARK = "\u2713";
  final static String LEFT_RIGHT_ARROW = "\u2194";

  color black;
  color gray;
  color graytransparent;
  color darktransparent;
  color white;
  color red;
  color aqua;
  color lightblue;
  color darkblue;
  color yellow;
  color silver;
  color brown;
  color bague;
  final boolean[] vfull = {true, true, true, true, true, true, true, true, true, true};
  final boolean[] hfull = {true, true, true, true, true, true, true, true};
  final boolean[] h2full = {true, false, false, false, true, true, true, true};
  final boolean[] MRCVfull = {true, true, true, true, true, true, true, true, false, false};
  final boolean[] MRCHfull = {true, true, true, true, false, false, true, true};
  final boolean[] modefull = {true, true, true, true, true, true, true, true, true, true, true, true, true};

  Gui() {
  }

  void create(MultiNX base) {
    this.base = base;
    WIDTH = base.width;
    HEIGHT = base.height;
    //xFocusArea= 2*(camera[mainCamera].screenWidth+xoffset)/2;
    //yFocusArea = 2*camera[mainCamera].screenHeight/2;
    xFocusArea= 2*(NX2000Camera.SCREEN_WIDTH+xoffset)/2;
    yFocusArea = 2*NX2000Camera.SCREEN_HEIGHT/2;
    iX = WIDTH / 8;
    iY = HEIGHT / 10;
    mX = WIDTH / 2;
    mY = HEIGHT / 2;

    black = color(0);   // black
    gray = color(128);
    graytransparent = color(128, 128, 128, 128);
    darktransparent = color(32, 32, 32, 128);
    white = color(255); // white
    red = color(255, 0, 0);
    aqua = color(128, 0, 128);
    lightblue = color(64, 64, 128);
    darkblue = color(32, 32, 64);
    yellow = color(255, 204, 0);
    silver = color(193, 194, 186);
    brown = color(69, 66, 61);
    bague = color(183, 180, 139);
  }

  void createGui(int cameraType) {
    horzMenuBarIndex = 0;
    horzMenuBar[0] = new HorzMenuBar1(cameraType);
    //horzMenuBar[0].create(cameraType);
    if (cameraType == MRC || cameraType == RPI) {
      horzMenuBar[0].setVisible(MRCHfull);
      horzMenuBar[0].setActive(MRCHfull);
    } else {
      horzMenuBar[0].setVisible(hfull);
      horzMenuBar[0].setActive(hfull);
    }

    horzMenuBar[1] = new HorzMenuBar2(cameraType);
    //horzMenuBar[1].create(cameraType);
    if (cameraType == MRC || cameraType == RPI) {
      horzMenuBar[1].setVisible(MRCHfull);
      horzMenuBar[1].setActive(MRCHfull);
    } else {
      horzMenuBar[1].setVisible(h2full);
      horzMenuBar[1].setActive(h2full);
    }

    vertMenuBar = new VertMenuBar();
    vertMenuBar.create(cameraType);
    if (cameraType == MRC || cameraType == RPI) {
      vertMenuBar.setVisible(MRCVfull);
      vertMenuBar.setActive(MRCVfull);
    } else {
      vertMenuBar.setVisible(vfull);
      vertMenuBar.setActive(vfull);
    }

    modeTable = new ModeTable();
    modeTable.create(cameraType);

    fnTable = new FnTable();
    fnTable.create(cameraType);

    navTable = new NavTable();
    navTable.create(cameraType);
  }

  void createConfigZone() {
    configZone = new ConfigZone();
    configZone.create();
  }

  void displayConfigZone() {
    configZone.display();
  }

  void removeConfigZone() {
    if (DEBUG) println("removeConfigZone()");
    configZone.remove();
  }

  void displayMenuBar() {
    horzMenuBar[horzMenuBarIndex].display();
    vertMenuBar.display();
  }

  void highlightFocusKey(boolean hold) {
    vertMenuBar.focusKey.setHighlight(hold);
  }

  void altHorzMenuBar() {
    horzMenuBarIndex++;
    if (horzMenuBarIndex >= NUM_HORZ_MENU_BAR) {
      horzMenuBarIndex = 0;
    }
  }

  //    void testGrid() {
  //        // debug
  //        base.stroke(gray);
  //        base.strokeWeight(4);
  //        base.rectMode(base.CORNER);
  //        int numKeys = 7;
  //        float x = 0;
  //        float y = HEIGHT - iY;
  //        float w = WIDTH / (float) numKeys;
  //        float h = iY;
  //        float inset = w / (float) numKeys;
  //        base.fill(graytransparent);
  //        for (int i = 0; i < 7; i++) {
  //            //base.rect((float)i*w +inset, y, w-2*inset, h, inset);
  //        }

  //        base.line(0, base.height - iY / 2, base.width, base.height - iY / 2);
  //        base.line(0, base.height - iY, base.width, base.height - iY);
  //        //Log.d(TAG, "menu width="+width + " height="+height);
  //        base.line(base.width / 2, 0, base.width / 2, base.height);
  //        base.line(0, base.height / 2, base.width, base.height / 2);
  //    }

  void displayGrid(int numDivisions) {
    stroke(gray);
    strokeWeight(4);
    rectMode(CORNER);
    float w = 2*(camera[mainCamera].screenWidth-xoffset);
    float h = 2*camera[mainCamera].screenHeight;
    fill(graytransparent);
    for (int i = 1; i < numDivisions+1; i++) {
      line(2*xoffset, i*(h/numDivisions), 2*xoffset+w, i*(h/numDivisions));
    }
    for (int i = 1; i < numDivisions+1; i++) {
      line(2*xoffset+i*(w/numDivisions), 0, 2*xoffset+i*(w/numDivisions), h);
    }
  }

  void displayFocusArea() {
    if (showPhoto || camera[mainCamera].type == MRC || camera[mainCamera].type == RPI) {
      // TODO not implemented for MRC nor IMX230
      return;
    }
    stroke(white);
    strokeWeight(4);
    rectMode(CORNER);
    //float w = 2*(camera[mainCamera].screenWidth-xoffset);
    //float h = 2*camera[mainCamera].screenHeight;
    noFill();
    rect(xFocusArea-focusSize/2, yFocusArea-focusSize/2, focusSize, focusSize);
  }

  void displayMessage(String msg, int position, int counter) {
    frameCounter = counter;
    messagePosition = position;
    message = msg;
  }

  void displayMessage(String msg, int counter) {
    frameCounter = counter;
    message = msg;
  }

  void displayMessage(String message) {
    if (message == null) {
      return;
    }
    float w = textWidth(message);
    float h =  textAscent()+textDescent();
    float d = textWidth("W");
    fill(192);
    //rectMode(CENTER);
    //rect(width/2 - w/2-2*d, height / 2-h, w+4*d, 2*h, h);
    //rectMode(CORNER);
    fill(192, 0, 0);
    //textSize(MEDIUM_FONT_SIZE);
    textSize(FONT_SIZE);
    textAlign(CENTER, CENTER);
    //text(message, (width / 2), base.height / 2);
    int where =  2*(NX2000Camera.SCREEN_WIDTH+xoffset)/2;
    text(message, where, base.height / 2);
    textAlign(LEFT);
  }


  /**
   * ModeTable appears in center of the screen.
   * The mode table select one mutually exclusive mode for the camera.
   */
  class ModeTable {
    // initialize Mode Keys
    MenuKey lensKey;
    MenuKey magicKey;
    MenuKey photoKey;
    MenuKey videoKey;
    MenuKey wifiKey;
    MenuKey sceneKey;
    MenuKey movieKey;
    MenuKey smartKey;
    MenuKey pKey;
    MenuKey aKey;
    MenuKey sKey;
    MenuKey mKey;
    MenuKey emptyKey;
    MenuKey empty2Key;
    MenuKey okKey;
    MenuKey[] table;
    int numKeys = 13;
    float insetY;
    float insetX;

    void create(int cameraType) {
      int keyColor = black;
      //PImage imgab = base.loadImage("icons/ab.png");
      //PImage imgana = base.loadImage("icons/ana.png");
      //PImage imgcan = base.loadImage("icons/can.png");
      //PImage imgcol = base.loadImage("icons/col.png");
      //PImage imgdub = base.loadImage("icons/dub.png");
      //PImage imghhab = base.loadImage("icons/hhab.png");
      //PImage imghwsbs = base.loadImage("icons/hwsbs.png");
      //PImage imgl2D = base.loadImage("icons/l2D.png");
      //PImage imgr2D = base.loadImage("icons/r2D.png");
      //PImage imgrow = base.loadImage("icons/row.png");
      //PImage imgsbs = base.loadImage("icons/sbs.png");
      //PImage imgxsbs = base.loadImage("icons/xsbs.png");
      //"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m"

      lensKey = new MenuKey(KEYCODE_MODE_TABLE, cameraKeyModes[0], FONT_SIZE, keyColor);
      magicKey = new MenuKey(KEYCODE_MODE_TABLE+1, cameraKeyModes[1], FONT_SIZE, keyColor);
      photoKey = new MenuKey(KEYCODE_MODE_TABLE, cameraKeyMRCModes[0], FONT_SIZE, keyColor);
      videoKey = new MenuKey(KEYCODE_MODE_TABLE+1, cameraKeyMRCModes[1], FONT_SIZE, keyColor);

      wifiKey = new MenuKey(1002, cameraKeyModes[2], FONT_SIZE, keyColor);
      sceneKey = new MenuKey(1003, cameraKeyModes[3], FONT_SIZE, keyColor);
      movieKey = new MenuKey(1004, cameraKeyModes[4], FONT_SIZE, keyColor);
      smartKey = new MenuKey(1005, cameraKeyModes[5], FONT_SIZE, keyColor);
      pKey = new MenuKey(1006, cameraKeyModes[6], FONT_SIZE, keyColor);
      aKey = new MenuKey(1007, cameraKeyModes[7], FONT_SIZE, keyColor);
      sKey = new MenuKey(1008, cameraKeyModes[8], FONT_SIZE, keyColor);
      mKey = new MenuKey(1009, cameraKeyModes[9], FONT_SIZE, keyColor);
      emptyKey = new MenuKey(1010, cameraKeyModes[10], FONT_SIZE, keyColor);
      empty2Key = new MenuKey(1011, cameraKeyModes[11], FONT_SIZE, keyColor);
      okKey = new MenuKey(1012, CHECK_MARK, FONT_SIZE, keyColor);

      table = new MenuKey[numKeys];
      table[0] = lensKey;
      table[1] = magicKey;
      table[2] = wifiKey;
      table[3] = sceneKey;
      table[4] = movieKey;
      table[5] = smartKey;
      table[6] = emptyKey;
      table[7] = empty2Key;
      table[8] = pKey;
      table[9] = aKey;
      table[10] = sKey;
      table[11] = mKey;
      table[12] = okKey;
      //int[] valueTable = {0, 1, 2, 3,
      //  4, 5, 6, 7,
      //  8, 9, 10, 11,
      //  12
      //};
      int[] valueTable = {0, 1, 2, 3,
        4, 5, 10, 11, 6, 7, 8, 9, 12
      };
      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX - iX/2; // table start from left
      float y = 3*iY;  // table start from middle
      int ROWS = 3;
      int COLS = 4;
      int ok = 12;
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, 0);
          table[COLS*i+j].setVisible(true);
          if (COLS*i+j == 6 || COLS*i+j == 7) {
            table[COLS*i+j].setVisible(false);
          }
          table[COLS*i+j].setValue(valueTable[COLS*i+j]);
        }
      }
      table[ok].setPosition(mX-iX, y + ((float)ROWS) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
      table[ok].setVisible(true);
      table[ok].setValue(1012);
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < table.length; i++) {
        table[i].setVisible(visible[i]);
      }
    }

    void saveSelection(int selected) {
    }

    void display() {
      if (modeSelection) {
        int mode = selectedCameraMode;
        for (int i = 0; i < table.length; i++) {
          if (table[i].getValue() == mode) {
            table[i].setHighlight(true);
          } else {
            table[i].setHighlight(false);
          }
          table[i].draw();
        }
      }
    }

    int mousePressed(int x, int y) {
      int keyCode = -1;
      // table touch control area at bottom of screen or sides
      for (int i = 0; i < numKeys; i++) {
        if (table[i].visible) {
          if ((x <= (table[i].x + table[i].w)) && (x >= (table[i].x)) &&
            (y >= table[i].y) && (y <= (table[i].y +table[i].h))) {
            keyCode = table[i].keyCode;
            break;
          }
        }
      }
      return keyCode;
    }
  }

  /**
   * ModeTable appears in center of the screen.
   */
  class ModeTableMRC {
    // initialize Mode Keys
    MenuKey photoKey;
    MenuKey videoKey;
    MenuKey wifiKey;
    MenuKey sceneKey;
    MenuKey movieKey;
    MenuKey smartKey;
    MenuKey pKey;
    MenuKey aKey;
    MenuKey sKey;
    MenuKey mKey;
    MenuKey emptyKey;
    MenuKey empty2Key;
    MenuKey okKey;
    MenuKey[] table;
    int numKeys = 13;
    float insetY;
    float insetX;

    void create(int cameraType) {
      int keyColor = black;
      //PImage imgab = base.loadImage("icons/ab.png");
      //PImage imgana = base.loadImage("icons/ana.png");
      //PImage imgcan = base.loadImage("icons/can.png");
      //PImage imgcol = base.loadImage("icons/col.png");
      //PImage imgdub = base.loadImage("icons/dub.png");
      //PImage imghhab = base.loadImage("icons/hhab.png");
      //PImage imghwsbs = base.loadImage("icons/hwsbs.png");
      //PImage imgl2D = base.loadImage("icons/l2D.png");
      //PImage imgr2D = base.loadImage("icons/r2D.png");
      //PImage imgrow = base.loadImage("icons/row.png");
      //PImage imgsbs = base.loadImage("icons/sbs.png");
      //PImage imgxsbs = base.loadImage("icons/xsbs.png");
      //"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m"

      photoKey = new MenuKey(KEYCODE_MODE_TABLE, cameraKeyMRCModes[0], FONT_SIZE, keyColor);
      videoKey = new MenuKey(KEYCODE_MODE_TABLE+1, cameraKeyMRCModes[1], FONT_SIZE, keyColor);
      wifiKey = new MenuKey(1002, cameraKeyModes[2], FONT_SIZE, keyColor);
      sceneKey = new MenuKey(1003, cameraKeyModes[3], FONT_SIZE, keyColor);
      movieKey = new MenuKey(1004, cameraKeyModes[4], FONT_SIZE, keyColor);
      smartKey = new MenuKey(1005, cameraKeyModes[5], FONT_SIZE, keyColor);
      pKey = new MenuKey(1006, cameraKeyModes[6], FONT_SIZE, keyColor);
      aKey = new MenuKey(1007, cameraKeyModes[7], FONT_SIZE, keyColor);
      sKey = new MenuKey(1008, cameraKeyModes[8], FONT_SIZE, keyColor);
      mKey = new MenuKey(1009, cameraKeyModes[9], FONT_SIZE, keyColor);
      emptyKey = new MenuKey(1010, cameraKeyModes[10], FONT_SIZE, keyColor);
      empty2Key = new MenuKey(1011, cameraKeyModes[11], FONT_SIZE, keyColor);
      okKey = new MenuKey(1012, CHECK_MARK, FONT_SIZE, keyColor);

      table = new MenuKey[numKeys];
      table[0] = photoKey;
      table[1] = videoKey;
      table[2] = wifiKey;
      table[3] = sceneKey;
      table[4] = movieKey;
      table[5] = smartKey;
      table[6] = emptyKey;
      table[7] = empty2Key;
      table[8] = pKey;
      table[9] = aKey;
      table[10] = sKey;
      table[11] = mKey;
      table[12] = okKey;
      //int[] valueTable = {0, 1, 2, 3,
      //  4, 5, 6, 7,
      //  8, 9, 10, 11,
      //  12
      //};
      int[] valueTable = {0, 1, 2, 3,
        4, 5, 10, 11, 6, 7, 8, 9, 12
      };
      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX - iX/2; // table start from left
      float y = 3*iY;  // table start from middle
      int ROWS = 3;
      int COLS = 4;
      int ok = 12;
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, 0);
          table[COLS*i+j].setVisible(true);
          if (COLS*i+j == 6 || COLS*i+j == 7) {
            table[COLS*i+j].setVisible(false);
          }
          table[COLS*i+j].setValue(valueTable[COLS*i+j]);
        }
      }
      table[ok].setPosition(mX-iX, y + ((float)ROWS) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
      table[ok].setVisible(true);
      table[ok].setValue(1012);
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < table.length; i++) {
        table[i].setVisible(visible[i]);
      }
    }

    void saveSelection(int selected) {
    }

    void display() {
      if (modeSelection) {
        int mode = selectedCameraMode;
        for (int i = 0; i < table.length; i++) {
          if (table[i].getValue() == mode) {
            table[i].setHighlight(true);
          } else {
            table[i].setHighlight(false);
          }
          table[i].draw();
        }
      }
    }

    int mousePressed(int x, int y) {
      int keyCode = -1;
      // table touch control area at bottom of screen or sides
      for (int i = 0; i < numKeys; i++) {
        if (table[i].visible) {
          if ((x <= (table[i].x + table[i].w)) && (x >= (table[i].x)) &&
            (y >= table[i].y) && (y <= (table[i].y +table[i].h))) {
            keyCode = table[i].keyCode;
            break;
          }
        }
      }
      return keyCode;
    }
  }

  /**
   * FnTable appears in center of the screen.
   * Launched by Sync soft key
   */
  class FnTable {
    // initialize function Keys
    MenuKey shutterNameKey;
    MenuKey shutterLeftKey;
    MenuKey shutterKey;
    MenuKey shutterRightKey;
    MenuKey fnNameKey;
    MenuKey fnLeftKey;
    MenuKey fnKey;
    MenuKey fnRightKey;
    MenuKey isoNameKey;
    MenuKey isoLeftKey;
    MenuKey isoKey;
    MenuKey isoRightKey;
    MenuKey unusedKey;
    MenuKey okKey;
    MenuKey syncCamerasKey;
    MenuKey nextCameraKey;
    MenuKey prevCameraKey;
    MenuKey zoneKey;  // status information, not part of table
    MenuKey[] table;
    int numKeys = 17;
    float insetY;
    float insetX;
    int zone = numKeys -1; // index

    void create(int cameraType) {
      int keyColor = black;
      int arrowKeyColor = aqua;
      shutterNameKey = new MenuKey(KEYCODE_FN_UPDATE, "SHUTTER", FONT_SIZE, white);
      shutterNameKey.setActive(false);
      shutterNameKey.setCorner(false);
      shutterLeftKey = new MenuKey(2001, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      shutterKey = new MenuKey(2002, camera[mainCamera].getShutterName(camera[mainCamera].getSsId()), FONT_SIZE, keyColor);
      shutterRightKey = new MenuKey(2003, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      fnNameKey = new MenuKey(2004, "FN", FONT_SIZE, white);
      fnNameKey.setActive(false);
      fnNameKey.setCorner(false);
      fnLeftKey = new MenuKey(2005, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      fnKey = new MenuKey(2006, camera[mainCamera].getFn(camera[mainCamera].getFnId()), FONT_SIZE, keyColor);
      fnRightKey = new MenuKey(2007, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      isoNameKey = new MenuKey(2008, "ISO", FONT_SIZE, white);
      isoNameKey.setActive(false);
      isoNameKey.setCorner(false);
      isoLeftKey = new MenuKey(2009, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      isoKey = new MenuKey(2010, isoName[isoId], FONT_SIZE, keyColor);
      isoRightKey = new MenuKey(2011, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);

      //syncCamerasKey = new MenuKey(KEYCODE_FN_UPDATE_SYNC, "Sync" , FONT_SIZE, keyColor);
      //prevCameraKey = new MenuKey(KEYCODE_FN_UPDATE_PREV, "Prev" , FONT_SIZE, keyColor);
      //okKey = new MenuKey(KEYCODE_FN_UPDATE_OK, CHECK_MARK, FONT_SIZE, keyColor);
      //nextCameraKey = new MenuKey(KEYCODE_FN_UPDATE_NEXT, "Next" , FONT_SIZE, keyColor);
      syncCamerasKey = new MenuKey(KEYCODE_0, "Sync", FONT_SIZE, keyColor);
      prevCameraKey = new MenuKey(KEYCODE_FN_UPDATE_PREV, "Prev", FONT_SIZE, keyColor);
      okKey = new MenuKey(KEYCODE_FN_UPDATE_OK, CHECK_MARK, FONT_SIZE, keyColor);
      nextCameraKey = new MenuKey(KEYCODE_FN_UPDATE_NEXT, "Next", FONT_SIZE, keyColor);
      zoneKey = new MenuKey(KEYCODE_NOP, "Camera Settings", FONT_SIZE, keyColor);

      table = new MenuKey[numKeys];
      table[0] = shutterNameKey;
      table[1] = shutterLeftKey;
      table[2] = shutterKey;
      table[3] = shutterRightKey;
      table[4] = fnNameKey;
      table[5] = fnLeftKey;
      table[6] = fnKey;
      table[7] = fnRightKey;
      table[8] = isoNameKey;
      table[9] = isoLeftKey;
      table[10] = isoKey;
      table[11] = isoRightKey;
      table[12] = syncCamerasKey;
      table[13] = prevCameraKey;
      table[14] = okKey;
      table[15] = nextCameraKey;
      table[16] = zoneKey;

      int[] valueTable = {0, 1, 2, 3,
        4, 5, 6, 7,
        8, 9, 10, 11,
        12, 13, 14, 15
      };
      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX -iX/2; // table start from left
      float y = 3*iY;  // table start from middle
      int ROWS = 4;
      int COLS = 4;
      float inset = WIDTH / 64f;
      float[] insetTab = { 0, inset, 0, inset, 0, inset, 0, inset, 0, inset, 0, inset};
      for (int i = 0; i < ROWS-1; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, insetTab[ROWS*i+ j]);
          table[COLS*i+j].setVisible(true);
          table[COLS*i+j].setValue(valueTable[COLS*i+j]);
        }
      }
      for (int i = ROWS-1; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
          table[COLS*i+j].setVisible(true);
          table[COLS*i+j].setValue(valueTable[COLS*i+j]);
        }
      }
      table[zone].setPosition(x, 2*iY-insetY, ROWS*iX+6*insetX, iY, WIDTH / 64f);
      table[zone].setVisible(true);
    }

    void setIso(int value) {
      isoId = value;
      isoKey.setCap(isoName[isoId]);
    }

    void setShutter(int value) {
      int id = camera[mainCamera].getSsId(value);
      shutterKey.setCap(camera[mainCamera].getShutterName(id));
      for (int i=0; i<numCameras; i++) {
        camera[i].shutterId = id;
      }
    }

    void setShutterId(int id) {
      for (int i=0; i<numCameras; i++) {
        camera[i].shutterId = id;
      }
      shutterKey.setCap(camera[mainCamera].getShutterName(id));
    }

    void setFn(int value) {
      int id = camera[mainCamera].getFnId(value);
      fnKey.setCap(camera[mainCamera].getFn(id));
      for (int i=0; i<numCameras; i++) {
        camera[i].fnId = id;
      }
    }

    void setFnId(int id) {
      for (int i=0; i<numCameras; i++) {
        camera[i].fnId = id;
      }
      fnKey.setCap(camera[mainCamera].getFn(id));
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < table.length; i++) {
        table[i].setVisible(visible[i]);
      }
    }

    void display() {
      if (fnSelection) {
        for (int i = 0; i < table.length; i++) {
          table[i].draw();
        }
      }
    }

    int mousePressed(int x, int y) {
      int keyCode = 0;
      // table touch control area at bottom of screen or sides
      for (int i = 0; i < numKeys; i++) {
        if (table[i].visible) {
          if ((x <= (table[i].x + table[i].w)) && (x >= (table[i].x)) &&
            (y >= table[i].y) && (y <= (table[i].y +table[i].h))) {
            keyCode = table[i].keyCode;
            break;
          }
        }
      }
      return keyCode;
    }
  }

  /**
   * NavTable appears in center of the screen.
   * It provides soft up, down, left, and right keys to navigate menu and Fn tables
   * Launched by Nav soft key
   */
  class NavTable {
    // initialize function Keys
    MenuKey navLeftKey;
    MenuKey navRightKey;
    MenuKey navUpKey;
    MenuKey navDownKey;
    MenuKey navOkKey;
    MenuKey navDummyKey;

    MenuKey[] table;
    int numKeys = 9;
    float insetY;
    float insetX;

    void create(int cameraType) {
      int keyColor = black;
      int arrowKeyColor = aqua;
      navLeftKey = new MenuKey(KEYCODE_NAV_LEFT, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      navRightKey = new MenuKey(KEYCODE_NAV_RIGHT, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      navUpKey = new MenuKey(KEYCODE_NAV_UP, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      navDownKey = new MenuKey(KEYCODE_NAV_DOWN, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      navOkKey = new MenuKey(KEYCODE_NAV_OK, "OK", FONT_SIZE, keyColor);
      navDummyKey = new MenuKey(KEYCODE_NOP, "", FONT_SIZE, keyColor);

      table = new MenuKey[numKeys];
      table[0] = navDummyKey;
      table[1] = navUpKey;
      table[2] = navDummyKey;
      table[3] = navLeftKey;
      table[4] = navOkKey;
      table[5] = navRightKey;
      table[6] = navDummyKey;
      table[7] = navDownKey;
      table[8] = navDummyKey;

      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX -iX/2; // table start from left
      float y = 3*iY;  // table start from middle
      int ROWS = 3;
      int COLS = 3;
      float inset = WIDTH / 64f;
      float[] insetTab = { 0, inset, 0, inset, 0, inset, 0, inset, 0, inset, 0, inset};
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, insetTab[ROWS*i+ j]);
        }
      }
      table[1].setVisible(true);
      table[3].setVisible(true);
      table[4].setVisible(true);
      table[5].setVisible(true);
      table[7].setVisible(true);
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < table.length; i++) {
        table[i].setVisible(visible[i]);
      }
    }

    void display() {
      if (navSelection) {
        for (int i = 0; i < table.length; i++) {
          table[i].draw();
        }
      }
    }

    int mousePressed(int x, int y) {
      int keyCode = 0;
      // table touch control area at bottom of screen or sides
      for (int i = 0; i < numKeys; i++) {
        if (table[i].visible) {
          if ((x <= (table[i].x + table[i].w)) && (x >= (table[i].x)) &&
            (y >= table[i].y) && (y <= (table[i].y +table[i].h))) {
            keyCode = table[i].keyCode;
            break;
          }
        }
      }
      return keyCode;
    }
  }

  /**
   * MenuBar appears at right of full screen when the screen is tapped.
   */
  class VertMenuBar {
    // initialize Keys
    MenuKey focusKey;
    MenuKey shutterKey;
    MenuKey evKey;
    MenuKey jogcwKey;
    MenuKey jogccwKey;
    MenuKey recordKey;
    MenuKey homeKey;
    MenuKey playBackKey;
    MenuKey[] menuKey;
    int numKeys = 8;
    float menuBase;
    float menux;
    float menuy;

    void create(int cameraType) {
      color keyColor = black;
      //PImage imgeye = base.loadImage("icons/eye.png");

      focusKey = new MenuKey(KEYCODE_F, "Focus", FONT_SIZE, keyColor);
      shutterKey = new MenuKey(KEYCODE_S, "Shutter", FONT_SIZE, keyColor);
      if (cameraType == NX2000) {
        evKey = new MenuKey(KEYCODE_E, "EV/OK", FONT_SIZE, keyColor);
      } else {
        evKey = new MenuKey(KEYCODE_E, "EV", FONT_SIZE, keyColor);
      }
      jogcwKey = new MenuKey(KEYCODE_J, "EV"+LEFT_TRIANGLE, FONT_SIZE, keyColor);
      jogccwKey = new MenuKey(KEYCODE_L, "EV"+RIGHT_TRIANGLE, FONT_SIZE, keyColor);
      recordKey = new MenuKey(KEYCODE_R, "Record", FONT_SIZE, red);
      if (cameraType == MRC || cameraType == RPI) {
        homeKey = new MenuKey(KEYCODE_H, "Fname", FONT_SIZE, keyColor);
      } else {
        homeKey = new MenuKey(KEYCODE_H, "Home", FONT_SIZE, keyColor);
      }
      playBackKey = new MenuKey(KEYCODE_P, "PB", FONT_SIZE, keyColor);
      menuKey = new MenuKey[numKeys];
      menuKey[0] = focusKey;
      menuKey[1] = shutterKey;
      menuKey[2] = jogcwKey;
      menuKey[3] = jogccwKey;
      menuKey[4] = evKey;
      menuKey[5] = recordKey;
      menuKey[6] = homeKey;
      menuKey[7] = playBackKey;
      float inset = 320 / ((float) numKeys) / 2f;
      menux = WIDTH - 320 +(2*inset);
      menuy = 0;
      float w = iX;
      float h = (HEIGHT-120)/ ((float) numKeys);
      menuBase = menuy;

      for (int i = 0; i < numKeys; i++) {
        menuKey[i].setPosition(menux, ((float) i) * h, w, h- inset, inset);
      }
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setVisible(visible[i]);
      }
    }

    void setActive(boolean[] active) {
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setActive(active[i]);
      }
    }

    void display() {
      highlightFocusKey(focus);
      fill(192);
      rect(WIDTH -320, 0, 320, HEIGHT - 120);
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      if (DEBUG) println("vert menubar mouse x="+x + " y="+y);
      if (y > menuBase && y < HEIGHT-120 && x > menux) {
        // menu touch control area at bottom of screen or sides
        for (int i = 0; i < numKeys; i++) {
          if (menuKey[i].visible && menuKey[i].active) {
            if (x >= menuKey[i].x && x<= (menuKey[i].x + menuKey[i].w) && y >= menuKey[i].y && y <= (menuKey[i].y +menuKey[i].h)) {
              mkeyCode = menuKey[i].keyCode;
              mkey = 0;
              if (DEBUG) println("vertMenu keycode="+mkeyCode);
              break;
            }
          }
        }
      }
      return mkeyCode;
    }
  }

  /**
   * MenuBar appears at bottom of full screen.
   */
  class HorzMenuBar {
    MenuKey[] menuKey;
    int numKeys = 8;
    float menuBase;
    float x, y, w, h;
    color keyColor = black;

    public HorzMenuBar() {
      menuKey = new MenuKey[numKeys];
      x = 0;
      y = HEIGHT - iY;
      w = WIDTH / ((float) numKeys);
      h = iY-4;
      menuBase = 2*camera[mainCamera].screenHeight;
    }

    void setVisible(boolean[] visible) {
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setVisible(visible[i]);
      }
    }

    void setActive(boolean[] active) {
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setActive(active[i]);
      }
    }

    void display() {
      fill(128);
      noStroke();
      rect(0, menuBase, WIDTH, HEIGHT-menuBase);

      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      if (DEBUG) println("horz menubar mouse x="+x + " y="+y + " menuBase="+menuBase);
      if (y > menuBase ) {
        // menu touch control area at bottom of screen or sides
        for (int i = 0; i < numKeys; i++) {
          if (menuKey[i].visible && menuKey[i].active) {
            if ((x <= (menuKey[i].x + menuKey[i].w)) && (x >= (menuKey[i].x))) {
              mkeyCode = menuKey[i].keyCode;
              break;
            }
          }
        }
      }
      return mkeyCode;
    }
  }

  /**
   * MenuBar appears at bottom of full screen.
   */
  class HorzMenuBar1 extends HorzMenuBar {
    // initialize Keys
    MenuKey cameraInfoKey;
    MenuKey cameraShowKey;
    MenuKey cameraSaveKey;
    MenuKey cameraSyncKey;
    MenuKey cameraMenuKey;
    MenuKey cameraFnKey;
    MenuKey cameraOkKey;
    MenuKey altKey;
    MenuKey backKey;

    public HorzMenuBar1(int cameraType) {
      super();
      cameraInfoKey = new MenuKey(KEYCODE_I, "Screen", FONT_SIZE, keyColor);
      cameraShowKey = new MenuKey(KEYCODE_SHOW, "Show", FONT_SIZE, keyColor);
      cameraSaveKey = new MenuKey(KEYCODE_SAVE, "Save", FONT_SIZE, keyColor);
      cameraMenuKey = new MenuKey(KEYCODE_M, "MENU", FONT_SIZE, keyColor);
      cameraFnKey = new MenuKey(KEYCODE_N, "Fn", FONT_SIZE, keyColor);
      cameraSyncKey = new MenuKey(KEYCODE_FN_ZONE, "Sync", FONT_SIZE, keyColor);
      cameraOkKey = new MenuKey(KEYCODE_K, "OK", FONT_SIZE, keyColor);
      altKey = new MenuKey(KEYCODE_C, "Alt1", FONT_SIZE, keyColor);
      backKey = new MenuKey(KEYCODE_BACKSPACE, "Back", FONT_SIZE, keyColor);

      menuKey[0] = cameraInfoKey;
      menuKey[1] = cameraShowKey;
      menuKey[2] = cameraSaveKey;
      menuKey[3] = cameraSyncKey;
      menuKey[4] = cameraMenuKey;
      menuKey[5] = cameraFnKey;
      if (cameraType == NX2000) {
        menuKey[6] = backKey;
      } else {
        menuKey[6] = cameraOkKey;
      }
      menuKey[7] = altKey;

      float inset = WIDTH / ((float) numKeys) / 7f;
      for (int i = 0; i < numKeys; i++) {
        menuKey[i].setPosition(((float) i) * w + inset, y, w - 2 * inset, h, inset);
      }
      //      menuKey[numKeys].setPosition(0, 0, w - 2 * inset, h, inset);
      //      menuKey[numKeys].setCorner(false);
    }
  }

  /**
   * MenuBar appears at bottom of full screen.
   */
  class HorzMenuBar2 extends HorzMenuBar {
    // initialize Keys
    MenuKey cameraInfoKey;
    MenuKey cameraRepeatKey;
    MenuKey cameraSaveKey;
    MenuKey cameraModeKey;
    MenuKey cameraMenuKey;
    MenuKey cameraFnKey;
    MenuKey cameraOkKey;
    MenuKey exitKey;
    MenuKey altKey;
    MenuKey cameraStatusKey;
    MenuKey cameraNavKey;
    MenuKey dummyKey;

    public HorzMenuBar2(int cameraType) {
      super();

      cameraInfoKey = new MenuKey(KEYCODE_I, "Screen", FONT_SIZE, keyColor);
      cameraRepeatKey = new MenuKey(KEYCODE_REPEAT, "Repeat", FONT_SIZE, keyColor);
      cameraSaveKey = new MenuKey(KEYCODE_SAVE, "Save", FONT_SIZE, keyColor);
      cameraModeKey = new MenuKey(KEYCODE_W, "Mode", FONT_SIZE, keyColor);
      exitKey = new MenuKey(KEYCODE_ESC, "EXIT", FONT_SIZE, keyColor);
      altKey = new MenuKey(KEYCODE_C, "Alt", FONT_SIZE, keyColor);
      dummyKey = new MenuKey(KEYCODE_NOP, "", FONT_SIZE, keyColor);
      cameraStatusKey = new MenuKey(KEYCODE_Y, "Status", FONT_SIZE, keyColor);
      cameraNavKey =  new MenuKey(KEYCODE_NAV_UPDATE, "Nav", FONT_SIZE, keyColor);

      menuKey[0] = cameraInfoKey;
      menuKey[1] = cameraRepeatKey;
      menuKey[2] = dummyKey;
      menuKey[3] = cameraNavKey;
      menuKey[4] = cameraModeKey;
      menuKey[5] = cameraStatusKey;
      menuKey[6] = exitKey;
      menuKey[7] = altKey;

      float inset = WIDTH / ((float) numKeys) / 7f;
      for (int i = 0; i < numKeys; i++) {
        menuKey[i].setPosition(((float) i) * w + inset, y, w - 2 * inset, h, inset);
      }
    }
  }

  /**
   * MenuBar appears at bottom of full screen.
   */
  class ConfigZone {
    // initialize Keys
    MenuKey zoneKey;
    MenuKey lastcKey;
    MenuKey[] menuKey;
    int numKeys = 2;
    float menuBase;

    void create() {
      color keyColor = black;

      zoneKey = new MenuKey(KEYCODE_NEW_CONFIG, "New", FONT_SIZE, keyColor);
      lastcKey = new MenuKey(KEYCODE_CURRENT_CONFIG, "Last", FONT_SIZE, keyColor);
      menuKey = new MenuKey[numKeys];
      menuKey[0] = zoneKey;
      menuKey[1] = lastcKey;
      float w = 640;
      float h = 104;
      float x = 294;
      //float y = camera[mainCamera].screenHeight ;
      float y = NX2000Camera.SCREEN_HEIGHT ;
      menuBase = y ;


      zoneKey.setPosition( x, y, w/2, h, 60);
      lastcKey.setPosition( x+w/2+40, y, w/2, h, 60);
      setActive();
    }

    void setActive() {
      if (DEBUG) println("gui.ConfigZone.setActive()");
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setVisible(true);
        menuKey[i].setActive(true);
      }
    }

    void remove() {
      if (DEBUG) println("gui.ConfigZone.remove()");
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].setVisible(false);
        menuKey[i].setActive(false);
      }
    }

    void display() {
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
      noFill();
      rect(menuKey[0].x, menuKey[0].y, menuKey[0].w, menuKey[0].h);
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      if (DEBUG) println("Config Zone mouse x="+x + " y="+y + " menuBase="+menuBase);
      if (y > menuBase ) {
        // menu touch control area at bottom of screen or sides
        for (int i = 0; i < numKeys; i++) {
          if (menuKey[i].visible && menuKey[i].active) {
            if ((x <= (menuKey[i].x + menuKey[i].w)) && (x >= (menuKey[i].x))) {
              mkeyCode = menuKey[i].keyCode;
              break;
            }
          }
        }
      }
      return mkeyCode;
    }
  }

  class MenuKey {
    float x, y, w, h; // location
    float inset;
    String cap;     // caption
    PImage img;
    int keyColor;
    int keyCode;
    int fontSize;
    boolean visible = false;
    boolean highlight = false;
    boolean active = true;
    boolean corner = true;
    boolean textOnly = false;
    int value;

    MenuKey() {
    }

    MenuKey(int keyCode, String cap, int fontSize, int keyColor) {
      this.keyCode = keyCode;
      this.cap = cap;
      this.keyColor = keyColor;
      this.fontSize = fontSize;
      this.img = null;
    }

    MenuKey(int keyCode, PImage img, int keyColor) {
      this.keyCode = keyCode;
      this.img = img;
      this.keyColor = keyColor;
      this.fontSize = base.FONT_SIZE;
    }

    void setPosition(float x, float y, float w, float h, float inset) {
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.inset = inset;
    }

    void setValue(int value) {
      this.value = value;
    }

    int getValue() {
      return value;
    }

    void setHighlight(boolean highlight) {
      this.highlight = highlight;
    }

    void setVisible(boolean visible) {
      this.visible = visible;
    }

    void setActive(boolean active) {
      this.active = active;
    }

    void setCorner(boolean corner) {
      this.corner = corner;
    }

    void setTextOnly(boolean value) {
      this.textOnly = value;
    }

    void draw() {
      if (visible) {
        base.stroke(gray);
        base.strokeWeight(4);
        base.rectMode(base.CORNER);
        if (img != null) {
          if (active) {
            base.fill(white);
          } else {
            base.fill(gray);
          }
          base.rect(x, y, w, h, inset);
          float ar = (float) img.width/ (float) img.height;
          float ah = h*0.8f;
          base.image(img, x- (ah*ar)/2+w/2, y+ah/8, ah*ar, ah);
          //base.noFill();
          base.stroke(keyColor);
          if (highlight) {
            base.stroke(255, 255, 0);
            base.strokeWeight(12);
            base.noFill();
            //base.fill(255, 128, 0);
            base.rect(x, y, w, h);
          }
        } else if (cap != null) {
          if (active) {
            if (highlight) {
              base.fill(255, 128, 0);
            } else {
              base.fill(white);
            }
          } else {
            base.fill(gray);
          }
          if (corner) {
            base.rect(x, y, w, h, inset);
          }
          base.textSize(fontSize);
          base.noStroke();
          base.noFill();
          if (corner) {
            base.fill(black);
          } else {
            base.fill(graytransparent);
          }
          base.textAlign(base.CENTER, base.CENTER);
          base.fill(keyColor);
          base.text(cap, x, y, w, h);
        }
      }
    }

    boolean isPressed(int mx, int my) {
      boolean hit = false;
      if (my >= y && my <= (y + h)
        && mx >= x && mx <= (x + w)) {
        hit = true;
      }
      return hit;
    }

    int getPressed(int mx, int my, int n) {
      int area = 0;
      if (my >= y && my <= (y + h)) {
        for (int i = 1; i <= n; i++) {
          if (mx >= x && mx <= (x + i * w / n)) {
            area = i;
            break;
          }
        }
      }
      return area;
    }

    void setCap(String cap) {
      this.cap = cap;
    }

    void setKeyCode(int keyCode) {
      this.keyCode = keyCode;
    }

    int getKeyCode() {
      return keyCode;
    }
  }
}

void drawIntroductionScreen() {
  fill(255);
  textAlign(LEFT);
  textSize(FONT_SIZE);

  text(TITLE, 300, 60);
  text(SUBTITLE, 300, 60+50);
  if (DEBUG) {
    text(VERSION_DEBUG, 300, 60+100);
  } else {
    text(VERSION, 300, 60+100);
  }

  text(CREDITS, 300, 60+150);
  textSize(FONT_SIZE);
  text("Select Multi-Camera Configuration File", 300, 400);

  for (int i=0; i<4; i++) {
    image(cameraImage, width- cameraImage.width, i*cameraImage.height);
  }
}
