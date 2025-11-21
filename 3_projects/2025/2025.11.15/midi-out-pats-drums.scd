TempoClock.default.tempo = 60/60;
////////////////////////////////////////////////////////////////////
// Out-sourced MIDI to DAW
////////////////////////////////////////////////////////////////////

(
Pbindef(\bd1,
\type, \midi,
\octave, 3,
\midiout, ~mOut, \chan, 0,
\degree, Pseq([0, 0, 0, 0], inf),
// \amp, Pseq([0.3, 0.7, 0.5, 0.8], inf),
\dur, Pseq([2/4, 1/4, 1/4, 1/2],inf),
\amp, 0.1
).play;
)
Pbindef(\bd1).stop;
Pbindef(\bd1).clear;

(
Pbindef(\hh1,
\type, \midi,
\octave, 3,
\midiout, ~mOut, \chan, 0,
\note, Pseq([\, \, 1, \], inf),
\dur, 1/2,
).play;
)
Pbindef(\hh1).stop;
