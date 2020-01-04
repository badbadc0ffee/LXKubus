import java.util.Arrays;

@LXCategory("Form")
  public static class PlanePattern extends LXPattern {

  public enum Axis {
    X, Y, Z
  };

  public final EnumParameter<Axis> axis =
    new EnumParameter<Axis>("Axis", Axis.X)
    .setDescription("Which axis the plane is drawn across");

  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position of the center of the plane");

  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");

  public PlanePattern(LX lx) {
    super(lx);
    addParameter("axis", this.axis);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }

  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    float n = 0;
    for (LXPoint p : model.points) {
      switch (this.axis.getEnum()) {
      case X: 
        n = p.xn; 
        break;
      case Y: 
        n = p.yn; 
        break;
      case Z: 
        n = p.zn; 
        break;
      }
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos)));
    }
  }
}

@LXCategory("Form")
  public static class SectorPattern extends LXPattern {

  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 360)
    .setDescription("Position of the center of the sector");

  public final CompoundParameter wth = new CompoundParameter("Width", 30, 0, 360)
    .setDescription("Thickness of the plane");

  public SectorPattern(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }

  public void run(double deltaMs) {
    float pos     = TWO_PI*this.pos.getValuef()/360;
    float falloff =     PI*this.wth.getValuef()/360;
    for (LXPoint p : model.points) {

      float angle = p.azimuth;
      if (LXUtils.wrapdist(angle, pos, TWO_PI)<falloff)
        colors[p.index] = LXColor.gray(100); 
      else
        colors[p.index] = LXColor.gray(0); 
      //colors[p.index] = LXColor.gray(falloff/LXUtils.wrapdist(angle,pos,TWO_PI));
    }
  }
}

@LXCategory("Form")
  public static class BeamPattern extends LXPattern {

  public final CompoundParameter azimuth = new CompoundParameter("Azimut", 0, 360)
    .setDescription("Azimut angle of the center of the sector");

  public final CompoundParameter elevation = new CompoundParameter("Elevation", 0, 180)
    .setDescription("Elevation angle of the center of the sector");

  public final CompoundParameter wth = new CompoundParameter("Width", 30, 0, 360)
    .setDescription("Thickness of the plane");

  public BeamPattern(LX lx) {
    super(lx);
    addParameter("azimuth", this.azimuth);
    addParameter("elevation", this.elevation);
    addParameter("width", this.wth);
  }

  public void run(double deltaMs) {
    double azimuth   = TWO_PI*this.azimuth.getValuef()/360;
    double elevation = TWO_PI*(this.elevation.getValuef()-90)/360;
    double falloff   =     PI*this.wth.getValuef()/360;
    for (LXPoint p : model.points) {
      double angle = Math.sqrt(
        Math.pow(LXUtils.wrapdist(p.azimuth, azimuth, TWO_PI), 2) +
        Math.pow(LXUtils.wrapdist(p.elevation, elevation, TWO_PI), 2));
      if (angle<falloff)
        colors[p.index] = LXColor.gray(100); 
      else
        colors[p.index] = LXColor.gray(0); 
      //colors[p.index] = LXColor.gray(falloff/LXUtils.wrapdist(angle,pos,TWO_PI));
    }
  }
}

@LXCategory("Image")
  public static class MapPattern extends LXPattern {

  static PImage image;

  public final CompoundParameter rot = new CompoundParameter("Rotation", 0, 360)
    .setDescription("Rotation of the image");

  public MapPattern(LX lx) {
    super(lx);
    addParameter("rotation", this.rot);
  }

  public void run(double deltaMs) {
    double rotation = rot.getValue()/360*TWO_PI;
    for (LXPoint p : model.points) {
      colors[p.index] = LXColor.gray(100); 
      color pixelcolor = image.get((int)(image.width*(p.azimuth+rotation)/TWO_PI), (int)(image.height*(PI/2+p.elevation)/PI));
      colors[p.index]= pixelcolor;
    }
  }
}

@LXCategory("Test")
  public static class GameOfLifePattern extends LXPattern {

  public final CompoundParameter period =
    (CompoundParameter) new CompoundParameter("Period", 1000, 100, 60000)
    .setDescription("Sets the epoch period in msecs")
    .setExponent(4)
    .setUnits(LXParameter.Units.MILLISECONDS);

  boolean alive[];
  boolean nextGen[];
  private int neighborsCount(KubusPoint p) {
    int neighbors = 0;
    for (KubusPoint neighbor : p.neighbors) {
      if (alive[neighbor.index]) neighbors++;
    }
    return neighbors;
  }
  public GameOfLifePattern(LX lx) {
    super(lx);
    addParameter("period", period);

    alive   = new boolean[model.points.length];
    nextGen = new boolean[model.points.length];

    Kubus kubus = ((Kubus)model);
    Board board = kubus.boards[0];
    alive[board.xy(5, 6).index] = true;
    alive[board.xy(5, 7).index] = true;
    alive[board.xy(6, 5).index] = true;
    alive[board.xy(6, 6).index] = true;
    alive[board.xy(7, 6).index] = true;
  }

  double timestamp;
  public void run(double deltaMs) {
    timestamp += deltaMs;
    int cellcount = 0;
    for (boolean a : alive) {
      if (a) cellcount++;
    }
    for (LXPoint p : model.points) {
      if (cellcount<100 && neighborsCount((KubusPoint)p)==0 && !alive[p.index]) {
        if (Math.random() < 0.0001) {
          KubusPoint point = (KubusPoint)p;
          alive[point.neighbors[0].index] = true;
          alive[point.neighbors[2].index] = true;
          alive[point.neighbors[3].index] = true;
          alive[point.neighbors[4].index] = true;
          alive[point.neighbors[5].index] = true;
          cellcount+=5;
        }
      }
      colors[p.index] = alive[p.index] ? LXColor.gray(100) : LXColor.gray(0);
    }
    if (timestamp > period.getValue()) {
      timestamp = 0;
      for (LXPoint p : model.points) {
        KubusPoint point = (KubusPoint)p;
        int neighbors = neighborsCount(point);
        boolean living = alive[point.index];
        nextGen[point.index] = (living && neighbors==2) || neighbors==3;
      }
      for (LXPoint p : model.points) {
        alive[p.index] = nextGen[p.index];
      }
    }
  }
}

