
//bitcrush original oscillator signal
void crush(float[] audio) {
  for (int i = 0; i < audio.length; i++) {  
    int temp = int(audio[i] * bitcrush);  
    audio[i] = (float)temp/bitcrush;
  }
}


//reset input samples to Sine
void makeSine() {
  for (int i = 0; i < 512; i++) {
    audiosignal[i] = sin(TWO_PI * float(i) / 512.0);
  }
}


//use Fourier Synthesis to create a square wave (start with sine);
void makeSquare() {
  makeSine();
  for (int i = 3; i < 50; i+=2) {
    addSine(i, 1.0/i, 0);
  }
}


//use Fourier Synthesis to create a triangle wave (start with sine);
void makeTriangle() {
  makeSine();
  int j = 1;
  for (int i = 3; i < 100; i+=2, j++) {
    addSine(3, 1.0/i-1, (PI*0.25)*j);
  }  
  checkAmp(audiosignal);
}


//add a sine wave at specified frequency, amplitude, and phase
void addSine(int freq, float amp, float phase) {
  for (int i = 0; i < 512; i++) {
    audiosignal[i]+= amp * sin((TWO_PI * (i*freq) / 512) + phase);
  }
}


//add a harmonic - copies the current audiosignal, multiplies the frequency of the wave by specified amount
//and adds this to original signal
void addHarmonic(int h, float amp) {
  float[] harmonic = new float[audiosignal.length];
  if (h == 2 || h == 4 || h == 8) {
    //number of complete cylces required over same amount of samples
    for (int j = 0; j < h; j++) {
      //j = current cycle
      //i goes from beginning of cycle to beginning of next cycle
      for (int i = audiosignal.length / h * j; i < audiosignal.length / h * (j+1); i++) {
        harmonic[i] = audiosignal[i*h - audiosignal.length * j];
      }
    }
  } 
  else {
    for (int j = 0; j < h; j++) {
      for (int i = audiosignal.length / h * j + j; i < audiosignal.length / h * (j+1) + (j+1); i++) {
        if (i < 512 && i*h - audiosignal.length * j < 512) {
          harmonic[i] = audiosignal[i*h - audiosignal.length * j];
        }
      }
    }
  }

  //add to original signal
  for (int i = 0; i < audiosignal.length; i++) {
    audiosignal[i] = audiosignal[i] + amp*harmonic[i];  
    audiosignal[i]*=0.75;
  }

  checkAmp(audiosignal);
}


//make sure audiosignal samples are within -1.0 and 1.0
void checkAmp(float[] aSignal) {
  float highest = 0.0;
  for (int i = 0; i < aSignal.length; i++) {
    if (abs(aSignal[i]) > highest) {
      highest = abs(aSignal[i]);
    }
  }  

  for (int i = 0; i < aSignal.length; i++) {
    aSignal[i] = aSignal[i] * (1.0/highest);
  }
}


//hard clip signal to within -1.0 to 1.0
void clip() {
  for (int i = 0; i < audiosignal.length; i++) {
    if (audiosignal[i] > 1.0) {
      audiosignal[i] = 1.0;
    }
    if (audiosignal[i] < -1.0) {
      audiosignal[i] = -1.0;
    }
  }
}


//adds a random number to each signal
void addNoise() {
  for (int i = 0; i < 512; i++) {
    audiosignal[i] += (random(-1, 1) * 0.1);
  }
  checkAmp(audiosignal);
}


//uses perlin noise (through processing's noise() function)
void addPerlin() {
  for (int i = 0; i < 512; i++) {
    audiosignal[i] = noise(frameCount*0.1 + i*0.01) * 2.0 - 1.0;
  }
}


//each sample becomes an average of neighbouring samples (a kind of low pass filter)
void smoothWave(float[] sig) {
  for (int i = 1; i < 510; i++) {
    sig[i] = (sig[i] + sig[i] + sig[i+1] + sig[i-1]) / 4;
  }

  sig[0] = (sig[0] +sig[0] + sig[1] + sig[511]) / 4;
  sig[511] = (sig[511] +sig[511] + sig[510] + sig[0]) / 4;
}

