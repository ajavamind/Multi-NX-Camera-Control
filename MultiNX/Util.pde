// utility helper functions
int SYSID = 0;
int APPID = 1;

int APPPREF_FNO_INDEX = 0x00000008;
int APPPREF_FNO_INDEX_OTHER_MODE = 0x0000000C;
int APPPREF_SHUTTER_SPEED_INDEX = 0x00000010; 
int APPPREF_SHUTTER_SPEED_INDEX_OTHER_MODE = 0x00000014;
int APPPREF_EVC = 0x00000018 ;
int APPPREF_ISO_PAS = 0x00000064;

int result;
boolean decoded = false;
int NO_TYPE = 0;
int LONG_TYPE = 1;
int BLOCK_TYPE = 2;
int resultType = NO_TYPE;

void decodeResult(String s) {
  if (resultType == LONG_TYPE) {
    decodeLong(s);
  } else if (resultType == BLOCK_TYPE) {
    decodeBlock(s);
  }
}

void decodeLong(String s) {
  int index = s.lastIndexOf("(0x");
  if (index >= 0) {
    println(s.substring(index+3, index+11));
    result = unhex(s.substring(index+3, index+11));
    println("result="+result);
    decoded = true;
  }
}

void decodeBlock(String s) {
  String block = s.replaceAll("\\s", "");
  int index = block.indexOf(']');
  if (index >= 0) {
    println(s.substring(index+1, index+9));
    result = unhex(s.substring(index+1, index+9));
    println("result="+result);
    decoded = true;
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
