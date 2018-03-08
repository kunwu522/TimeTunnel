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
  
  void update(float x, float y) {
    if (x == -1 && y == -1) {
      lastX = x;
      lastY = y;
      return;
    }
    
    if (lastX != -1 || lastY != -1) {
      x = lerp(lastX, x, 0.2);
      y = lerp(lastY, y, 0.2);
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