/**
 * This file has a bunch of example patterns, each illustrating the key
 * concepts and tools of the LX framework.
 */

public class LayerDemoPattern extends LXPattern {

  private final BoundedParameter colorSpread = new BoundedParameter("Clr", 0.5, 0, 3);
  private final BoundedParameter stars = new BoundedParameter("Stars", 100, 0, 100);

  public LayerDemoPattern(LX lx) {
    super(lx);
    addParameter(colorSpread);
    addParameter(stars);
    addLayer(new CircleLayer(lx));
    addLayer(new RodLayer(lx));
    for (int i = 0; i < 200; ++i) {
      addLayer(new StarLayer(lx));
    }
  }

  public void run(double deltaMs) {
    // The layers run automatically
  }

  public class CircleLayer extends LXLayer {

    private final SinLFO xPeriod = new SinLFO(3400, 7900, 11000);
    private final SinLFO brightnessX = new SinLFO(model.xMin, model.xMax, xPeriod);

    public CircleLayer(LX lx) {
      super(lx);
      addModulator(xPeriod).start();
      addModulator(brightnessX).start();
    }

    public void run(double deltaMs) {
      // The layers run automatically
      float falloff = 100 / (4*FEET);
      for (LXPoint p : model.points) {
        float yWave = model.yRange/2 * sin(p.x / model.xRange * PI);
        float distanceFromCenter = dist(p.x, p.y, model.cx, model.cy);
        float distanceFromBrightness = dist(p.x, abs(p.y - model.cy), brightnessX.getValuef(), yWave);
        colors[p.index] = LXColor.hsb(
          palette.getHuef() + colorSpread.getValuef() * distanceFromCenter, 
          100, 
          max(0, 100 - falloff*distanceFromBrightness)
          );
      }
    }
  }

  public class RodLayer extends LXLayer {

    private final SinLFO zPeriod = new SinLFO(2000, 5000, 9000);
    private final SinLFO zPos = new SinLFO(model.zMin, model.zMax, zPeriod);

    public RodLayer(LX lx) {
      super(lx);
      addModulator(zPeriod).start();
      addModulator(zPos).start();
    }

    public void run(double deltaMs) {
      for (LXPoint p : model.points) {
        float b = 100 - dist(p.x, p.y, model.cx, model.cy) - abs(p.z - zPos.getValuef());
        if (b > 0) {
          addColor(p.index, LXColor.hsb(
            palette.getHuef() + p.z, 
            100, 
            b
            ));
        }
      }
    }
  }

  public class StarLayer extends LXLayer {

    private final TriangleLFO maxBright = new TriangleLFO(0, stars, random(2000, 8000));
    private final SinLFO brightness = new SinLFO(-1, maxBright, random(3000, 9000));

    private int index = 0;

    public StarLayer(LX lx) {
      super(lx);
      addModulator(maxBright).start();
      addModulator(brightness).start();
      pickStar();
    }

    private void pickStar() {
      index = (int) random(0, model.size-1);
    }

    public void run(double deltaMs) {
      if (brightness.getValuef() <= 0) {
        pickStar();
      } else {
        addColor(index, LXColor.hsb(palette.getHuef(), 50, brightness.getValuef()));
      }
    }
  }
}






//Borrowed from Tree of Tenere (https://github.com/treeoftenere/Tenere)


public static class Wave extends LXPattern {
  // by Mark C. Slee

  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 28*FEET)
    .setDescription("Width of the wave");

  public final CompoundParameter rate =
    new CompoundParameter("Rate", 6000, 18000)
    .setDescription("Rate of the of the wave motion");

  public final SawLFO phase = new SawLFO(0, TWO_PI, rate);

  public final double[] bins = new double[512];

  public Wave(LX lx) {
    super(lx);
    startModulator(phase);
    addParameter(size);
    addParameter(rate);
  }

  public void run(double deltaMs) {
    double phaseValue = phase.getValue();
    float falloff = 100 / size.getValuef();
    for (int i = 0; i < bins.length; ++i) {
      bins[i] = model.cy + model.yRange/2 * Math.sin(i * TWO_PI / bins.length + phaseValue);
    }
    for (LXPoint p : model.points) {
      int idx = Math.round((bins.length-1) * (p.x - model.xMin) / model.xRange);
      float y1 = (float) bins[idx];
      float y2 = (float) bins[(idx*4 / 3 + bins.length/2) % bins.length];
      float b1 = max(0, 100 - falloff * abs(p.y - y1));
      float b2 = max(0, 100 - falloff * abs(p.y - y2));
      float b = max(b1, b2);
      colors[p.index] = b > 0 ? palette.getColor(b, b) : #000000;
    }
  }
}

public static class Swirl extends LXPattern {
  // by Mark C. Slee

  public final SinLFO xPos = new SinLFO(model.xMin, model.xMax, startModulator(
    new SinLFO(19000, 39000, 51000).randomBasis()
    ));

  public final SinLFO yPos = new SinLFO(model.yMin, model.yMax, startModulator(
    new SinLFO(19000, 39000, 57000).randomBasis()
    ));

  public final CompoundParameter swarmBase = new CompoundParameter("Base", 
    //12*INCHES,
    //1*INCHES,
    //140*INCHES

    RADIUS /  10.0, 
    RADIUS /  50.0, 
    RADIUS /   2.0
    );

