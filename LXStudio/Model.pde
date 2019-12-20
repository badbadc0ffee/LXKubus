LXModel buildModel() {
  return new Board();
}

public static class Board extends LXModel {

  public final static int   SIZE    = 12;
  public final static float SPACING = 50/3 * MM;

  public Board() {
    super(new Fixture(new LXVector(0, 0, -SIZE/2*SPACING), new LXVector(SPACING, 0, 0), new LXVector(0, -SPACING, 0)));
  }

  public static class Fixture extends LXAbstractFixture {
    Fixture(LXVector origin, LXVector colstep, LXVector rowstep) {
      LXVector pos = origin;
      pos.sub(colstep.mult((SIZE/2+0.5)));
      pos.sub(rowstep.mult((SIZE/2+0.5)));
      for (int row = 0; row < SIZE; ++row) {
        for (int col = 0; col < SIZE; ++col) {
          addPoint(new LXPoint(pos));
          if (col < SIZE-1) {
            if (row %2 ==0) {
              pos.add(colstep);
            } else {
              pos.sub(colstep);
            }
          }
        }
        pos.add(rowstep);
      }
    }
  }
}
