
// sources
Ndef(\kick, { Decay2.ar(Impulse.ar(2), 0.005, 0.2) * SinOsc.ar(45) * 0.8 ! 2 }).quant_(1).play(out:6);
Ndef(\pad,  { Saw.ar([100,101]) * 0.15 }).play;

// ducking stage
Ndef(\duck, {
    var pad  = Ndef.ar(\pad);
    var amp  = Amplitude.kr(Mix(Ndef.ar(\kick)), 0.01, 0.1).lag(0.03);
    var gain = (1 - (amp * 1.6)).clip(0.2, 1); // floor at -14 dB
    pad * gain
}).play;

// one trigger per *beat* (TempoClock.default is driven by Tidal cps)
Ndef(\beat, { Impulse.kr(TempoClock.default.tempo) }).quant_(1);

// 4-on-the-floor kick: fire on every beat
Ndef(\kick).quant = 1;

(
Ndef(\kick, {
    var trig = Ndef.kr(\beat);          // 1 trig per beat
    var env  = Decay2.kr(trig, 0.001, 0.12);
    // simple punchy synth kick
    var sweep = EnvGen.kr(Env([1, 0], [0.06], curve: -8), trig);
    var sig   = SinOsc.ar(48 + 120*sweep) * env * 0.9
              + BPF.ar(WhiteNoise.ar(0.15), 1200, 0.5) * env * 0.25;
    (sig ! 2) * 0.7
}).play(quant: 1);

)

// if you want quarter‑notes explicitly (same as above):
// Ndef(\kick, { ... trig = Ndef.kr(\beat) ... });

// if you want 8ths or 16ths instead:
Ndef(\beat8,  { Impulse.kr(TempoClock.default.tempo * 2) }).quant_(1);
Ndef(\beat16, { Impulse.kr(TempoClock.default.tempo * 4) }).quant_(1);
// then use trig = Ndef.kr(\beat8) or \beat16 in the kick if desired


History.clear.end;     // if needed, clear History first
History.start;         // starts recording, opens log file

// execute these lines one by one, as a little performance history
1 + 2;
p = ProxySpace.push(s.boot);
~a = { Dust.ar([1, 1] * 30) * 0.3 };
~a.play;
~a.end(3);

History.started; // is it on now?

// stops recording history and ends logging.
History.end;
History.started;

History.document;      // creates a document with current history
History.showLogFolder; // opens the folder where logs are written.
History.showLogFile;   // opens the current log file as it was written.


// make a gui window, to access code history lines at will,
// e.g. for code reuse in performance, adaptation, sharing, etc:
g = History.makeWin;
// specify left-bottom position, and number of lines in textview
g = History.makeWin(0@20, 5);

// play back the recorded history line by line
History.play(0);


// history can even record and play back stops with CmdPeriod.
// run these lines one at a time:
History.clear.start;
1 + 2;
2 + 3;
s.boot;
(dur: inf).play;

CmdPeriod.run; // or hit the Stop key command, Cmd-., or ctrl-.
3 + 4; // continue recording into history
4 + 5;
History.end;

// Replays history, including a CmdPeriod, and keeps replaying history.
History.play;


