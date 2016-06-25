class Cell {
  ArrayList<Point> cellWall = new ArrayList<Point>();
  ArrayList<Cell> bubbles = new ArrayList<Cell>();
  float wallK = 0.5;
  float innerK = 0.001;
  float innerBubbleF = 1;
  int r = int(random(0, 200));
  int g = int(random(0, 200));
  int b = int(random(0, 200));
  
  int size() {
    return cellWall.size();
  }
  
  float decayRate() {
   return 0.01 * (size()*size()*0.001);
  }
  
  Cell(float x, float y, int size) {
    float rad = 1.0 / size * 2*PI;
    float radius = 1;
    for (int i = 0; i < size; i++) {
      cellWall.add(
        new Point(x + radius * cos(i * rad), 
        y + radius * sin(i * rad)));
    }
  }
  
  Point center(){
    float sumX = 0;
    float sumY = 0;
    for (Point point : cellWall) {
      sumX = sumX + point.x;
      sumY = sumY + point.y;
    }
    return new Point(sumX/size(), sumY/size());
    
  }
  
  float wallL() {
    if (this == player) {
      if (keys.space) {
        wallK = 0.2;
        innerK = 1;//0.01;
        return 5;
      }
      if (keys.shift) {
        wallK = 0.05;
        innerK = 0.00001;
        return 20;
      }
    }
    wallK = 0.2;
    innerK = 0.001;
    return 10;
  }

  float innerSpringL() {
    return cellWall.size() * wallL() / PI;
  }

  void addForce(float fx, float fy) {
    for (Point p : cellWall) {
      p.vx += fx;
      p.vy += fy;
    }
  }

  void addPoint() {
    if ( size() == 0 ){
      return;
    }
    
    int aNumber = (int)random(0, cellWall.size());

    Point aPoint = cellWall.get(aNumber);
    Point aFriendPoint = cellWall.get((aNumber+1) % cellWall.size());

    cellWall.add(aNumber, new Point((aPoint.x + aFriendPoint.x) / 2, (aPoint.y + aFriendPoint.y) / 2));
  }
  
  void shrink(int n) {
    if (n <= 0 || size() == 0) {
      return;
    }
    cellWall.remove((int)random(0, cellWall.size()));
    shrink(n - 1);
  }

  void update() {
    if (cellWall.size() == 0) {
      return;
    }

    for (Point point : cellWall) {
      point.update();
    }

    Point prev = cellWall.get(0);
    for (int i = 1; i < cellWall.size(); i++) {
      Point point = cellWall.get(i);
      spring(prev, point, wallK, wallL());
      prev = point;
    }
    spring(cellWall.get(0), prev, wallK, wallL());

    for (int i = 0; i < cellWall.size(); i++) {
      Point a = cellWall.get(i);
      for (int j = i+1; j < cellWall.size(); j++) {
        Point b = cellWall.get(j);
        spring(a, b, innerK * 0.1, innerSpringL());
        nucleusForce(a, b, this, this);
      }
    }

    ArrayList<Cell> cellToRemove = new ArrayList<Cell>();
    for (Cell cell : bubbles) {
      cell.update();

      for (Point innerPoint : cell.cellWall) {
        for (Point point : cellWall) {
          nucleusForce(point, innerPoint, this, cell);
          //attract(point, innerPoint, -innerBubbleF);
        }
        //attract(nucleus, innerPoint, -innerBubbleF * 10);
      }

      if (!isCellContained(cell, this)) {
        cellsToAdd.add(cell);
        cellToRemove.add(cell);
      } else if (random(1) < 0.1 && cell.size() != 0) { // eating the bubblnes
        cell.cellWall.remove(cell.size() - 1);
        addPoint();
        float p = 1.0/this.cellWall.size();
        this.r = int(this.r*(1-p)+cell.r*p);
        this.g = int(this.g*(1-p)+cell.g*p);
        this.b = int(this.b*(1-p)+cell.b*p);

        if (cell.cellWall.size() == 0) {
          cellToRemove.add(cell);
        }
      }
    }
    for (Cell cell : cellToRemove) {
      bubbles.remove(cell);
    }

    for (int i = 0; i < bubbles.size(); i ++) {
      Cell a = bubbles.get(i);
      for (int j = i+1; j < bubbles.size(); j++) {
        Cell b = bubbles.get(j);
        for (Point point : a.cellWall) {
          for (Point innerPoint : b.cellWall) {
            nucleusForce(point, innerPoint, a, b);
            //attract(point, innerPoint, -0.001);
          }
        }
      }
    }
  }

  void draw() {
    if (cellWall.size() == 0) {
      //println("empty cell");
      return;
    }

    PShape cellShape;  // The PShape object

    cellShape = createShape();
    cellShape.beginShape();
    cellShape.fill(r, g, b, 100);
    //cellShape.strokeWeight(0);
    //cellShape.strokeJoin(ROUND);
    cellShape.noStroke();
    for (int i = 0; i < cellWall.size(); i++) {
      Point point = cellWall.get(i);
      cellShape.vertex(point.x, point.y);
    }
    cellShape.vertex(cellWall.get(0).x, cellWall.get(0).y);
    cellShape.endShape();
    shape(cellShape, 0, 0);


    for (Cell cell : bubbles) {
      cell.draw();
    }
  }

  boolean containsPoint(Point p) {
    boolean c = false;
    for (int i = 0; i < cellWall.size(); i++) {
      int j = i + 1;
      if (i == cellWall.size() - 1) {
        j = 0;
      }
      Point a = cellWall.get(i);
      Point b = cellWall.get(j);
      if (((a.y >= p.y) != (b.y >= p.y)) &&
        (p.x <= (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x)) {
        c = !c;
      }
    }
    return c;
  }
}