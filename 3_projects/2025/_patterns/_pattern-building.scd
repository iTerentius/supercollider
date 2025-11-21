
(
// 2025-11-20 09:15 drum song template with Pdefn + Pbindef + Pdef

////////////////////////////////////////////////////////////
// SynthDefs – simple 3 piece kit
////////////////////////////////////////////////////////////

SynthDef(\bd, { |out=0, amp=0.5, freq=55, atk=0.001, rel=0.25|
    var env, pitchEnv, sig;
    env = Env.perc(atk, rel).kr(doneAction: 2);
    pitchEnv = Env([1.5, 1, 0.7], [0.02, 0.18]).kr;
    sig = SinOsc.ar(freq * pitchEnv);
    sig = LPF.ar(sig, 2000) * env;
    Out.ar(out, sig ! 2 * amp);
}).add;

SynthDef(\sn, { |out=0, amp=0.4, rel=0.25|
    var env, noise, tone, sig;
    env = Env.perc(0.001, rel).kr(doneAction: 2);
    noise = WhiteNoise.ar;
    noise = BPF.ar(noise, 6000, 0.6);
    tone = SinOsc.ar(200) * 0.3;
    sig = (noise + tone) * env;
    Out.ar(out, sig ! 2 * amp);
}).add;

SynthDef(\hh, { |out=0, amp=0.3, rel=0.12|
    var env, noise, sig;
    env = Env.perc(0.001, rel).kr(doneAction: 2);
    noise = WhiteNoise.ar;
    noise = HPF.ar(noise, 8000);
    sig = noise * env;
    Out.ar(out, sig ! 2 * amp);
}).add;

TempoClock.default.tempo = 120 / 60;  // 120 bpm

////////////////////////////////////////////////////////////
// Section fragments as Pdefn – step patterns for song form
// Each step is one sixteenth note (\dur = 0.25)
////////////////////////////////////////////////////////////

// Kick – intro, verse, chorus
Pdefn(\k_intro, Pseq([
    // bar 1
    1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0,
    // bar 2 same
    1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0,  1, 0, 0, 0
], 1));

Pdefn(\k_verse, Pseq([
    // simple groove with occasional extra kicks
    1, 0, 0, 0,  1, 0, 1, 0,  1, 0, 0, 0,  1, 0, 1, 0,
    1, 0, 0, 0,  1, 0, 1, 0,  1, 0, 0, 0,  1, 0, 1, 1
], 2));  // repeat two times

Pdefn(\k_chorus, Pseq([
    // denser chorus pattern
    1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0,  1, 1, 1, 0
], 4));  // four bars

// Snare – intro, verse, chorus
Pdefn(\s_intro, Pseq([
    // sparse lead-in on 4
    0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0,
    0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0
], 1));

Pdefn(\s_verse, Pseq([
    // backbeat on 2 and 4
    0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0,  1, 0, 0, 0
], 8));  // eight bars

Pdefn(\s_chorus, Pseq([
    // add a few pickups
    0, 0, 0, 0,  1, 0, 0, 0,  0, 1, 0, 0,  1, 0, 0, 1
], 4));

// Hi-hat – intro, verse, chorus
Pdefn(\h_intro, Pseq([
    // eighths
    1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0,
    1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0
], 1));

Pdefn(\h_verse, Pseq([
    // add some off accents
    1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 0,  1, 0, 1, 1
], 8));

Pdefn(\h_chorus, Pseq([
    // sixteenth feel
    1, 1, 1, 0,  1, 1, 1, 0,  1, 1, 1, 0,  1, 1, 1, 1
], 4));

////////////////////////////////////////////////////////////
// Song-level Pdefn – concatenate sections into whole form
// Form: intro, verse, chorus then end
////////////////////////////////////////////////////////////

Pdefn(\k_song, Pseq([
    Pdefn(\k_intro),
    Pdefn(\k_verse),
    Pdefn(\k_chorus)
], 1));

Pdefn(\s_song, Pseq([
    Pdefn(\s_intro),
    Pdefn(\s_verse),
    Pdefn(\s_chorus)
], 1));

Pdefn(\h_song, Pseq([
    Pdefn(\h_intro),
    Pdefn(\h_verse),
    Pdefn(\h_chorus)
], 1));

////////////////////////////////////////////////////////////
// Voice skeletons with Pbindef – use song-level Pdefn
////////////////////////////////////////////////////////////

Pbindef(\kick,
    \instrument, \bd,
    \dur, 0.25,          // sixteenths
    \amp, Pdefn(\k_song) * 0.35
);

Pbindef(\snare,
    \instrument, \sn,
    \dur, 0.25,
    \amp, Pdefn(\s_song) * 0.4
);

Pbindef(\hat,
    \instrument, \hh,
    \dur, 0.25,
    \amp, Pdefn(\h_song) * 0.25,
    \rel, 0.08
);

////////////////////////////////////////////////////////////
// Top-level Pdef – the "song"
////////////////////////////////////////////////////////////

Pdef(\drumSong,
    Ppar([
        Pbindef(\kick),
        Pbindef(\snare),
        Pbindef(\hat)
    ])
);

)  // end block
Pbindef(\kick).play;
Pdef(\drumSong).play;
