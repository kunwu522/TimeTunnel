#include "FastLED.h"

#define COLOR_ORDER GRB

#define NUM_STRIPS 5
#define NUM_LEDS 620

CRGB leds[NUM_STRIPS][NUM_LEDS];

int type = 0;
char mode = '0';

void setup() {
//  Serial.begin(115200);
  
  FastLED.addLeds<WS2812B, 2, COLOR_ORDER>(leds[0], NUM_LEDS);
  FastLED.addLeds<WS2812B, 3, COLOR_ORDER>(leds[1], NUM_LEDS);
  FastLED.addLeds<WS2812B, 4, COLOR_ORDER>(leds[2], NUM_LEDS);
  FastLED.addLeds<WS2812B, 5, COLOR_ORDER>(leds[3], NUM_LEDS);
  FastLED.addLeds<WS2812B, 6, COLOR_ORDER>(leds[4], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 7, COLOR_ORDER>(leds[5], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 8, COLOR_ORDER>(leds[6], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 9, COLOR_ORDER>(leds[7], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 10, COLOR_ORDER>(leds[8], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 11, COLOR_ORDER>(leds[9], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 12, COLOR_ORDER>(leds[10], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 13, COLOR_ORDER>(leds[11], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 14, COLOR_ORDER>(leds[12], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 15, COLOR_ORDER>(leds[13], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 16, COLOR_ORDER>(leds[14], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 17, COLOR_ORDER>(leds[15], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 18, COLOR_ORDER>(leds[16], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 17, COLOR_ORDER>(leds[17], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 18, COLOR_ORDER>(leds[18], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 19, COLOR_ORDER>(leds[19], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 20, COLOR_ORDER>(leds[20], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 21, COLOR_ORDER>(leds[21], NUM_LEDS);

//  FastLED.setBrightness(140);
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
    case 2: fireLeds(); break;
    case 3: lineAdding(); break;
    case 4: areaLineAdding(); break;
    case 5: sparking(); break;
    default: break;
  }
//  delay(1000);
}

void type0() {
  for (int i = 0; i < NUM_STRIPS; i++) {
//    for ( int j = 0; j < NUM_LEDS; j++) {
//      int r = random(255);
//      int g = random(255);
//      int b = random(255);
//      leds[i][j] = CRGB(r, g, b);
//    }
    fill_solid(leds[i], NUM_LEDS, CRGB::White);
  }
  FastLED.setBrightness(150);
  FastLED.show();

  delay(1000);
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
    FastLED.delay(5);
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

void fireLeds() {
  for(int i = 0; i < NUM_STRIPS; i++) {
    fire(i);
  }
  FastLED.show();
  FastLED.delay(1000 / 60);
}

void areaLineAdding() {
  for (int line = 0; line < NUM_STRIPS; line++) {
    for (int led = 0; led < NUM_LEDS; led++) {
      if (led < 206 && led > (206 * 2)) {
        leds[line][led] = CRGB::White;
        leds[NUM_STRIPS - 1 - line][led] = CRGB::Black;
      } else {
        leds[line][led] = CRGB::Black;
        leds[NUM_STRIPS - 1 - line][led] = CRGB::White;
      }
    }
    FastLED[line].showLeds(128);
    FastLED[NUM_STRIPS - 1 - line].showLeds(128);
  }
  delay(50);
  for (int line = 0; line < NUM_STRIPS; line++) {
    for (int led = 0; led < NUM_LEDS; led++) {
      if (led < 206 && led > (206 * 2)) {
        leds[line][led] = CRGB::Black;
      } else {
        leds[NUM_STRIPS - 1 - line][led] = CRGB::Black;
      }
    }
    FastLED[line].showLeds(128);
    FastLED[NUM_STRIPS - 1 - line].showLeds(128);
  }
}

void lineAdding() {
  int r = random(255);
  int g = random(255);
  int b = random(255);
  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB(r, g, b));
    FastLED[i].showLeds(255);
    delay(10);
  }
  delay(100);
  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
    FastLED[i].showLeds(255);
    delay(10);
  }
  delay(1000);
}

void sparking() {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[0][i] = CRGB::White;
    leds[0][i + 1] = CRGB::White;
    FastLED.delay(33);
    leds[0][i] = CRGB::Black;
    leds[0][i + 1] = CRGB::Black;
  }
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

  for( int j = 0; j < 60; j++) {
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

