boolean saveBackground = false;

boolean cmdPressed = false;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = true;
  } else {
    if (cmdPressed && key == 'b') {
      saveBackground = true;
    } else if (cmdPressed && key == 's') {
      //smoothImage.save("image/smooth" + millis() + ".jpg");
    } else if (cmdPressed && key == 'p') {
      //writeToFile();
    } else if (cmdPressed && key == 'e') {
      //printDepth = true;
    }
  }
}