TempoClock.default.tempo = 1;
////////////////////////////////////////////////////////////////////
// Out-sourced MIDI to DAW
////////////////////////////////////////////////////////////////////
(
Pdefn(\doom, Pseq(
[0, \, 4, \],inf));
Pdefn(\doom_dur, Pseq(
[1/4, Rest(3/4)] ,inf));
Pdefn(\doom_sus, Pseq(
[1/2, 1/4, 1, 1/2] ,inf));
Pdefn(\doom_oct, Pseq(
[3, 2], inf));
Pdefn(\doom_cc1, Pwhite(
100, 400, inf));
Pdefn(\doom_cc2, Pbrown(
0, 1, inf));
)
/* DOOM */
(
Pdef(\doom, Pbind(
  \type, \midi,
  \midiout, ~mOut, \chan, 0,
  \octave,  Pdefn(\doom_oct),
  \degree,  Pdefn(\doom),
  \sustain, Pdefn(\doom_sus),
  \dur,     Pdefn(\doom_dur) 
)).quant_(4);
~apcAssignPad.(32, \doom);
)
Pdef(\doom).play(quant: 4);
Pdef(\doom).stop;

~mOut.control(0, 2, 80); 
(
Pdef(\doom_cc1,  Pbind(
\type,           \midi,
\midiout,        Pfunc { ~mOut },
\chan,           1,
\midicmd,        \control,
\ctlNum,         1,
\control,        Pdefn(\doom_cc1)
\dur,            0.25
)).quant_(4);
)
Pdef(\doom_cc1).play;
Pdef(\doom_cc1).stop;

(
Pdef(\doom_cc2, Pbind(
  \type, \midi,
  \midiout, Pfunc { ~mOut },
  \chan, 2,
  \midicmd, \control,
  \ctlNum, 2,
  \control, Pdefn(\doom_cc1),
  \dur, 0.25
)).quant_(4);
)
Pdef(\doom_cc2).play;
Pdef(\doom_cc2).stop;
Pdef.clear;
Pdef(\bit_s1).play(quant: 4); Pdef(\bit_p1).play(quant: 4); Pdef(\ccTest).play(quant: 4);
Pdef(\bit_s1).stop; Pdef(\bit_p1).stop; Pdef(\ccTest).stop;
