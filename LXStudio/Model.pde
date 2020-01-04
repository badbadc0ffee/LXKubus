public final static int   SIZE    = 12;
public final static int   MAX_X   = SIZE-1;
public final static int   MAX_Y   = SIZE-1;
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
    updateNeighbors();
    for (Board b : boards)
      b.updateNeighbors();
  }
  public static class Fixture extends LXAbstractFixture {
    static Board boards[] = { 
      new Board(new LXVector( 0, 0, -WIDTH/2), new LXVector(SPACING, 0, 0), new LXVector(0, -SPACING, 0), 0), 
      new Board(new LXVector( 0, +WIDTH/2, 0), new LXVector(SPACING, 0, 0), new LXVector(0, 0, -SPACING), 3), 
      new Board(new LXVector( -WIDTH/2, 0, 0), new LXVector(0, SPACING, 0), new LXVector(0, 0, -SPACING), 2), 
      new Board(new LXVector( 0, 0, +WIDTH/2), new LXVector(0, SPACING, 0), new LXVector(-SPACING, 0, 0), 2), 
      new Board(new LXVector( 0, -WIDTH/2, 0), new LXVector(0, 0, SPACING), new LXVector(-SPACING, 0, 0), 3), 
      new Board(new LXVector( +WIDTH/2, 0, 0), new LXVector(0, 0, SPACING), new LXVector(0, -SPACING, 0), 0)
    };
    Fixture() {
      for (Board board : boards)
        addPoints(board);
    }
  }

  private void updateNeighbors() {
    boards[0].neighbors[0] = boards[1];
    boards[0].neighbors[1] = boards[1];
    boards[0].neighbors[2] = boards[5];
    boards[0].neighbors[4] = boards[4];
    boards[0].neighbors[5] = boards[2];
    boards[0].neighbors[6] = boards[2];

    boards[1].neighbors[0] = boards[2];
    boards[1].neighbors[1] = boards[2];
    boards[1].neighbors[2] = boards[3];
    boards[1].neighbors[4] = boards[5];
    boards[1].neighbors[5] = boards[0];
    boards[1].neighbors[6] = boards[0];

    boards[2].neighbors[0] = boards[0];
    boards[2].neighbors[1] = boards[0];
    boards[2].neighbors[2] = boards[4];
    boards[2].neighbors[4] = boards[3];
    boards[2].neighbors[5] = boards[1];
    boards[2].neighbors[6] = boards[1];

    boards[3].neighbors[0] = boards[2];
    boards[3].neighbors[1] = boards[4];
    boards[3].neighbors[2] = boards[4];
    boards[3].neighbors[4] = boards[5];
    boards[3].neighbors[5] = boards[5];
    boards[3].neighbors[6] = boards[1];

    boards[4].neighbors[0] = boards[0];
    boards[4].neighbors[1] = boards[5];
    boards[4].neighbors[2] = boards[5];
    boards[4].neighbors[4] = boards[3];
    boards[4].neighbors[5] = boards[3];
    boards[4].neighbors[6] = boards[2];

    boards[5].neighbors[0] = boards[1];
    boards[5].neighbors[1] = boards[3];
    boards[5].neighbors[2] = boards[3];
    boards[5].neighbors[4] = boards[4];
    boards[5].neighbors[5] = boards[4];
    boards[5].neighbors[6] = boards[0];

    for (int board=0; board<6; ++board) {
      boards[board].neighbors[3] = boards[board].neighbors[2];
      boards[board].neighbors[7] = boards[board].neighbors[6];
    }
  }
}

static class KubusPoint extends LXPoint {
  KubusPoint neighbors[];
  KubusPoint(LXVector pos) {
    super(pos);
    neighbors = new KubusPoint[8];
  }
};

