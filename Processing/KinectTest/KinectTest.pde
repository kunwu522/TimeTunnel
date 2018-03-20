import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import java.util.*;

final int KINECT_DEPTH_WIDTH = 512;
final int KINECT_DEPTH_HEIGHT = 424;

// For one kinect
Kinect2 kinect2;

PImage background;
PImage smoothImage;

ArrayList<Blob> blobs = new ArrayList<Blob>();

boolean printDepth = false;

void setup(){
  //size(1024, 848);
  size(512, 424);
  kinect2 = new Kinect2(this);
  if (kinect2.getNumKinects() == 0) {
    exit();
    return;
  }

  kinect2.initDepth();
  kinect2.initDevice();

  if (kinect2.depthWidth != KINECT_DEPTH_WIDTH
    || kinect2.depthHeight != KINECT_DEPTH_HEIGHT) {
    println("Error, Kinect depth size do not match");
    exit();
    return;
  }

  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(KINECT_DEPTH_WIDTH, KINECT_DEPTH_HEIGHT, RGB);
  }
  smoothImage = createImage(KINECT_DEPTH_WIDTH, KINECT_DEPTH_HEIGHT, RGB);

  //writer = createWriter("raw_depth.txt");
}

void draw() {
  //image(kinect2.getDepthImage(), 0, 0);
  //saveRawDepth(kinect2.getRawDepth());
    int t1 = millis();
    int[] rawDepth = kinect2.getRawDepth();
   int[] smoothDepth = filterRawDepthArray(kinect2.getRawDepth());
   int t2 = millis();
    smoothImage.loadPixels();
    for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
      for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
        int index = x + y * KINECT_DEPTH_WIDTH;
        int d = rawDepth[index];
        float rate = 0;
        if (d != 0) {
          rate = float(4500 - d) / 4500.0;
        }
        smoothImage.pixels[index] = color(255 * rate, 255 * rate, 255 * rate);
      }
    }
    smoothImage.updatePixels();
   int t3 = millis();
   detectBlob(smoothImage);
   int t4 = millis();
   println("Step 1 time: " + (t2 - t1) + ", step 2 time: " + (t3 - t2));
    image(smoothImage, 0, 0);
    if (printDepth) {
      printArray(rawDepth);
      exit();
    }
   fill(0, 255, 0);
   ellipse(averageX, averageY, 20, 20);
}

int diffColor(color c1, color c2) {
  int r1 = c1 >> 16 & 0xFF;
  int g1 = c1 >> 8 & 0xFF;
  int b1 = c1 & 0xFF;

  int r2 = c2 >> 16 & 0xFF;
  int g2 = c2 >> 8 & 0xFF;
  int b2 = c2 & 0xFF;


  return (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) + (b2-b1)*(b2-b1);
}


/******************************
*
*  Background subtraction
*
*
*******************************/
int averageX = 0;
int averageY = 0;
void detectBlob(PImage image) {
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      if (isBlobDiff(background, image, x, y, 3)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
      }
    }
  }
  if (foundBlob) {
    averageX = int(sumX / count);
    averageY = int(sumY / count);
  } else {
    averageX = -20;
    averageY = -20;
  }
}

// void buildDisplayImage(PImage image) {
//   display.loadPixels();
//   for (int x = 0; x < depthWidth; x++) {
//     for (int y = 0; y < depthHeight; y++) {
//       int offset = x + y * depthWidth;
//       if (isBlobDiff(background, image, x, y, 5)) {
//         display.pixels[offset] = color(255);
//         //sumX += x;
//         //sumY += y;
//         //count++;
//         //boolean found = false;
//         //for (Blob b : blobs) {
//         //  if (b.isNear(x, y)) {
//         //    b.add(x, y);
//         //    found = true;
//         //    break;
//         //  }
//         //}
//         //if (!found) {
//         //  Blob b = new Blob(x, y);
//         //  blobs.add(b);
//         //}
//       } else {
//         display.pixels[offset] = 0;
//       }
//     }
//   }
//   //println("############ Blob num:" + blobs.size());
//   display.updatePixels();
//   //averageX = sumX / count;
//   //averageY = sumY / count;
// }
//
// void blobDetection(PImage image) {
//   int sumX = 0;
//   int sumY = 0;
//   float count = 0;
//   boolean foundBlob = false;
//   for (int x = 0; x < kinect2.depthWidth; x++) {
//     for (int y = 0; y < kinect2.depthHeight; y++) {
//       int index = x + y * kinect2.depthWidth;
//       color c = image.pixels[index];
//       if (c == color(255)) {
//         sumX += x;
//         sumY += y;
//         count++;
//         foundBlob = true;
//         //println("fasdfasdf");
//       }
//     }
//   }
//
//   if (foundBlob) {
//     averageX = int(sumX / count);
//     averageY = int(sumY / count);
//   } else {
//     averageX = -20;
//     averageY = -20;
//   }
// }

boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  boolean isDiff = true;

  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_DEPTH_WIDTH
        && nearY >= 0 && nearY < KINECT_DEPTH_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_DEPTH_WIDTH;
        color bgColor = background.pixels[nearIndex];
        color currentColor = image.pixels[nearIndex];
        if (diffColor(bgColor, currentColor) < 30 * 30) {
          isDiff = false;
        }
      }
    }
  }

  //int diff =  diffColor(color(sumRedBg / count, sumGreenBg / count, sumBlueBg / count),
  //                color(sumRedC / count, sumGreenC / count, sumBlueC / count));
  //println("diff color is " + diff);
  return isDiff;
}

/******************************
*
*  Smooth depth image (denoise depth image)
*
*
*******************************/
int innerBandThreshold = 3;
int outerBandThreshold = 5;
int avarageThreshold = 30;

int[] filterRawDepthArray(int[] rawDepth) {
    int[] smoothDepth = new int[rawDepth.length];
    int widthBound = kinect2.depthWidth - 1;
    int heightBound = kinect2.depthHeight - 1;
    // int smoothDepth = 0;

    for (int x = 0; x < kinect2.depthWidth; x++) {
        for (int y = 0; y < kinect2.depthHeight; y++) {
            int offset = x + y * kinect2.depthWidth;
            if (rawDepth[offset] == 0) {
                Map<Integer, Integer> frequencyMap = new HashMap<Integer, Integer>();
                int innerBandCount = 0;
                int outerBandCount = 0;
                for (int i = -2; i < 3; i++) {
                    for (int j = -2; j < 3; j++) {
                        int nearX = x + i;
                        int nearY = y + j;
                        if (nearX >=0 && nearX <= widthBound
                            && nearY >=0 && nearY <= heightBound) {
                            int index = nearX + nearY * kinect2.depthWidth;
                            if (rawDepth[index] != 0) {
                                Integer depth = Integer.valueOf(rawDepth[index]);
                                if (frequencyMap.containsKey(depth)) {
                                    frequencyMap.put(depth, frequencyMap.get(depth) + 1);
                                } else {
                                    frequencyMap.put(depth, 1);
                                }

                                 if (i != 2 && i != -2 && j != -2 && j != -2) {
                                    innerBandCount++;
                                } else {
                                    outerBandCount++;
                                }
                            }
                        }
                    }
                }

                if (innerBandCount >= innerBandThreshold || outerBandCount >= outerBandThreshold) {
                    int depth = 0;
                    Object[] values = frequencyMap.values().toArray();
                    Arrays.sort(values, new Comparator<Object>() {
                        @Override
                        public int compare(Object o1, Object o2) {
                            Integer i1 = (Integer)o1;
                            Integer i2 = (Integer)o2;
                            if (i1.intValue() > i2.intValue()) {
                                return -1;
                            } else {
                                return 1;
                            }
                        }
                    });
                    for (Map.Entry<Integer, Integer> e : frequencyMap.entrySet()) {
                        if (e.getValue().intValue() == ((Integer)values[0]).intValue()) {
                            depth = e.getKey().intValue();
                            break;
                        }
                    }
                    smoothDepth[offset] = depth;
                }
                //println("################ Finish to smooth");
            } else {
                smoothDepth[offset] = rawDepth[offset];
            }

            // float rate = 0;
            // if (smoothDepth != 0) {
            //   rate = float(4500 - smoothDepth) / 4500.0;
            // }
            // smoothImage.pixels[offset] = color(255 * rate, 255 * rate, 255 * rate);
        }
    }
    return smoothDepth;
}

