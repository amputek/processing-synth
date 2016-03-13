import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
customWave sig;
Filter filterEffect;

//GUI elements here: 
Knob cutoff;
Knob reso;
Knob lfoRate;
Knob lfoDepth;
Knob pitch;
Knob amp;

Toggle pass;
Toggle filterActive;
Toggle lfoActive;
PFont font;

float theNumber = 44100.0/512.0;

//mouse variables - saves time of last mouse and whether not a UI element is active
boolean mouseDown = false;

boolean fr = true;
boolean autoSmooth = false;
boolean filterOn = false;
boolean lfoOn = false;

float[] audiosignal;   //input signal wavetable
float[] outputsignal;  //final output signal (what comes through speakers)
float[] fxsignal;      //signal post-filter

int bitcrush = 512;


void setup()
{
  size(912, 700, P3D);
  smooth();
  font = loadFont("Monospaced-48.vlw");
  textFont(font, 12);
  minim = new Minim(this);

  //signals
  audiosignal = new float[512];
  outputsignal = new float[512];
  fxsignal = new float[512];

  //initalise GUI elements
  cutoff =    new Knob(345, 340, 40, "cutoff");
  reso =      new Knob(420, 340, 40, "reso");
  lfoRate =   new Knob(345, 420, 40, "LFO rate");
  lfoDepth =  new Knob(420, 420, 40, "LFO depth");
  pitch =     new Knob(110, 350, 60, "pitch");

  filterActive = new Toggle(480, 330, "active", "off", "on");
  pass =         new Toggle(480, 390, "pass", "lp", "hp");
  lfoActive =        new Toggle(480, 450, "lfo", "off", "on");

  //new filter effect
  filterEffect = new Filter(3000);

  //start off with sine
  makeSine();

  out = minim.getLineOut(Minim.STEREO, 1024, 44100);
  sig = new customWave(100, 0.5, 44100);

  sig.setSignal(audiosignal);
  out.addSignal(sig);
}


//draw oscilliscope method
void oscilliscope() {
  stroke(255, 0, 0, 150);
  strokeWeight(1);
  for (int i = 1; i < 511; i++){
    line(i+50, 600 + out.left.get(i)*100, i-1+50, 600 + out.left.get(i-1)*100);
  }
}

//draw method
void draw() {
  background(0);
  
  drawGUI();
  oscilliscope();
  updateFilter();

  //smooth function - esentially a destructive low pass filter
  if (autoSmooth == true) {
    smoothWave(audiosignal);
  }
  
  //get pitch from pitch knob
  if(pitch.active == true){
    sig.setFreq(int((pitch.value() + 1.0) * 300));
  }

  stroke(255, 0, 0, 255);
  strokeWeight(2);

  //draw wavetable(s)
  for (int i = 1; i < 512; i++) {
    outputsignal[i] = out.left.get(i);
    strokeWeight(2);

    if (filterOn == true) {     
      stroke(0, 255, 255, 255);
      line(i+50, fxsignal[i] * 100 + 150, i-1+50, fxsignal[i-1] * 100 + 150);
            
      stroke(255,0,0,100);
      line(i+50, audiosignal[i] * 100 + 150, i-1+50, audiosignal[i-1] * 100 + 150);

    } else {
      
      line(i+50, audiosignal[i] * 100 + 150, i-1+50, audiosignal[i-1] * 100 + 150);
    }
  }

  //metering windows
  updateFR(audiosignal, 612, 50);
  updateFR(outputsignal, 612, 300);
  
  text(frameRate, width - 100, height - 20);

}



