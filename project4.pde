/*
 James Luberisse
 Date: Oct 29 2021
 CAP3027
 Project 4: Procedural Terrain
 */
import java.util.*;
import controlP5.*;
import java.lang.Math;   

ControlP5 cp5;

/*
check list:
 UI: good
 Camera: good;
 grid: good
 terrain: bad;
 color: good;
 
 */

int X, Y;

public PVector globalPosition = new PVector(0, 0, 0);
public PVector localPosition = new PVector(0, 0, 0);

Button GENERATE;
Slider ROWS;
Slider COLUMNS;
Slider TERRAIN_SIZE;
Slider HEIGHT_MODIFIER;
Slider SNOW_THRESHOLD;
Textfield LOAD;
Toggle STROKE;
Toggle COLOR;
Toggle BLEND_TOGGLE;


PImage img;
PShape grid;


color snow = color(255); 
color grass = color(143, 170, 64);
color rock = color(135, 135, 135); 
color dirt = color(160, 126, 84);
color water = color(0, 75, 200);
color Background = color(0, 0, 0);



public class Camera {
  float theta;
  float phi;
  float x;
  float y;
  float z;

  float radius = 100.0;
  float zoom = 0.25;
  float scale = 1.0;
  int counter = 0;


  Camera() {
  }


  void Update() {

    positionMap();  
    perspective(radians(90.0f), (float)width/height, 1, 1000);   
    translate(width/2, height /2, 0);
    camera(globalPosition.x*abs(zoom), globalPosition.y*abs(zoom), globalPosition.z*abs(zoom), localPosition.x, localPosition.y, localPosition.z, 0, 1, 0);
  }





  void radiansMap() {

    this.theta = radians(map(500, 0, width-1, 0, 360));
    this.phi = radians(map(400, 0, height-1, 1, 179));
  }

  void positionMap() {
    globalPosition.x = localPosition.x + this.radius*cos(phi)*sin(theta); 
    globalPosition.y = localPosition.y + this.radius*cos(theta); 
    globalPosition.z = localPosition.z + this.radius*sin(theta)*sin(phi);
  }
}


public class Terrain {

  ArrayList<PVector> vertexData = new ArrayList<PVector>();
  ArrayList<Integer> triangleData = new ArrayList<Integer>();
  int gridSize =  1;
  float rows;
  float cols;
  float x = 0;
  float y = 0;
  float z = 0;
  float height_mod;
  float snow = 0;
  String image = "";

  boolean colorOn = false;
  boolean blendOn = false;
  boolean strokeOn = false;
  // store data for vertex 



  void grid() { 
    shape(grid, 0, 0);  

    colorMode(RGB);
    for (int i = 0; i < vertexData.size(); i++) {
      pushMatrix();
      if (!strokeOn) {
        noStroke();
      } else {
        stroke(0);
      }
 
      translate(vertexData.get(i).x, vertexData.get(i).y, vertexData.get(i).z);

      popMatrix();
    }
  }  



