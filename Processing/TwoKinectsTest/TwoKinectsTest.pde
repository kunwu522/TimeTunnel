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

File[] files;

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

  // File directory = new File("/Users/tony/Work/TimeTunnel/Processing/TwoKinectsTest/data");
  // if (!directory.isDirectory()) {
  //   println("Error, can not open data directory.");
  //   exit();
  //   return;
  // }
  // files = directory.listFiles();
  // if (files == null || files.length == 0) {
  //   println("Error, No files");
  //   exit();
  //   return;
  // }

  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(1024,424,RGB);
  }
}

int mode = 0;
void draw() {
  switch (mode) {
    case 0:
      recordKinect();
      break;
    case 1:
      displayKinectSmoothDepth();
      break;
    case 2:
      displayDataFiles();
      break;
    default:
      break;
  }
}

boolean checkKinect(Kinect2 kinect2) {
  return kinect2.depthWidth == KINECT_WIDTH
          && kinect2.depthHeight == KINECT_HEIGHT;
}
