
import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

Pixel[][] tree;
Pixel[][] walkers;

int savedTime;
int gravityCenterX;
int gravityCenterY;

float colorOffset = 255;
float GRAVITY_STRENGTH = 0.8;
int NUMBER_OF_WALKERS = 20000;
float CIRCLE_RADIUS_PERCENT = 0.5;
boolean SHOULD_DISPLAY_WALKERS = true;
int TIME_BETWEEN_GRAVITY_CHANGES = 10;


class Pixel {
  int column;
  int row;
  boolean stuck;

  Pixel(boolean stuck, int column, int row) {
    this.stuck = stuck;
    this.column = column;
    this.row = row;
  }

  String toString() {
    return column + " " + row;
  }
}

void setup() {
  //size(1280, 1000);
  //size(500, 500);
  fullScreen();
  
  pixelDensity(1);
  
  background(0);
  
  setupEmptyArrays();

  addInitialTree();

  addInitialWalkers();
  
  
  randomizeGravityCenter();
  savedTime = millis();
}


void draw() {
  

  
  int passedTime = millis()-savedTime;
  if (passedTime > TIME_BETWEEN_GRAVITY_CHANGES * 1000) {
    savedTime = millis();
    
    randomizeGravityCenter();
  }

  loadPixels();

  //loop over each row & column
  int random = (int) (Math.random() * 3);
  
  switch(random) {
  case 0:
    for (int row = 0; row < height; row++) {
      for (int column = 0; column < width; column++) {
        calculate(row, column);
      }
    }
    break;

  case 1:
    for (int row = height-1; row >= 0; row--) {
      for (int column = 0; column < width; column++) {
        calculate(row, column);
      }
    }
    break;

  case 2:
    for (int row = 0; row < height; row++) {
      for (int column = width-1; column >= 0; column--) {
        calculate(row, column);
      }
    }
    break;

  case 3:
    for (int row = height-1; row >= 0; row--) {
      for (int column = width-1; column >= 0; column--) {
        calculate(row, column);
      }
    }
    break;
    
  }
  
  
  colorOffset += 0.05;
  //if (colorOffset > 100) {
  //  colorOffset = 0;
  //}

  //DRAW GRID
  //for (int minXLimit = 0, xSection = 0; minXLimit < width; minXLimit += width/gridCount, xSection++) {
  //  for (int minYLimit = 0, ySection = 0; minYLimit < height; minYLimit += height/gridCount, ySection++) {
  //    stroke(100);
  //    strokeWeight(1);
  //    rect(minXLimit, minYLimit, width/gridCount, height/gridCount);
  //  }
  //}

  updatePixels();
  
  for(int row = 0; row < height; row++) {
    if (tree[row][0] != null || tree[row][width-1] != null) {
      restart();
      return;
    }
  }
  
  for(int column = 0; column < width; column++) {
    if (tree[0][column] != null || tree[height-1][column] != null) {
      restart();
      return;
    }
  }
}

void restart() {
  setupEmptyArrays();
  addInitialTree();
  addInitialWalkers();
}

void setupEmptyArrays() {
  tree = new Pixel[height][width];
  walkers = new Pixel[height][width];

  for (int row = 0; row < height; row++) {
    for (int column = 0; column < width; column++) {
      tree[row][column] = null;
      walkers[row][column] = null;
    }
  }
}

void addInitialTree() {
  //add tree members
  int r = (int) ((CIRCLE_RADIUS_PERCENT * height) / 2);
  int start = width/2-r;
  int end = width/2+r;
  for (int x = start; x < end; x++) {
    //tree[height/2][column] = new Pixel(true, column, height/2);

    int distanceFromCenter = (int) (Math.sqrt( pow(r, 2) - pow(x-width/2, 2) ));
    int upper = distanceFromCenter + height/2;
    int lower = -1 * distanceFromCenter + height/2;

    tree[lower][x] = new Pixel(true, x, lower);
    tree[upper][x] = new Pixel(true, x, upper);
  }
}

void addInitialWalkers() {
  //add walkers
  for (int count = 0; count < NUMBER_OF_WALKERS; count++) {
    createRandomWalker();
  }
}

