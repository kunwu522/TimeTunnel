import processing.serial.*;

final int TEENSY_NUM_STRIPS = 5;
final int TEENSY_NUM_LEDS = 620;
final int BAUD_RATE = 921600;

Teensy[] teensys = new Teensy[2];

void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem3071001");
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem3654571");
  teensys[1] = new Teensy(this, "/dev/cu.usbmodem3162511");
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem2885451");
  
  println("Teensy setup done!");
  println();
}

SimulateThread t1;
SimulateThread t2;
void setupSimulateThread() {
  t1 = new SimulateThread("fake1");
  t2 = new SimulateThread("fake2");
  t1.start();
  t2.start();
}

void simulateSendMessageToTeensys(PImage image) {
  byte[] data = new byte[NUM_STRIPS * NUM_LEDS_PER_STRIP * 3 + 1];
  data[0] = '*';
  int offset = 1;
  for (int s = 0; s < strips.length; s++) {
    LedStrip strip = strips[s];
    int x = strip.offset;
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
      int index = x + y * SCREEN_WIDTH;
      color c = image.pixels[index];
      data[offset++] = (byte)(c >> 16 & 0xFF);
      data[offset++] = (byte)(c >> 8 & 0xFF);
      data[offset++] = (byte)(c & 0xFF);
    }
    if (s < 4) {
      t1.send(data);
    } else {
      t2.send(data);
    }
  }
  //t1.send()
}

class Teensy {
  int id;
  String name;
  Serial port;
  String portName;
  LedStrip[] ledStrips = new LedStrip[TEENSY_NUM_STRIPS];
  byte[] data = new byte[TEENSY_NUM_STRIPS * 3 + 1];
  
  SendDataThread sendThread;
  RecieveDataThread recieveThread;
  
  
  Teensy(PApplet parent, String name) {
    portName = name;
    try {
      port = new Serial(parent, portName, 921600);
      if (port == null) {
        println("Error, port is null.");
        throw new NullPointerException();
      }
      port.bufferUntil('\n');
      port.write('?');
    } catch (Throwable e) {
      println("Serial Port " + portName + " does not exist.");
      exit();
      return;
    }
    
    delay(100);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + portName + " is not responding");
      exit();
      return;
    }
    String param[] = line.split(",");
    if (param.length != 4) {
      println("Error, port " + portName + " invalid reponse: " + line);
      exit();
      return;
    }
    println("Response: " + line);
    id = Integer.parseInt(param[0]);
    name = param[1];
    int stripsNum = Integer.parseInt(param[2]);
    int ledsNum = Integer.parseInt(param[3].trim());
    if (stripsNum != TEENSY_NUM_STRIPS || ledsNum != TEENSY_NUM_LEDS) {
      println("Error -- teensy: " + name + ", the number of leds and strips is not match.");
      exit();
      return;
    }
    
    for (int i = 0; i < ledStrips.length; i++) {
      ledStrips[i] = strips[i + id * TEENSY_NUM_STRIPS];
    }
    
    sendThread = new SendDataThread(name + "_send_thread", port);
    sendThread.start();
    
    recieveThread = new RecieveDataThread(name + "_recieve_thread", port);
    //recieveThread.start();
    
    println(name + " setup.");
    println();
  }
  
  PImage lastImage;
  boolean isSame = true;
  void send(PImage image) {
    update(image);
    data[0] = '*';
    //if (!isSame) {
      sendThread.send(data);
    //}
    isSame = true;
    lastImage = image;
  }
  
  void update(PImage image) {
    int offset = 1;
    for (LedStrip strip : ledStrips) {
      color c = image.pixels[strip.offset];
      if (lastImage != null) {
        color lastC = lastImage.pixels[strip.offset];
        if (lastC != c) {
          isSame = false;
        }
      }
      data[offset++] = (byte)(c >> 16 & 0xFF);
      data[offset++] = (byte)(c >> 8 & 0xFF);
      data[offset++] = (byte)(c & 0xFF);
    }
  }
}