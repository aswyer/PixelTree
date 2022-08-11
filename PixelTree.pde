Pixel[][] tree;
Pixel[][] walkers;

color[][] scaledPixels;

int savedTime;
int gravityCenterX;
int gravityCenterY;

float colorOffset = 255;

float GRAVITY_STRENGTH = 1;
int NUMBER_OF_WALKERS = 1000;

float CIRCLE_RADIUS_PERCENT = 0.05;
int NUMBER_OF_STARTING_POINTS = 5;

boolean SHOULD_DISPLAY_WALKERS = true;
int TIME_BETWEEN_GRAVITY_CHANGES = 1;

int scaleFactor = 2;

int scaledWidth;
int scaledHeight;

ArrayList<String> debugRunTimes = new ArrayList<String>();

class Pixel {
  int column;
  int row;
  boolean stuck;
  
  color displayColor = -1;

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
  size(1000, 1000);
  //size(500, 500);
  //fullScreen();
  pixelDensity(1);
  
  frameRate(120);
  
  noCursor();
  background(0);
  
  scaledWidth = width / scaleFactor;
  scaledHeight = height / scaleFactor;
  
  setupEmptyArrays();
  addInitialTree();
  addInitialWalkers();

  randomizeGravityCenter();
  savedTime = millis();
}


void draw() {
  int debugStartTime = millis();

  int passedTime = millis()-savedTime;
  if (passedTime > TIME_BETWEEN_GRAVITY_CHANGES * 1000) {
    savedTime = millis();
    
    randomizeGravityCenter();
  }
  
  for (int row = 0; row < scaledHeight; row++) {
    for (int column = 0; column < scaledWidth; column++) {
      calculate(row, column);
    }
  }

  loadPixels();
  
  for (int row = 0; row < height; row++) {
      for (int column = 0; column < width; column++) {
        
          int fullIndex = column + row * width;
          pixels[fullIndex] = scaledPixels[row/scaleFactor][column/scaleFactor];

      }
  }
  
  updatePixels();
  
  //COLOR OFFSET
  colorOffset += 0.002;

  //RESTART
  for(int row = 0; row < scaledHeight; row++) {
    if (tree[row][0] != null || tree[row][scaledWidth-1] != null) {
      restart();
      return;
    }
  }
  
  for(int column = 0; column < scaledWidth; column++) {
    if (tree[0][column] != null || tree[scaledHeight-1][column] != null) {
      restart();
      return;
    }
  }


  //Debug Timings
  int debugDeltaTime = millis() - debugStartTime;
  debugRunTimes.add("" + debugDeltaTime);
  
  if (frameCount > 120*15) {
    
    String[] stockArr = new String[debugRunTimes.size()];
    stockArr = debugRunTimes.toArray(stockArr);
    
    saveStrings("times.txt",stockArr);
    println("SAVED");
    
    exit();
  }
}

void restart() {
  setupEmptyArrays();

  addInitialTree();
  addInitialWalkers();
}

void setupEmptyArrays() {

  scaledPixels = new color[scaledHeight][scaledWidth];
  
  tree = new Pixel[scaledHeight][scaledWidth];
  walkers = new Pixel[scaledHeight][scaledWidth];

  for (int row = 0; row < scaledHeight; row++) {
    for (int column = 0; column < scaledWidth; column++) {
      tree[row][column] = null;
      walkers[row][column] = null;
      scaledPixels[row][column] = color(0,0,0);
    }
  }
}

void addInitialTree() {
  //CIRCLE
  int r = (int) ((CIRCLE_RADIUS_PERCENT * scaledHeight) / 2);
  int start = scaledWidth/2-r;
  int end = scaledWidth/2+r;
  
  for (int x = start; x < end; x++) {
   int distanceFromCenter = (int) (Math.sqrt( pow(r, 2) - pow(x-scaledWidth/2, 2) ));
   int upper = distanceFromCenter + scaledHeight/2;
   int lower = -1 * distanceFromCenter + scaledHeight/2;

   tree[lower][x] = new Pixel(true, x, lower);
   tree[upper][x] = new Pixel(true, x, upper);
  }


  //RANDOM POINTS
  // for(int i = 0; i < NUMBER_OF_STARTING_POINTS; i++) {
  //  int x = (int) (Math.random()*screenWidth);
  //  int y = (int) (Math.random()*screenHeight);
    
  //  tree[y][x] = new Pixel(true, x, y);
  // }
  
  //STRAIGHT LINE
  // for(int i = screenWidth/4; i < screenWidth-(screenWidth/4); i++) {
  //   tree[screenHeight/2][i] = new Pixel(true, i, screenHeight/2);
  // }
  
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
    if (column + 1 < scaledWidth) { 
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
    if (row + 1 < scaledHeight) {
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
    if (column + 1 < scaledWidth) {
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
    if (row + 1 < scaledHeight) {
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
      // int previousIndex = column + row * screenWidth;
      scaledPixels[row][column] = color(0,0,0);
      scaledPixels[walker.row][walker.column] = color(50, 50, 50);
    }
  }


  //draw tree member
  if (tree[row][column] != null) { 
    
    float columnOffset = ((float) column / scaledWidth);
    float rowOffset = ((float) row / scaledHeight);
    
    Pixel currentPixel = tree[row][column];
    
    if (currentPixel.displayColor == -1) {
      currentPixel.displayColor = color( 
        abs( tan(colorOffset + columnOffset) ) * 255, 
        abs( sin(colorOffset - rowOffset)) * 255, 
        abs( cos(colorOffset + columnOffset)) * 255
      );
    }
    
    // int index = column + row * screenWidth;
    scaledPixels[row][column] = currentPixel.displayColor;
    
    // colorOffset += 0.00002;
    
    //currentPixel.color = currentColor;
    //pixels[index] = color( 
    //  abs( tan(colorOffset + columnOffset) ) * 255, 
    //  abs( sin(colorOffset - rowOffset)) * 255, 
    //  abs( cos(colorOffset + columnOffset)) * 255
    //);
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
   gravityCenterX = (int) (Math.random() * scaledWidth);
   gravityCenterY = (int) (Math.random() * scaledHeight);
   
   //println(gravityCenterX, gravityCenterY);
}

void createRandomWalker() {
  int randomRow = (int) (Math.random() * scaledHeight); 
  int randomColumn = (int) (Math.random() * scaledWidth);
  //int randomRow = (int) (Math.random() * screenHeight/4) + screenHeight/2 - screenHeight/8; 
  //int randomColumn = (int) (Math.random() * screenWidth/4) + screenWidth/2 - screenWidth/8;
  if (walkers[randomRow][randomColumn] == null && tree[randomRow][randomColumn] == null) {
    walkers[randomRow][randomColumn] = new Pixel(false, randomColumn, randomRow);
  } 
  //else {
   // createRandomWalker();
  //}
}

//void mousePressed() {
//  println("START");
//  for(int row = 0; row < screenHeight; row++) {
//    println("new row");
//    println(walkers[row]);
//  }
//  println("END");
//}
