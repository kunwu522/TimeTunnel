import java.util.*;
import java.io.*;

static int SCREEN_WIDTH = 260;
static int SCREEN_HEIGHT = 620;
final int NUM_STRIPS = 2;
final int NUM_LEDS_PER_STRIP = 620;

final boolean launchTeensy = true;

float x1;
float x2;

PGraphics canvas;

void setup() {
  size(260, 620, P3D);
  canvas = createGraphics(SCREEN_WIDTH, SCREEN_HEIGHT, P3D);
  setupStrips();
  if (launchTeensy) {
    setupTeensy();
  } else {
    setupSimulateThread();
  }
}

void draw() {
  canvas.beginDraw();
  canvas.background(169, 169, 169);
  drawStrips();
  drawCursor();
  canvas.endDraw();
  
  image(canvas, 0, 0);
  
  PImage display = get();
  if (launchTeensy) {
    for (Teensy teensy : teensys) {
      teensy.send(display);
    }
  } else {
    simulateSendMessageToTeensys(display);
  }
}