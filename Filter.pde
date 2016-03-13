public class Filter {

  float a1, a2, a3, b1, b2;    //coefficients
  float r = 0.1;               //resonance
  float cutoff = 1000;
  float baseCutoff = 1000;     //base cutoff around which an LFO would oscillate
  String pass = "lp";
  
  float LFOrate = 0.1;
  float LFOdepth = 500;

  public Filter(int cutoff) {
    setCutoff(cutoff);
  }

  void update(){
    setCutoff((sin(frameCount*LFOrate) * LFOdepth) + baseCutoff);
  }

  void setDepth(int depth){
    LFOdepth = depth;
  }

  void setResonance(float reso) {
    if (reso >- 0.1 && reso <= 1.0) {
      r = reso;
      calculateCoefficients();
    }
  }
  
  void setState(String p){
    if(p != pass){
      pass = p; 
      calculateCoefficients();
      applyFilter();
    }  
  }

  void setCutoff(float cutoff) {
    this.cutoff = cutoff;
    this.baseCutoff = cutoff;
    calculateCoefficients();
  }

  //calculate coefficients - low pass or high pass
  void calculateCoefficients() {
    if (pass == "lp") {
      float c = 1.0 / tan(PI * cutoff / 44100);
      a1 = 1.0 / (1.0 + r * c + c * c);
      a2 = 2*a1;
      a3 = a1;
      b1 = 2.0 * (1.0 - c*c) * a1;
      b2 = (1.0 - r * c + c * c) * a1;
    } 
    else {
      float c = tan(PI * cutoff / 44100);
      a1 = 1.0 / ( 1.0 + r * c + c * c);
      a2 = -2*a1;
      a3 = a1;
      b1 = 2.0 * ( c*c - 1.0) * a1;
      b2 = ( 1.0 - r * c + c * c) * a1;
    }
  }

  void process(float[] sig) {

    float[] output = new float[sig.length];

    //first two samples do not use 'earlier' coefficients - no pre - input/output to refer to
    output[0] = a1*sig[0];
    output[1] = a1*sig[1] + a2*sig[0];
    
    //loop through rest of signal using all coefficients
    for (int i = 2; i < sig.length; i++) {
      output[i] = a1*sig[i] + a2*sig[i-1] + a3*sig[i-2] - b1*output[i-1] - b2*output[i-2];
    }
    
    //smooths the first and last 20 samples towards 0 to avoid clicks
    for(int i = 1; i < 20; i++){
      output[512-i] = output[512-i] * (1.0 - (1.0/i));
      output[i-1] = output[i-1] * (1.0 - (1.0/i));
    }

    arraycopy(output, sig);
  }
}
