import java.util.*;

public class Field {
  int x, y;
  boolean visible = false, hovering = false, hasMine = false, flagged = false;
  int counter = 0;
  public Field(int x, int y) {
    this.x = x;
    this.y = y;
  }



  void SetMine() {
    this.hasMine = true;
  }
  
  void RemoveMine(){
    if (this.CheckMine()){
      this.hasMine = false;
      for (int i = this.x - 1; i < this.x + 2; i++) {
        if (i < 0 || i >= fieldSize) continue;
        for (int j = this.y - 1; j < this.y + 2; j++) {
          if (j < 0 || j >= fieldSize) continue;
          grid[i][j].DecreaseCounter();
          
        }
      }
    }
  }

  boolean CheckMine() {
    return this.hasMine;
  }

  void IncreaseCounter() {
    this.counter += 1;
  }
  
  void DecreaseCounter() {
    this.counter -= 1;
  }

  void Hover() {
    this.hovering = true;
  }

  void Unhover() {
    this.hovering = false;
  }

  void Draw() {
    if (this.visible) {
      // Light Green: #AAD751
      // Dark Green: #A2D149
      if ((this.x + this.y) % 2 == 0) {
        fill(darkYellow);
      } else {
        fill(lightYellow);
      }

      noStroke();
      rect(this.x * LEN, this.y * LEN, LEN, LEN);

      if (CheckMine()) {
        fill(255, 0, 0);
        circle(this.x * LEN + LEN / 2, this.y * LEN + LEN / 2, LEN/4);
      } else {
        fill(GetColor(this.counter));
        textSize(LEN*0.7);
        textAlign(CENTER, CENTER);
        text(Integer.toString(this.counter), this.x * LEN, this.y * LEN - LEN / 12, LEN, LEN);
      }
    } else {
      if (this.hovering) {
        fill(hoverColor);
      } else if ((this.x + this.y) % 2 == 0) {
        fill(lightGreen);
      } else {
        fill(darkGreen); //A2D149
      }

      noStroke();
      float len = width / fieldSize;
      rect(this.x * len, this.y * len, len, len);
      
      if (this.flagged){
        image(flagImage, this.x * len, this.y * len);
      }
    }
  }

  void Activate() {
    this.visible = true;
    if (this.CheckMine()){
      GameOver();
    }
    this.Draw();
  }
  
  void SearchSurroundings(){
    if (this.counter == 0 && !this.hasMine) {
      for (int i = this.x - 1; i < this.x + 2; i++) {
        if (i < 0 || i >= fieldSize) continue;
        for (int j = this.y - 1; j < this.y + 2; j++) {
          if (j < 0 || j >= fieldSize) continue;
          
          Field field = grid[i][j];
            if (!field.visible && !fieldsToReveal.contains(field) && !field.flagged){
              fieldsToReveal.add(field);
              field.SearchSurroundings();
            }
        }
      }
    }
  }
  
  void SwapFlag(){
    this.flagged = !this.flagged;
    this.Draw();
  }
}

void AssignFields() {

  for (int i = 0; i < fieldSize; i++) {
    for (int j = 0; j < fieldSize; j++) {

      grid[i][j] = new Field(i, j);

      if (random(1) < 0.2) {
        grid[i][j].SetMine();
      }
    }
  }
}

void SetCounters() {

  for (int i = 0; i < fieldSize; i++) {
    for (int j = 0; j < fieldSize; j++) {
      if (grid[i][j].hasMine) {
        IncreaseNearbyCounters(i, j);
      }
    }
  }
}

void IncreaseNearbyCounters(int x, int y) {

  for (int i = x - 1; i < x + 2; i++) {
    if (i < 0 || i >= fieldSize) continue;
    for (int j = y - 1; j < y + 2; j++) {
      if (j < 0 || j >= fieldSize) continue;
      grid[i][j].IncreaseCounter();
    }
  }
}


void DrawGrid() {

  for (int i = 0; i < fieldSize; i++) {
    for (int j = 0; j < fieldSize; j++) {
      grid[i][j].Draw();
    }
  }
}


color GetColor(int value) {
  color col;
  switch (value) {
  case 0:
    col = #67FBFF;
    break;
  case 1:
    col = #1976D1;
    break;
  case 2:
    col = #388E3C;
    break;
  case 3:
    col = #CBA406;
    break;
  case 4:
    col = #E57213;
    break;
  case 5:
    col = #F53500;
    break;
  case 6:
    col = #AA2500;
    break;
  case 7:
    col = #791B01;
    break;
  case 8:
  default:
    col = #3E0D00;
  }
  return col;
}

Field DetermineHover(int x, int y) {
  return grid[x / LEN][y / LEN];
}

void UpdateHover(int x, int y) {
  if (gameOver) return;
  Field newField = DetermineHover(x, y);
  if (hoveredField != newField) {
    if (hoveredField != null) {
      hoveredField.Unhover();
      hoveredField.Draw();
    }
    newField.Hover();
    newField.Draw();
    hoveredField = newField;
  }
}

void RemoveMines(Field field){
  for (int i = field.x - 1; i < field.x + 2; i++) {
    if (i < 0 || i >= fieldSize) continue;
    for (int j = field.y - 1; j < field.y + 2; j++) {
      if (j < 0 || j >= fieldSize) continue; 
      grid[i][j].RemoveMine();
    }
  }
}

int fieldSize = 15;
int LEN;
int mousePressTime;
int revealTime;
int revealDelay = 10;
int gameOverScreenAlpha = 0;
int gameOverScreenLimit = 128;

float gameOverScreenIncrement = 2;

color lightYellow = #E5C29F;
color darkYellow = #D7B899;
color hoverColor = #B9DD77;
color darkGreen = #A0C947;
color lightGreen = #AAD751;

PImage flagImage;

boolean gameOver = false;
boolean gameBegin = true;

Field hoveredField;
Field[][] grid = new Field[fieldSize][fieldSize];

Queue<Field> fieldsToReveal = new LinkedList<Field>();

void setup() {
  revealTime = millis();
  flagImage = loadImage("flag_icon.png");
  size(900, 900);
  LEN = width / fieldSize;
  flagImage.resize(LEN, LEN);
  strokeWeight(3);
  AssignFields();
  // Verify bomb positions
  SetCounters();
  DrawGrid();
  frameRate(60);
}

void draw() {
  if (pmouseX != mouseX || pmouseY != mouseY) {
    UpdateHover(mouseX, mouseY);
  }
  
  if (fieldsToReveal.size() > 0 && millis() - revealTime > revealDelay){
    revealTime = millis();
    fieldsToReveal.remove().Activate();
  }
  
  if (gameOver && gameOverScreenAlpha < gameOverScreenLimit){
    fill(255, 0, 0, gameOverScreenIncrement);
    gameOverScreenAlpha += gameOverScreenIncrement;
    rect(0, 0, width, height);
    textSize(width/10);
    fill(255, 0, 0, gameOverScreenIncrement * 3);
    text("Game Over", 0, 0, width, height*0.9);
  }
  
}

void mousePressed() {
  mousePressTime = millis();
}

void mouseReleased() {
  int currentTime = millis();
  if (currentTime - mousePressTime < 1000 && !gameOver) {
    if (hoveredField != null && !hoveredField.flagged && mouseButton == LEFT) {
      if (gameBegin){
        gameBegin = false;
        RemoveMines(hoveredField);
      }
      hoveredField.Activate();
      hoveredField.SearchSurroundings();
    } else if (mouseButton == RIGHT && !hoveredField.visible){
      hoveredField.SwapFlag();
    }
  }
}

void GameOver(){
  gameOver = true;
}
