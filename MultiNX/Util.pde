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
  for (int i=0; i<numCameras; i++) {
    camera[i].takePhoto();
  }
}

void focusMultiPhoto(NX2000Camera[] camera) {
  for (int i=0; i<numCameras; i++) {
    camera[i].client.write("st key push s1;sleep 1;st key release s1\n"); // focus
  }
}

//String convertCounter(int value) {
//  if (value <10) {
//    return ("000"+value);
//  } else if (value <100) {
//    return ("00"+value);
//  } else if (value <1000)
//    return ("0"+value);
//  return str(value);
//}

  // Add leading zeroes to number
String number(int index) {
  // fix size of index number at 4 characters long
  //  if (index == 0)
  //    return "";
  if (index < 10)
    return ("000" + String.valueOf(index));
  else if (index < 100)
    return ("00" + String.valueOf(index));
  else if (index < 1000)
    return ("0" + String.valueOf(index));
  return String.valueOf(index);
}
