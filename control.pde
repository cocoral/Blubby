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