  void mapTerrain() {
    
       
    int y = 0; 
    vertexData.clear();
    for (float i = -(gridSize/2); i <= gridSize/2 + 0.0001 ; i+=(gridSize/rows)) {
      for (float j = -(gridSize/2); j <= gridSize/2 + 0.001; j+=(gridSize/cols)) {
        vertexData.add(new PVector(j, y, i));
      }
    }  
    

    triangleData.clear();
    for(int i = 0; i < rows; i++) {
      for(int j = 0; j < cols; j++) {
      int startIndex = i * ((int)(cols+1)) + j;
     
      triangleData.add(startIndex);
      triangleData.add(startIndex + 1);
      triangleData.add(startIndex + (int)(cols+1));
      
      triangleData.add(startIndex + 1);
      triangleData.add(startIndex + 1 + (int)(cols+1));
      triangleData.add(startIndex + (int)(cols+1));  
    }
  }

    grid = createShape();  
    grid.beginShape(TRIANGLE);
    grid.fill(255);
    for (int i =0; i < triangleData.size(); i++) {
      //println(i);
   
      
      grid.vertex(vertexData.get(triangleData.get(i)).x, vertexData.get(triangleData.get(i)).y, vertexData.get(triangleData.get(i)).z);
    }
    grid.endShape();    
  
      int value = -1;
      try {  
        value = Integer.parseInt(image);
      } 
      catch(NumberFormatException e) {
      }  
      if (value >= 0 && value <= 6) {
        
        int xIndex = 0;
        int yIndex = 0;
        String fileName = "data/terrain" + image + ".png";
        img = loadImage(fileName);      
        for (int i = 0; i <= rows; i++) {
          for (int j = 0; j <= cols; j++) {
            xIndex =  (int) map(j, 0, cols+1, 0, img.width);
            yIndex =  (int) map(i, 0, rows+1, 0, img.height);
            color imgColor = img.get(xIndex, yIndex);  
            float heightFromColor = map(red(imgColor), 0, 255, 0, 1);
            int vertIndex = i * ((int) cols + 1) + j;
            vertexData.get(vertIndex).y = heightFromColor*(-HEIGHT_MODIFIER.getValue());
          }
        }
        
     
      grid = createShape();  
      grid.beginShape(TRIANGLE);
      grid.fill(255);
      for (int i =0; i < triangleData.size(); i++) {
        //println(i);
        
        if (COLOR.getBooleanValue() == true) {
            
                 float relativeHeight =  (abs(vertexData.get(triangleData.get(i)).y) * (-HEIGHT_MODIFIER.getValue())) / (-SNOW_THRESHOLD.getValue()*2) ;
                 //println(relativeHeight);
                 if(relativeHeight >= 0.8) {
                   
                   if(BLEND_TOGGLE.getBooleanValue() == true) {
                     float ratio = (relativeHeight - 0.8) /0.2f;
                     color blend =  lerpColor(rock, color(254, 254, 254), ratio);
                     grid.fill(blend);
                   }else {                  
                     grid.fill(color(255,255,255));
                   }

                 }
                 else if(relativeHeight >= 0.4 && relativeHeight < 0.8) {
                    if(BLEND_TOGGLE.getBooleanValue() == true) {
                        float ratio = (relativeHeight - 0.8) /0.2f;
                        color blend =  lerpColor(grass, rock, ratio);
                        grid.fill(blend);

                       }
                       else 
                       {                  
                     grid.fill(rock);
                   }
                 }
                 else if(relativeHeight >= 0.2 && relativeHeight < 0.4) {
                    
                   if(BLEND_TOGGLE.getBooleanValue() == true) {
                     float ratio = (relativeHeight - 0.8) /0.2f;
                     color blend =  lerpColor(dirt, grass, ratio);   
                     grid.fill(blend);

                     }
                    else {                  
                     grid.fill(grass);
                   }

                 } 
                 else {
                             
                     grid.fill(water);
                   
                 }
      } 
        grid.vertex(vertexData.get(triangleData.get(i)).x, vertexData.get(triangleData.get(i)).y, vertexData.get(triangleData.get(i)).z);
  
        
      }
      grid.endShape();
    
    
    
    } 
   
  }

  void mapColors() {
    
    
    
    
    
  }
  //  pushMatrix();
  //  for (int i=0; i<=20; i++) {
  //    stroke(255);
  //    line(-100, 0, -100+10*i, 100, 0, -100+10*i);
  //    stroke(255);
  //    line(-100+10*i, 0, -100, -100+10*i, 0, 100);
  //    fill(255);
  //  }

  //  stroke(255);
  //   line(-100, 0, 0, 100, 0, 0);
  //  stroke(255);
  //  line(0, 0, -100, 0, 0, 100);
  //  popMatrix();
  //}
}

Camera Cam3D = new Camera();

Terrain terrain = new Terrain(); 

