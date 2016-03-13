
//Discrete Fourier Transform on specified componenet
float dft(int component, float[] aSignal) {
  float[] real = new float[512];
  float[] imaginary = new float[512];
  float[] sine = new float[512];
  float[] cosine = new float[512];
  float realTotal = 0;
  float imaginaryTotal = 0;
  float[] signal = new float[512];


  //if component is 0 - real number total is simply the signal values added together, imaginary total is 0
  if (component == 0) {
    for (int i = 0; i < 512; i++) {
      realTotal+= aSignal[i];
      imaginaryTotal = 0;
    }
  } else {
    for (int i = 0; i < 512; i++) {
      sine[i] = sin(TWO_PI* (i*component) / 512);
      cosine[i] = cos(TWO_PI* (i*component) / 512);
      real[i] = aSignal[i] * cosine[i];
      imaginary[i] = aSignal[i] * sine[i];
      realTotal += real[i];
      imaginaryTotal+=imaginary[i];
    }
  }
 
  float magnitude = sqrt((realTotal*realTotal) + (imaginaryTotal*imaginaryTotal));

  return magnitude;

}

//frequency responder on specified signal - drawn at x,y
void updateFR(float[] aSignal, int x, int y) {
  float[] magnitudes = new float[256];
  
  for (int i = 1; i < 256; i+=2) {
    //calculate magnitude for specific component (every other, to reduce processing time)
    magnitudes[i] = dft(i, aSignal);
  }

  fill(0, 0);
  stroke(255, 255);
  strokeWeight(1);
  rect(x, y, 258, 200);

  fill(255);
  textAlign(CENTER);
  int j = 0;
  
  
  
  //draw out vlaues
  for (int i = 1; i < 256; i+=2, j++) {
    
    stroke(0,255-i,i,255);
    strokeWeight(1);
    
    float d = constrain(40 * log(magnitudes[i]) * log(10), 0, 200);
    line(x+2 + i, y+200-d, x+2 + i, y+200);
   
    stroke(0,255,255,255);
    strokeWeight(2);

    if(i > 2){
      float d1 = constrain(40 * log(magnitudes[i-2]) * log(10) * 1, 0, 200);
      line(x+2 + i, y+200-d, x+2 + i-2, y+200-d1);
      
    }
    
    //write out the Hz below the graph
    if(j % 20 == 0){
      line(x+2 + (i), y+200, x+2 + (i), y+205);
      int n = int(theNumber*i);
      String k = "" + n;
      if(n > 10000){
        k = (n/1000) + "k";
      }
      text(k, x+2 + i, y+215);
    }
  }
}

