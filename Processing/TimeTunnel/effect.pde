int averageX = 0;
int averageY = 0;

int x1;
int x2;

void drawMode() {
  int mode = 0;
  switch (mode) {
    case 0: 
      drawCursor();
      break;
    case 1:
      drawRect();
      break;
    case 2:
      drawLine();
      break;
    default:
      break;
  }
}

void drawLine() {
  int x = launchKinect ? averageX : mouseX;
  x1 = (int)lerp(x1, x, 0.05);
  stroke(255);
  strokeWeight(40);
  line(x1, 0, x1, SCREEN_HEIGHT);
}

void drawCursor() {
  int x = launchKinect ? averageX : mouseX;
  x1 = (int)lerp(x1, x, 0.05); //<>//
  //println("blob x: " + averageX);
  x2 = (int)lerp(x2, x1, 0.1);
  
  noStroke();
  //float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  if (x1 > x2) {
    setGradient(x2, 0, tempWidth, (float)SCREEN_HEIGHT, color(128, 128, 128), color(255), X_AXIS);
  } else {
    setGradient(x1, 0, tempWidth, (float)SCREEN_HEIGHT, color(255), color(128, 128, 128), X_AXIS);
  }
  //for (int i = 0; i < tempWidth; i++) {
  //  stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
  //  if (x1 > x2) {
  //    line(x1 - i, 0, x1 - i, SCREEN_HEIGHT);
  //  } else {
  //    line(x1 + i, 0, x1 + i, SCREEN_HEIGHT);
  //  }
  //}
}

void drawRect() {
  noStroke();
  fill(color(0, 0, 255));
  ellipse(mouseX, mouseY, 20, 20);
}


int Y_AXIS = 1;
int X_AXIS = 2;
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}