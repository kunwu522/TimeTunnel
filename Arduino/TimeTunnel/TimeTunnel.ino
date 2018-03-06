#include "FastLED.h"

#define TEENSY_ID 0

#define STRIP_TYPE WS2812B
#define COLOR_ORDER RGB

#define NUM_STRIPS 5      // Two types of controller
//#define NUM_STRIPS 4

#define NUM_LEDS 620

#define BRIGHTNESS 128 // default brightness is 50%

CRGB leds[NUM_STRIPS][NUM_LEDS];

const int maxQueueSize = (NUM_STRIPS * 3 + 1) * 3;
char queue[maxQueueSize];
int front = -1, rear = -1;

void setup() {
  Serial.setTimeout(50);

  if (TEENSY_ID < 2) {
    FastLED.addLeds<STRIP_TYPE, 2, COLOR_ORDER>(leds[0], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 3, COLOR_ORDER>(leds[1], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 4, COLOR_ORDER>(leds[2], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 5, COLOR_ORDER>(leds[3], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 6, COLOR_ORDER>(leds[4], NUM_LEDS);
  } else {
    FastLED.addLeds<STRIP_TYPE, 2, COLOR_ORDER>(leds[0], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 3, COLOR_ORDER>(leds[1], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 4, COLOR_ORDER>(leds[2], NUM_LEDS);
    FastLED.addLeds<STRIP_TYPE, 5, COLOR_ORDER>(leds[3], NUM_LEDS);
  }
  
}

void loop() {
  while (Serial.available() > 0 && queueSize() < maxQueueSize) {
    enqueue(Serial.read());
  }

  char startByte;
  if (dequeue(&startByte)) {
    if (startByte == '?') {
      sendTeensyInfo();
    } else if (startByte == '*') {
      processQueue();
    } else {
      Serial.print("Invalid start byte: ");
      Serial.write(startByte);
      Serial.print('\n');
    }
  }
}

void processQueue() {
  if (queueSize() < NUM_STRIPS * 3) {
    return;
  }

  char data[NUM_STRIPS * 3];
  if (dequeueWithSize(data, sizeof(data)) {
    showLeds(data);
  }
}

void showLeds(char * data) {
  for (int i = 0; i < NUM_STRIPS; i++) {
    for (int j = 0; j < NUM_LEDS; j++) {
      leds[i][j] = CRGB(data[0], data[1], data[2]);
      data += 3;
    }
  }
  FastLED.setBrightness(BRIGHTNESS);
  FastLED.show();
}

void sendTeensyInfo() {
  Serial.print(TEENSY_ID);
  Serial.write(',');
  char teensyName[strlen("teensyx")];
  strcat(teensyName, TEENSY_ID);
  Serial.print(teensyName);
  Serial.write(',');
  Serial.print(NUM_STRIPS);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.print('\n');
}

/*
 * Buffer queue Method set
 * 
 */
void enqueue(char value) {
  if (rear == maxQueueSize - 1) return;
  if (front == -1) front =0;
  rear++;
  queue[rear] = char;
}

boolean dequeue(char *value) {
  if (front == -1 || rear == -1) {
    return 0;
  }

  *value = queue[front];
  front++;
  if (front - 1 = rear) {
    front = -1;
    rear = -1;
  }
  return 1;
}

boolean dequeueWithSize(char *data, unsigned int size) {
  if (rear - front + 1 >= size) {
    if (memcopy(data, &queue[front], size)) {
      front += size;
      if (front - 1 == rear) {
        front = -1;
        rear = -1;
      }
      return 1;
    }
  }
  return 0;
}

int queueSize() {
  if (rear == -1 && front == -1) {
    return 0;
  }
  return rear - front + 1;
}

