import java.awt.event.KeyEvent;

float drag = 0.9;

class Point {
  float x, y, vx, vy;
  
  Point(float x, float y) {
    this.x = x;
    this.y = y;
    this.vx = random(-1, 1);
    this.vy = random(-1, 1);
  }
  
  void update() {
    x += vx;
    y += vy;
    vx *= drag;
    vy *= drag;
  }
  
  void draw() {
    fill(255, 255, 255);
    ellipse(x, y, 2, 2);
  }
}

void spring(Point a, Point b, float k, float l) {
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  float d = max(1, sqrt(dx * dx + dy * dy));
  float force = (l - d) * k;
  float fx = dx / d * force;
  float fy = dy / d * force;
  
  a.vx -= fx;
  a.vy -= fy;
  b.vx += fx;
  b.vy += fy;
}

void attract(Point a, Point b, float f) {
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  float d = max(1, sqrt(dx * dx + dy * dy));
  float force = f / (d * d);
  float fx = dx / d * force;
  float fy = dy / d * force;
  
  a.vx += fx;
  a.vy += fy;
  b.vx -= fx;
  b.vy -= fy;
}

void nucleusForce(Point a, Point b, Cell cellA, Cell cellB) {
  float dx = b.x - a.x;
  float dy = b.y - a.y;
  float d = max(5, sqrt(dx * dx + dy * dy));
  float force = min(5, 5 * 1 / d * max(0, min(cellA.wallL(), cellB.wallL()) * 1 - d));
  float fx = dx / d * force;
  float fy = dy / d * force;
  
  a.vx -= fx;
  a.vy -= fy;
  b.vx += fx;
  b.vy += fy;
}

class Cell {
  ArrayList<Point> cellWall = new ArrayList<Point>();
  ArrayList<Cell> bubbles = new ArrayList<Cell>();
  float wallK = 0.5;
  float innerK = 0.001;
  float innerBubbleF = 1;
  int r = int(random(0,200));
  int g = int(random(0,200));
  int b = int(random(0,200));
  
  
  
  Cell(float x, float y, int size) {
    float rad = 1.0 / size * 2*PI;
    float radius = 1;
    for (int i = 0; i < size; i++) {
      cellWall.add(
        new Point(x + radius * cos(i * rad),
                  y + radius * sin(i * rad)));
    }
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
    for (Point p: cellWall) {
      p.vx += fx;
      p.vy += fy;
    }
  }
  
  void addPoint() {
    int aNumber = (int)random(0, cellWall.size());
    
    Point aPoint = cellWall.get(aNumber);
    Point aFriendPoint = cellWall.get((aNumber+1) % cellWall.size());
    
    cellWall.add(aNumber, new Point((aPoint.x + aFriendPoint.x) / 2, (aPoint.y + aFriendPoint.y) / 2));
  }

