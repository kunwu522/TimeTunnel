void drawMode() {
  int mode = 0;
  switch (mode) {
    case 0: 
      drawCursor();
      break;
    case 1:
      drawRect();
      break;
    default:
      break;
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

void drawRect() {
  canvas.noStroke();
  canvas.fill(color(0, 0, 255));
  ellipse(mouseX, mouseY, 20, 20);
}