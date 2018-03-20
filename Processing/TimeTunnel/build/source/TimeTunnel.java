import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import java.io.*; 
import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 
import org.openkinect.tests.*; 
import java.util.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TimeTunnel extends PApplet {




static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 620;
final int NUM_STRIPS = 10;
final int NUM_LEDS_PER_STRIP = 620;

final boolean launchTeensy = false;
final boolean launchKinect = false;

//PGraphics canvas;

public void setup() {
  
  setupStrips();
  //canvas = createGraphics(SCREEN_WIDTH, SCREEN_HEIGHT);
  if (launchKinect) {
    setupKinect();
  }
  setupKinect();
  if (launchTeensy) {
    setupTeensy();
  }
}

public void draw() {
  background(169, 169, 169);
  if (launchKinect) {
    drawKinect();
  }
  drawStrips();
  drawMode();

  if (launchTeensy) {
    PImage display = get(0, 0, 512, 620);
    for (Teensy teensy : teensys) {
      teensy.send(display);
    }
  }
  //delay(50);
}

//void exit() {
//  for (Teensy teensy : teensys) {
//    if (teensy != null) teensy.disconnect();
//  }
//  println("Time Tunnel exit.");
//  super.exit();
//}

//void stop() {
//  println("Time Tunnel stop.");
//  super.stop();
//}
/******************************
*  
*  For Control
*
*
*******************************/

public void saveBackgounndImage() {
  background = get(0, 620, 512, 424);
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
int averageX = 0;
int averageY = 0;

int x1;
int x2;

public void drawMode() {
  int mode = 0;
  switch (mode) {
    case 0: 
      drawCursor();
      break;
    case 1:
      drawRect();
      break;
    case 2:
      drawLine();
      break;
    default:
      break;
  }
}

public void drawLine() {
  int x = launchKinect ? averageX : mouseX;
  x1 = (int)lerp(x1, x, 0.05f);
  stroke(255);
  strokeWeight(40);
  line(x1, 0, x1, SCREEN_HEIGHT);
}

public void drawCursor() {
  int x = launchKinect ? averageX : mouseX;
  x1 = (int)lerp(x1, x, 0.05f); //<>//
  //println("blob x: " + averageX);
  x2 = (int)lerp(x2, x1, 0.1f);
  
  noStroke();
  //float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  if (x1 > x2) {
    setGradient(x2, 0, tempWidth, (float)SCREEN_HEIGHT, color(128, 128, 128), color(255), X_AXIS);
  } else {
    setGradient(x1, 0, tempWidth, (float)SCREEN_HEIGHT, color(255), color(128, 128, 128), X_AXIS);
  }
  //for (int i = 0; i < tempWidth; i++) {
  //  stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
  //  if (x1 > x2) {
  //    line(x1 - i, 0, x1 - i, SCREEN_HEIGHT);
  //  } else {
  //    line(x1 + i, 0, x1 + i, SCREEN_HEIGHT);
  //  }
  //}
}

public void drawRect() {
  noStroke();
  fill(color(0, 0, 255));
  ellipse(mouseX, mouseY, 20, 20);
}


int Y_AXIS = 1;
int X_AXIS = 2;
public void setGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}







Kinect2 kinect2;

PImage background;
PImage smoothImage;
PImage display;
PImage previous;

final int KINECT_WIDTH = 512;
final int KINECT_HEIGHT = 424;

public void setupKinect() {
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  
  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
  }
  display = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
  smoothImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
}

public void drawKinect() {
  smoothImage.loadPixels();
  int[] smoothDepth = filterRawDepthArray(kinect2.getRawDepth());
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      int depth = smoothDepth[index];
      float rate = 0;
      if (depth != 0) {
        rate = PApplet.parseFloat(4500 - depth) / 4500.0f;
      }
      smoothImage.pixels[index] = color( 255 * rate, 255 * rate, 255 * rate);
    }
  }
  smoothImage.updatePixels();
  //image(smoothImage, 0, 620);
  buildDisplayImage(smoothImage);
  //image(display, 512, 620);
  
  blobDetection(display);
  
  //fill(0, 255, 0);
  //ellipse(averageX + 512, averageY + 620, 20, 20);
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