  public final CompoundParameter swarmMod = new CompoundParameter("Mod", 0, RADIUS/10.0);
  //public final CompoundParameter swarmMod = new CompoundParameter("Mod", 0, 120*INCHES);

  public final SinLFO swarmSize = new SinLFO(0, swarmMod, 19000);

  public final SawLFO pos = new SawLFO(0, 1, startModulator(
    new SinLFO(1000, 9000, 17000)
    ));

  public final SinLFO xSlope = new SinLFO(-1, 1, startModulator(
    new SinLFO(78000, 104000, 17000).randomBasis()
    ));

  public final SinLFO ySlope = new SinLFO(-1, 1, startModulator(
    new SinLFO(37000, 79000, 51000).randomBasis()
    ));

  public final SinLFO zSlope = new SinLFO(-.2, .2, startModulator(
    new SinLFO(47000, 91000, 53000).randomBasis()
    ));

  public Swirl(LX lx) {
    super(lx);
    addParameter(swarmBase);
    addParameter(swarmMod);
    startModulator(xPos.randomBasis());
    startModulator(yPos.randomBasis());
    startModulator(pos);
    startModulator(swarmSize);
    startModulator(xSlope);
    startModulator(ySlope);
    startModulator(zSlope);
  }

  public void run(double deltaMs) {
    final float xPos = this.xPos.getValuef();
    final float yPos = this.yPos.getValuef();
    final float pos = this.pos.getValuef();
    final float swarmSize = this.swarmBase.getValuef() + this.swarmSize.getValuef();
    final float xSlope = this.xSlope.getValuef();
    final float ySlope = this.ySlope.getValuef();
    final float zSlope = this.zSlope.getValuef();

    for (LXPoint p : model.points) {
      float radix = (xSlope*(p.x-model.cx) + ySlope*(p.y-model.cy) + zSlope*(p.z-model.cz)) % swarmSize; // (p.x - model.xMin + p.y - model.yMin) % swarmSize;
      float dist = dist(p.x, p.y, xPos, yPos); 
      float size = max(RADIUS / 10.0, 2*swarmSize - .5*dist);
      //float size = max(20*INCHES, 2*swarmSize - .5*dist);
      float b = 100 - (100 / size) * LXUtils.wrapdistf(radix, pos * swarmSize, swarmSize);
      b = constrain(b, 0, 100);      
      colors[p.index] = (b > 0) ? palette.getColor(b, b) : #000000;
    }
  }
}

public static class Rotors extends LXPattern {
  // by Mark C. Slee

  public final SawLFO aziumuth = new SawLFO(0, PI, startModulator(
    new SinLFO(11000, 29000, 33000)
    ));

  public final SawLFO aziumuth2 = new SawLFO(PI, 0, startModulator(
    new SinLFO(23000, 49000, 53000)
    ));

  public final SinLFO falloff = new SinLFO(200, 900, startModulator(
    new SinLFO(5000, 17000, 12398)
    ));

  public final SinLFO falloff2 = new SinLFO(250, 800, startModulator(
    new SinLFO(6000, 11000, 19880)
    ));

  public float maxb = 0;

  public Rotors(LX lx) {
    super(lx);
    startModulator(aziumuth);
    startModulator(aziumuth2);
    startModulator(falloff);
    startModulator(falloff2);
  }

  public void run(double deltaMs) {
    float aziumuth = this.aziumuth.getValuef();
    float aziumuth2 = this.aziumuth2.getValuef();
    float falloff = this.falloff.getValuef();
    float falloff2 = this.falloff2.getValuef();
    for (LXPoint p : model.points) {
      float yn = (1 - .8 * (p.y - model.yMin) / model.yRange);
      float fv = .3 * falloff * yn;
      float fv2 = .3 * falloff2 * yn;
      float b = max(
        100 - fv * LXUtils.wrapdistf(p.azimuth, aziumuth, PI), 
        100 - fv2 * LXUtils.wrapdistf(p.azimuth, aziumuth2, PI)
        );
      b = max(30, b);
      /*
      if (b > maxb) {
       out("New Max B: %.2f\n", b);
       maxb = b;
       }
       b = b * 100.0 / maxb;*/
      float s = constrain(50 + b/2, 0, 100);
      b = constrain(b, 0, 100);
      colors[p.index] = palette.getColor(b, b);
    }
  }
}

public static class DiamondRain extends LXPattern {
  // by Mark C. Slee

  public final static int NUM_DROPS = 24; 

