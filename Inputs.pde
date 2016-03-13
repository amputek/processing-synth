
void mousePressed () {
  bitcrush = 512;
}

void mouseReleased() {
  mouseDown = false;
}

void mouseDragged() {
  if (mouseDown == false) {
    if (mouseX > 50 && mouseX < 562 && mouseY > 50 && mouseY < 250) {
      if (pmouseX > 50 && pmouseX < 562 && pmouseY > 50 && pmouseY < 250) {

        //px = earliest (left-most) point
        //py = earliest (highest) point
        //this so a for-loop can accurately draw a line between these points
        int px, py, nx, ny;
        if (mouseX < pmouseX) {
          px = mouseX - 50;
          nx = pmouseX - 50;
        } 
        else {
          px = pmouseX - 50;
          nx = mouseX - 50;
        }

        if (mouseY < pmouseY) {
          py = mouseY - 50;
          ny = pmouseY - 50;
        } 
        else {
          py = pmouseY - 50;
          ny = mouseY - 50;
        }

        //draw line (in integer increments) between previous mouse position and current mouse position
        int j = py;
        for (int i = px; i < nx; i++) {
          if (j < ny) {
            j++;
          }
          float y = float(j) / (100);
          y = y -1;
          audiosignal[i] = y;
          if (filterOn == true) {
            applyFilter();
          }
        }
      }
    }
  }
}


void keyPressed() {
    if (key == 's') { 
      autoSmooth = !autoSmooth;
    } 
    else if (key == 'c') {
      crush(audiosignal);
      bitcrush = bitcrush / 2;
    } 
    else if (key == '2') {  
      addHarmonic(2, 0.5);
    } 
    else if (key == '3') {  
      addHarmonic(3, 0.5);
    } 
    else if (key == '4') {  
      addHarmonic(4, 0.5);
    } 
    else if (key == '5') {  
      addHarmonic(5, 0.5);
    } 
    else if (key == '6') {  
      addHarmonic(6, 0.5);
    }  
    else if (key == '7') {  
      addHarmonic(7, 0.5);
    } 
    else if (key == 'n') {
      addNoise();
    } 
    else  if (key == 'w') {
      makeSine();
    } 
    else if (key == 'q') {
      makeSquare();
    } 
    else if (key == 't') {
      makeTriangle();
    } 
    else if (key == 'p') {
      addPerlin();
    }
    else if (key == 'g') {
      fr = !fr;
    } 
    else if (key == 'i') {
      makeTriangle();
    } 
    else if (key == 'u') {
      for (int i = 0; i < 512; i++) {
        println(audiosignal[i]);
      }
    }
  
  if(filterOn == true){
    applyFilter();
  }
  
}
