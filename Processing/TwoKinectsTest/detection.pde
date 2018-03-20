int innerBandThreshold = 3;
int outerBandThreshold = 5;
int avarageThreshold = 30;
PImage getDenoisedDepthImage(int[] rawDepth) {
  PImage image = createImage(TUNNEL_WIDTH,TUNNEL_HEIGHT,RGB);
  int widthBound = TUNNEL_WIDTH - 1;
  int heightBound = TUNNEL_HEIGHT - 1;
  image.loadPixels();
  for (int x = 0; x < TUNNEL_WIDTH; x++) {
    for (int y = 0; y < TUNNEL_HEIGHT; y++) {
      int smoothDepth = 0;
      int offset = x + y * TUNNEL_WIDTH;
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
              int index = nearX + nearY * TUNNEL_WIDTH;
              if (rawDepth[index] != 0) {
                Integer depth = Integer.valueOf(rawDepth[index]);
                if (frequencyMap.containsKey(depth)) {
                  frequencyMap.put(depth, frequencyMap.get(depth) + 1);
                } else {
                  frequencyMap.put(depth, 1);
                }
                if (i != 2 && i != -2 && j != 2 && j != -2) {
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
      } else {
        smoothDepth = rawDepth[offset];
      }

      float rate = 0;
      if (smoothDepth != 0) {
        rate = float(4500 - smoothDepth) / 4500.0;
      }
      image.pixels[offset] = color(255 * rate, 255 * rate, 255 * rate);
    }
  }
  image.updatePixels();
  return image;
}

/******************************
*
*  Background subtraction
*
*
*******************************/
void detectBlob(PImage image) {
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < TUNNEL_WIDTH; x++) {
    for (int y = 0; y < TUNNEL_WIDTH; y++) {
      if (isBlobDiff(background, image, x, y, 5)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
      }
    }
  }
  if (foundBlob) {
    objectX = int(sumX / count);
    objectY = int(sumY / count);
  } else {
    objectX = -20;
    objectX = -20;
  }
}

boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  if (background == null) {
    return false;
  }
  boolean isDiff = true;
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < TUNNEL_WIDTH
        && nearY >= 0 && nearY < TUNNEL_WIDTH) {
        int nearIndex = nearX + nearY * TUNNEL_WIDTH;
        color bgColor = background.pixels[nearIndex];
        color currentColor = image.pixels[nearIndex];
        if (diffColor(bgColor, currentColor) < 30 * 30) {
          isDiff = false;
        }
      }
    }
  }
  return isDiff;
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
