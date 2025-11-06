//////////////////////////////////////////////////////////////////////////////////////
(
Ndef(\dynklanks).fadeTime_(2);
Ndef(\dynklanks, { | freqs = #[200, 671, 1153, 1723] |
	DynKlank.ar(`[freqs, nil, [1, 1, 1, 1]], PinkNoise.ar([0.007,0.007]))
  // DynKlank.ar(`[freqs, nil, [1, 1, 1, 1]], Dust.ar(8, 0.1)) 
});
)
~rez = ~t3.play(Ndef(\dynklanks));
~rez.tryPerform(\free);
// Ndef(\dynklanks).play;
// Ndef(\dynklanks).stop(3);
Ndef(\dynklanks).clear;

Ndef(\dynklanks).xset(\freqs, [333, 444, 555, 666].rand);

/////////////////////////////////////////////////////////////////////////////////////
(
var env = Env.new([0, 1, 0], [0.01, 1], [0, -4]);
~grainenv = Buffer.loadCollection(s, env.discretize(8192));
)
~samp1 = ~samplesTree.at(\hoarder_mono).asArray[4];
~samp1 = ~samplesTree.at(\hoarder_mono).asArray;
~samp1 = ~samplesTree.at(\_mono).asArray;
~samp1 = ~getSample.(\_mono, \Ya_Ya_125bpm_Vox);

Pdef(\gpat, Pbind(\instrument, \gb1, \dur, Pseq([2, Rest()],inf), \amp, 0.2, \trig_rate, 32, \buf, ~samp1, \env, ~grainenv, \grain_dur, Prand([0.05, 0.125, 0.25, 0.5],inf), \rate, Prand([-4, 2, 0],inf), \out, ~t2.inbus.index)).play;

~t2_src = ~t2.play(\gb1, [\buf, ~samp1, \env, ~grainenv] );
~t2_src.tryPerform(\free);
~t2_src.set(\trig_enabled, 1, \pos, 0);
~t2_src.set(\buf, ~samp2);
~t2_src.free;

~samp2 = Buffer.readChannel(s, "/Users/isaaclinder/Music/supercollider/_samples/Field/Bambu/bambu-1.wav", channels: [0]);
~loadSamplesRecursive.("~/Music/supercollider/_samples/_mono/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/_mono/hoarder_mono/");
~samp2 = ~samplesTree[\hoarder_mono][\04_6_rats];