int[] zeroDepthFilling(int[] depth, int threshold) {
  int[] nonZeroDepth = new int[depth.length];
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      if (depth[index] == 0) {
        int maxDepth = 0;
        for (int i = -threshold; i <= threshold; i++) {
          for (int j = -threshold; j <= threshold; j++) {
            int neighborX = x + i;
            int neighborY = y + j;
            if (neighborX >= 0 && neighborX < kinect2.depthWidth
              && neighborY >= 0 && neighborY < kinect2.depthHeight) {
                int neighborIndex = neighborX + neighborY * kinect2.depthWidth;
                if (depth[neighborIndex] > maxDepth) {
                  maxDepth = depth[neighborIndex];
                }
            }
          }
        }
        nonZeroDepth[index] = maxDepth;
      } else {
        nonZeroDepth[index] = depth[index];
      }
    }
  }
  return nonZeroDepth;
}

Queue<int[]> averageQueue = new LinkedList<int[]>();

int[] comparePreviousDepth(int[] depthArray) {
  averageQueue.add(depthArray);
  int[] result = new int[depthArray.length];
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      boolean hasNosie = false;
      int sum = 0;
      int count = 0;
      for (int[] depth : averageQueue) {
        if (depth[index] == 0) {
          hasNosie = true;
        } else {
          sum += depth[index];
          count++;
        }

      }
      if (hasNosie && count > 0) {
        result[index] = sum / count;
      } else {
        result[index] = depthArray[index];
      }
    }
  }

  if (averageQueue.size() > avarageThreshold) {
    averageQueue.remove();
  }
  return result;
}

int[] weightedMovingAverage(int[] depthArray) {
  averageQueue.add(depthArray);

  if (averageQueue.size() > avarageThreshold) {
    averageQueue.remove();
  }

  int[] averagedDepthArray = new int[depthArray.length];
  int[] sumDepthArray = new int[depthArray.length];

  int denominator = 0;
  int count = 1;
  for (int[] depth : averageQueue) {
    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        int index = x + y * kinect2.depthWidth;
        int d = depth[index] != 0 ? depth[index] : 4500;
        sumDepthArray[index] += d * count;
      }
    }
    denominator += count;
    count++;
  }
  for (int i = 0; i < depthArray.length; i++) {
    if (depthArray[i] == 0) {
      averagedDepthArray[i] = sumDepthArray[i] / denominator;
    } else {
      averagedDepthArray[i] = depthArray[i];
    }
  }

  return averagedDepthArray;
}

PImage denosieDepthImage(PImage image, int[] rawDepth, int averageThreshold, int medianThreshold) {
  int depthWidth = image.width;
  int depthHeight = image.height;
  PImage smoothedImage = image.copy();
  smoothedImage.loadPixels();
  for (int x = 0; x < depthWidth; x++) {
    for (int y = 0; y < depthHeight; y++) {
      int offset = x + y * depthWidth;
      int d = rawDepth[offset];
      if (d == 0) {
        float red = 0, green = 0, blue = 0;
        for (int i = -averageThreshold; i <= averageThreshold; i++) {
          for (int j = -averageThreshold; j <= averageThreshold; j++) {
            int searchX = x + i;
            int searchY = y + j;
            if (searchX >= 0 && searchX <= depthWidth - 1
               && searchY >= 0 && searchY <= depthHeight -1) {
              color c = smoothedImage.pixels[searchX + searchY * depthWidth];
              int r = c >> 16 & 0xFF;
              int g = c >> 8 & 0xFF;
              int b = c & 0xFF;
              //println("red: " + r + " green: " + g + " blue: " + b);
              red += r;
              green += g;
              blue += b;
            }
          }
        }
        int length = (averageThreshold * 2 + 1) * (averageThreshold * 2 + 1);
        smoothedImage.pixels[offset] = color(red / length, green / length, blue / length);
      }
    }
  }
  smoothedImage.updatePixels();
  return medianFilter(smoothedImage, medianThreshold);
}