void setup() {
  cp5 = new ControlP5(this);
  X =  width/2;
  Y =  height/2;
  GENERATE = cp5.addButton("GENERATE")
    .setPosition(10, 70)
    .setSize(100, 30);

  ROWS = cp5.addSlider("ROWS")
    .setPosition(10, 10)
    .setRange(1, 100)
    .setValue(10)
    .setCaptionLabel("ROWS");


  COLUMNS = cp5.addSlider("COLUMNS")
    .setPosition(10, 25)
    .setRange(1, 100)
    .setValue(10)
    .setCaptionLabel("COLUMNS");



  TERRAIN_SIZE = cp5.addSlider("TERRAIN SIZE")
    .setPosition(10, 40)
    .setRange(20, 50)
    .setValue(30)
    .setCaptionLabel("TERRAIN SIZE");


  HEIGHT_MODIFIER =  cp5.addSlider("HEIGHT MODIFIER")
    .setPosition(400, 55)
    .setRange(-5, 5)
    .setCaptionLabel("HEIGHT MODIFIER");


  SNOW_THRESHOLD =  cp5.addSlider("SNOW THRESHOLD")
    .setPosition(400, 75)
    .setRange(1, 5)
    .setCaptionLabel("SNOW THRESHOLD");


  LOAD = cp5.addTextfield("LOAD FROM FILE")
    .setPosition(10, 115)
    .setCaptionLabel("LOAD FROM FILE")
    .setAutoClear(false)
    .setValue("");

  STROKE = cp5.addToggle("STROKE")
    .setPosition(400, 10)
    .setSize(50, 25)
    .setState(false)
    ;

  COLOR = cp5.addToggle("COLOR")
    .setPosition(460, 10)
    .setSize(50, 25)
    .setState(false)
    ;

  BLEND_TOGGLE = cp5.addToggle("BLEND")
    .setPosition(520, 10)
    .setSize(50, 25)
    .setState(false)
    ;


  frameRate(60);
  background(0, 0, 0);
  size(1200, 800, P3D);

  terrain.gridSize = (int) TERRAIN_SIZE.getValue();
  terrain.cols = (int) COLUMNS.getValue();
  terrain.rows = (int) ROWS.getValue();
  terrain.height_mod = (float) HEIGHT_MODIFIER.getValue();
  terrain.snow = SNOW_THRESHOLD.getValue();
  terrain.strokeOn = STROKE.getBooleanValue();
  terrain.colorOn = COLOR.getBooleanValue();
  terrain.blendOn = BLEND_TOGGLE.getBooleanValue();
  background(Background);
  terrain.mapTerrain();
  terrain.grid();
  Cam3D.radiansMap();


  resetMatrix(); // Reset the "world" matrix
  camera(); // Reset the view matrix
  perspective(); // Reset the projection matrix
}

void start() {
}


void draw() {
  colorMode(RGB);
  Cam3D.Update();
  generating();
}

void generating() {


  background(Background);
  terrain.mapTerrain();
  terrain.grid();


  resetMatrix(); // Reset the "world" matrix
  camera(); // Reset the view matrix
  perspective(); // Reset the projection matrix
}


public void GENERATE() {
  terrain.gridSize = (int) TERRAIN_SIZE.getValue();
  terrain.cols = (int) COLUMNS.getValue();
  terrain.rows = (int) ROWS.getValue();
  terrain.image =  LOAD.getText();
  terrain.mapTerrain();
}

public void HEIGHT_MODIFIER() {
    terrain.height_mod = (float) HEIGHT_MODIFIER.getValue();

  
}
public void SNOW_THRESHOLD() {

  terrain.snow = SNOW_THRESHOLD.getValue();

};

public void STROKE() {
  
    terrain.strokeOn = STROKE.getBooleanValue();

}
public void COLOR() {
    terrain.colorOn = COLOR.getBooleanValue();
  
}
public void BLEND_TOGGLE() {
    terrain.blendOn = BLEND_TOGGLE.getBooleanValue();

}

void mouseDragged() {
  if (!cp5.isMouseOver()) {
    float prev = pmouseX;
    prev = mouseX - prev;
    float deltaX = prev;
    deltaX *= 0.01;

    float prevy = pmouseY;
    prevy = mouseY - prevy;
    float deltaY = prevy;
    deltaY *= 0.01;


    Cam3D.phi += deltaX;
    Cam3D.theta += deltaY;
  }
}
