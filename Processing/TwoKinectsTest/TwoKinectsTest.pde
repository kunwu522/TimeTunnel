import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import java.util.*;

final int TUNNEL_WIDTH = 1024;
final int TUNNEL_HEIGHT = 620;
final int KINECT_WIDTH = 512;
final int KINECT_HEIGHT = 424;

Kinect2 kinect2a;
Kinect2 kinect2b;

PImage background;

void setup() {
  size(1024, 424);
  kinect2a = new Kinect2(this);
  kinect2b = new Kinect2(this);

  if (kinect2a.getNumKinects() != 2) {
    println("Error, number of kinects is not enough.");
    exit();
    return;
  }

  kinect2a.initDepth();
  kinect2a.initDevice(0);
  kinect2b.initDepth();
  kinect2b.initDevice(1);

  if (!checkKinect(kinect2a) || !checkKinect(kinect2b)) {
    println("Error, invalid kinect.");
    exit();
    return;
  }

  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(1024,424,RGB);
  }
}

void draw() {
  int[] rawDepth1 = kinect2a.getRawDepth();
  int[] rawDepth2 = kinect2b.getRawDepth();
  int[] rawDepth = new int[rawDepth1.length + rawDepth2.length];
  for (int i = 0; i < rawDepth.length; i++) {
    int x = i % KINECT_WIDTH;
    int y = (i - x) / KINECT_WIDTH;
    if (x < KINECT_WIDTH) {
      rawDepth[i] = kinect2a.getRawDepth[x + y * KINECT_WIDTH];
    } else {
      x = x - KINECT_WIDTH;
      rawDepth[i] = kinect2b.getRawDepth[x + y * KINECT_WIDTH];
    }
  }
  PImage smoothImage = getDenoisedDepthImage(rawDepth);
  image(smoothImage,0,0);
}

boolean checkKinect(Kinect2 kinect2) {
  return kinect2.depthWidth == KINECT_WIDTH
          && kinect2.depthHeight == KINECT_HEIGHT;
}
