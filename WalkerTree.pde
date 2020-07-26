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
  size(200, 300);

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
  for (int column = 0; column < width; column++) {
    tree[height/2][column] = new Pixel(true, column, height/2);
  }
  
  //add walkers
  for (int count = 0; count < 10000; count++) {
    int randomRow = (int) (Math.random() * height); 
    int randomColumn = (int) (Math.random() * width);
    walkers[randomRow][randomColumn] = new Pixel(false, randomColumn, randomRow);
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
       if(Math.random() >= 0.5) {
       if (canMoveRight && canMoveLeft) {
         if(Math.random() >= 0.5) { //move right
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
       if(Math.random() >= 0.5) {
       if (canMoveUp && canMoveDown) {
         if(Math.random() >= 0.5) { //move up
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
       }

       //update pixel array with status of walker
       int index = column + row * width;
       pixels[index] = color(255, 0, 0);
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


int randomDisplacement() {
  return ThreadLocalRandom.current().nextInt(-1, 1 + 1);
}
