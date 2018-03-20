byte[] intToByte(int[] ints) {
  if (ints == null || ints.length == 0) {
    println("Error, int array is null or length is zero.");
    exit();
    return null;
  }
  byte[] bytes = new byte[ints.length * 2];
  int offset = 0;
  for (int i = 0; i < ints.length; i++) {
    bytes[offset++] = (byte)((ints[i] >> 8) & 0xFF);
    bytes[offset++] = (byte)(ints[i] & 0xFF);
  }
  return bytes;
}

int[] byteToInt(byte[] bytes) {
  if (bytes == null || bytes.length == 0) {
    println("Error, byte array is null or lenght is zero.");
    exit();
  }
  int[] ints = new int[bytes.length / 2];
  int offset = 0;
  for (int i = 0; i < bytes.length - 1; i+=2) {
    ints[offset++] = ((bytes[i] & 0xFF) << 8) | (bytes[i+1] & 0xFF);
  }
  return ints;
}

void saveData(int[] depth) {
  byte[] data = intToByte(depth);
  saveBytes("data/depth" + millis() + ".dat",data);
}

int[] loadData(String fileName) {
  byte[] data = loadBytes(fileName);
  return byteToInt(data);
}
