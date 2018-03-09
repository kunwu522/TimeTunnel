int averageX = 0;
int averageY = 0;

float x1;
float x2;

void drawMode() {
  int mode = 2;
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
  x1 = lerp(x1, averageX, 0.05);
  canvas.stroke(255);
  canvas.strokeWeight(40);
  canvas.line(x1, 0, x1, SCREEN_HEIGHT);
}

void drawCursor() {
  x1 = lerp(x1, averageX, 0.1); //<>//
  //println("blob x: " + averageX);
  x2 = lerp(x2, x1, 0.1);
  
  canvas.noStroke();
  float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  for (int i = 0; i < tempWidth; i++) {
    canvas.stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
    if (x1 > x2) {
      canvas.line(x1 - i, 0, x1 - i, SCREEN_HEIGHT);
    } else {
      canvas.line(x1 + i, 0, x1 + i, SCREEN_HEIGHT);
    }
  }
}

void drawRect() {
  canvas.noStroke();
  canvas.fill(color(0, 0, 255));
  ellipse(mouseX, mouseY, 20, 20);
}