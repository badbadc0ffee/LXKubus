heronarts.lx.studio.LXStudio lx;

void setup() {
  size(1600, 900, P3D);
  lx = new heronarts.lx.studio.LXStudio(this, buildModel(), MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
}

void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  try {
    LXDatagramOutput output = new LXDatagramOutput(lx);
    for (int f=0; f<6; f++) {
      int[] pointIndices = new int[144];
      for (int i=0; i<144; i++) {
        pointIndices[i] = i+f*144;
      };
      output.addDatagram(new StreamingACNDatagram(1+f, pointIndices).setAddress("kubus.moesch.org"));
    }
    lx.engine.addOutput(output);
  }
  catch (Exception e) {
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
