//import com.dcconcept.*;

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import java.util.*;

final static boolean IS_ONE_KINECT = true;

//DCLogger dcLogger;

//List<Kinect2> kinects = new ArrayList();
// For one kinect
Kinect2 kinect2;
// For two kinect
Kinect2 kinect2a;
Kinect2 kinect2b;

PImage background;
PImage smoothImage;
PImage display;
PImage previous;

GaussianFilter filter;
ArrayList<Blob> blobs = new ArrayList<Blob>();

LinePatternView linePattern;

int depthWidth = 0;
int depthHeight = 0;

void setup(){
  //size(1024, 848);
  size(1024, 848);
  
  if (IS_ONE_KINECT) {
    kinect2 = new Kinect2(this);
    depthWidth = kinect2.depthWidth;
    depthHeight = kinect2.depthHeight;
    
    kinect2.initDepth();
    kinect2.initDevice();
  } else {
    kinect2a = new Kinect2(this);
    kinect2b = new Kinect2(this);
    
    depthWidth = kinect2a.depthWidth + kinect2b.depthWidth;
    depthHeight = kinect2a.depthHeight;
    
    kinect2a.initDepth();
    kinect2b.initDepth();
    kinect2a.initDevice(0);
    kinect2b.initDevice(1);
  }
  
  filter = new GaussianFilter(1, 7, depthWidth, depthHeight);
  
  //dcLogger = new DCLogger(this, "DCKinectCapturer");
  //Kinect2 kinect = new Kinect2(this);
  //int kinectCount = kinect.getNumKinects();
  //if (kinectCount <= 0) {
  //  println("Error, this is no available kinect.");
  //  return;
  //}
  //for (int i = 0; i < kinectCount; i++) {
  //  Kinect2 k = new Kinect2(this);
  //  k.initDepth();-
  //  k.initDevice(i);
  //  kinects.add(k);
  //}
  
  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(depthWidth, depthHeight, RGB);
  }
  display = createImage(depthWidth, depthHeight, RGB);
  smoothImage = createImage(depthWidth, depthHeight, RGB);
  
  linePattern = new LinePatternView(depthWidth, depthHeight, 5);
}

void draw() {
  if (IS_ONE_KINECT) {
    oneKinectDraw();
  } else {
    drawTwoKinects();
  }
}

void oneKinectDraw() {
  image(kinect2.getDepthImage(), 0, 0);
  smoothImage.loadPixels();
  int[] smoothDepth = filterRawDepthArray(kinect2.getRawDepth());
  //int[] smoothDepth = comparePreviousDepth(filterRawDepthArray(kinect2.getRawDepth()));
  //int[] smoothDepth = zeroDepthFilling(weightedMovingAverage(filterRawDepthArray(kinect2.getRawDepth())), 10);
  
  //int[] rawDepth = kinect2.getRawDepth();
  //int[] gaussionFilteredDepth = filter.filter(kinect2.getRawDepth());
  
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      int d = smoothDepth[index];      
      float rate = 0;
      if (d != 0) {
        rate = float(4500 - d) / 4500.0;
      }
      smoothImage.pixels[index] = color(255 * rate, 255 * rate, 255 * rate);
    }
  }
  smoothImage.updatePixels();
  image(smoothImage, 512, 0);
  
  
  buildDisplayImage(smoothImage);
 
  //for (Blob b: blobs) {
  //  if (b.size() > 500) {
  //    b.show();
  //  }
  //}
  image(display, 0, 424);
  
  blobDetection(display);
  
  fill(0, 255, 0);
  ellipse(averageX, averageY + 424, 20, 20);
  
  linePattern.update(averageX, averageY);
  image(linePattern.image, 512, 424);
  //if (mouseX > 512 && mouseY < 424) {
  //  displayColor(smoothImage.pixels[mouseX - 512 + mouseY * kinect2.depthWidth]);
  //}
}

void drawTwoKinects() {
  //image(kinect2a.getDepthImage(), 0, 0);
  //image(kinect2b.getDepthImage(), 512, 0);
  
  int[] smoothDepth1 = filterRawDepthArray(kinect2a.getRawDepth());
  int[] smoothDepth2 = filterRawDepthArray(kinect2b.getRawDepth());
  int[] smoothDepth = new int[smoothDepth1.length + smoothDepth2.length];
  for (int i = 0; i < smoothDepth1.length + smoothDepth2.length; i++) {
    int x = i % depthWidth;
    int y = (i - x) / depthWidth;
    
    if (x < 512) {
      smoothDepth[i] = smoothDepth1[x + y * 512];
    } else {
      x = x - 512;
      smoothDepth[i] = smoothDepth2[x + y * 512];
    }
  }
  
  for (int x = 0; x < depthWidth; x++) {
    for (int y = 0; y < depthHeight; y++) {
      int index = x + y * depthWidth;
      int d = smoothDepth[index];      
      float rate = 0;
      if (d != 0) {
        rate = float(4500 - d) / 4500.0;
      }
      smoothImage.pixels[index] = color(255 * rate, 255 * rate, 255 * rate);
    }
  }
  smoothImage.updatePixels();
  image(smoothImage, 0, 0);
  
  
  buildDisplayImage(smoothImage);
  image(display, 0, 424);
  
  linePattern.update(averageX, averageY);
  image(linePattern.image, 0, 848);
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
void buildDisplayImage(PImage image) {
  display.loadPixels();
  for (int x = 0; x < depthWidth; x++) {
    for (int y = 0; y < depthHeight; y++) {
      int offset = x + y * depthWidth;
      if (isBlobDiff(background, image, x, y, 5)) {
        display.pixels[offset] = color(255);
        //sumX += x;
        //sumY += y;
        //count++;
        //boolean found = false;
        //for (Blob b : blobs) {
        //  if (b.isNear(x, y)) {
        //    b.add(x, y);
        //    found = true;
        //    break;
        //  }
        //}
        //if (!found) {
        //  Blob b = new Blob(x, y);
        //  blobs.add(b);
        //}
      } else {
        display.pixels[offset] = 0;
      }
    }
  }
  //println("############ Blob num:" + blobs.size());
  display.updatePixels();
  //averageX = sumX / count;
  //averageY = sumY / count;
}

void blobDetection(PImage image) {
  int sumX = 0;
  int sumY = 0;
  float count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      color c = image.pixels[index];
      if (c == color(255)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
        //println("fasdfasdf");
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

boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  boolean isDiff = true;
  
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < depthWidth 
        && nearY >= 0 && nearY < depthHeight) {
        int nearIndex = nearX + nearY * depthWidth;
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
  if (IS_ONE_KINECT) {
    background = get(512, 0, 512, 424);
  } else {
    background = get(0, 0, 1024, 424);
  }
  background.save("image/background.jpg");
  println("Updated background image successful");
}

boolean cmdPressed = false;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = true;
  } else {
    if (cmdPressed && key == 'b') {
      saveBackgounndImage();
    } else if (cmdPressed && key == 'i') {
      innerBandThreshold++;
    } else if (cmdPressed && key =='u') {
      innerBandThreshold--;
    } else if (cmdPressed && key == 'o') {
      outerBandThreshold++;
    } else if (cmdPressed && key == 'p') {
      outerBandThreshold--;
    }
  }
}

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