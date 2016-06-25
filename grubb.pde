class Grubb extends Cell {

  int generation = 0; 

  Grubb(float x, float y) {
    super(x, y, 3);
    this.r = 0;
    this.g = 0; 
    this.b = 255;
  }

  float decayRate() {
    return 0;
  }

  void update() {
    super.update();
    generation += 1;
    
    if (random(1) < 0.01) {
      addPoint();
    } 


    if (generation > 600 ) {
      shrink(size());
    }

    if (size() > 6 ) {
      shrink (size() / 2); 
      Point c = center();
      float dx = random(-1, 1);
      float n;
      if (random(1)< 0.5) {
        n = -1;
      } else {
        n = 1;
      }
      float dy = n * sqrt (1- dx * dx );
      cellsToAdd.add(new Grubb(c.x + dx, c.y + dy ));
    }
    
  }
}