  public DiamondRain(LX lx) {
    super(lx);
    for (int i = 0; i < NUM_DROPS; ++i) {
      addLayer(new Drop(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }

  public class Drop extends LXLayer {

    public final float MAX_LENGTH = 14*FEET;

    public final SawLFO yPos = new SawLFO(model.yMax + MAX_LENGTH, model.yMin - MAX_LENGTH, 4000 + Math.random() * 3000);
    public float azimuth;
    public float azimuthFalloff;
    public float yFalloff;

    Drop(LX lx) {
      super(lx);
      startModulator(yPos.randomBasis());
      init();
    }

    private void init() {
      this.yPos.setPeriod(2500 + Math.random() * 11000);
      azimuth = (float) Math.random() * TWO_PI;
      azimuthFalloff = 140 + 340 * (float) Math.random();
      yFalloff = 100 / (2*FEET + 12*FEET * (float) Math.random());
    }

    public void run(double deltaMs) {
      float yPos = this.yPos.getValuef();
      if (this.yPos.loop()) {
        init();
      }
      for (LXPoint p : model.points) {
        float yDist = abs(p.y - yPos);
        float azimuthDist = abs(p.azimuth - azimuth); 
        float b = 100 - yFalloff*yDist - azimuthFalloff*azimuthDist;
        if (b > 0) {
          addColor(p.index, palette.getColor(b, b));
        }
      }
    }
  }
}

//public class Azimuth extends LXPattern {

//  public final CompoundParameter azim = new CompoundParameter("Azimuth", 0, TWO_PI);  

//  public Azimuth(LX lx) {
//    super(lx);
//    addParameter("azim", this.azim);
//  }

//  public void run(double deltaMs) {
//    float azim = this.azim.getValuef();
//    for (Branch b : tree.branches) {
//      setColor(b, LX.hsb(0, 0, max(0, 100 - 400 * LXUtils.wrapdistf(b.azimuth, azim, TWO_PI))));
//    }
//  }
//}

//public class AxisTest extends LXPattern {

//  public final CompoundParameter xPos = new CompoundParameter("X", 0);
//  public final CompoundParameter yPos = new CompoundParameter("Y", 0);
//  public final CompoundParameter zPos = new CompoundParameter("Z", 0);

//  public AxisTest(LX lx) {
//    super(lx);
//    addParameter("xPos", xPos);
//    addParameter("yPos", yPos);
//    addParameter("zPos", zPos);
//  }

//  public void run(double deltaMs) {
//    float x = this.xPos.getValuef();
//    float y = this.yPos.getValuef();
//    float z = this.zPos.getValuef();
//    for (LXPoint p : model.points) {
//      float d = abs(p.xn - x);
//      d = min(d, abs(p.yn - y));
//      d = min(d, abs(p.zn - z));
//      colors[p.index] = palette.getColor(p, max(0, 100 - 1000*d));
//    }
//  }
//}

//public class Swarm extends LXPattern {

//  private static final int NUM_GROUPS = 5;

//  public final CompoundParameter speed = new CompoundParameter("Speed", 2000, 10000, 500);
//  public final CompoundParameter base = new CompoundParameter("Base", 10, 60, 1);

//  public final LXModulator[] pos = new LXModulator[NUM_GROUPS];

//  public final LXModulator swarmX = startModulator(new SinLFO(
//    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 17000).randomBasis()))),
//    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 15000).randomBasis()))),
//    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
//  ).randomBasis());

//  public final LXModulator swarmY = startModulator(new SinLFO(
//    startModulator(new SinLFO(0, .2, startModulator(new SinLFO(3000, 9000, 19000).randomBasis()))),
//    startModulator(new SinLFO(.8, 1, startModulator(new SinLFO(4000, 7000, 13000).randomBasis()))),
//    startModulator(new SinLFO(9000, 17000, 33000).randomBasis())
//  ).randomBasis());

//  public Swarm(LX lx) {
//    super(lx);
//    addParameter("speed", speed);
//    addParameter("base", base);
//    for (int i = 0; i < pos.length; ++i) {
//      final int ii = i;
//      pos[i] = new SawLFO(0, LeafAssemblage.NUM_LEAVES, new FunctionalParameter() {
//        public double getValue() {
//          return speed.getValue() + ii*500; 
//      }}).randomBasis();
//      startModulator(pos[i]);
//    }
//  }

//  public void run(double deltaMs) {
//    int i = 0;
//    float base = this.base.getValuef();
//    float swarmX = this.swarmX.getValuef();
//    float swarmY = this.swarmY.getValuef();
//    for (LeafAssemblage assemblage : tree.assemblages) {
//      float pos = this.pos[i++ % NUM_GROUPS].getValuef();
//      for (Leaf leaf : assemblage.leaves) {
//        float falloff = min(100, base + 40 * dist(leaf.points[0].xn, leaf.points[0].yn, swarmX, swarmY));  
//        colors[leaf.points[0].index] = palette.getColor(leaf.point, max(20, 100 - falloff*LXUtils.wrapdistf(leaf.orientation.index, pos, LeafAssemblage.LEAVES.length)));
//      }
//    }
//  }
//}

public abstract class TenerePattern extends LXPattern {

  protected final Kubus model;

  public TenerePattern(LX lx) {
    super(lx);
    this.model = (Kubus) lx.model;
  }

  public abstract String getAuthor();

  public void onActive() {
    // TODO: report via OSC to blockchain
  }

  public void onInactive() {
    // TODO: report via OSC to blockchain
  }
}

public class PatternSolid extends LXPattern {

  public final CompoundParameter h = new CompoundParameter("Hue", 0, 360);
  public final CompoundParameter s = new CompoundParameter("Sat", 0, 100);
  public final CompoundParameter b = new CompoundParameter("Brt", 100, 100);

  public PatternSolid(LX lx) {
    super(lx);
    addParameter("h", this.h);
    addParameter("s", this.s);
    addParameter("b", this.b);
  }

  public void run(double deltaMs) {
    setColors(LXColor.hsb(this.h.getValue(), this.s.getValue(), this.b.getValue()));
  }
}

public class PatternTumbler extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  private LXModulator azimuthRotation = startModulator(new SawLFO(0, 1, 15000).randomBasis());
  private LXModulator thetaRotation = startModulator(new SawLFO(0, 1, 13000).randomBasis());

  public PatternTumbler(LX lx) {
    super(lx);
  }

  public void run(double deltaMs) {
    float azimuthRotation = this.azimuthRotation.getValuef();
    float thetaRotation = this.thetaRotation.getValuef();
    for (Board leaf : model.boards) {
      float tri1 = LXUtils.trif(azimuthRotation + leaf.points[0].azimuth / PI);
      float tri2 = LXUtils.trif(thetaRotation + (PI + leaf.points[0].theta) / PI);
      float tri = max(tri1, tri2);
      setColor(leaf, LXColor.gray(100 * tri * tri));
    }
  }
}

public class PatternBorealis extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter speed =
    new CompoundParameter("Speed", .5, .01, 1)
    .setDescription("Speed of motion");

  public final CompoundParameter scale =
    new CompoundParameter("Scale", .5, .1, 1)
    .setDescription("Scale of lights");

  public final CompoundParameter spread =
    new CompoundParameter("Spread", 6, .1, 10)
    .setDescription("Spreading of the motion");

  public final CompoundParameter base =
    new CompoundParameter("Base", .5, .2, 1)
    .setDescription("Base brightness level");

  public final CompoundParameter contrast =
    new CompoundParameter("Contrast", 1, .5, 2)
    .setDescription("Contrast of the lights");    

  public PatternBorealis(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("scale", this.scale);
    addParameter("spread", this.spread);
    addParameter("base", this.base);
    addParameter("contrast", this.contrast);
  }

  private float yBasis = 0;

  public void run(double deltaMs) {
    this.yBasis -= deltaMs * .0005 * this.speed.getValuef();
    float scale = this.scale.getValuef();
    float spread = this.spread.getValuef();
    float base = .01 * this.base.getValuef();
    float contrast = this.contrast.getValuef();
    for (Board leaf : model.boards) {
      float nv = noise(
        scale * (base * leaf.points[0].rxz - spread * leaf.points[0].yn), 
        leaf.points[0].yn + this.yBasis
        );
      setColor(leaf, LXColor.gray(constrain(contrast * (-50 + 180 * nv), 0, 100)));
    }
  }
}

public class PatternClouds extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter thickness =
    new CompoundParameter("Thickness", 50, 100, 0)
    .setDescription("Thickness of the cloud formation");

