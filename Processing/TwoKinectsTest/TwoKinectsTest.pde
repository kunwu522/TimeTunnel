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

int objectX = 0;
int objectY = 0;

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
    background = createImage(KINECT_WIDTH * 2,KINECT_HEIGHT,RGB);
  }
}

void draw() {
  background(0);
  int[] rawDepth1 = kinect2a.getRawDepth();
  int[] rawDepth2 = kinect2b.getRawDepth();
  int[] rawDepth = new int[rawDepth1.length + rawDepth2.length];
  int t1 = millis();
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
  int t2 = millis();
  PImage smoothImage = getDenoisedDepthImage(rawDepth);
  if (saveBackground) {
    background = smoothImage;
    background.save("image/background.jpg");
    saveBackground = false;
  }
  int t3 = millis();
  detectBlob(smoothImage);
  int t4 = millis();
  //image(smoothImage,0,0);
  fill(0, 0, 255);
  noStroke();
  ellipse(objectX, objectY, 20, 20);
  println("Merge depth: " + (t2 - t1) + ", denoise: " + (t3 - t2) + ", detection: " + (t4 - t3));
}

boolean checkKinect(Kinect2 kinect2) {
  return kinect2.depthWidth == KINECT_WIDTH
          && kinect2.depthHeight == KINECT_HEIGHT;
}