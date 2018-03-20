import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 
import org.openkinect.tests.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class KinectTest extends PApplet {








final int KINECT_DEPTH_WIDTH = 512;
final int KINECT_DEPTH_HEIGHT = 424;

// For one kinect
Kinect2 kinect2;

PImage background;
PImage smoothImage;

ArrayList<Blob> blobs = new ArrayList<Blob>();

public void setup(){
  //size(1024, 848);
  
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
}

public void draw() {
  image(kinect2.getDepthImage(), 0, 0);
  int t1 = millis();
  smoothImage.loadPixels();
  filterRawDepthArray(kinect2.getRawDepth());
  smoothImage.updatePixels();
  int t2 = millis();
  detectBlob(smoothImage);
  int t3 = millis();
  println("Step 1 time: " + (t2 - t1) + ", step 2 time: " + (t3 - t2));
  fill(0, 255, 0);
  ellipse(averageX, averageY, 20, 20);
}

public int diffColor(int c1, int c2) {
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
public void detectBlob(PImage image) {
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      int index = x + y * KINECT_DEPTH_WIDTH;
      if (isBlobDiff(background, image, x, y, 5)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
      }
    }
  }
  if (foundBlob) {
    averageX = PApplet.parseInt(sumX / count);
    averageY = PApplet.parseInt(sumY / count);
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

public boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  boolean isDiff = true;

  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_DEPTH_WIDTH
        && nearY >= 0 && nearY < KINECT_DEPTH_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_DEPTH_WIDTH;
        int bgColor = background.pixels[nearIndex];
        int currentColor = image.pixels[nearIndex];
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

public void filterRawDepthArray(int[] rawDepth) {
  // int[] smoothDepth = new int[rawDepth.length];
    int widthBound = kinect2.depthWidth - 1;
    int heightBound = kinect2.depthHeight - 1;
    int smoothDepth = 0;

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
                    smoothDepth = depth;
                }
                //println("################ Finish to smooth");
            } else {
                smoothDepth = rawDepth[offset];
            }

            float rate = 0;
            if (smoothDepth != 0) {
              rate = PApplet.parseFloat(4500 - smoothDepth) / 4500.0f;
            }
            smoothImage.pixels[offset] = color(255 * rate, 255 * rate, 255 * rate);
        }
    }
}

