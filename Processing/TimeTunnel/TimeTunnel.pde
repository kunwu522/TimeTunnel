import java.util.*;
import java.io.*;

static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 620;
final int NUM_STRIPS = 10;
final int NUM_LEDS_PER_STRIP = 620;

final boolean launchTeensy = false;

float x1;
float x2;

PGraphics canvas;

void setup() {
  size(512, 620, P3D);
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

void drawCursor() {
  x1 = lerp(x1, mouseX, 0.1);
  x2 = lerp(x2, x1, 0.1);
  
  canvas.noStroke();
  float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  for (int i = 0; i < tempWidth; i++) {
    stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
    if (x1 > x2) {
      line(x1 - i, 0, x1 - i, SCREEN_HEIGHT);
    } else {
      line(x1 + i, 0, x1 + i, SCREEN_HEIGHT);
    }
  }
}