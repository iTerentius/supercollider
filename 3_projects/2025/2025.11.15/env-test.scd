TempoClock.default.tempo = 1;
(
~g1envbuf.tryPerform(\free);
~g1envbuf = Buffer.loadCollection(
  s,
  Env([0,1,0],[0.05,1.0],[0,-4]).asSignal(512)  // power-of-two size
);
)
(
SynthDef(\et, { |out, freq=220, amp=0.4, t_gate=1, dur=1|
  var env, sig;
  env = EnvGen.kr(Env([0, 1, 0], [0.3, 1], 4), t_gate, 1, 0, dur.sqrt, 2);
  sig = LFPulse.ar([freq, freq+1]*env.midiratio * 0.5 * SinOsc.ar(dur/env, 3pi/2), 0, dur.sqrt) * amp;
  Out.ar(out, sig);
}).add;
)
(
Pdef(\p_et, Pbind(
  \instrument, \et, 
  \t_gate, 1, 
  // \octave, Pseq([4!2,5].flat, inf), 
  \octave, 4,
  \scale, Scale.phrygian, 
  \degree, Prand([0,1,4,7,Rest()], inf), 
  // \dur, Pseq([Pbjorklund2(3,8,inf), Rest(0.25)]/4, inf), 
  \dur, Pseq([Pseq([0.125, 0.25], inf), Rest()], inf), 
  // \dur, Pbjorklund2(7, 8, inf),
  \out, ~t2.inbus.index
));
)
Pdef(\p_et).play;
Pdef(\p_et).stop;
Pdef(\p_et).clear;

~t2_et = ~t1.play(\et);
~t2_et.tryPerform(\free);
~t2_gin1 = ~t1.playfx(\gin1, [\envbufnum, ~g1envbuf.bufnum, \amp, 1.2, \trigRate, 150, \grainDur, 0.04]);
~t2_gin1.tryPerform(\free);
~t2_gin1.class;
~t2_delay = ~t2.newPostSend(~r2, 1);
~t2_delay.free;
~t2_verb = ~t2.newPostSend(~r1, 1);
~t2_verb.free;

Ndef(\lfo, {SinOsc.kr(10).range(-0.5, 0.5)});
Ndef(\lfo).clear;
~t2.set(\pan, Ndef(\lfo));
~t2.pan_()

Env.new([0, 1, 0.8, 0], [0.1, 0.7, 1], 4).plot;

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
)
Pdef(\doom).play(quant: 4);
Pdef(\doom).stop;

~mOut.control(0, 2, 80); 
(
Pdef(\doom_cc1, Pbind(
  \type, \midi,
  \midiout, Pfunc { ~mOut },
  \chan, 1,
  \midicmd, \control,
  \ctlNum, 1,
  \control, Pdefn(\doom_cc1)
  \dur, 0.25
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
