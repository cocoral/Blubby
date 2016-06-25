float drag = 0.9;

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