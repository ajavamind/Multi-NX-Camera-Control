
PGraphics pg;
int counter=0;

void savePhoto() {
  if (DEBUG) println("savePhoto");
  //saveCompositePhoto();
  saveCameraPhotos();
}

void saveCameraPhotos() {
  counter++;
  for (int i=0; i<NumCameras; i++) {
    if (camera[i].lastPhoto != null) {
      int w = camera[i].lastPhoto.width;
      int h = camera[i].lastPhoto.height;
      if (w>0 && h>0) {
        if (saveFolderPath != null) {
          String name = camera[i].filename;
          if (DEBUG) println(name);
          int ia = name.lastIndexOf("/")+1;
          int ib = name.lastIndexOf(".");
          if (DEBUG) println(name +" "+ ia +" "+ib);
          if (ia >= 0 && ib >=0 ) {
            name = name.substring(name.lastIndexOf("/")+1, name.lastIndexOf("."));
          }
          if (DEBUG) println(name);
          //name.replace("\\.JPG", "");
          //if (DEBUG) println(name);
          //name.replace("\\.SRW", "");
          //if (DEBUG) println(name);
          String cname = camera[i].name;
          if (cname == null || cname.equals("") || cname.equals(" ")) {
            cname = "";
          } else {
            cname = "_"+camera[i].name;
          }
          String out = saveFolderPath+File.separator+"MNX"+convertCounter(counter)+"_"+name+cname+".JPG";
          if (DEBUG) println("save="+out);
          camera[i].lastPhoto.save(out);
        }
      }
    }
  }
}

void saveCompositePhoto() {
  int gw=0;
  int gh=0;
  int w = 0;
  int h = 0;
  String suffix="";
  boolean valid = true;
  for (int i=0; i<NumCameras; i++) {
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
    if (NumCameras == 2) {
      gw= 2*w;
      gh = h;
      suffix = "_2x1";
    } else if (NumCameras == 4) {
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
    if (NumCameras == 4) {
      pg.image(camera[2].lastPhoto, 0, h);
      pg.image(camera[3].lastPhoto, w, h);
    }
    pg.endDraw();

    if (saveFolderPath != null) {
      String out = saveFolderPath+File.separator+"test"+suffix+".jpg";
      if (DEBUG) println("save="+out);
      pg.save(out);
    }
  }
}
