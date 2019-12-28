public final static int   SIZE    = 12;
public final static float WIDTH   = 200*MM;
public final static float SPACING = 50*MM/3;

LXModel buildModel() {
  return new Kubus();
}

public static class Kubus extends LXModel {
  Board boards[];
  public Kubus() {
    super(new Fixture());
    boards = Fixture.boards;
  }
  public static class Fixture extends LXAbstractFixture {
    static Board boards[] = { 
      new Board(new LXVector(       0,        0, -WIDTH/2), new LXVector(SPACING,      0,      0), new LXVector(       0, -SPACING,       0)),
      new Board(new LXVector(       0,  WIDTH/2,        0), new LXVector(SPACING,      0,      0), new LXVector(       0,        0,-SPACING)),
      new Board(new LXVector(-WIDTH/2,        0,        0), new LXVector(      0,SPACING,      0), new LXVector(       0,        0,-SPACING)),
      new Board(new LXVector(       0,        0,  WIDTH/2), new LXVector(      0,SPACING,      0), new LXVector(-SPACING,        0,       0)),
      new Board(new LXVector(       0, -WIDTH/2,        0), new LXVector(      0,      0,SPACING), new LXVector(-SPACING,        0,       0)),
      new Board(new LXVector( WIDTH/2,        0,        0), new LXVector(      0,      0,SPACING), new LXVector(       0, -SPACING,       0)),
    };
    Fixture() {
      for (Board board : boards)
        addPoints(board);
    }
  }
}

public static class Board extends LXModel {
  public Board(LXVector origin, LXVector colstep, LXVector rowstep) {
    super(new Fixture(origin, colstep, rowstep));
  }
  public static class Fixture extends LXAbstractFixture {
    Fixture(LXVector origin, LXVector colstep, LXVector rowstep) {
      LXVector pos = origin
        .sub(new LXVector(colstep).mult(SIZE/2-0.5))
        .sub(new LXVector(rowstep).mult(SIZE/2-0.5))
        .rotate((float)Math.toRadians(-45), 0, 0, 1)
        .rotate((float)Math.acos(Math.sqrt((double)2/3)), 1, 0, 0);
      colstep
        .rotate((float)Math.toRadians(-45), 0, 0, 1)
        .rotate((float)Math.acos(Math.sqrt((double)2/3)), 1, 0, 0);
      rowstep
        .rotate((float)Math.toRadians(-45), 0, 0, 1)
        .rotate((float)Math.acos(Math.sqrt((double)2/3)), 1, 0, 0);
      for (int row = 0; row < SIZE; ++row) {
        for (int col = 0; col < SIZE; ++col) {
          addPoint(new LXPoint(pos));
          if (col < SIZE-1) {
            if (row%2 ==0) {
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