void updateFilter(){
  
  boolean reapply = false;  
  //bool function here because of a bug which results in filter not working as intended ONLY the first time it is ever switched on
  //solved by reapplying the filter at the end of the filter process
  
  if(filterActive.state() == 1){
    if(filterOn == false){
      filterOn = true;
      reapply = true;
      applyFilter();
    }
  } else {
    if(filterOn == true){
      filterOn = false;
      sig.setSignal(audiosignal);
      fxsignal = new float[512];    
    }
  }
  
  
  //if filter is switched on, process. otherwise don't bother.
  if(filterOn == true){
    //check if high pass / low pass
    if(pass.state == -1){
      filterEffect.setState("lp");  
    } else {
      filterEffect.setState("hp");  
    }
    
    //mapping cutoff from knob (-1, 1) to (150 to 10150)
    float cut = (cutoff.value() + 1.0) * 5000 + 550;
   
    //mapping resonance from 0.25 to 0.75
    float res = ((reso.value() + 1.0) / 2) * 0.5 + 0.25;
    filterEffect.setResonance(res);

    //if LFO is on
    if(lfoActive.state() == 1){
      if(lfoOn == false){
        lfoOn = true; 
   
        //mapping rate to ...
        float rate = 0.55 + (lfoRate.value() / 4);
      
        //mapping depth from (-1.0, 1.0) to (0, 500);
        float depth = (lfoDepth.value() + 1.0) * 200;
      
        //make sure depth does not exceed cutoff (goes below 0)
        if(cut < 700){
          depth = cut-600;
        }
      
        filterEffect.baseCutoff = cut;
        filterEffect.LFOrate = rate;
        filterEffect.LFOdepth = depth;
      }
    } else {
      if(lfoOn == true){
        lfoOn = false;
      }  
    }
    
    if(lfoRate.active == true){
      float rate = 0.55 + (lfoRate.value() / 4);
      filterEffect.LFOrate = rate;
    }
    
    if(lfoDepth.active == true){
      float depth = (lfoDepth.value() + 1.0) * 200;
      filterEffect.LFOdepth = depth;
              if(cut < 700){
          depth = cut-600;
        }
      
    }
    
    //the sine function is kept in the filter class- this is just telling it to update
    if(lfoOn == true){
      filterEffect.update();
    }
    
    //if cutoff knob is being moved - update cutoff (and therefore coefficients)
    if(cutoff.active == true){
      filterEffect.setCutoff(cut); 
    }
    
    
    //if any of the filter parameters change, reapply filter (recalculate coefficients)
    if (cutoff.active == true || reso.active == true || lfoOn == true) {
      applyFilter();
    }
    
    if(reapply == true){
      applyFilter();  
    }
    
  } 
}


//copies current wavetable for processing
void applyFilter() {

  arraycopy(audiosignal, fxsignal);
  
  for(int i = 0; i < 512; i++){
    fxsignal[i] *= 0.7;  
  }
  
  filterEffect.process(fxsignal);
  sig.setSignal(fxsignal);
}


void drawGUI(){
  fill(255, 255);
  strokeWeight(1);
  stroke(255, 255);
  
  //texts
  textAlign(LEFT);
  text("waveform", 50, 50);
  text("input frequency response", 615, 50);

  text(("global controls"), 50, 300);
  text(("filter controls"), 306, 300);
  text(("output frequency response"), 615, 300);
  text("oscilliscope", 50, 550);

  textAlign(CENTER);
  text("[s: toggle autosmooth] [2-7: add harmonic] [c: bitcrush] [u: print signal values]", width/2, height - 35);
  text("[i: make triangle] [q: make square] [w: make sine] [p: make perlin] [n: add noise]", width/2, height - 20);

  textAlign(RIGHT);
  text((sig.frequency() + "Hz"), 50+512, 250);
  
  //rectangle frames
  fill(0, 0);
  rect(50, 50, 512, 200);
  line(50, 150, 612-50, 150);
  rect(50, 300, 205, 200);
  rect(50, 550, 512, 100);
  rect(306, 300, 256, 200); //middle box
  line(50, 600, 612-50, 600);
  rect(612, 550, 258, 100);
  
  //knobs
  cutoff.draw();
  lfoRate.draw();
  lfoDepth.draw();
  reso.draw();  
  pitch.draw();
  
  //toggles
  lfoActive.draw();
  pass.draw();
  filterActive.draw();
 
}


void stop() {
  out.close();
  minim.stop();
  super.stop();
}

