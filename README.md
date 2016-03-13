# Processing Synthesizer

Simple additive/subtractive synthesizer using Processing. Allows custom hand-drawn wavetables. Uses Discrete Fourier Transform (DFT) to calculate frequency response.

### Requirements
Requires processing 2.0+ and the [minim audio library](http://code.compartmental.net/tools/minim/). Works with Processing 3.0.

### Hotkeys
* s: toggle 'autosmoothing' - continually averages out the waveform in realtime
* 2-7: add nth harmonic. 2n = octave. 3n = perfect fifth, etc.
* c: bitcrush - halves the bitrate at each keypress.
* i: turn waveform into a triangle wave
* q: turn wafeform into squarewave
* p: generate random waveform using perlin noise
* p: generate random waveform using white noise
