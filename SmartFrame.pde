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

import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

Pixel[][] tree;
Pixel[][] walkers;

void setup() {
  //size(1280, 1000);
  fullScreen();
  pixelDensity(1);
  tree = new Pixel[height][width];
  walkers = new Pixel[height][width];
  background(0);

  for (int row = 0; row < height; row++) {
    for (int column = 0; column < width; column++) {
      tree[row][column] = null;
      walkers[row][column] = null;
    }
  }

  //add tree members
  int r = height / 5;
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

  //add walkers
  for (int count = 0; count < 50000; count++) {
    createRandomWalker();
  }
}


void draw() {
  background(0);

  loadPixels();

  //loop over each row & column
  for (int row = 0; row < height; row++) {
    for (int column = 0; column < width; column++) {

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

        //MOVE LEFT OR RIGHT
        //can move either left or right
        if (Math.random() >= 0.5) {
          if (canMoveRight && canMoveLeft) {
            if (Math.random() >= 0.5) { //move right
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
        }

        //MOVE UP OR DOWN
        //can move either up or down
        if (Math.random() >= 0.5) {
          if (canMoveUp && canMoveDown) {
            if (Math.random() >= 0.5) { //move up
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
          tree[row][column] = walker;

          //unbecome a walker
          walkers[row][column] = null;

          //add new random walker
          createRandomWalker();
        }

        //update pixel array with status of walker
        int index = column + row * width;
        pixels[index] = color(100, 150, 100);
      }

      //draw tree member
      if (tree[row][column] != null) { 
        int index = column + row * width;
        pixels[index] = color(255, 255, 255);
      }
    }
  }

  //DRAW GRID
  //for (int minXLimit = 0, xSection = 0; minXLimit < width; minXLimit += width/gridCount, xSection++) {
  //  for (int minYLimit = 0, ySection = 0; minYLimit < height; minYLimit += height/gridCount, ySection++) {
  //    stroke(100);
  //    strokeWeight(1);
  //    rect(minXLimit, minYLimit, width/gridCount, height/gridCount);
  //  }
  //}

  updatePixels();
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

//void createRandomWalker() {
//  int randomRow = (int) (Math.random() * height); 
//  int randomColumn = (int) (Math.random() * width);
//  if (walkers[randomRow][randomColumn] == null && tree[randomRow][randomColumn] == null){
//    walkers[randomRow][randomColumn] = new Pixel(false, randomColumn, randomRow);
//  } else {
//    createRandomWalker();
//  }
  
//}

void createRandomWalker() {
  int randomRow = (int) (Math.random() * height/2) + height/4; 
  int randomColumn = (int) (Math.random() * width/2) + width/4;
  if (walkers[randomRow][randomColumn] == null && tree[randomRow][randomColumn] == null){
    walkers[randomRow][randomColumn] = new Pixel(false, randomColumn, randomRow);
  } else {
    createRandomWalker();
  }
  
}


int randomDisplacement() {
  return ThreadLocalRandom.current().nextInt(-1, 1 + 1);
}
