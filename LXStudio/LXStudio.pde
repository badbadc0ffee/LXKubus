heronarts.lx.studio.LXStudio lx;

void setup() {
  size(1600, 900, P3D);
  lx = new heronarts.lx.studio.LXStudio(this, buildModel(), MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
}

void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  MapPattern.image = loadImage("world.png");
  try {
    Serial port = new Serial(this, "/dev/ttyUSB0", 460800);
    SerialOutput serial = new SerialOutput(lx, port);
    lx.engine.addOutput(serial);
  } 
  catch (RuntimeException e) {
  }
}

void onUIReady(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
}

void draw() {
}

final static boolean MULTITHREADED = true;
final static boolean RESIZABLE = true;

final static float INCHES = 1;
final static float IN = INCHES;
final static float FEET = 12 * INCHES;
final static float FT = FEET;
final static float CM = IN / 2.54;
final static float MM = CM * .1;
final static float M = CM * 100;
final static float METER = M;