PImage medianFilter(PImage image, int templateSize) {
  if (templateSize % 2 == 0) {
    println("Invalid template size, has to been 3, 5, 7... etc");
    return null;
  }
  PImage filtedImage = createImage(image.width, image.height, RGB);

  image.loadPixels();
  filtedImage.loadPixels();
  int[] redArray = new int[templateSize * templateSize];
  int[] greenArray = new int[templateSize * templateSize];
  int[] blueArray = new int[templateSize * templateSize];

  for (int x = (templateSize - 1) / 2; x < image.width - (templateSize - 1) / 2; x++) {
    for (int y = (templateSize - 1) / 2; y < image.height - (templateSize - 1) / 2; y++) {
      int offset = x + y * image.width;
      int index = 0;
      for (int i = - (templateSize - 1) / 2; i <= (templateSize - 1) / 2; i++) {
        for (int j = - (templateSize - 1) / 2; j <= (templateSize -1) / 2; j++) {
          int searchX = x + i;
          int searchY = y + j;
          color c = image.pixels[searchX + searchY * image.width];
          redArray[index] = c>>16 & 0xFF;
          greenArray[index] = c>>8 & 0xFF;
          blueArray[index] = c & 0xFF;
          index++;
        }
      }
      Arrays.sort(redArray);
      Arrays.sort(greenArray);
      Arrays.sort(blueArray);
      filtedImage.pixels[offset] = color(redArray[4], greenArray[4], blueArray[4]);
    }
  }
  filtedImage.updatePixels();
  return filtedImage;
}


/******************************
*
*  For Control
*
*
*******************************/

void saveBackgounndImage() {
  // background = get();
  // background.save("image/background.jpg");
  int[] rawDepth = kinect2.getRawDepth();
  byte[] data = new byte[rawDepth.length * 2];
  int offset = 0;
  for (int i = 0; i < rawDepth.length; i++) {
    data[offset++] = (byte)(rawDepth[i] >> 8 & 0xFF);
    data[offset++] = (byte)(rawDepth[i] & 0xFF);
  }
  saveBytes("data/background.dat",data);

  println("Updated background image successful");
}

boolean cmdPressed = false;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = true;
  } else {
    if (cmdPressed && key == 'b') {
      saveBackgounndImage();
    } else if (cmdPressed && key == 's') {
      smoothImage.save("image/smooth" + millis() + ".jpg");
    } else if (cmdPressed && key == 'p') {
      //writeToFile();
    } else if (cmdPressed && key == 'e') {
      printDepth = true;
    }
  }
}

//void writeToFile() {
//  writer.flush();
//  writer.close();
//  exit();
//}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = false;
  }
}

void displayThreshold() {
  fill(255, 0, 0);
  text("inner band threshold: " + innerBandThreshold, 20, 20);
  fill(255, 0, 0);
  text("outer band threshold: " + outerBandThreshold, 20, 40);
  fill(255, 0, 0);
  text("avarage frames count: " + avarageThreshold, 20, 60);
  fill(255, 0, 0);
  text("avarage queue size: " + averageQueue.size(), 20, 80);
}

void displayInfo(int rawDepth, int filterDepth) {
  fill(255, 0, 0);
  text("mouse: " + mouseX + ":" + mouseY, 20, 20);
  fill(255, 0, 0);
  text("raw depth: " + rawDepth, 20, 40);
  fill(255, 0, 0);
  text("filtered depth: " + filterDepth, 20, 60);
}

void displayColor(color c) {
  fill(255, 0, 0);
  text("mouse: " + mouseX + ":" + mouseY, 20, 20);
  fill(255, 0, 0);
  text("raw color: " + red(c) + "," + green(c) + "," + blue(c), 20, 40);
}

void saveRawDepth(int[] rawDepth) {
  byte[] data = new byte[rawDepth.length * 2];
  int offset = 0;
  for (int i = 0; i < rawDepth.length; i++) {
    data[offset++] = (byte)(rawDepth[i] >> 8 & 0xFF);
    data[offset++] = (byte)(rawDepth[i] & 0xFF);
  }
  saveBytes("data/raw_depth" + millis() + ".dat",data);
}