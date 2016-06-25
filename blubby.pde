import java.awt.event.KeyEvent;

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

void update() {
  controls();
  
  if (random(1) < 0.01) {
    //cellsToAdd.add(new Cell(random(0, width), random(0, height), (int) (random(5, 50))));
    cellsToAdd.add(new Grubb(random(0, width), random(0, height)));
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
    
    if (random(1) < cell.decayRate()) {
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