
//import static android.view.KeyEvent.*;
//import static android.view.KeyEvent.KEYCODE_0;
//import static android.view.KeyEvent.KEYCODE_1;
//import static android.view.KeyEvent.KEYCODE_DEL;
//import static android.view.KeyEvent.KEYCODE_I;
//import static android.view.KeyEvent.KEYCODE_M;
//import static android.view.KeyEvent.KEYCODE_MEDIA_NEXT;
//import static android.view.KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE;
//import static android.view.KeyEvent.KEYCODE_MEDIA_PREVIOUS;
//import static android.view.KeyEvent.KEYCODE_PAGE_DOWN;
//import static android.view.KeyEvent.KEYCODE_PAGE_UP;
//import static android.view.KeyEvent.KEYCODE_MEDIA_STOP;

//int FONT_SIZE = 48;
int MEDIUM_FONT_SIZE =  72;
int LARGE_FONT_SIZE = 96;
int GIANT_FONT_SIZE = 128;

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

volatile boolean modeSelection = false;
volatile boolean fnSelection = false;

int cameraMode = 0;
int selectedCameraMode = 0;
String[] cameraModes ={"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m", "", ""};
String[] cameraKeyModes ={"Lens", "Magic", "WiFi", "Scene", "Movie", "Smart", "P", "A", "S", "M", "", ""};
// setting "movie" mode does not function in NX2000 with "st key mode"

String[] shutterName = { "Bulb", "30\"", "25\"", "20\"", "15\"", "13\"", "10\"", 
"8\"", "6\"", "5\"", "4\"", "3\"", "2.5\"", "2\"", "1.6\"", "1.3\"", "1\"", "0.8\"", "0.6\"", "0.5\"", "0.4\"", "0.3\"", 
"1/4", "1/5", "1/6", "1/8", "1/10", "1/13", "1/15", "1/20", "1/25", "1/30", "1/40", "1/50", "1/60", "1/80", "1/100", "1/125",
"1/160", "1/200", "1/250", "1/320", "1/400", "1/500", "1/640", "1/800", "1/1000", "1/1250", "1/1600", "1/2000", "1/2500", "1/3200", "1/4000"
};
int shutterId = 1;
String[] fnName = { "F3.5", "F4.0", "F4.5", "F5.0", "F5.6", "F6.3", "F7.1", "F8.0", "F9.0", "F10", "F11", "F13", "F14", "F16", "F18", "F20", "F22" };
int fnId = 0;

String[] isoName = { "AUTO", "100", "200", "400", "800", "1600", "3200", "6400", "12800", "25600" };
String[] isoName3 = { "AUTO", "100", "125", "160", "200", "250", "320", "400", "500", "640", "800", "1000", 
"1250", "1600", "2000", "2500", "3200", "4000", "5000", "6400", "8000", "10000", "12800", "16000", "20000", "25600" };
int isoId = 1;

// The GUI assumes the camera screen image is at (0,0)
class Gui {
  MultiNX base;
  HorzMenuBar horzMenuBar;
  VertMenuBar vertMenuBar;
  ModeTable modeTable;
  FnZone fnZone;
  FnTable fnTable;
  
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
  final static String LEFT_TRIANGLE = "\u22B2";
  final static String RIGHT_TRIANGLE = "\u22B3";
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
  final boolean[] hfull = {true, true, true, true, true, true, false};
  final boolean[] modefull = {true, true, true, true, true, true, true, true, true, true, true, true, true};

  Gui() {
  }

  void create(MultiNX base) {
    this.base = base;
    WIDTH = base.width;
    HEIGHT = base.height;
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

    horzMenuBar = new HorzMenuBar();
    horzMenuBar.create();
    horzMenuBar.setVisible(hfull);
    horzMenuBar.setActive(hfull);

    vertMenuBar = new VertMenuBar();
    vertMenuBar.create();
    vertMenuBar.setVisible(vfull);
    vertMenuBar.setActive(vfull);

    modeTable = new ModeTable();
    modeTable.create();

    fnZone = new FnZone();
    fnZone.create();
    fnTable = new FnTable();
    fnTable.create();
  }

  void displayMenuBar() {
    horzMenuBar.display();
    vertMenuBar.display();
    fnZone.display();
  }

