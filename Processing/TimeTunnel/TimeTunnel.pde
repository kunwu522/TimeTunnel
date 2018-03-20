import java.util.*;
import java.io.*;

static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 620;
final int NUM_STRIPS = 10;
final int NUM_LEDS_PER_STRIP = 620;

final boolean launchTeensy = false;
final boolean launchKinect = true;

//PGraphics canvas;

void setup() {
  size(512, 620);
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

void draw() {
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