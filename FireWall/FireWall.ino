#include "FastLED.h"

#define COLOR_ORDER GRB
#define CHIPSET WS2812B
#define NUM_LEDS 16
#define NUM_STRIPS 8

#define BRIGHTNESS 168
#define FRAMES_PER_SECOND 60

CRGB leds[NUM_STRIPS][NUM_LEDS];

void setup() {
  FastLED.addLeds<CHIPSET, 0, COLOR_ORDER>(leds[0], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 1, COLOR_ORDER>(leds[1], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 2, COLOR_ORDER>(leds[2], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 3, COLOR_ORDER>(leds[3], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 4, COLOR_ORDER>(leds[4], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 5, COLOR_ORDER>(leds[5], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 6, COLOR_ORDER>(leds[6], NUM_LEDS);
  FastLED.addLeds<CHIPSET, 7, COLOR_ORDER>(leds[7], NUM_LEDS);
  
  FastLED.setBrightness(BRIGHTNESS);

  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::White);
  }
  FastLED.show();
  delay(5000);
  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
  }
  FastLED.show();
}

void loop() {
  for (int l = 0; l < NUM_STRIPS; l++) {
    fire(l);
  }
  FastLED.show();
  FastLED.delay(1000 / 80);
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

