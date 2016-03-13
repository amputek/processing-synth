//GUI elements, recognise mouse input etc..

public class Knob{
  
  int x, y;
  float value, tempValue;

  float lowBoundary, highBoundary;
  float stepSize;
  
  int radius;
  boolean active;
  int pmy;
  String name;
  
  public Knob(int x, int y, int radius, String name){
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.name = name;
    
    lowBoundary = -1.0;
    highBoundary = 1.0;
    stepSize = ((highBoundary-lowBoundary) / 100.0);
    
  }
  
  void setBoundaries(float low, float high){
    lowBoundary = low;
    highBoundary = high;
    stepSize = ((highBoundary-lowBoundary) / 100.0);
  }
  
  void draw(){ 
      if(mousePressed == true){
         if(mouseDown == false){
          if(dist(mouseX,mouseY,x,y) < radius){
            mouseDown = true;
            active = true;
            pmy = mouseY;
            tempValue = value;
          }
         }
    } else {
      active = false;
    }
    
    if(active == true){
    
      value = tempValue + (float(pmy-mouseY)*0.02);
      if(value > 1.0){
        value = 1.0;  
      } else if (value < -1.0){
        value = -1.0;  
      }
    }
    
    float xpos = x-sin(-value*2.5)*radius*0.4;
    float ypos = y-cos(-value*2.5)*radius*0.4;
    
    strokeWeight(1);
    fill(0,0);
    
    ellipse(x-sin(-2.5)*radius*0.7, y-cos(-2.5)*radius*0.7, 4,4);
    ellipse(x-sin(2.5)*radius*0.7, y-cos(2.5)*radius*0.7, 4,4);
    
    line(xpos, ypos, x, y);
    strokeWeight(2);
    ellipse(x,y,radius,radius);
    strokeWeight(1);
    ellipse(x,y,radius*0.8,radius*0.8);
    
    fill(255);
    textAlign(CENTER);
    text(name, x, y + radius);
    
  }
  
  float value(){
    return value;
  }
}


//fancy radio button sort of thing
public class Toggle{
  
  int x, y;
  int state;
  String l, r, title;

  public Toggle(int x, int y, String title, String l, String r){
    this.x = x;
    this.y = y;
    this.l = l;
    this.r = r;
    this.title = title;
    state = -1;
  }
  
  void draw(){
    stroke(255);
    fill(0);
    rect(x, y, 40, 20);

    if(mouseDown == false){
      if(mousePressed == true){
        if(mouseX-x < 40 && mouseX-x > 0){
          if(mouseY-y < 20 && mouseY-y > 0){
            mouseDown = true;
            state = -state;
          }
        }  
      }
    }
    
    int a;
    if(state == 1){
      a = 26;  
    } else {
      a = 0;  
    }
    
    fill(255);
    rect(x + 2 + a, y + 2, 10, 16);
    textAlign(CENTER);
    text(title, x+20, y - 5);
    text(l, x, y + 30);
    text(r, x+40, y + 30);      
  }
  
  int state(){
    return state;  
  }
}

