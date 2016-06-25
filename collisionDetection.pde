
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