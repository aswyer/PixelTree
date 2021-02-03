import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PixelTree extends PApplet {

Pixel[][] tree;
Pixel[][] walkers;

int[][] scaledPixels;

int savedTime;
int gravityCenterX;
int gravityCenterY;

float colorOffset = 255;

float GRAVITY_STRENGTH = 1;
int NUMBER_OF_WALKERS = 12000;

float CIRCLE_RADIUS_PERCENT = 0.02f;
int NUMBER_OF_STARTING_POINTS = 5;

boolean SHOULD_DISPLAY_WALKERS = true;
int TIME_BETWEEN_GRAVITY_CHANGES = 3;

int scaleFactor = 5;

int screenWidth = width / scaleFactor;
int screenHeight = height / scaleFactor;

class Pixel {
  int column;
  int row;
  boolean stuck;
  
  int displayColor = -1;

  Pixel(boolean stuck, int column, int row) {
    this.stuck = stuck;
    this.column = column;
    this.row = row;
  }

  public String toString() {
    return column + " " + row;
  }
}

public void setup() {
  //size(1280, 1000);
   
  //fullScreen();
  

  noCursor();
  
  background(0);
  
  setupEmptyArrays();
  addInitialTree();
  addInitialWalkers();

  randomizeGravityCenter();
  savedTime = millis();
}


public void draw() {
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
    for (int row = 0; row < screenHeight; row++) {
      for (int column = 0; column < screenWidth; column++) {
        calculate(row, column);
      }
    }
    break;

  case 1:
    for (int row = screenHeight-1; row >= 0; row--) {
      for (int column = 0; column < screenWidth; column++) {
        calculate(row, column);
      }
    }
    break;

  case 2:
    for (int row = 0; row < screenHeight; row++) {
      for (int column = screenWidth-1; column >= 0; column--) {
        calculate(row, column);
      }
    }
    break;

  case 3:
    for (int row = screenHeight-1; row >= 0; row--) {
      for (int column = screenWidth-1; column >= 0; column--) {
        calculate(row, column);
      }
    }
    break;
    
  }
  
  
  // colorOffset += 0.0005;
  //if (colorOffset > 100) {
  //  colorOffset = 0;
  //}

  //DRAW GRID
  //for (int minXLimit = 0, xSection = 0; minXLimit < screenWidth; minXLimit += screenWidth/gridCount, xSection++) {
  //  for (int minYLimit = 0, ySection = 0; minYLimit < screenHeight; minYLimit += screenHeight/gridCount, ySection++) {
  //    stroke(100);
  //    strokeWeight(1);
  //    rect(minXLimit, minYLimit, screenWidth/gridCount, screenHeight/gridCount);
  //  }
  //}


  //MAP SCALED PIXELS TO PIXELS
  int scaledX = 0;
  int xCounter = 0;

  int scaledY = 0;
  int yCounter = 0;

  for (int row = height-1; row >= 0; row--) {
      for (int column = 0; column < width; column++) {

        int fullIndex = column + row * screenWidth;
        pixels[fullIndex] = scaledPixels[scaledY][scaledX];
        
        if (xCounter >= scaleFactor) {
          scaledX += 1;
          xCounter = 0;
        } else {
          xCounter++;
        }
        
      }
      
      if (yCounter >= scaleFactor) {
          scaledY += 1;
          yCounter = 0;
      } else {
        yCounter++;
      }
  }
  updatePixels();
  

  //RESTART
  for(int row = 0; row < screenHeight; row++) {
    if (tree[row][0] != null || tree[row][screenWidth-1] != null) {
      restart();
      return;
    }
  }
  
  for(int column = 0; column < screenWidth; column++) {
    if (tree[0][column] != null || tree[screenHeight-1][column] != null) {
      restart();
      return;
    }
  }


  //COLOR OFFSET
  colorOffset += 0.002f;
}

public void restart() {
  setupEmptyArrays();

  //remove some tree members
  // for (int row = 0; row < screenHeight; row++) {
  // for (int column = 0; column < screenWidth; column++) {
  //   if (Math.random() > 0.02) {
  //     tree[row][column] = null;
  //   }

  //   walkers[row][column] = null;
  // }
  // }

  addInitialTree();
  addInitialWalkers();
}

public void setupEmptyArrays() {

  scaledPixels = new int[screenHeight][screenWidth];
  
  tree = new Pixel[screenHeight][screenWidth];
  walkers = new Pixel[screenHeight][screenWidth];

  for (int row = 0; row < screenHeight; row++) {
    for (int column = 0; column < screenWidth; column++) {
      tree[row][column] = null;
      walkers[row][column] = null;
    }
  }
}

public void addInitialTree() {
  //CIRCLE
  int r = (int) ((CIRCLE_RADIUS_PERCENT * screenHeight) / 2);
  int start = screenWidth/2-r;
  int end = screenWidth/2+r;
  for (int x = start; x < end; x++) {
   //tree[screenHeight/2][column] = new Pixel(true, column, screenHeight/2);

   int distanceFromCenter = (int) (Math.sqrt( pow(r, 2) - pow(x-screenWidth/2, 2) ));
   int upper = distanceFromCenter + screenHeight/2;
   int lower = -1 * distanceFromCenter + screenHeight/2;

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

public void addInitialWalkers() {
  //add walkers
  for (int count = 0; count < NUMBER_OF_WALKERS; count++) {
    createRandomWalker();
  }
}

public void calculate(int row, int column) {
  //move & update walker
  
  if (walkers[row][column] != null) {

    Pixel walker = walkers[row][column];

    //check for walkers surrounding & walls then randomly move
    boolean canMoveRight = false;
    if (column + 1 < screenWidth) { 
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
    if (row + 1 < screenHeight) {
      if (walkers[row+1][column] == null) {
        canMoveDown = true;
      }
    }

    //println(canMoveRight);
    //println(canMoveLeft);
    //println(canMoveUp);
    //println(canMoveDown);
    //println(row + " " + column);

    
    if (Math.random() >= 0.5f) {
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
    if (column + 1 < screenWidth) {
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
    if (row + 1 < screenHeight) {
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
    
    float columnOffset = ((float) column / screenWidth);
    float rowOffset = ((float) row / screenHeight);
    
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

public void moveRight(Pixel walker) {
  walkers[walker.row][walker.column+1] = walker;
  walkers[walker.row][walker.column] = null;
  walker.column++;
}

public void moveLeft(Pixel walker) {
  walkers[walker.row][walker.column-1] = walker;
  walkers[walker.row][walker.column] = null;
  walker.column--;
}

public void moveUp(Pixel walker) {
  walkers[walker.row-1][walker.column] = walker;
  walkers[walker.row][walker.column] = null;
  walker.row--;
}

public void moveDown(Pixel walker) {
  walkers[walker.row+1][walker.column] = walker;
  walkers[walker.row][walker.column] = null;
  walker.row++;
}


public void randomizeGravityCenter() {
   gravityCenterX = (int) (Math.random() * screenWidth);
   gravityCenterY = (int) (Math.random() * screenHeight);
   
   println(gravityCenterX, gravityCenterY);
}

public void createRandomWalker() {
  int randomRow = (int) (Math.random() * screenHeight); 
  int randomColumn = (int) (Math.random() * screenWidth);
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
  public void settings() {  size(500, 500);  pixelDensity(1); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PixelTree" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