  public final CompoundParameter xSpeed = (CompoundParameter)
    new CompoundParameter("XSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the X axis");

  public final CompoundParameter ySpeed = (CompoundParameter)
    new CompoundParameter("YSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the Y axis");

  public final CompoundParameter zSpeed = (CompoundParameter)
    new CompoundParameter("ZSpd", 0, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Motion along the Z axis");

  public final CompoundParameter scale = (CompoundParameter)
    new CompoundParameter("Scale", 3, .25, 10)
    .setDescription("Scale of the clouds")
    .setExponent(2);

  public final CompoundParameter xScale =
    new CompoundParameter("XScale", 0, 0, 10)
    .setDescription("Scale along the X axis");

  public final CompoundParameter yScale =
    new CompoundParameter("YScale", 0, 0, 10)
    .setDescription("Scale along the Y axis");

  public final CompoundParameter zScale =
    new CompoundParameter("ZScale", 0, 0, 10)
    .setDescription("Scale along the Z axis");

  private float xBasis = 0, yBasis = 0, zBasis = 0;

  public PatternClouds(LX lx) {
    super(lx);
    addParameter("thickness", this.thickness);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("scale", this.scale);
    addParameter("xScale", this.xScale);
    addParameter("yScale", this.yScale);
    addParameter("zScale", this.zScale);
  }

  private static final double MOTION = .0005;

  public void run(double deltaMs) {
    this.xBasis -= deltaMs * MOTION * this.xSpeed.getValuef();
    this.yBasis -= deltaMs * MOTION * this.ySpeed.getValuef();
    this.zBasis -= deltaMs * MOTION * this.zSpeed.getValuef();
    float thickness = this.thickness.getValuef();
    float scale = this.scale.getValuef();
    float xScale = this.xScale.getValuef();
    float yScale = this.yScale.getValuef();
    float zScale = this.zScale.getValuef();
    for (Board leaf : model.boards) {
      float nv = noise(
        (scale + leaf.points[0].xn * xScale) * leaf.points[0].xn + this.xBasis, 
        (scale + leaf.points[0].yn * yScale) * leaf.points[0].yn + this.yBasis, 
        (scale + leaf.points[0].zn * zScale) * leaf.points[0].zn + this.zBasis
        );
      setColor(leaf, LXColor.gray(constrain(-thickness + (150 + thickness) * nv, 0, 100)));
    }
  }
}

public class PatternScanner extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Speed that the plane moves at");

  public final CompoundParameter sharp = (CompoundParameter)
    new CompoundParameter("Sharp", 0, -50, 150)
    .setDescription("Sharpness of the falling plane")
    .setExponent(2);

  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlope", 0, -1, 1)
    .setDescription("Slope on the X-axis");

  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlope", 0, -1, 1)
    .setDescription("Slope on the Z-axis");

  private float basis = 0;

  public PatternScanner(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("sharp", this.sharp);
    addParameter("xSlope", this.xSlope);
    addParameter("zSlope", this.zSlope);
  }

  public void run(double deltaMs) {
    float speed = this.speed.getValuef();
    speed = speed * speed * ((speed < 0) ? -1 : 1);
    float sharp = this.sharp.getValuef();
    float xSlope = this.xSlope.getValuef();
    float zSlope = this.zSlope.getValuef();
    this.basis = (float) (this.basis - .001 * speed * deltaMs) % 1.;
    for (Board leaf : model.boards) {
      setColor(leaf, LXColor.gray(max(0, 50 - sharp + (50 + sharp) * LXUtils.trif(leaf.points[0].yn + this.basis + (leaf.points[0].xn-.5) * xSlope + (leaf.points[0].zn-.5) * zSlope))))  ;
    }
  }
}

