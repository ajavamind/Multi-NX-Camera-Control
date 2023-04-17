
PGraphics pg;
int photoNumber=0;
PImage lastAnaglyph;

void savePhoto(String filename) {
  if (DEBUG) println("savePhoto "+ filename);
  saveCameraPhotos();
  if (DEBUG) println("saveCompositePhoto");
  saveCompositePhoto(filename);
  saveAnaglyphPhoto(filename);
}

void saveCameraPhotos() {
  photoNumber++;
  savePhotoNumber(photoNumber);
  for (int i=0; i<numCameras; i++) {
    if (camera[i].lastPhoto != null) {
      int w = camera[i].lastPhoto.width;
      int h = camera[i].lastPhoto.height;
      if (w>0 && h>0) {
        if (saveFolderPath != null) {
          String name = camera[i].filename;
          if (DEBUG) println(name);
          int ia = name.lastIndexOf("/")+1;
          int ib = name.lastIndexOf(".");
          //if (DEBUG) println(name +" "+ ia +" "+ib);
          if (ia >= 0 && ib >=0 ) {
            name = name.substring(name.lastIndexOf("/")+1, name.lastIndexOf("."));
          }
          if (DEBUG) println(name);
          //name.replace("\\.JPG", "");
          //if (DEBUG) println(name);
          //name.replace("\\.SRW", "");
          //if (DEBUG) println(name);
          String cname = camera[i].suffix;
          String out = saveFolderPath+File.separator+name+"_"+number(photoNumber)+cname+".JPG";
          //String out = saveFolderPath+File.separator+"MNX"+convertCounter(photoNumber)+"_"+cname+".JPG";
          if (DEBUG) println("save="+out);
          camera[i].lastPhoto.save(out);
        }
      }
    }
  }
}

void saveCompositePhoto(String filename) {
  int gw=0;
  int gh=0;
  int w = 0;
  int h = 0;
  String suffix="";
  boolean valid = true;
  for (int i=0; i<numCameras; i++) {
    if (camera[i].lastPhoto == null) {
      valid = false;
      break;
    }
    w = camera[i].lastPhoto.width;
    h = camera[i].lastPhoto.height;
    if (w<=0 && h<=0) {
      valid = false;
      break;
    }
  }
  if (valid) {
    if (numCameras == 2) {
      gw= 2*w;
      gh = h;
      suffix = "_2x1";
    } else if (numCameras == 4) {
      gw= 2*w;
      gh = 2*h;
      suffix = "_2x2";
    } else {
      return;
    }
    pg = createGraphics(gw, gh);
    pg.beginDraw();
    pg.background(0);
    pg.image(camera[0].lastPhoto, 0, 0);
    pg.image(camera[1].lastPhoto, w, 0);
    if (numCameras == 4) {
      pg.image(camera[2].lastPhoto, 0, h);
      pg.image(camera[3].lastPhoto, w, h);
    }
    pg.endDraw();

    if (saveFolderPath != null) {
      String out = saveFolderPath+File.separator+filename+suffix+".jpg";
      if (DEBUG) println("save="+out);
      try {
        pg.save(out);
      }
      catch (Error err) {
        gui.displayMessage(err.toString(), 180);
      }
    }
  }
}

void saveAnaglyphPhoto(String filename) {
  int gw=0;
  int gh=0;
  int w = 0;
  int h = 0;
  String suffix="";
  boolean valid = true;
  for (int i=0; i<numCameras; i++) {
    if (camera[i].lastPhoto == null) {
      valid = false;
      break;
    }
    w = camera[i].lastPhoto.width;
    h = camera[i].lastPhoto.height;
    if (w<=0 && h<=0) {
      valid = false;
      break;
    }
  }
  if (valid) {
    if (numCameras == 2) {
      gw= 2*w;
      gh = h;
      suffix = "_ana";
    } else if (numCameras == 4) {
      //gw= 2*w;
      //gh = 2*h;
      //suffix = "_2x2";
    } else {
      return;
    }
    if (lastAnaglyph != null) {
      lastAnaglyph.parent = null; // dispose
      lastAnaglyph = null;
    }
    try {
      lastAnaglyph =createAnaglyph(camera[0].lastPhoto, camera[1].lastPhoto, horizontalOffset);

      if (saveFolderPath != null) {
        String out = saveFolderPath+File.separator+filename+suffix+".jpg";
        if (DEBUG) println("save="+out);
        lastAnaglyph.save(out);
      }
    }
    catch (Error err) {
      gui.displayMessage(err.toString(), 180);
    }
  }
}

// create anaglyph from left and right eye views
PImage createAnaglyph(PImage left, PImage right, int offset) {
  PImage img;
  if (DEBUG) println("createAnaglyph() from PImage ");
  if (!(left != null && left.width > 0)) {
    return null;
  } else if (!(right != null && right.width > 0)) {
    return null;
  }
  img = colorAnaglyph(left, right, offset);
  return img;
}


private PImage colorAnaglyph(PImage bufL, PImage bufR, int offset) {
  // color anaglyph merge left and right images
  if (DEBUG) println("colorAnaglyph offset="+offset);
  if (bufL == null || bufR == null)
    return null;
  //if (DEBUG) println("parallax="+parallax);
  PImage bufA = createImage(bufL.width, bufL.height, RGB);
  bufA.loadPixels();
  bufL.loadPixels();
  bufR.loadPixels();
  int cr = 0;
  int w = bufL.width;
  int h = bufL.height;
  int i = 0;
  int j = w - offset;
  int k = w;
  int len = bufL.pixels.length;
  while (i < len) {
    if (j > 0) {
      cr = bufR.pixels[i];
      if ((i + offset) < 0  || (i+offset) >= len) {
        //if (DEBUG) println("anaglyph creation out of range "+ (i+offset));
      } else {
        bufA.pixels[i] = color(red(bufL.pixels[i+offset]), green(cr), blue(cr));
      }
      j--;
    } else {
      bufA.pixels[i] = 0;
    }
    k--;
    if (k <= 0) {
      k = w;
      j = w - offset;
    }
    i++;
  }
  bufA.updatePixels();
  PImage temp = createImage(w-offset, h, RGB);
  temp.copy(bufA, 0, 0, temp.width, temp.height, 0, 0, temp.width, temp.height);
  bufA.parent = null; // dispose
  bufA = null;
  return temp;
}

// rotate image based on camera orientation
PImage rotatePhoto(PImage src, int degrees) {
  if (degrees == 0) return src;
  int dw = src.width;
  int dh = src.height;
  if (degrees % 180 != 0) { // check for portrait rotation
    int temp = dw;
    dw = dh;
    dh = temp;
  }
  //float ar = (float)dw/(float)dh;
  PImage img = createImage(dw, dh, RGB);
  float rotateRadians = radians(degrees);
  PGraphics pg;
  pg = createGraphics(dw, dh);
  pg.beginDraw();
  //pg.background(0);
  pg.pushMatrix();
  pg.translate(dw/2, dh/2);
  pg.rotate(rotateRadians);
  pg.image(src, -src.width/2, -src.height/2, src.width, src.height);  //
  pg.popMatrix();
  pg.endDraw();
  //img = pg.copy();
  //pg.dispose();
  img = pg;
  return img;
}
