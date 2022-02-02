interface Client {
  Client getClient();
  boolean active();
  int available();
  String readString();
  void write(String data);
  void stop();
  boolean isConnected();
}