public class PatternVortex extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter speed = (CompoundParameter)
    new CompoundParameter("Speed", 2000, 9000, 300)
    .setExponent(.5)
    .setDescription("Speed of vortex motion");

  public final CompoundParameter size =
    new CompoundParameter("Size", 4*FEET, 1*FEET, 10*FEET)
    .setDescription("Size of vortex");

  public final CompoundParameter xPos = (CompoundParameter)
    new CompoundParameter("XPos", model.cx, model.xMin, model.xMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-position of vortex center");

  public final CompoundParameter yPos = (CompoundParameter)
    new CompoundParameter("YPos", model.cy, model.yMin, model.yMax)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-position of vortex center");

  public final CompoundParameter xSlope = (CompoundParameter)
    new CompoundParameter("XSlp", .2, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("X-slope of vortex center");

  public final CompoundParameter ySlope = (CompoundParameter)
    new CompoundParameter("YSlp", .5, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Y-slope of vortex center");

  public final CompoundParameter zSlope = (CompoundParameter)
    new CompoundParameter("ZSlp", .3, -1, 1)
    .setPolarity(LXParameter.Polarity.BIPOLAR)
    .setDescription("Z-slope of vortex center");

  private final LXModulator pos = startModulator(new SawLFO(1, 0, this.speed));

  private final LXModulator sizeDamped = startModulator(new DampedParameter(this.size, 5*FEET, 8*FEET));
  private final LXModulator xPosDamped = startModulator(new DampedParameter(this.xPos, model.xRange, 3*model.xRange));
  private final LXModulator yPosDamped = startModulator(new DampedParameter(this.yPos, model.yRange, 3*model.yRange));
  private final LXModulator xSlopeDamped = startModulator(new DampedParameter(this.xSlope, 3, 6));
  private final LXModulator ySlopeDamped = startModulator(new DampedParameter(this.ySlope, 3, 6));
  private final LXModulator zSlopeDamped = startModulator(new DampedParameter(this.zSlope, 3, 6));

  public PatternVortex(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("size", this.size);
    addParameter("xPos", this.xPos);
    addParameter("yPos", this.yPos);
    addParameter("xSlope", this.xSlope);
    addParameter("ySlope", this.ySlope);
    addParameter("zSlope", this.zSlope);
  }

  public void run(double deltaMs) {
    final float xPos = this.xPosDamped.getValuef();
    final float yPos = this.yPosDamped.getValuef();
    final float size = this.sizeDamped.getValuef();
    final float pos = this.pos.getValuef();

    final float xSlope = this.xSlopeDamped.getValuef();
    final float ySlope = this.ySlopeDamped.getValuef();
    final float zSlope = this.zSlopeDamped.getValuef();

    float dMult = 2 / size;
    for (Board leaf : model.boards) {
      float radix = abs((xSlope*abs(leaf.points[0].x-model.cx) + ySlope*abs(leaf.points[0].y-model.cy) + zSlope*abs(leaf.points[0].z-model.cz)));
      float dist = dist(leaf.points[0].x, leaf.points[0].y, xPos, yPos); 
      //float falloff = 100 / max(20*INCHES, 2*size - .5*dist);
      //float b = 100 - falloff * LXUtils.wrapdistf(radix, pos * size, size);
      float b = abs(((dist + radix + pos * size) % size) * dMult - 1);
      setColor(leaf, (b > 0) ? LXColor.gray(b*b*100) : #000000);
    }
  }
}

public class PatternAxisPlanes extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter xSpeed = new CompoundParameter("XSpd", 19000, 31000, 5000).setDescription("Speed of motion on X-axis");
  public final CompoundParameter ySpeed = new CompoundParameter("YSpd", 13000, 31000, 5000).setDescription("Speed of motion on Y-axis");
  public final CompoundParameter zSpeed = new CompoundParameter("ZSpd", 17000, 31000, 5000).setDescription("Speed of motion on Z-axis");

  public final CompoundParameter xSize = new CompoundParameter("XSize", .1, .05, .3).setDescription("Size of X scanner");
  public final CompoundParameter ySize = new CompoundParameter("YSize", .1, .05, .3).setDescription("Size of Y scanner");
  public final CompoundParameter zSize = new CompoundParameter("ZSize", .1, .05, .3).setDescription("Size of Z scanner");

  private final LXModulator xPos = startModulator(new SinLFO(0, 1, this.xSpeed).randomBasis());
  private final LXModulator yPos = startModulator(new SinLFO(0, 1, this.ySpeed).randomBasis());
  private final LXModulator zPos = startModulator(new SinLFO(0, 1, this.zSpeed).randomBasis());

  public PatternAxisPlanes(LX lx) {
    super(lx);
    addParameter("xSpeed", this.xSpeed);
    addParameter("ySpeed", this.ySpeed);
    addParameter("zSpeed", this.zSpeed);
    addParameter("xSize", this.xSize);
    addParameter("ySize", this.ySize);
    addParameter("zSize", this.zSize);
  }

  public void run(double deltaMs) {
    float xPos = this.xPos.getValuef();
    float yPos = this.yPos.getValuef();
    float zPos = this.zPos.getValuef();
    float xFalloff = 100 / this.xSize.getValuef();
    float yFalloff = 100 / this.ySize.getValuef();
    float zFalloff = 100 / this.zSize.getValuef();

    for (Board leaf : model.boards) {
      float b = max(max(
        100 - xFalloff * abs(leaf.points[0].xn - xPos), 
        100 - yFalloff * abs(leaf.points[0].yn - yPos)), 
        100 - zFalloff * abs(leaf.points[0].zn - zPos)
        );
      setColor(leaf, LXColor.gray(max(0, b)));
    }
  }
}

public class PatternAudioMeter extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0)
    .setDescription("Sets the mode of the equalizer");

  public final CompoundParameter size =
    new CompoundParameter("Size", .2, .1, .4)
    .setDescription("Sets the size of the display");

  public PatternAudioMeter(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
    addParameter("size", this.size);
  }

  public void run(double deltaMs) {
    float meter = lx.engine.audio.meter.getValuef();
    float mode = this.mode.getValuef();
    float falloff = 100 / this.size.getValuef();
    for (Board leaf : model.boards) {
      float leafPos = 2 * abs(leaf.points[0].yn - .5);
      float b1 = constrain(50 - falloff * (leafPos - meter), 0, 100);
      float b2 = constrain(50 - falloff * abs(leafPos - meter), 0, 100);
      setColor(leaf, LXColor.gray(lerp(b1, b2, mode)));
    }
  }
}

