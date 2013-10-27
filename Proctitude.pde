// create a video using: avconv -i flow-%06d.png -b 8000k flow.avi

import java.util.*;

String view = "data/view1/";

List<Location> locations;
float[] homography;
PImage map;
PImage particle;

Map<String,? extends List<Location>> dates;

final int timeOffset = 6*3600*1000; // day begins at 00h00 + timeOffset 

HashMap<String,LinkedList<Location>> scan() {
  HashMap<String,LinkedList<Location>> dates = new HashMap<String,LinkedList<Location>>();
  
  for (Location location : locations) {
    if (!dates.containsKey(location.date)) {
      dates.put(location.date, new LinkedList<Location>());  
    }
    dates.get(location.date).add(location);
  }
  
  return dates;
}

void setup() {
  size(1280, 720, P3D); // don't use P2D here, it will produce a processing.opengl.PGraphicsOpenGL$Tessellator$TessellatorCallback.vertex(PGraphicsOpenGL.java:12150) (processing 2.0.3 ubuntu 13.10 64bit)
  hint(DISABLE_DEPTH_TEST); // since we actually draw 2d, depth test may cause unexpected results
  textFont(createFont("Ubuntu",48));
  frameRate(30);
  strokeWeight(2);
  
  println("loading ...");
  locations = loadLocations("data/LocationHistory.json");  
  
  // load view
  double[][] calibGeo = loadCoords(view + "/calib-geo.csv");
  double[][] calibPixel = loadCoords(view + "/calib-pixel.csv");
  map = loadImage(view + "/map.png");
  
  // determine homography (calibration)
  homography = homest(calibGeo, calibPixel);
  //homography = loadHomography("data/view1/homography.csv");
  
  particle = gauss(64,64);
  
  println("sorting ...");
  dates = scan();
  //for (String date : dates.keySet()) {
  //  println(date + " " + dates.get(date).size());  
  //}
    
}

int ms = 0;

void drawDay(List<Location> day, int time, boolean drawTrace, boolean drawMe) {
    color c = nightAndDay(ms);
    float r = 2*blue(c);
    float g = 2*red(c);
    float b = 2*green(c);
  
    if (drawTrace) {
      noFill();
      beginShape();
      for (Location location : day) {
        if (location.daystamp < time) {
          PVector p = transform(homography, location.latitude, location.longitude);
          int alpha = (int)(255*pow((float)location.daystamp / time, 10));
          stroke(r,g,b,alpha);
          curveVertex(p.x, p.y);
        }  
      }
      endShape();
    }
    
    if (drawMe) {
      Location me = null;
      int meDaystamp = 0;
      for (Location location : day) {
        if (location.daystamp < ms) {
          if (location.daystamp > meDaystamp) {
            meDaystamp = location.daystamp;
            me = location;
          }
        }  
      }
      if (me != null) {
        PVector p = transform(homography, me.latitude, me.longitude);
        imageMode(CENTER);
        tint(r,g,b);
        image(particle,p.x, p.y);
        noTint();
      }
    }
    
}

void draw() {
  background(0);
  
  final int timeFadeOut = 3600*24*1000;
  final int timeDone = (int) (1.2*3600*24*1000);
  
  // update time
  ms = (ms + 30000); 
  
  if (ms > timeDone) {
    exit();
    //ms = 0;  
  }
  
  pushMatrix();
  
  // panning animation  
  float amt = (float) ms / (3600*24*1000); 
  translate( lerp(-450,0,amt) , lerp(-300,0,amt) );
  scale( lerp(1.3,0.68,amt) );
  translate( lerp(-100,0,amt) , 0 );
  
  // draw map
  imageMode(CORNER);
  tint(nightAndDay(ms));
  image(map,0,0);
  noTint();
  
  // traces
  for (List<Location> day : dates.values()) {
    int time = ms > timeFadeOut ? (int)(1.1 * ms) : ms; // fade away faster while fadeout
    drawDay(day, time, true, false);
  }
  
  // mes
  for (List<Location> day : dates.values()) {
    drawDay(day, ms, false, true);
  }  
  
  popMatrix();
  
  // draw time
  if (ms < timeFadeOut) {
    fill(0,0,0,128); noStroke();
    rect(0,0,155,60);

    fill(255);
    int time = (ms + timeOffset) % (24*3600000);
    text(String.format("%02d", time/3600000)+"h"+String.format("%02d", time/60000 % 60) ,10,48);
  }
  
  // fade out
  if (ms > timeFadeOut) {
    int alpha = (int) (255 - 255.0 * (timeDone - ms) / (timeDone - timeFadeOut));
    fill(0,0,0,alpha);
    rect(0,0,width,height);  
  }

  saveFrame("flow-######.png");   
}

