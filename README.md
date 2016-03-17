# Processing Synthesizer

Additive/subtractive synthesizer using Processing. Allows custom hand-drawn wavetables. Uses Discrete Fourier Transform (DFT) to calculate frequency response.

Biquad Filter Coefficient algorithms courtesy of Patrice Tarrabia [musicdsp.org/archive.php]()

## Requirements
Requires processing 2.0+ and the [minim audio library](http://code.compartmental.net/tools/minim/). Works with Processing 3.0.

## Hotkeys
* s: toggle 'autosmoothing' - continually averages out the waveform in realtime
* 2-7: add nth harmonic. 2n = octave. 3n = perfect fifth, etc.
* c: bitcrush - halves the bitrate at each keypress.
* i: turn waveform into a triangle wave
* q: turn wafeform into squarewave
* p: generate random waveform using perlin noise
* p: generate random waveform using white noise

## Description

The minim ‘Oscillator’ class has been extended to allow a customisable wavetable array. Normally, the `protected value(float step)` method returns a float which is taken from a predefined set. For example, for a Sinewave oscillator, the method would `return (float) sin(step * 512.0)`. For this task, however, the method returns a value from the audiosignal array - allowing a custom audiosignal array, which can changed dynamically in real-time while still being accessed by the Oscillator class. Calculations and filters can be applied to the array of values without disrupting the output. The signal class makes use linear interpolation to ensure a clean signal.

#### Additive Synthesis

It is possible to convert the signal to a sine, square, or triangle wave. These are achieved by adding together sine waves of varying harmonics, phases, and amplitudes. To create a square wave, for example, the program will continuously call the `addSine(int freq, float amp, float phase)` method, where the frequency increases by two each time, and the amplitude is reduced by a third. The more this is repeated, the ‘tighter’ the square wave becomes. Just as the square wave can be built from sine tones, Fourier Analysis suggests that any sound, regardless of complexity, has an equation of sinusoids that will generate it.

The program also has the ability to add harmonics to custom waves. This `addHarmonic(int h, float amp)` works by taking the full wavetable and converting into a higher frequency - so that the full wavetable fits into the total window size a number of times (specified by h). If h = 2, for example, the a new wavetable will be created which completes a cycle twice as fast. This new wave is then added to the original signal (with an amp modifier taken into account).

Other additive techniques used are white noise (where each sample becomes a random number between -1.0 and 1.0), and Perlin noise (which is a more natural form of noise). Note that these are not actual noise, because they are applied destructively to the wavetable once, and the resulting 512 samples will be repeated as a cycle. True noise would continuously create new random samples.


#### Subtractive Synthesis

When the filter is applied, the audiosignal array is copied to a new signal array (called fxsignal). This new array is filtered. The waveform can still be edited as normal, with edits affecting the original audiosignal array, which in turn is copied and filtered to become the filtered array. This means that the synth will continue to allow editing even while the filter is on - with a copied, affected signal being updated in parallel to the original signal.

The Filter itself is it’s class - which stores the coefficient values, as well as cutoff and resonance values. As cutoff and resonance values can be altered by GUI knobs, the coefficients will update accordingly. Some smoothing is used (on the first and last 20 samples) in order to avoid clicks as the wavetable jumps from the 512th sample to the 0th sample.

###### Low Pass Coefficients
```
c = 1.0 / tan(PI * cutoff / 44100)
a1 = 1.0 / (1.0 + r * c + c * c)
a2 = 2 * a1
a3 = a1
b1 = 2.0 * (1.0 - c * c) * a1
b2 = (1.0 - r * c + c * c ) * a1
```

###### High Pass Coefficients
```
c = tan(PI * cutoff / 44100)
a1 = 1.0 / (1.0 + r * c + c * c)
a2 = -2 * a1
a3 = a1
b1 = 2.0 * (c * c - 1.0) * a1
b2 = (1.0 - r * c + c * c ) * a1
```

###### Filter equation
```
out[i] = a1*sig[i] + a2*sig[i-1] + a3*sig[i-2] - b1*out[i-1] - b2*out[i-2]
```

The filter has low pass and high pass options, which affect the coefficents accordingly. The filter also has an Low-Frequency Oscillator which will dynamically affect the cutoff parameter. The value of the cutoff oscillates (through a sinewave function) by the amount specified by the LFO Rate and LFO Depth knobs. If the LFO is enabled, the Filter class will constantly update the coefficients at the oscillating cutoff.



#### Discrete Fourier Transform

The frequency responders use Discrete Fourier Transforms to calculate magnitudes at various frequencies. This is located in the `updateFR(float[] aSignal, int x, int y)` and `dft(int component, float[] aSignal)` methods.

The DFT process involves totalling up ‘bins’ along the frequency spectrum. The algorithm is roughly as follows (also see comments in the source code of these methods):

* Take a cosine who’s length fits into the sample window a number of times specified by the component
* Multiply each sample value of the signal by cosine value
Sum these together to get the ‘real’ component at frequency which is determined by component * (Samplerate / WindowSize)
Repeat process with a sine wave to get the ‘imaginary’ component

The resulting table contains a set of Bin numbers, Frequencies, Real components, and Imaginary components. To locate the magnitude at the specified frequency, the square root of the sums of the real and imaginary components is taken. This tells us “frequency by frequency the amplitude relationship of the various harmonics in the signal.” This set of numbers can now be plotted onto a graph as a dynamic Frequency Responder.

input frequency response is DFT applied to the wavetable itself - prior to pitching and output.
output frequency response is DFT applied to the final resulting signal that minim passes.