public static class Board extends LXModel {
  int rotation;
  Board neighbors[];
  Board(LXVector origin, LXVector colstep, LXVector rowstep, int rotation) {
    super(new Fixture(origin, colstep, rowstep));
    this.rotation = rotation;
    neighbors = new Board[8];
  }
  KubusPoint xy(int x, int y) {
    int col = x;
    int row = y;
    switch (rotation) {
    case 1:
      col = MAX_Y-y;
      row = x;
      break;
    case 2:
      col = MAX_X-x;
      row = MAX_Y-y;
      break;
    case 3:
      col = y;
      row = MAX_X-x;
      break;
    }
    if (row%2 != 0) col = MAX_X-col;
    return (KubusPoint)points[row*SIZE+col];
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
      for (int row = 0; row <= MAX_Y; ++row) {
        for (int col = 0; col <= MAX_X; ++col) {
          KubusPoint point = new KubusPoint(pos);
          addPoint(point);
          boolean evenrow = (row % 2) == 0;
          boolean lastcol = col == MAX_X;
          if (lastcol) {
            pos.add(rowstep);
          } else {
            if (evenrow) {
              pos.add(colstep);
            } else {
              pos.sub(colstep);
            }
          }
        }
      }
    }
  }
  public void updateNeighbors() {
    int board = xy(0, 0).index/144;

    for (int row = 1; row < MAX_Y; ++row) {
      for (int col = 1; col < MAX_X; ++col) {
        xy(col, row).neighbors[0] = xy(  col, row-1);
        xy(col, row).neighbors[1] = xy(col+1, row-1);
        xy(col, row).neighbors[2] = xy(col+1, row);
        xy(col, row).neighbors[3] = xy(col+1, row+1);
        xy(col, row).neighbors[4] = xy(  col, row+1);
        xy(col, row).neighbors[5] = xy(col-1, row+1);
        xy(col, row).neighbors[6] = xy(col-1, row);
        xy(col, row).neighbors[7] = xy(col-1, row-1);
      }
    }

    for (int row = 0; row <= MAX_Y; ++row) {
      xy(0, row).neighbors[2] = xy(1, row);
      xy(0, row).neighbors[6] = board<3 ? neighbors[6].xy(row, 0) : neighbors[6].xy(MAX_X, row);
      xy(MAX_X, row).neighbors[2] = board<3 ? neighbors[2].xy(0, row) : neighbors[2].xy(row, MAX_Y);
      xy(MAX_X, row).neighbors[6] = xy(MAX_X-1, row);
      if (row!=0) {
        xy(0, row).neighbors[7] = board<3 ? neighbors[6].xy(row-1, 0) : neighbors[6].xy(MAX_X, row-1);
        xy(0, row).neighbors[0] = xy(0, row-1);
        xy(0, row).neighbors[1] = xy(1, row-1);
        xy(MAX_X, row).neighbors[7] = xy(MAX_X-1, row-1);
        xy(MAX_X, row).neighbors[0] = xy(MAX_X, row-1);
        xy(MAX_X, row).neighbors[1] = board<3 ? neighbors[2].xy(0, row-1) : neighbors[2].xy(row-1, MAX_Y);
      }
      if (row!=MAX_Y) {
        xy(0, row).neighbors[3] = xy(1, row+1);
        xy(0, row).neighbors[4] = xy(0, row+1);
        xy(0, row).neighbors[5] = board<3 ? neighbors[6].xy(row+1, 0) : neighbors[6].xy(MAX_X, row+1);
        xy(MAX_X, row).neighbors[3] = board<3 ? neighbors[2].xy(0, row+1) : neighbors[2].xy(row+1, MAX_Y);
        xy(MAX_X, row).neighbors[4] = xy(MAX_X, row+1);
        xy(MAX_X, row).neighbors[5] = xy(MAX_X-1, row+1);
      }
    }

    for (int col = 0; col <= MAX_X; ++col) {
      xy(col, 0).neighbors[0] = board<3 ? neighbors[0].xy(0, col) : neighbors[0].xy(col, MAX_Y);
      xy(col, MAX_Y).neighbors[0] = xy(col, MAX_Y-1);
      xy(col, 0).neighbors[4] = xy(col, 1);
      xy(col, MAX_Y).neighbors[4] = board<3 ? neighbors[4].xy(col, 0) : neighbors[4].xy(MAX_X, col);
      if (col!=MAX_X) {
        xy(col, 0).neighbors[1] = board<3 ? neighbors[0].xy(0, col+1) : neighbors[0].xy(col+1, MAX_Y);
        xy(col, 0).neighbors[2] = xy(col+1, 0);
        xy(col, 0).neighbors[3] = xy(col+1, 1);
        xy(col, MAX_Y).neighbors[1] = xy(col+1, MAX_Y-1);
        xy(col, MAX_Y).neighbors[2] = xy(col+1, MAX_Y);
        xy(col, MAX_Y).neighbors[3] = board<3 ? neighbors[4].xy(col+1, 0) : neighbors[4].xy(MAX_X, col+1);
      }
      if (col!=0) {
        xy(col, 0).neighbors[5] = xy(col-1, 1);
        xy(col, 0).neighbors[6] = xy(col-1, 0);
        xy(col, 0).neighbors[7] = board<3 ? neighbors[0].xy(0, col-1) : neighbors[0].xy(col-1, MAX_Y);
        xy(col, MAX_Y).neighbors[5] = board<3 ? neighbors[4].xy(col-1, 0) : neighbors[4].xy(MAX_X, col-1);
        xy(col, MAX_Y).neighbors[6] = xy(col-1, MAX_Y);
        xy(col, MAX_Y).neighbors[7] = xy(col-1, MAX_Y-1);
      }
    }

    xy(0, 0).neighbors[7] = xy(0, 0);
    xy(MAX_X, 0).neighbors[1] = neighbors[1].xy(0, MAX_Y);
    xy(0, MAX_Y).neighbors[5] = neighbors[5].xy(MAX_X, 0);
    xy(MAX_X, MAX_Y).neighbors[3] = xy(MAX_X, MAX_Y);
  }
}
