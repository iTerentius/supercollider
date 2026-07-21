
(
Ndef.dictFor(s).clock = ~link;
Ndef.dictFor(s).quant = 1;
Ndef.dictFor(s).fadeTime = 2;
)
// Example:
Ndef(\pad, { SinOsc.ar([100, 441]) * 0.2 });
Ndef(\pad).fadeTime = 2;

Ndef(\pad).play;
Ndef(\pad).stop;
Ndef(\pad).clear;

Ndef(\pad).source = ~ufn[\dk];
Ndef(\pad).map(\freq,  Ndef(\lfo));

Ndef(\lfo, {SinOsc.ar(0.5) + 3 * 2});

(
Ndef(\insLead).fadeTime = 0;
Ndef(\insLead, { |freq = 220, amp = 0.3,   mod1 = 1 |
  SinOsc.ar(freq ! 2) * mod1 * amp * EnvGen.kr(Env.asr(0.1, 1, 0.8), gate: 1)
}).play;
Ndef(\insLead)[1] = \pset -> Pbind(
  \octave,  3,  
  \degree,   Pslide([0, 2,  1,  4,  7,  9], inf,  3,  4),  
  \dur,  1/2, 
  \amp,  0.1,
  \bits,   Pwhite(4,  24, inf), 
  \rate,   Pseq([500, 3000, 12000], inf), 
  \stretch, Pseg([1,  1/4], [4],  \sin,  inf),  
);
Ndef(\insLead)[2] = \filter -> { |in|
        var sig = in;
        var wet = Decimator.ar(sig, \rate.kr(44100), \bits.kr(8));
        XFade2.ar(sig, wet, \mix.kr(1).linlin(0, 1, -1, 1)) * \amp.kr(1)
    };
Ndef(\insLead)[3] = \mix ->  ~ufn[\dk];
)
Ndef(\insLead).map(\bits, Ndef(\lfo));
Ndef(\insLead)[2] = nil;
Ndef(\insLead).stop;
Ndef(\insLead).clear;
~sTree[\bd];

(
~loadSamps.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamps.("~/Music/supercollider/_samples/goldbaby/Cassette808/");
~loadSamps.("~/Music/supercollider/_samples/_mono/");
)
(
Ndef(\insKick).source =  Pbind(
  \instrument,  \pBs,  
  \bufnum,  Pseq(~sTree[\bass_drums].values[1..3], inf),   
  \amp,  0.4, 
  \dur,   1,
  \stretch, Pseg([1,   1/5],[8],  \sin,   inf), 
);
Ndef(\insKick)[1] = \filter -> {|in, delayTime=2.0, size=0.2, damp=0,  diff=0.707,  feedback=0.9, modDepth=0.1, modFreq=2.0 | Greyhole.ar(in, delayTime, size,  damp, diff, feedback, modDepth, modFreq)};
// Ndef(\insKick)[1] = nil;
);

)
// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
Ndef(\insKick).set(\size,  0.8, \damp,  0.1,  \diff,  0.8,  \modDepth,  0.5);
Ndef(\insKick).map(\modFreq,  Ndef(\lfo));
Ndef(\insKick).map(\size,  Ndef(\lfo));
Ndef(\insKick).set(\wet1, 0.5);
Ndef(\insKick).play;
Ndef(\insKick).stop;
Ndef(\insKick).clear;
Ndef.clear;

NdefMixer(s);