public int[] zeroDepthFilling(int[] depth, int threshold) {
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

public int[] comparePreviousDepth(int[] depthArray) {
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

public int[] weightedMovingAverage(int[] depthArray) {
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

public PImage denosieDepthImage(PImage image, int[] rawDepth, int averageThreshold, int medianThreshold) {
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
              int c = smoothedImage.pixels[searchX + searchY * depthWidth];
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

public PImage medianFilter(PImage image, int templateSize) {
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
          int c = image.pixels[searchX + searchY * image.width];
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

public void saveBackgounndImage() {
  background = get();
  background.save("image/background.jpg");
  println("Updated background image successful");
}

boolean cmdPressed = false;
public void keyPressed() {
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

public void keyReleased() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = false;
  }
}

public void displayThreshold() {
  fill(255, 0, 0);
  text("inner band threshold: " + innerBandThreshold, 20, 20);
  fill(255, 0, 0);
  text("outer band threshold: " + outerBandThreshold, 20, 40);
  fill(255, 0, 0);
  text("avarage frames count: " + avarageThreshold, 20, 60);
  fill(255, 0, 0);
  text("avarage queue size: " + averageQueue.size(), 20, 80);
}

public void displayInfo(int rawDepth, int filterDepth) {
  fill(255, 0, 0);
  text("mouse: " + mouseX + ":" + mouseY, 20, 20);
  fill(255, 0, 0);
  text("raw depth: " + rawDepth, 20, 40);
  fill(255, 0, 0);
  text("filtered depth: " + filterDepth, 20, 60);
}

public void displayColor(int c) {
  fill(255, 0, 0);
  text("mouse: " + mouseX + ":" + mouseY, 20, 20);
  fill(255, 0, 0);
  text("raw color: " + red(c) + "," + green(c) + "," + blue(c), 20, 40);
}
class Blob {
  float minX;
  float minY;
  float maxX;
  float maxY;
  
  ArrayList<PVector> points;
  
  public Blob(float x, float y) {
    minX = x;
    minY = y;
    maxX = x;
    maxY = y;
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }
  
  public void show() {
    stroke(0, 255, 0);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minX, minY, maxX, maxY);
  }
  
  public void add(float x, float y) {
    points.add(new PVector(x, y));
    minX = min(minX, x);
    minY = min(minY, y);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
  }
  
  public float size() {
    return (maxX - minX) * (maxY - minY);
  }
  
  public boolean isNear(float x, float y) {
    float d = 1000000;
    for (PVector v : points) {
      float tempD = distSq(x, y, v.x, v.y);
      if (tempD < d) {
        d = tempD;
      }
    }
    
    if (d < 10 * 10) {
      return true;
    } else {
      return false;
    }
  }
  
  private float distSq(float x1, float y1, float x2, float y2) {
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
  }
}
class GaussianFilter {
  
  private double[] kernel;
  private int kernelSize;
  private int width;
  private int height;
  
  public GaussianFilter(float sigma, int kernelSize, int width, int height) {
    this.kernelSize = kernelSize;
    this.width = width;
    this.height = height;
    
    kernel = new double[kernelSize * kernelSize];
    for (int y = 0; y < kernelSize; y++) {
      double y2c = y - (kernelSize - 1) / 2;
      for (int x = 0; x < kernelSize; x++) {
        double x2c = x - (kernelSize - 1) / 2; 
        kernel[x + y * kernelSize] = 1 / (2 * Math.PI * sigma * sigma) 
                    * Math.exp(- (x2c * x2c + y2c * y2c) / (2 * sigma * sigma));
      }
    }
    
  }
  
  public int[] filter(int[] input) {
    int[] result = new int[input.length];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int value = 0;
        int overflow = 0;
        int kernelHalf = (kernelSize - 1) / 2;
        for (int j = -kernelHalf; j <= kernelHalf; j++) {
          for (int i = -kernelHalf; i <= kernelHalf; i++) {
            int searchX = x + i;
            int searchY = y + j;
            int kernelIndex = i + j * kernelSize + ((kernelSize * kernelSize) - 1) / 2;
            if (searchX < 0 || searchX >= width || searchY < 0 || searchY >= height) {
              overflow += kernel[kernelIndex];
              continue;
            }
            int v = input[searchX + searchY * width];
            if (v == 0) {
              v = 4500;
            }
            value += (int)(v * kernel[kernelIndex]);
          }
        }
        
        if (overflow > 0) {
          value = 0;
          for (int j = -kernelHalf; j <= kernelHalf; j++) {
            for (int i = -kernelHalf; i <= kernelHalf; i++) {
              int searchX = x + i;
              int searchY = y + j;
              int kernelIndex = i + j * kernelSize + ((kernelSize * kernelSize) - 1) / 2;
              if (searchX < 0 || searchX >= width || searchY < 0 || searchY >= height) {
                continue;
              }
              int v = input[searchX + searchY * width];
              if (v == 0) {
                v = 4500;
              }
              value += (int)(v * kernel[kernelIndex] * (1 / (1 - overflow)));
            }
          }
        }
        result[x + y * width] = value;
      }
    }
    //println("Here i am");
    return result;
  }
}
class LinePatternView {
  //PImage image;
  PGraphics image;
  int lineWidth;
  
  float lastX = -1;
  float lastY = -1;
  
  LinePatternView(int width, int height, int lineWidth) {
    image = createGraphics(width, height);
    this.lineWidth = lineWidth;
  }
  
  public void update(float x, float y) {
    if (x == -1 && y == -1) {
      lastX = x;
      lastY = y;
      return;
    }
    
    if (lastX != -1 || lastY != -1) {
      x = lerp(lastX, x, 0.2f);
      y = lerp(lastY, y, 0.2f);
    }
    image.beginDraw();
    image.background(0);
    image.stroke(255);
    image.rect(x - lineWidth / 2, 0, lineWidth, image.height);
    image.endDraw();
    lastX = x;
    lastY = y;
  }
  
}
  public void settings() {  size(512, 424); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "KinectTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