void calculate(int row, int column) {
  //move & update walker
  
  if (walkers[row][column] != null) {

    Pixel walker = walkers[row][column];

    //check for walkers surrounding & walls then randomly move
    boolean canMoveRight = false;
    if (column + 1 < width) { 
      if (walkers[row][column+1] == null) {
        canMoveRight = true;
      }
    }
    boolean canMoveLeft = false;
    if (column - 1 >= 0) { 
      if (walkers[row][column-1] == null) {
        canMoveLeft = true;
      }
    }
    boolean canMoveUp = false; 
    if (row - 1 >= 0) {
      if (walkers[row-1][column] == null) {
        canMoveUp = true;
      }
    }
    boolean canMoveDown = false; 
    if (row + 1 < height) {
      if (walkers[row+1][column] == null) {
        canMoveDown = true;
      }
    }

    //println(canMoveRight);
    //println(canMoveLeft);
    //println(canMoveUp);
    //println(canMoveDown);
    //println(row + " " + column);

    
    if (Math.random() >= 0.5) {
    //MOVE LEFT OR RIGHT
    //can move either left or right
    if (canMoveRight && canMoveLeft) {
      float chance = GRAVITY_STRENGTH;
      if (walker.column < gravityCenterX) {
        chance = 1-GRAVITY_STRENGTH; //more likely to move right
      }
      if (Math.random() >= chance) { //move right
        moveRight(walker);
      } else { //move left
        moveLeft(walker);
      }
    }
    //can only move left
    else if (!canMoveRight && canMoveLeft) {
      moveLeft(walker);
    } 
    //can only move right
    else if (!canMoveLeft && canMoveRight) {
      moveRight(walker);
    }
    } else {

    //MOVE UP OR DOWN
    //can move either up or down
    //if (Math.random() >= 0.5) {
    if (canMoveUp && canMoveDown) {
      float chance = GRAVITY_STRENGTH;
      if (walker.row >= gravityCenterY) {
        chance = 1-GRAVITY_STRENGTH; //more likely to move up
      }
      if (Math.random() >= chance) { //move up
        moveUp(walker);
      } else { //move down
        moveDown(walker);
      }
    }
    //can only move down
    else if (!canMoveUp && canMoveDown) {
      moveDown(walker);
    } 
    //can only move up
    else if (!canMoveDown && canMoveUp) {
      moveUp(walker);
    }
    }

    //check for tree members surrounding. become a tree memeber or stay a walker.
    boolean hasRightTreeMember = false;
    if (column + 1 < width) {
      if (tree[row][column+1] != null) {
        hasRightTreeMember = true;
      }
    }
    boolean hasLeftTreeMember = false;
    if (column - 1 >= 0) {
      if (tree[row][column-1] != null) {
        hasLeftTreeMember = true;
      }
    }
    boolean hasTopTreeMember = false;
    if (row - 1 >= 0) {
      if (tree[row-1][column] != null) {
        hasTopTreeMember = true;
      }
    }
    boolean hasBottomTreeMember = false;
    if (row + 1 < height) {
      if (tree[row+1][column] != null) {
        hasBottomTreeMember = true;
      }
    }

    if ( hasRightTreeMember || hasLeftTreeMember || hasTopTreeMember || hasBottomTreeMember) {
      //become tree member
      tree[walker.row][walker.column] = new Pixel(true, walker.column, walker.row);

      //unbecome a walker
      walkers[walker.row][walker.column] = null;
      
      //add new random walker
      createRandomWalker();
    }

    //update pixel array with status of walker
    if (SHOULD_DISPLAY_WALKERS) {
      int previousIndex = column + row * width;
      pixels[previousIndex] = color(0,0,0);
      int index = walker.column + walker.row * width;
      pixels[index] = color(50, 50, 50);
    }
  }


  //draw tree member
  if (tree[row][column] != null) { 
    int index = column + row * width;
    pixels[index] = color(abs(sin(100-colorOffset))*255, abs(sin(colorOffset))*255, abs(sin((100-colorOffset)/2))*255);
  }
}

void moveRight(Pixel walker) {
  walkers[walker.row][walker.column+1] = walker;
  walkers[walker.row][walker.column] = null;
  walker.column++;
}

void moveLeft(Pixel walker) {
  walkers[walker.row][walker.column-1] = walker;
  walkers[walker.row][walker.column] = null;
  walker.column--;
}

void moveUp(Pixel walker) {
  walkers[walker.row-1][walker.column] = walker;
  walkers[walker.row][walker.column] = null;
  walker.row--;
}

void moveDown(Pixel walker) {
  walkers[walker.row+1][walker.column] = walker;
  walkers[walker.row][walker.column] = null;
  walker.row++;
}


void randomizeGravityCenter() {
   gravityCenterX = (int) (Math.random() * width);
   gravityCenterY = (int) (Math.random() * height);
   
   println(gravityCenterX, gravityCenterY);
}

void createRandomWalker() {
  int randomRow = (int) (Math.random() * height); 
  int randomColumn = (int) (Math.random() * width);
  //int randomRow = (int) (Math.random() * height/4) + height/2 - height/8; 
  //int randomColumn = (int) (Math.random() * width/4) + width/2 - width/8;
  if (walkers[randomRow][randomColumn] == null && tree[randomRow][randomColumn] == null) {
    walkers[randomRow][randomColumn] = new Pixel(false, randomColumn, randomRow);
  } else {
    createRandomWalker();
  }
}


//void mousePressed() {
//  println("START");
//  for(int row = 0; row < height; row++) {
//    println("new row");
//    println(walkers[row]);
//  }
//  println("END");
//}
