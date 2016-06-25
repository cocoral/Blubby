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