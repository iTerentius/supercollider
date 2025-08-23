~verbBus = Bus.audio(s, 2);
~delBus  = Bus.audio(s, 2);

Ndef(\mel).fadeTime = 0.25; // smooth switching of sources/filters

// Pattern → directly into Ndef(\mel). Internally it writes to the proxy’s private bus.
(
Ndef(\mel, Pbind(
    \instrument, \test,
    \octave, 5,
    \dur, Pseq([0.125, 0.125, 0.25, 0.25], inf),
    \degree, Pseq([0, 2, 4, 2, 5, 4, 2, 0], inf),
    \legato, 0.8,
    \amp, 0.15,

    // per‑event aux‑send amounts (0..1); these are read by a filter tap below
    \verbSend, Pwhite(0.0, 0.5, inf),
    \delSend,  Pseg(Pseq([0.0, 0.6, 0.2, 0.8], inf), 4, \lin)
));

)

// Start audio
Ndef(\mel).play;

// [0] gentle HPF to clean sub rumble
(
Ndef(\mel)[0] = \filter -> { |in|
    HPF.ar(in, 1440)
};
)

// [1] tone shaper: resonant lowpass you can tweak live via .set
(
Ndef(\mel)[1] = \filter -> { |in freq=1400 rq=0.3|
    RLPF.ar(in, freq.clip(60, 18000), rq.clip(0.05, 1.0))
};
)

// [2] soft drive
(
Ndef(\mel)[2] = \filter -> { |in drive=0.4|
    var sat = tanh(in * (1 + (drive * 10)));
    // mix a little dry to keep dynamics
    XFade2.ar(in, sat, 0.2)
};
)

// tweakable example:
// Ndef(\mel).set(\freq, 1800, \rq, 0.2, \drive, 0.6);

