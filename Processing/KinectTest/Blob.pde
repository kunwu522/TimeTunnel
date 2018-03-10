class Blob {
  float minX;
  float minY;
  float maxX;
  float maxY;
  
  ArrayList<PVector> points;
  
  public Blob(float x, float y) {
    minX = x;
    minY = y;
    maxX = x;
    maxY = y;
    points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }
  
  void show() {
    stroke(0, 255, 0);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minX, minY, maxX, maxY);
  }
  
  void add(float x, float y) {
    points.add(new PVector(x, y));
    minX = min(minX, x);
    minY = min(minY, y);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
  }
  
  float size() {
    return (maxX - minX) * (maxY - minY);
  }
  
  boolean isNear(float x, float y) {
    float d = 1000000;
    for (PVector v : points) {
      float tempD = distSq(x, y, v.x, v.y);
      if (tempD < d) {
        d = tempD;
      }
    }
    
    if (d < 10 * 10) {
      return true;
    } else {
      return false;
    }
  }
  
  private float distSq(float x1, float y1, float x2, float y2) {
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
  }
}