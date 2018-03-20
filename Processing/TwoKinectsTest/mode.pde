void recordKinect() {
  int[] rawDepth1 = kinect2a.getRawDepth();
  int[] rawDepth2 = kinect2b.getRawDepth();
  int[] rawDepth = new int[rawDepth1.length + rawDepth2.length];
  for (int x = 0; x < KINECT_WIDTH * 2; x++) {
    for (int y = 0; y < KINECT_HEIGHT; y++) {
      int index = x + y * KINECT_WIDTH * 2;
      if (x < KINECT_WIDTH) {
        int index1 = x + y * KINECT_WIDTH;
        rawDepth[index] = rawDepth1[index1];
      } else {
        int index2 = (x - KINECT_WIDTH) + y * KINECT_WIDTH;
        rawDepth[index] = rawDepth2[index2];
      }
    }
  }
  saveData(rawDepth);
  image(getDenoisedDepthImage(rawDepth), 0, 0);
}

int fileOffset = 0;
void displayDataFiles() {
  background(0);
  // println("Start to display...");
  // for (File file : files) {
  File file = files[fileOffset++];
  int[] rawDepth = loadData("data/" + file.getName());
  println("read file " + file.getName() + ", length: " + rawDepth.length);
  if (rawDepth == null) {
    println("Error, can not read data from " + file.getName());
    exit();
    return;
  }
  PImage smoothImage = getDenoisedDepthImage(rawDepth);
  image(smoothImage,0,0);
  if (fileOffset == files.length) {
    exit();
  }
}

void displayKinectSmoothDepth() {
  int[] rawDepth1 = kinect2a.getRawDepth();
  int[] rawDepth2 = kinect2b.getRawDepth();
  int[] rawDepth = new int[rawDepth1.length + rawDepth2.length];
  for (int x = 0; x < KINECT_WIDTH * 2; x++) {
    for (int y = 0; y < KINECT_HEIGHT; y++) {
      int index = x + y * KINECT_WIDTH * 2;
      if (x < KINECT_WIDTH) {
        int index1 = x + y * KINECT_WIDTH;
        rawDepth[index] = rawDepth1[index1];
      } else {
        int index2 = (x - KINECT_WIDTH) + y * KINECT_WIDTH;
        rawDepth[index] = rawDepth2[index2];
      }
    }
  }
  PImage smoothImage = getDenoisedDepthImage(rawDepth);
  image(smoothImage,0,0);
}