public int[] filterRawDepthArray(int[] rawDepth) {
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

/******************************
*  
*  Background subtraction
*
*
*******************************/
public void buildDisplayImage(PImage image) {
  display.loadPixels();
  for (int x = 0; x < KINECT_WIDTH; x++) {
    for (int y = 0; y < KINECT_HEIGHT; y++) {
      int offset = x + y * KINECT_WIDTH;
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

public void blobDetection(PImage image) {
  int sumX = 0;
  int sumY = 0;
  float count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      int c = image.pixels[index];
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
    averageX = PApplet.parseInt(sumX / count);
    averageY = PApplet.parseInt(sumY / count);
  } else {
    averageX = -20;
    averageY = -20;
  }
}

public boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  boolean isDiff = true;
  
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_WIDTH 
        && nearY >= 0 && nearY < KINECT_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_WIDTH;
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

/*************************
 *
 *  Common Functions 
 *
 *************************/
public int diffColor(int c1, int c2) {
  int r1 = c1 >> 16 & 0xFF;
  int g1 = c1 >> 8 & 0xFF;
  int b1 = c1 & 0xFF;
  
  int r2 = c2 >> 16 & 0xFF;
  int g2 = c2 >> 8 & 0xFF;
  int b2 = c2 & 0xFF;
  
  
  return (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) + (b2-b1)*(b2-b1);
}

static float LED_WIDTH = 10;

int totalStripsNum = 0;

LedStrip[] strips = new LedStrip[NUM_STRIPS];

public void setupStrips() {
  int interval = floor(SCREEN_WIDTH / (NUM_STRIPS + 1));
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new LedStrip(i, NUM_LEDS_PER_STRIP, interval + (interval * i));
  }
}

public void drawStrips() {
  for (LedStrip strip : strips) {
    strip.drawStrip();
    //strip.drawStrip(canvas);
  }
  //for (Teensy teensy : teensys) {
  //  for (LedStrip strip : teensy.ledStrips) {
  //    strip.drawStrip(canvas);
  //  }
  //}
}


class LedStrip {
  int id;
  int ledNum;
  int offset;
  
  public LedStrip(int id, int ledNum, int offset) {
    this.id = id;
    this.ledNum = ledNum;
    this.offset = offset;
  }
  
  public void drawStrip(PGraphics canvas) {
    canvas.noFill();
    canvas.stroke(0, 0, 0);
    canvas.strokeWeight(2);
    canvas.line(offset, 0, offset, SCREEN_HEIGHT);
  }
  
  public void drawStrip() {
    noFill();
    stroke(0);
    strokeWeight(2);
    line(offset, 0, offset, SCREEN_HEIGHT);
  }
  
  private boolean isEqualColorWithThreshold(int c1, int c2) {
    int r1 = c1 >> 16 & 0xFF;
    int g1 = c1 >> 8 & 0xFF;
    int b1 = c1 & 0xFF;
    int r2 = c2 >> 16 & 0xFF;
    int g2 = c2 >> 8 & 0xFF;
    int b2 = c2 & 0xFF;
    
    if (r1 != g1 || r1 != b1 || b1 != g1) {
      println("Error, invalid color: " + r1 + "-" + g1 + "-" + b1);
      return true;
    }
    
    if (r2 != g2 || r2 != b2 || g2 != b2) {
      println("Error, invalid color: " + r2 + "-" + g2 + "-" + b2);
      return true;
    }
    
    if (abs(r2 - r1) > 30) {
      return false;
    } else {
      return true;
    }
  }
  
  
  private int compareColors(int c1, int c2) {
    int r1 = c1 >> 16 & 0xFF;
    int g1 = c1 >> 8 & 0xFF;
    int b1 = c1 & 0xFF;
    int r2 = c2 >> 16 & 0xFF;
    int g2 = c2 >> 8 & 0xFF;
    int b2 = c2 & 0xFF;
    
    if (r1 == r2 && g1 == g2 && b1 == b2) {
      return 0;
    } else if (r1 > r2 || g1 > g2 || b1 > b2) {
      return 1;
    } else {
      return -1;
    }
  }
}


final int TEENSY_NUM_STRIPS = 5;
final int TEENSY_NUM_LEDS = 620;
final int BAUD_RATE = 921600;

Teensy[] teensys = new Teensy[2];

public void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem3071001");
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem3654571");
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem3162511");
  teensys[1] = new Teensy(this, "/dev/cu.usbmodem2885451");
  
  println("Teensy setup done!");
  println();
}

class Teensy {
  int id;
  String name;
  Serial port;
  String portName;
  LedStrip[] ledStrips = new LedStrip[TEENSY_NUM_STRIPS];
  //byte[] data = new byte[TEENSY_NUM_STRIPS * TEENSY_NUM_LEDS * 3 + 1];
  byte[] data = new byte[TEENSY_NUM_STRIPS * 3 + 1];
  
  SendDataThread sendThread;
  RecieveDataThread recieveThread;
  
  
  Teensy(PApplet parent, String name) {
    portName = name;
    try {
      port = new Serial(parent, portName, 921600);
      if (port == null) {
        println("Error, port is null.");
        throw new NullPointerException();
      }
      //port.bufferUntil('\n');
      port.write('?');
    } catch (Throwable e) {
      println("Serial Port " + portName + " does not exist.");
      exit();
      return;
    }
    
    delay(100);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + portName + " is not responding");
      exit();
      return;
    }
    String param[] = line.split(",");
    if (param.length != 3) {
      println("Error, port " + portName + " invalid reponse: " + line);
      exit();
      return;
    }
    println("Response: " + line);
    id = Integer.parseInt(param[0]);
    name = "teensy" + id;
    int stripsNum = Integer.parseInt(param[1]);
    int ledsNum = Integer.parseInt(param[2].trim());
    if (stripsNum != TEENSY_NUM_STRIPS || ledsNum != TEENSY_NUM_LEDS) {
      println("Error -- teensy: " + name + ", the number of leds and strips is not match.");
      exit();
      return;
    }
    
    for (int i = 0; i < ledStrips.length; i++) {
      ledStrips[i] = strips[i + id * TEENSY_NUM_STRIPS];
    }
    
    sendThread = new SendDataThread(name + "_send_thread", port);
    sendThread.start();
    
    recieveThread = new RecieveDataThread(name + "_recieve_thread", port);
    recieveThread.start();
    
    println(name + " setup.");
    println();
  }
  
  //PImage lastImage;
  //boolean isSame = true;
  public void send(PImage image) {
    update(image);
    data[0] = '*';
    //port.write(data);
    sendThread.send(data);
  }
  
  //public void disconnect() {
  //  sendThread.done();
  //  recieveThread.done();
  //  port.write('!');
  //  delay(100);
  //  String response = port.readStringUntil('\n');
  //  println("Disconnect teensy: " + response);
  //}
  
  private void update(PImage image) {
    int offset = 1;
    for (LedStrip strip : ledStrips) {
      //for (int y = 0; y < SCREEN_HEIGHT; y++) { //All pixels
      //  int index = strip.offset + y * SCREEN_WIDTH;
      //  color c = image.pixels[index];
      //  data[offset++] = (byte)(c >> 16 & 0xFF);
      //  data[offset++] = (byte)(c >> 8 & 0xFF);
      //  data[offset++] = (byte)(c & 0xFF);
      //}
      int index = strip.offset;
      int c = image.pixels[index];
      data[offset++] = (byte)(c >> 16 & 0xFF);
      data[offset++] = (byte)(c >> 8 & 0xFF);
      data[offset++] = (byte)(c & 0xFF);
    }
  }
}

