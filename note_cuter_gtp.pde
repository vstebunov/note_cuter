import java.util.List;

PImage src;

String imageFilename;
int imageWidth, imageHeight;
String deckName;

class Rectangle {
  int x, y, w, h;
  
  Rectangle(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

void settings() {
  imageFilename = "johny.jpg";
  imageWidth = 783;
  imageHeight = 449;
  deckName = "johny";
  
  size(imageWidth, imageHeight);
}


void setup() {    
  src = loadImage(imageFilename); 
         
  noFill();
  stroke(color(0,255,0));
  
  image(src, 0, 0);  
  Rectangle keyRectangle = new Rectangle(30,6,51,75);
  
  ArrayList<Rectangle> tabRectangle = new ArrayList<Rectangle>();
     
  tabRectangle.add(new Rectangle(81, 6, 31, 75));
  tabRectangle.add(new Rectangle(102, 6, 197, 75));
  tabRectangle.add(new Rectangle(102 + 197, 6, 164, 75));
  tabRectangle.add(new Rectangle(102 + 197 + 164, 6, 144, 75));
  tabRectangle.add(new Rectangle(102 + 197 + 164 + 144, 6, 154, 75));
  
  tabRectangle.add(new Rectangle(41, 99, 181, 75));
  tabRectangle.add(new Rectangle(41 + 181, 99, 181, 75));
  
  rect(keyRectangle.x, keyRectangle.y, keyRectangle.w, keyRectangle.h);
  for (Rectangle r: tabRectangle) {    
    rect(r.x, r.y, r.w, r.h);
  }

  for (int i = 0; i < tabRectangle.size() - 2; i = i + 1) {  
    saveRectangle(deckName, i, keyRectangle, tabRectangle.subList(0 + i,3 + i));
  }
};

void saveRectangle(
    String deckName,
    int index,
    Rectangle keyRectangle,
    List<Rectangle> tabRectangle
  ) {
  
  if (keyRectangle == null) {
    println("keyRectangle are empty or null");
    return;
  }
  
  if (tabRectangle == null || tabRectangle.size() == 0) {
    println("tabRectangle are empty or null!");
    return;
  }
   
  PImage key = createImage(keyRectangle.w, keyRectangle.h, RGB);
    
  key = src.get(keyRectangle.x,keyRectangle.y,keyRectangle.w,keyRectangle.h);
  
  
  int tabRectangleWidth = 0;
  for (Rectangle r: tabRectangle) {
    tabRectangleWidth = r.w + tabRectangleWidth;
  }
  
  int tabRectangleHeight = tabRectangle.get(0).h; 
  
  
  Rectangle finalRectangle = new Rectangle(
    0,
    0,
    keyRectangle.w + tabRectangleWidth,
    tabRectangleHeight);
      
  PImage rectangle = createImage(finalRectangle.w, finalRectangle.h, RGB);
    
  rectangle.set(0,0,key);
  
  int xPos = keyRectangle.w;
  int yPos = 0;
  for (Rectangle r: tabRectangle) {
    PImage tab = createImage(r.w, r.h, RGB);
    tab = src.get(r.x, r.y, r.w, r.h);    
    rectangle.set(xPos, yPos, tab);
    xPos = xPos + r.w;    
  }
  rectangle.save(deckName+index+".jpg");
}