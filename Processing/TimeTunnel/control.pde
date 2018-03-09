/******************************
*  
*  For Control
*
*
*******************************/

void saveBackgounndImage() {
  background = get(0, 620, 512, 424);
  background.save("image/background.jpg");
  println("Updated background image successful");
}

boolean cmdPressed = false;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = true;
  } else {
    if (cmdPressed && key == 'b') {
      saveBackgounndImage();
    } else if (cmdPressed && key == 'i') {
      innerBandThreshold++;
    } else if (cmdPressed && key =='u') {
      innerBandThreshold--;
    } else if (cmdPressed && key == 'o') {
      outerBandThreshold++;
    } else if (cmdPressed && key == 'p') {
      outerBandThreshold--;
    }
  }
}