final  char[] hexArray = "0123456789ABCDEF".toCharArray();
public String bytesToHex(byte[] bytes) {
  char[] hexChars = new char[bytes.length * 2];
  for ( int j = 0; j < bytes.length; j++ ) {
      int v = bytes[j] & 0xFF;
      hexChars[j * 2] = hexArray[v >>> 4];
      hexChars[j * 2 + 1] = hexArray[v & 0x0F];
  }
  return new String(hexChars);
}


class SendDataThread extends Thread {
  String name;
  Serial  port;
  int send_time;
  boolean running;
  boolean sendData;
  byte[] data;

  SendDataThread(String name, Serial port) {
    this.port = port;
    this.name = name;
    running = false;
    sendData = false;
    send_time = 0;
  }

  public void start() {
    running = true;
    super.start();
  }

  public void send(byte[] data) {
    this.data = data;
    sendData = true;
  }

  public int getTime() {
    return send_time;
  }

  public void done() {
    running = false;
  }

  public void run() {
    
    while (running) {
      if (sendData) {
        //println(millis() + ", " + name + " send data: " + bytesToHex(data));
        sendData = false;
        synchronized(this) {
          port.write(data);  // send data over serial to teensy
        }
      } else {
        yield();
      }
    }
  }
}

class RecieveDataThread extends Thread {
  String name;
  Serial port;
  boolean running;
  
  RecieveDataThread(String name, Serial port) {
    this.name = name;
    this.port = port;
  }
  
  public void start() {
    running = true;
    super.start();
  }
  
  public void done() {
    running = false;
  }
  
  public void run() {
    while(running) {
      if (port.available() > 0) {
        String response = port.readStringUntil('\n');
        if (response != null) {
          println(millis() + ", " + name + " response: " + response);
        }
      }
      delay(100);
    }
  }
}

class SimulateThread extends Thread {
  String name;
  boolean running;
  boolean sendData;
  byte[] data;
  
  SimulateThread(String name) {
    this.name = name;
  }
  
  public void start() {
    running = true;
    super.start();
  }
  
  public void done() {
    running = false;
  }
  
  public synchronized void send(byte[] data) {
    this.data = data;
    sendData = true;
  }
  
  public void run() {
    while (running) {
      if (sendData) {
        println(bytesToHex(data));
      } else {
        yield();
      }
    }
  }
}
  public void settings() {  size(512, 620); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TimeTunnel" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
