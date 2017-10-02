import java.util.List;

PImage src;
Rectangle keyRectangle;
ArrayList<Rectangle> tabRectangle;
ArrayList<PImage> outputs;

Rectangle captured;
int offsetX;
int offsetY;

int offsetResult;

Rectangle resized;

String imageFilename;
String deckName;

Boolean globalTabLock;

class Rectangle {
  int x, y, w, h;
  
  Rectangle(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  Rectangle(String CSVLine) {
    String[] param = split(CSVLine, ',');
    this.x = Integer.parseInt(param[0]);
    this.y = Integer.parseInt(param[1]);
    this.w = Integer.parseInt(param[2]);
    this.h = Integer.parseInt(param[3]);
  }
  
  String toCSVLine() {
    return this.x + "," + this.y + "," + this.w + "," + this.h;        
  }
    
}

void setup() {  
  selectInput("Select a file to process:", "process");  
  
  tabRectangle = new ArrayList<Rectangle>();
}

void settings() {
  fullScreen();
}

void draw() {
	noFill();
	clear();

	if (src == null) { return; }
	image(src,0,0);

	if (globalTabLock) { return; }

	if (keyRectangle == null) { return; } //<>//

  if (mouseNear(keyRectangle)) {
    stroke(color(0,30,0));
  } else {
	  stroke(color(255,0,0));
  }
	rect(keyRectangle.x, keyRectangle.y, keyRectangle.w, keyRectangle.h);

	if (tabRectangle == null/* || tabRectangle.size() == 0*/) { return; }  

	for (Rectangle r: tabRectangle) {   
		if (r == captured) {
			stroke(color(0,30,0));
		} else {
			stroke(color(0,255,0));
		}
		if (mouseNear(r)) {
			stroke(color(0,0,200));
		}
		rect(r.x, r.y, r.w, r.h);
	}

	if (outputs == null) {return; }

	if (mouseInScrollDownBorder()) {
		offsetResult -= 10;
	}

	if (mouseInScrollUpBorder()) {
		offsetResult += 10;
	}

	int outputHeight = offsetResult;
	try {
		for (PImage output: outputs) {
			image(output, src.width + 10, 0 + outputHeight);
			outputHeight += output.height + 10;
		}
	} catch (Exception e) {
		println(e);
	}
}

boolean mouseInScrollUpBorder() {
  return mouseY < 120 && mouseX > src.width;
}

boolean mouseInScrollDownBorder() {
  return mouseY >= height - 120 && mouseX > src.width;
}

boolean mouseInside(Rectangle r) {
  return r.x < mouseX 
      && r.y < mouseY 
      && r.w + r.x > mouseX
      && r.h + r.y > mouseY; 
}

boolean mouseNear(Rectangle r) {
  return ((r.y == mouseY || r.y + r.h == mouseY) && r.x <= mouseX && r.x + r.w >= mouseX) ||
          ((r.x == mouseX || r.x + r.w == mouseX) && r.y <= mouseY && r.y + r.h >= mouseY);
}

void capture() { 
  for (Rectangle r: tabRectangle) {
    if (mouseInside(r)) {
       captured = r; 
       offsetX = mouseX - r.x;
       offsetY = mouseY - r.y;
       break; 
    } else if (mouseNear(r)) {
       resized = r;
       break;
    }
  }

  if (mouseInside(keyRectangle)) {
	  captured = keyRectangle;
	  offsetX = mouseX - keyRectangle.x;
	  offsetY = mouseY - keyRectangle.y;	  
  } else if (mouseNear(keyRectangle)) {
    resized = keyRectangle;
  }
}

void releaseCapture() {
  if (captured != null) {
    captured = null;
    calculate();
  } else if (resized != null) {
    resized = null;
    calculate();
  }
}

void dragCapture() {
 captured.x = mouseX - offsetX;
 captured.y = mouseY - offsetY;     
}

void dragResize() {
  resized.w = mouseX - resized.x;
  if (resized != keyRectangle ) {
    resized.h = keyRectangle.h;
  } else {
    resized.h = mouseY - resized.y;
  }
}

void mousePressed(MouseEvent evt) {
  if (mouseX > src.width || mouseY > src.height) { return; }
  if (evt.getCount() == 2) { doubleClicked(); return; }
  capture();  
}

void mouseReleased() {
  releaseCapture();  
}

void mouseDragged() {
  if (captured != null) {
    dragCapture();
  } else if (resized != null) {
    dragResize();
  }
}

void doubleClicked() {
  if (tabRectangle.size() == 0) {
    tabRectangle.add(new Rectangle(mouseX, mouseY, 20, 20));
    return;
  }
  Rectangle last = tabRectangle.get(tabRectangle.size() -1);  
  tabRectangle.add(new Rectangle(mouseX - last.w / 2, mouseY - last.h / 2, last.w, last.h));
}

void process(File selection) {          
  imageFilename = selection.getAbsolutePath();
  deckName = selection.getName().replaceFirst("[.][^.]+$", "");  
  src = loadImage(imageFilename); 
  
  loadState(deckName);
      
  calculate();  
};

void calculate() {
  outputs = new ArrayList<PImage>();
  for (int i = 0; i < tabRectangle.size() - 2; i = i + 1) {  
    saveRectangle(deckName, i, keyRectangle, tabRectangle.subList(0 + i,3 + i));
  }
  saveState(deckName, keyRectangle, tabRectangle);
}

void loadState(String deckName) {
  String filename = deckName + ".txt";
  File f = new File(sketchPath(filename));
  if (!f.exists()) {
    globalTabLock = false;
    setDefault();
    return;
  }
  
  BufferedReader reader;
  try {
	 reader = createReader(filename);
  } catch(Exception e) {
    e.printStackTrace();
    setDefault();    
    return;
  }
	String line;
	globalTabLock = true;
	try {
		line = reader.readLine();    
		keyRectangle = new Rectangle(line);

		line = reader.readLine();
		while (line != null) {
			tabRectangle.add(new Rectangle(line));
			line = reader.readLine();
		} 
		reader.close();
	} catch (IOException e) {
		e.printStackTrace();
		setDefault();
	}
	globalTabLock = false;
}

void setDefault() {
  keyRectangle = new Rectangle(30,6,51,75);  
}

void saveState(
	String deckName, 
	Rectangle key, 
	ArrayList<Rectangle> tab
) {
	PrintWriter output = createWriter(deckName + ".txt");  
	output.println(key.toCSVLine());  
	for (Rectangle t: tab) {
		output.println(t.toCSVLine());
	}  
	output.flush();
	output.close();
}

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

	outputs.add(rectangle);
}