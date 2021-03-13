
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

volatile boolean modeSelection = false;
int cameraMode = 0;
int selectedCameraMode = 0;
String[] cameraModes ={"lens", "magic", "wi-fi", "scene", "movie", "smart", "p", "a", "s", "m", "", ""};
// setting "movie" mode does not function in NX2000 with "st key mode"

// The GUI assumes the camera screen image is at (0,0)
class Gui {
  MultiNX base;
  HorzMenuBar horzMenuBar;
  VertMenuBar vertMenuBar;
  ModeTable modeTable;

  // information zone touch coordinates
  // screen boundaries for click zone use
  float WIDTH;
  float HEIGHT;
  float iX;
  float iY;
  float mX;
  float mY;
  //float inset;

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

  void createGui(MultiNX base) {
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
  }

  void displayMenuBar() {
    horzMenuBar.display();
    vertMenuBar.display();
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

      lensKey = new MenuKey(1000, cameraModes[0], FONT_SIZE, keyColor);
      magicKey = new MenuKey(1001, cameraModes[1], FONT_SIZE, keyColor);
      wifiKey = new MenuKey(1002, cameraModes[2], FONT_SIZE, keyColor);
      sceneKey = new MenuKey(1003, cameraModes[3], FONT_SIZE, keyColor);
      movieKey = new MenuKey(1004, cameraModes[4], FONT_SIZE, keyColor);
      smartKey = new MenuKey(1005, cameraModes[5], FONT_SIZE, keyColor);
      pKey = new MenuKey(1006, cameraModes[6], FONT_SIZE, keyColor);
      aKey = new MenuKey(1007, cameraModes[7], FONT_SIZE, keyColor);
      sKey = new MenuKey(1008, cameraModes[8], FONT_SIZE, keyColor);
      mKey = new MenuKey(1009, cameraModes[9], FONT_SIZE, keyColor);
      emptyKey = new MenuKey(1010, cameraModes[10], FONT_SIZE, keyColor);
      empty2Key = new MenuKey(1011, cameraModes[11], FONT_SIZE, keyColor);
      okKey = new MenuKey(1012, CHECK_MARK, FONT_SIZE, keyColor);

      table = new MenuKey[numKeys];
      table[0] = lensKey;
      table[1] = magicKey;
      table[2] = wifiKey;
      table[3] = sceneKey;
      table[4] = movieKey;
      table[5] = smartKey;
      table[6] = pKey;
      table[7] = aKey;
      table[8] = sKey;
      table[9] = mKey;
      table[10] = emptyKey;
      table[11] = empty2Key;
      table[12] = okKey;
      int[] valueTable = {0, 1, 2, 3, 
        4, 5, 6, 7, 
        8, 9, 10, 11, 
        12
      };
      insetY = iY/8;
      insetX = iX/8;
      float x = (mX)-insetX-iX-2*insetX- iX; // table start from left
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
      table[ok].setPosition(mX-iX/2, y + ((float)ROWS) * (iY + 2 * insetY), iX, iY, WIDTH / 64f);
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
      cameraMenuKey = new MenuKey(KEYCODE_M, "Menu", FONT_SIZE, keyColor);
      cameraFnKey = new MenuKey(KEYCODE_N, "FN", FONT_SIZE, keyColor);
      cameraModeKey = new MenuKey(KEYCODE_W, "Mode", FONT_SIZE, keyColor);
      cameraOkKey = new MenuKey(KEYCODE_K, "OK", FONT_SIZE, keyColor);
      //xxxxKey = new MenuKey(KEYCODE_M, imgeye, keyColor);
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