  void highlightFocusKey(boolean hold) {
    vertMenuBar.focusKey.setHighlight(hold);
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

  void displayMessage(String message) {
    float w = base.textWidth(message);
    float h =  base.textAscent()+textDescent();
    float d = base.textWidth("W");
    base.fill(192);
    base.rect(width/2 - w/2-d, height / 2-h, w+2*d, 2*h, h);
    base.fill(192, 0, 0);
    base.textSize(MEDIUM_FONT_SIZE);
    base.textAlign(CENTER, CENTER);
    base.text(message, width / 2, base.height / 2);
    base.textAlign(LEFT);
  }


  /**
   * ModeTable appears in center of the screen.
   */
  class ModeTable {
    // initialize Mode Keys
    MenuKey lensKey;
    MenuKey magicKey;
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

    void create() {
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

      lensKey = new MenuKey(1000, cameraKeyModes[0], FONT_SIZE, keyColor);
      magicKey = new MenuKey(1001, cameraKeyModes[1], FONT_SIZE, keyColor);
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
      table[8] = pKey;
      table[9] = aKey;
      table[10] = sKey;
      table[11] = mKey;
      table[6] = emptyKey;
      table[7] = empty2Key;
      table[12] = okKey;
      int[] valueTable = {0, 1, 2, 3, 
        4, 5, 6, 7, 
        8, 9, 10, 11, 
        12
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
    MenuKey okKey;
    MenuKey[] table;
    int numKeys = 13;
    float insetY;
    float insetX;

    void create() {
      int keyColor = black;
      int arrowKeyColor = aqua;
      shutterNameKey = new MenuKey(2000, "SHUTTER", FONT_SIZE, white);
      shutterNameKey.setActive(false);
      shutterNameKey.setCorner(false);
      shutterLeftKey = new MenuKey(2001, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      shutterKey = new MenuKey(2002, shutterName[shutterId], FONT_SIZE, keyColor);
      shutterRightKey = new MenuKey(2003, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      fnNameKey = new MenuKey(2004, "FN", FONT_SIZE, white);
      fnNameKey.setActive(false);
      fnNameKey.setCorner(false);
      fnLeftKey = new MenuKey(2005, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      fnKey = new MenuKey(2006, fnName[fnId], FONT_SIZE, keyColor);
      fnRightKey = new MenuKey(2007, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      isoNameKey = new MenuKey(2008, "ISO", FONT_SIZE, white);
      isoNameKey.setActive(false);
      isoNameKey.setCorner(false);
      isoLeftKey = new MenuKey(2009, LEFT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      isoKey = new MenuKey(2010, isoName[isoId], FONT_SIZE, keyColor);
      isoRightKey = new MenuKey(2011, RIGHT_TRIANGLE, MEDIUM_FONT_SIZE, arrowKeyColor);
      okKey = new MenuKey(2012, CHECK_MARK, FONT_SIZE, keyColor);

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
      table[12] = okKey;
      int[] valueTable = {0, 1, 2, 3, 
        4, 5, 6, 7, 
        8, 9, 10, 11, 
        12
      };
      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX -iX/2; // table start from left
      float y = 3*iY;  // table start from middle
      int ROWS = 3;
      int COLS = 4;
      int ok = 12;
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          table[COLS*i+j].setPosition(x + ((float)j) * (iX + 2 * insetX), y + ((float)i) * (iY + 2 * insetY), iX, iY, 0);
          table[COLS*i+j].setVisible(true);
          table[COLS*i+j].setValue(valueTable[COLS*i+j]);
        }
      }
      //table[ok].setPosition(mX-iX, y + ((float)ROWS) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
      table[ok].setPosition(x + 2* (iX + 2 * insetX), y + ((float)ROWS) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
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
      if (fnSelection) {
        //int mode = selectedCameraMode;
        for (int i = 0; i < table.length; i++) {
          //if (table[i].getValue() == mode) {
          //  table[i].setHighlight(true);
          //} else {
          //  table[i].setHighlight(false);
          //}
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
    void create() {
      color keyColor = black;
      //PImage imgeye = base.loadImage("icons/eye.png");

      focusKey = new MenuKey(KEYCODE_F, "Focus", FONT_SIZE, keyColor);
      shutterKey = new MenuKey(KEYCODE_S, "Shutter", FONT_SIZE, keyColor);
      evKey = new MenuKey(KEYCODE_E, "EV", FONT_SIZE, keyColor);
      jogcwKey = new MenuKey(KEYCODE_J, LEFT_TRIANGLE, FONT_SIZE, keyColor);
      jogccwKey = new MenuKey(KEYCODE_L, RIGHT_TRIANGLE, FONT_SIZE, keyColor);
      recordKey = new MenuKey(KEYCODE_R, "Record", FONT_SIZE, red);
      homeKey = new MenuKey(KEYCODE_H, "Home", FONT_SIZE, keyColor);
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
      menux = WIDTH - 320 +1.5*inset ;
      menuy = 0;
      float w = iX; //WIDTH / ((float) numKeys);
      float h = (HEIGHT-120)/ ((float) numKeys);
      menuBase = menuy;

      for (int i = 0; i < numKeys; i++) {
        menuKey[i].setPosition(menux, ((float) i) * h, w, h- inset, 0);
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
      fill(192);
      rect(WIDTH -320, 0, 320, HEIGHT - 120);
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      println("vert menubar mouse x="+x + " y="+y);
      if (y > menuBase && y < HEIGHT-120 && x > menux) {
        // menu touch control area at bottom of screen or sides
        for (int i = 0; i < numKeys; i++) {
          if (menuKey[i].visible && menuKey[i].active) {
            if (x >= menuKey[i].x && x<= (menuKey[i].x + menuKey[i].w) && y >= menuKey[i].y && y <= (menuKey[i].y +menuKey[i].h)) {
              mkeyCode = menuKey[i].keyCode;
              mkey = 0;
              println("vertMenu keycode="+mkeyCode);
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
    // initialize Keys
    MenuKey cameraInfoKey;
    MenuKey cameraModeKey;
    MenuKey cameraMenuKey;
    MenuKey cameraFnKey;
    MenuKey cameraOkKey;
    MenuKey backKey;
    MenuKey[] menuKey;
    int numKeys = 6;
    float menuBase;

    void create() {
      color keyColor = black;
      //PImage imgeye = base.loadImage("icons/eye.png");

      cameraInfoKey = new MenuKey(KEYCODE_I, "Info", FONT_SIZE, keyColor);
      cameraMenuKey = new MenuKey(KEYCODE_M, "MENU", FONT_SIZE, keyColor);
      cameraFnKey = new MenuKey(KEYCODE_N, "Fn", FONT_SIZE, keyColor);
      cameraModeKey = new MenuKey(KEYCODE_W, "Mode", FONT_SIZE, keyColor);
      cameraOkKey = new MenuKey(KEYCODE_K, "OK", FONT_SIZE, keyColor);
      backKey = new MenuKey(KEYCODE_ESCAPE, "EXIT", FONT_SIZE, keyColor);
      menuKey = new MenuKey[numKeys];
      menuKey[0] = cameraInfoKey;
      menuKey[1] = cameraModeKey;
      menuKey[2] = cameraMenuKey;
      menuKey[3] = cameraFnKey;
      menuKey[4] = cameraOkKey;
      menuKey[5] = backKey;
      //menuKey[6] = magnifyKey;

      float x = 0;
      float y = HEIGHT - iY;
      float w = WIDTH / ((float) numKeys);
      float h = iY-4;
      menuBase = 2*NX2000Camera.screenHeight;

      float inset = WIDTH / ((float) numKeys) / 7f;
      for (int i = 0; i < numKeys; i++) {
        menuKey[i].setPosition(((float) i) * w + inset, y, w - 2 * inset, h, inset);
      }
      //      menuKey[numKeys].setPosition(0, 0, w - 2 * inset, h, inset);
      //      menuKey[numKeys].setCorner(false);
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
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      println("horz menubar mouse x="+x + " y="+y + " menuBase="+menuBase);
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
  class FnZone {
    // initialize Keys
    MenuKey zoneKey;
    MenuKey[] menuKey;
    int numKeys = 1;
    float menuBase;

    void create() {
      color keyColor = black;

      zoneKey = new MenuKey(KEYCODE_FN_ZONE, null, FONT_SIZE, keyColor);
      menuKey = new MenuKey[numKeys];
      menuKey[0] = zoneKey;

      float w = 1016;
      float h = 104;
      float x = 294;
      float y = 2*NX2000Camera.screenHeight -h;
      menuBase = 2*NX2000Camera.screenHeight -h;


      menuKey[0].setPosition( x, y, w, h, 0);
      menuKey[0].setVisible(true);
      menuKey[0].setActive(true);
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
      for (int i = 0; i < menuKey.length; i++) {
        menuKey[i].draw();
      }
      noFill();
      rect(menuKey[0].x, menuKey[0].y, menuKey[0].w, menuKey[0].h);
    }

    int mousePressed(int x, int y) {
      int mkeyCode = 0;
      int mkey = 0;
      println("Fn Zone mouse x="+x + " y="+y + " menuBase="+menuBase);
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
