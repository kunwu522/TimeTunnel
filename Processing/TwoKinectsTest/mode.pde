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