public abstract class BufferPattern extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter speedRaw = (CompoundParameter)
    new CompoundParameter("Speed", 256, 2048, 64)
    .setExponent(.5)
    .setDescription("Speed of the wave propagation");

  public final LXModulator speed = startModulator(new DampedParameter(speedRaw, 256, 512));

  private static final int BUFFER_SIZE = 4096;
  protected int[] history = new int[BUFFER_SIZE];
  protected int cursor = 0;

  public BufferPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speedRaw);
    for (int i = 0; i < this.history.length; ++i) {
      this.history[i] = #000000;
    }
  }

  public final void run(double deltaMs) {
    // Add to history
    if (--this.cursor < 0) {
      this.cursor = this.history.length - 1;
    }
    this.history[this.cursor] = getColor();
    onRun(deltaMs);
  }

  protected int getColor() {
    return LXColor.gray(100 * getLevel());
  }

  protected float getLevel() {
    return 0;
  }

  abstract void onRun(double deltaMs);
}



public abstract class PatternMelt extends BufferPattern {

  private final float[] multipliers = new float[32];

  public final CompoundParameter level =
    new CompoundParameter("Level", 0)
    .setDescription("Level of the melting effect");

  public final BooleanParameter auto =
    new BooleanParameter("Auto", true)
    .setDescription("Automatically make content");

  public final CompoundParameter melt =
    new CompoundParameter("Melt", .5)
    .setDescription("Amount of melt distortion");

  private final LXModulator meltDamped = startModulator(new DampedParameter(this.melt, 2, 2, 1.5));
  private LXModulator rot = startModulator(new SawLFO(0, 1, 39000)); 
  private LXModulator autoLevel = startModulator(new TriangleLFO(-.5, 1, startModulator(new SinLFO(3000, 7000, 19000))));

  public PatternMelt(LX lx) {
    super(lx);
    addParameter("level", this.level);
    addParameter("auto", this.auto);
    addParameter("melt", this.melt);
    for (int i = 0; i < this.multipliers.length; ++i) {
      float r = random(.6, 1);
      this.multipliers[i] = r * r * r;
    }
  }

  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float rot = this.rot.getValuef();
    float melt = this.meltDamped.getValuef();
    for (Board leaf : model.boards) {
      float az = leaf.points[0].azimuth;
      float maz = (az / TWO_PI + rot) * this.multipliers.length;
      float lerp = maz % 1;
      int floor = (int) (maz - lerp);
      float m = lerp(1, lerp(this.multipliers[floor % this.multipliers.length], this.multipliers[(floor + 1) % this.multipliers.length], lerp), melt);      
      float d = getDist(leaf);
      int offset = round(d * speed * m);
      setColor(leaf, this.history[(this.cursor + offset) % this.history.length]);
    }
  }

  protected abstract float getDist(Board leaf);

  public float getLevel() {
    if (this.auto.isOn()) {
      float autoLevel = this.autoLevel.getValuef();
      if (autoLevel > 0) {
        return pow(autoLevel, .5);
      }
      return 0;
    }
    return this.level.getValuef();
  }
}

public class PatternMeltDown extends PatternMelt {
  public PatternMeltDown(LX lx) {
    super(lx);
  }

  protected float getDist(Board leaf) {
    return 1 - leaf.points[0].yn;
  }
}

public class PatternMeltUp extends PatternMelt {
  public PatternMeltUp(LX lx) {
    super(lx);
  }

  protected float getDist(Board leaf) {
    return leaf.points[0].yn;
  }
}

public class PatternMeltOut extends PatternMelt {
  public PatternMeltOut(LX lx) {
    super(lx);
  }

  protected float getDist(Board leaf) {
    return 2*abs(leaf.points[0].yn - .5);
  }
}


public abstract class WavePattern extends BufferPattern {

  public static final int NUM_MODES = 5; 
  private final float[] dm = new float[NUM_MODES];

  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0, NUM_MODES - 1)
    .setDescription("Mode of the wave motion");

  private final LXModulator modeDamped = startModulator(new DampedParameter(this.mode, 1, 8)); 

  protected WavePattern(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
  }

  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float mode = this.modeDamped.getValuef();
    float lerp = mode % 1;
    int floor = (int) (mode - lerp);
    for (Board leaf : model.boards) {
      dm[0] = abs(leaf.points[0].yn - .5);
      dm[1] = .5 * abs(leaf.points[0].xn - .5) + .5 * abs(leaf.points[0].yn - .5);
      dm[2] = abs(leaf.points[0].xn - .5);
      dm[3] = leaf.points[0].yn;
      dm[4] = 1 - leaf.points[0].yn;

      int offset1 = round(dm[floor] * dm[floor] * speed);
      int offset2 = round(dm[(floor + 1) % dm.length] * dm[(floor + 1) % dm.length] * speed);
      int c1 = this.history[(this.cursor + offset1) % this.history.length];
      int c2 = this.history[(this.cursor + offset2) % this.history.length];
      setColor(leaf, LXColor.lerp(c1, c2, lerp));
    }
  }
}

public class PatternAudioWaves extends WavePattern {

  public final BooleanParameter manual =
    new BooleanParameter("Manual", false)
    .setDescription("When true, uses the manual parameter");

  public final CompoundParameter level =
    new CompoundParameter("Level", 0)
    .setDescription("Manual input level");