////////////////////////////////////////////////////////////
// Boot + safety
////////////////////////////////////////////////////////////
// s.waitForBoot {
    // a shared aux bus for "send" effects (stereo)
    ~verbBus = Bus.audio(s, 2);
    ~delBus  = Bus.audio(s, 2);

    ////////////////////////////////////////////////////////
    // 1) SOURCE: Ndef driven by a Pattern
    //    Ndef(\mel) will host a pattern player and audio chain.
    ////////////////////////////////////////////////////////
    Ndef(\mel).fadeTime = 0.25; // smooth switching of sources/filters

    // Pattern → directly into Ndef(\mel). Internally it writes to the proxy’s private bus.
    Ndef(\mel, Pbind(
        \instrument, \default,
        \octave, 5,
        \dur, Pseq([0.125, 0.125, 0.25, 0.25], inf),
        \degree, Pseq([0, 2, 4, 2, 5, 4, 2, 0], inf),
        \legato, 0.8,
        \amp, 0.15,

        // per‑event aux‑send amounts (0..1); these are read by a filter tap below
        \verbSend, Pwhite(0.0, 0.5, inf),
        \delSend,  Pseg(Pseq([0.0, 0.6, 0.2, 0.8], inf), 4, \lin)
    ));

    // Start audio
    Ndef(\mel).play;

    ////////////////////////////////////////////////////////
    // 2) INSERT FX CHAIN on Ndef(\mel)
    //    Use numbered slots: [0], [1], [2] ... (ordered top → bottom)
    //    Each slot is a \filter whose function gets 'in' (the running signal).
    ////////////////////////////////////////////////////////

    // [0] gentle HPF to clean sub rumble
    Ndef(\mel)[0] = \filter -> { |in| HPF.ar(in, 40) };

    // [1] tone shaper: resonant lowpass you can tweak live via .set
    Ndef(\mel)[1] = \filter -> { |in freq=1400 rq=0.3|
        RLPF.ar(in, freq.clip(60, 18000), rq.clip(0.05, 1.0));
    };

    // [2] soft drive
    Ndef(\mel)[2] = \filter -> { |in drive=0.4|
        var sat = tanh(in * (1 + (drive * 10)));
        // mix a little dry to keep dynamics
        XFade2.ar(in, sat, 0.2)
    };

    // tweakable example:
    // Ndef(\mel).set(\freq, 1800, \rq, 0.2, \drive, 0.6);

    ////////////////////////////////////////////////////////
    // 3) AUX SENDS (post‑insert tap) → dedicated effect Ndefs
    //    We tap the signal, write scaled copies to aux buses, and leave 'in' unchanged.
    ////////////////////////////////////////////////////////
    Ndef(\mel)[90] = \filter -> { |in verbSend=0 delSend=0|
        // scale sends and write to aux buses
        Out.ar(~verbBus, in * verbSend);
        Out.ar(~delBus,  in * delSend);
        in // pass the dry/insert‑processed signal along unchanged
    };

    // Now define the aux FX that *read* from those buses.
    // Reverb aux
    Ndef(\verb, {
        var wet = In.ar(~verbBus, 2);
        wet = FreeVerb2.ar(wet[0], wet[1], mix: 0.33, room: 0.86, damp: 0.5);
        // light post‑verb EQ to keep it airy
        wet = BHiPass.ar(wet, 200) ! 2;
        wet * 0.5
    }).play(addAction: \addToTail); // tail so it renders after sources

    // Delay aux
    Ndef(\delay, {
        var wet = In.ar(~delBus, 2);
        var t   = 0.375; // 3/8 @ 1 beat/sec; change to taste
        // ping‑pong
        var l = CombL.ar(wet[0], 1.0, t, 4);
        var r = CombL.ar(wet[1], 1.0, t*0.75, 4);
        (l + r) * 0.35
    }).play(addAction: \addToTail);

    ////////////////////////////////////////////////////////
    // 4) DRIVING THE SEND AMOUNTS FROM THE PATTERN
    //    The \verbSend and \delSend keys in the Pattern will flow into slot [90].
    //    You can also set global floors/offsets here:
    ////////////////////////////////////////////////////////
    Ndef(\mel).set(\verbSend, 0.2, \delSend, 0.1); // baseline; per‑event values add on top

    ////////////////////////////////////////////////////////
    // 5) LIVE CONTROL CHEATSHEET
    ////////////////////////////////////////////////////////
    (
    // swap the melodic pattern on the fly
    Ndef(\mel).source = Pbind(
        \instrument, \default,
        \scale, Scale.dorian,
        \degree, Pshuf((0..7), inf),
        \dur, 0.125,
        \amp, 0.12,
        \verbSend, Pwhite(0.0, 0.5, inf),
        \delSend,  Pseg(Pseq([0.0, 0.7, 0.2, 0.6], inf), 6, \exp)
    );
    );

    // edit insert FX params live
    // Ndef(\mel).set(\freq, 1200, \rq, 0.25);
    // Ndef(\mel).set(\drive, 0.8);

    // change aux FX tones live
    // Ndef(\verb).vol = -6;   // proxy volume in dB
    // Ndef(\delay).vol = -9;

    // reorder or bypass insert FX:
    // Remove a slot:
    // Ndef(\mel).clear(2); // removes the drive slot
    // Replace a slot:
    // Ndef(\mel)[1] = \filter -> { |in| BPF.ar(in, 1000, 0.2) };

    // stop everything quickly:
    // Ndef.clear;  s.freeAll; ~verbBus.free; ~delBus.free;
};