  void update() {
    if (cellWall.size() == 0) {
      print("empty cell update");
      return;
    }
    
    for (Point point: cellWall) {
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
    for (Cell cell: bubbles) {
      cell.update();
      
      for (Point innerPoint: cell.cellWall) {
        for (Point point: cellWall) {
          nucleusForce(point, innerPoint, this, cell);
          //attract(point, innerPoint, -innerBubbleF);
        }
        //attract(nucleus, innerPoint, -innerBubbleF * 10);
      }
      
      if (!isCellContained(cell, this)) {
        cellsToAdd.add(cell);
        cellToRemove.add(cell);
      } else if (random(1) < 0.1) { // eating the bubblnes
        cell.cellWall.remove(cell.cellWall.size() - 1);
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
    for (Cell cell: cellToRemove) {
      bubbles.remove(cell);
    }
    
    for (int i = 0; i < bubbles.size(); i ++) {
      Cell a = bubbles.get(i);
      for (int j = i+1; j < bubbles.size(); j++) {
        Cell b = bubbles.get(j);
        for (Point point: a.cellWall) {
          for (Point innerPoint: b.cellWall) {
            nucleusForce(point, innerPoint, a, b);
            //attract(point, innerPoint, -0.001);
          }
        }
      }
    }
  }
  
  void draw() {
    if (cellWall.size() == 0) {
      println("empty cell");
      return;
    }
    
    PShape cellShape;  // The PShape object

    cellShape = createShape();
    cellShape.beginShape();
    cellShape.fill(r,g,b,40);
    //cellShape.strokeWeight(0);
    //cellShape.strokeJoin(ROUND);
    cellShape.noStroke();
    for (int i = 0; i < cellWall.size();i++){
      Point point = cellWall.get(i);
      cellShape.vertex(point.x, point.y);
    }
    cellShape.vertex(cellWall.get(0).x, cellWall.get(0).y);
    cellShape.endShape();
    shape(cellShape, 0, 0);
    
    
    for (Cell cell: bubbles) {
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

class Keys {
  boolean up, down, left, right, shift, space;
  
  void keyPressed() {
    switch (keyCode) {
      case UP: up = true; break;
      case DOWN: down = true; break;
      case LEFT: left = true; break;
      case RIGHT: right = true; break;
      case SHIFT: shift = true; break;
      case KeyEvent.VK_SPACE: space = true; break;
    }
  }
  
  void keyReleased() {
    switch (keyCode) {
      case UP: up = false; break;
      case DOWN: down = false; break;
      case LEFT: left = false; break;
      case RIGHT: right = false; break;
      case SHIFT: shift = false; break;
      case KeyEvent.VK_SPACE: space = false; break;
    }
  }
}
ArrayList<Cell> cells = new ArrayList<Cell>();
ArrayList<Cell> cellsToAdd = new ArrayList<Cell>();
Cell player;
Keys keys = new Keys();

void setup() {
  size(displayWidth, displayHeight);
  player = new Cell(width / 2, height / 2, 30);
  cells.add(player);
  cells.add(new Cell(random(0, width), random(0, height), 5));
  //player.bubbles.add(new Cell(width / 2, height / 2, 10));
  //player.bubbles.add(new Cell(width / 2, height / 2, 10));
}

boolean isCellContained(Cell a, Cell b) {
  boolean allIn = true;
  for (Point p: a.cellWall) {
    if (!b.containsPoint(p)) {
      allIn = false;
    }
  }
  return allIn;
}

boolean areCellsIntersecting(Cell a, Cell b) {
  for (Point p: a.cellWall) {
    if (b.containsPoint(p)) {
      return true;
    }
  }
  for (Point p: b.cellWall) {
    if (a.containsPoint(p)) {
      return true;
    }
  }
  return false;
}

void checkOverlap() {
  ArrayList<Cell> toRemove = new ArrayList<Cell>();
  
  for (int i = 0; i < cells.size(); i++) {
    Cell a = cells.get(i);
    for (int j = 0; j < cells.size(); j++) {
      if (i == j) {
        continue;
      }
      Cell b = cells.get(j);
      if (toRemove.contains(a)) {
        continue;
      }
      boolean contained = isCellContained(a, b);
      if (contained) {
        toRemove.add(a);
        b.bubbles.add(a);
      }
    }
  }
  
  for (Cell cell: toRemove) {
    cells.remove(cell);
  }
  
  for (int i = 0; i < cells.size(); i++) {
    Cell a = cells.get(i);
    for (int j = i + 1; j < cells.size(); j++) {
      Cell b = cells.get(j);
      if (areCellsIntersecting(a, b)) {
        for (int k = 0; k < a.cellWall.size(); k++) {
          Point aPoint = a.cellWall.get(k);
          for (int l = 0; l < b.cellWall.size(); l++) {
            Point bPoint = b.cellWall.get(l);
            if (b.containsPoint(aPoint) || a.containsPoint(bPoint)) {
              nucleusForce(aPoint, bPoint, a, b);
              spring(aPoint, bPoint, 0.00005, min(a.innerSpringL(), b.innerSpringL()) / 2); 
            }
            
          }
        }
      }
    }
  }
}

void keyReleased() {
  keys.keyReleased();
}

void controls() {
  if (keyPressed) {
    keys.keyPressed();
  }
  
  float dx = 0; //mouseX - player.nucleus.x;
  float dy = 0; //mouseY - player.nucleus.y;
  if (keys.up) {
    dy -= 1;
  }
  if (keys.down) {
    dy += 1;
  }
  
  if (keys.left) {
    dx -= 1;
  }
  if (keys.right) {
    dx += 1;
  }
  float d = max(1, sqrt(dx * dx + dy * dy));
  
  float f = 0.5;
  player.addForce(dx / d * f, dy / d * f);
}

void update() {
  controls();
  
  if (random(1) < 0.01) {
    cellsToAdd.add(new Cell(random(0, width), random(0, height), (int) (random(5, 50))));
  }
  
  for (Cell cell: cellsToAdd) {
    cells.add(cell);
  }
  
  cellsToAdd.clear();
  
  for (int i = 0; i < cells.size(); i ++) {
    Cell a = cells.get(i);
    for (int j = i+1; j < cells.size(); j++) {
      Cell b = cells.get(j);
      if (areCellsIntersecting(a, b)) {
        continue;
      }
      for (Point point: a.cellWall) {
        for (Point innerPoint: b.cellWall) {
          nucleusForce(point, innerPoint, a, b);
        }
      }
    }
  }
  
  ArrayList<Cell> cellsToRemove = new ArrayList<Cell>();
  for (Cell cell: cells) {
    cell.update();
    if (random(1) < 0.01) {
      cell.cellWall.remove((int) random(0, cell.cellWall.size()));
      if (cell.cellWall.size() == 0) {
        cellsToRemove.add(cell);
      }
    }
  }
  for (Cell cell: cellsToRemove) {
    cells.remove(cell);
  }
  
  checkOverlap();
}

void draw() {
  background(255);
  update();
  
  for (Cell cell: cells) {
    cell.draw();
    if (cell.containsPoint(new Point(mouseX, mouseY))) {
      fill(0, 0, 255);
      ellipse(mouseX, mouseY, 20, 20);
    }
  }
}