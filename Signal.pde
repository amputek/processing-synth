//wavetable class
class customWave extends Oscillator {

  float[] currentsignal;

  public customWave(float f, float a, float s) {
    super(f, a, s);
  }

  void setSignal(float[] signal) {
    currentsignal = signal;
  }

  //converts a 0.0 - 1.0 float to a 0-512 integer using linear interpolation
  protected float value(float step) {

    float x = step * 512.0;
    int x0 = floor(x);    //lower array value
    int x1 = ceil(x);     //higher array value
    
    if (x1 == 512) {
      x1 = 0;
    }
    float y0 = currentsignal[x0];
    float y1 = currentsignal[x1];

    float y = y0 + ((x-x0)*y1 - (x-x0)*y0) / (x1 - x0);

    return y;
  }
}