  public PatternAudioWaves(LX lx) {
    super(lx);
    addParameter("manual", this.manual);
    addParameter("level", this.level);
  }

  protected float getLevel() {
    return this.manual.isOn() ? this.level.getValuef() : this.lx.engine.audio.meter.getValuef();
  }
} 

public abstract class PatternAudioMelt extends BufferPattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  private final float[] multipliers = new float[32];

  public final CompoundParameter melt =
    new CompoundParameter("Melt", .5)
    .setDescription("Amount of melt distortion");

  private final LXModulator meltDamped = startModulator(new DampedParameter(this.melt, 2, 2, 1.5));
  private LXModulator rot = startModulator(new SawLFO(0, 1, 39000)); 

  public PatternAudioMelt(LX lx) {
    super(lx);
    addParameter("melt", this.melt);  
    for (int i = 0; i < this.multipliers.length; ++i) {
      float r = random(.6, 1);
      this.multipliers[i] = r * r * r;
    }
  }

  public void onRun(double deltaMs) {
    float speed = this.speed.getValuef();
    float rot = this.rot.getValuef();
    float melt = this.meltDamped.getValuef();
    for (Board leaf : model.boards) {
      float az = leaf.points[0].azimuth;
      float maz = (az / TWO_PI + rot) * this.multipliers.length;
      float lerp = maz % 1;
      int floor = (int) (maz - lerp);
      float m = lerp(1, lerp(this.multipliers[floor % this.multipliers.length], this.multipliers[(floor + 1) % this.multipliers.length], lerp), melt);      
      float d = getDist(leaf);
      int offset = round(d * speed * m);
      setColor(leaf, this.history[(this.cursor + offset) % this.history.length]);
    }
  }

  protected abstract float getDist(Board leaf);

  public float getLevel() {
    return this.lx.engine.audio.meter.getValuef();
  }
} 

public class PatternAudioMeltDown extends PatternAudioMelt {
  public PatternAudioMeltDown(LX lx) {
    super(lx);
  }

  public float getDist(Board leaf) {
    return 1 - leaf.points[0].yn;
  }
}

public class PatternAudioMeltUp extends PatternAudioMelt {
  public PatternAudioMeltUp(LX lx) {
    super(lx);
  }

  public float getDist(Board leaf) {
    return leaf.points[0].yn;
  }
}

public class PatternAudioMeltOut extends PatternAudioMelt {
  public PatternAudioMeltOut(LX lx) {
    super(lx);
  }

  public float getDist(Board leaf) {
    return 2 * abs(leaf.points[0].yn - .5);
  }
}

public class PatternSirens extends TenerePattern {
  public String getAuthor() {
    return "Mark C. Slee";
  }

  public final CompoundParameter base =
    new CompoundParameter("Base", 20, 0, 60)
    .setDescription("Base brightness level");

  public final CompoundParameter speed1 = new CompoundParameter("Spd1", 9000, 19000, 5000).setDescription("Speed of siren 1");
  public final CompoundParameter speed2 = new CompoundParameter("Spd2", 9000, 19000, 5000).setDescription("Speed of siren 2");
  public final CompoundParameter speed3 = new CompoundParameter("Spd3", 9000, 19000, 5000).setDescription("Speed of siren 3");
  public final CompoundParameter speed4 = new CompoundParameter("Spd4", 9000, 19000, 5000).setDescription("Speed of siren 4");

  public final CompoundParameter size1 = new CompoundParameter("Sz1", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 1");
  public final CompoundParameter size2 = new CompoundParameter("Sz2", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 2");
  public final CompoundParameter size3 = new CompoundParameter("Sz3", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 3");
  public final CompoundParameter size4 = new CompoundParameter("Sz4", PI / 8, PI / 32, HALF_PI).setDescription("Size of siren 4");

  public final BooleanParameter reverse = new BooleanParameter("Reverse", false); 

  public final LXModulator azim1 = startModulator(new SawLFO(0, TWO_PI, this.speed1).randomBasis());
  public final LXModulator azim2 = startModulator(new SawLFO(TWO_PI, 0, this.speed2).randomBasis());
  public final LXModulator azim3 = startModulator(new SawLFO(0, TWO_PI, this.speed3).randomBasis());
  public final LXModulator azim4 = startModulator(new SawLFO(TWO_PI, 0, this.speed2).randomBasis());

  public PatternSirens(LX lx) {
    super(lx);
    addParameter("speed1", this.speed1);
    addParameter("speed2", this.speed2);
    addParameter("speed3", this.speed3);
    addParameter("speed4", this.speed4);
    addParameter("size1", this.size1);
    addParameter("size2", this.size2);
    addParameter("size3", this.size3);
    addParameter("size4", this.size4);
  }

  public void run(double deltaMs) {
    float azim1 = this.azim1.getValuef();
    float azim2 = this.azim2.getValuef();
    float azim3 = this.azim3.getValuef();
    float azim4 = this.azim3.getValuef();
    float falloff1 = 100 / this.size1.getValuef();
    float falloff2 = 100 / this.size2.getValuef();
    float falloff3 = 100 / this.size3.getValuef();
    float falloff4 = 100 / this.size4.getValuef();
    for (Board leaf : model.boards) {
      float azim = leaf.points[0].azimuth;
      float dist = max(max(max(
        100 - falloff1 * LXUtils.wrapdistf(azim, azim1, TWO_PI), 
        100 - falloff2 * LXUtils.wrapdistf(azim, azim2, TWO_PI)), 
        100 - falloff3 * LXUtils.wrapdistf(azim, azim3, TWO_PI)), 
        100 - falloff4 * LXUtils.wrapdistf(azim, azim4, TWO_PI)
        );
      setColor(leaf, LXColor.gray(max(0, dist)));
    }
  }
}
