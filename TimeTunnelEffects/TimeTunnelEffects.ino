#include "FastLED.h"

#define COLOR_ORDER GRB

#define NUM_STRIPS 8
#define NUM_LEDS 16

CRGB leds[NUM_STRIPS][NUM_LEDS];

int type = 0;
char mode = '0';

void setup() {
  Serial.begin(115200);
  
  FastLED.addLeds<WS2812B, 0, COLOR_ORDER>(leds[0], NUM_LEDS);
  FastLED.addLeds<WS2812B, 1, COLOR_ORDER>(leds[1], NUM_LEDS);
  FastLED.addLeds<WS2812B, 2, COLOR_ORDER>(leds[2], NUM_LEDS);
  FastLED.addLeds<WS2812B, 3, COLOR_ORDER>(leds[3], NUM_LEDS);
  FastLED.addLeds<WS2812B, 4, COLOR_ORDER>(leds[4], NUM_LEDS);
  FastLED.addLeds<WS2812B, 5, COLOR_ORDER>(leds[5], NUM_LEDS);
  FastLED.addLeds<WS2812B, 6, COLOR_ORDER>(leds[6], NUM_LEDS);
  FastLED.addLeds<WS2812B, 7, COLOR_ORDER>(leds[7], NUM_LEDS);

  FastLED.setBrightness(128);
}

void loop() {
  byte startByte = Serial.read();
  
  if (startByte == '#') { // Change Running Mode
    mode = Serial.read();
  }
  int type = mode - '0';
  switch (type) {
    case 0: type0(); break;
    case 1: type1(); break;
    case 2: type2(); break;
    default: break;
  }
//  delay(1000);
}

void type0() {
  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
  }
  FastLED.show();
}

void type1() {
//  resetLeds();
  for (int i = 0; i < NUM_LEDS - 1; i++) {
    for (int l = 0; l < NUM_STRIPS; l++) {
      if (l % 2 == 0) {
        leds[l][i] = CRGB::White;
        leds[l][i + 1] = CRGB::White;
      } else {
        leds[l][NUM_LEDS - 1 - i] = CRGB::White;
        leds[l][NUM_LEDS - 1 - i - 1] = CRGB::White;
      }
    }
    FastLED.delay(33);
    for (int l = 0; l < NUM_STRIPS; l++) {
      if (l % 2 == 0) {
        leds[l][i] = CRGB::Black;
        leds[l][i + 1] = CRGB::Black;
      } else {
        leds[l][NUM_LEDS - 1 - i] = CRGB::Black;
        leds[l][NUM_LEDS - 1 - i - 1] = CRGB::Black;
      }
    }
  }
  FastLED.show();
}

void type2() {
  for(int i = 0; i < NUM_STRIPS; i++) {
    fire(i);
  }
  FastLED.show();
  FastLED.delay(1000 / 60);
}

void type3() {
  
}

#define COOLING 55
#define SPARKING 120
void fire(int strip) {
  static byte heat[NUM_LEDS];
  for (int i = 0; i < NUM_LEDS; i++) {
    heat[i] = qsub8(heat[i], random8(0, ((COOLING * 10) / NUM_LEDS) + 2));
  }

  for (int k = NUM_LEDS - 1; k >=2; k--) {
    heat[k] = (heat[k -1] + heat[k - 2] + heat[k -2]) / 3;
  }

  if(random8() < SPARKING ) {
      int y = random8(7);
      heat[y] = qadd8( heat[y], random8(160,255) );
  }

  for( int j = 0; j < NUM_LEDS; j++) {
      CRGB color = HeatColor( heat[j]);
      int pixelnumber;
      if (false) {
        pixelnumber = (NUM_LEDS-1) - j;
      } else {
        pixelnumber = j;
      }
      leds[strip][pixelnumber] = color;
  }
}

void resetLeds() {
  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
  }
  FastLED.show();
  delay(1000);
}

