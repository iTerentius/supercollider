// _includes/sc-tidal-sync.scd
// Keep TidalCycles <-> SuperDirt (SuperCollider) in lockstep without Ableton Link.
// Idempotent: safe to re-evaluate. Does NOT reload soundfiles or restart SuperDirt.

(
///////////////////////////////////////////////////////////////////////////////
// 0) Settings — adjust these to taste
///////////////////////////////////////////////////////////////////////////////
~desiredLatency = 0.10;   // MUST match oLatency in BootTidal.hs
~enableBeatBus  = true;   // if true, expose Ndef(\beat) as a 1-per-beat trigger
~enableKick     = false;  // if true, also make a synced Ndef(\kick)

///////////////////////////////////////////////////////////////////////////////
// 1) One clock only + latency
///////////////////////////////////////////////////////////////////////////////
~clock = TempoClock.default;

// Set server scheduling latency if different
if(s.latency != ~desiredLatency) { s.latency = ~desiredLatency; };

///////////////////////////////////////////////////////////////////////////////
// 2) Mirror Tidal's /cps into SC's TempoClock (bpm = cps*120; tempo = bpm/60 = cps*2)
///////////////////////////////////////////////////////////////////////////////
~tidalCpsSync ?? {
    ~tidalCpsSync = OSCdef(
        \tidalCpsSync,
        { |msg, time, addr, recvPort|
            var cps = msg[1].asFloat;
            // tempo in beats-per-second
            ~clock.tempo = cps * 2;
        },
        '/cps',
        nil // accept from any sender (Tidal sends from 127.0.0.1:57120 by default)
    );
    "OSC cps→TempoClock sync installed.".postln;
};

///////////////////////////////////////////////////////////////////////////////
// 3) Ensure existing SuperDirt orbits use the same clock (no stop/start)
///////////////////////////////////////////////////////////////////////////////
if(~dirt.notNil) {
    if(~dirt.orbits.notNil) {
        ~dirt.orbits.do { |o|
            // orbits respond to clock_
            try { o.clock_(~clock) } { |err| err.postln };
        };
    };
} {
    "Warning: ~dirt is nil. Create SuperDirt before running this include.".warn;
};

///////////////////////////////////////////////////////////////////////////////
// 4) Optional beat bus and synced kick (quantized to bar)
///////////////////////////////////////////////////////////////////////////////
if(~enableBeatBus) {
    // one trigger per beat, locked to ~clock tempo
    Ndef(\beat, { Impulse.kr(~clock.tempo) }).quant_(1);
    "Ndef(beat) ready (1 trig per beat).".postln;
};

if(~enableKick) {
    Ndef(\kick).quant = 1;
    Ndef(\kick, {
        var trig = if(~enableBeatBus) { Ndef.kr(\beat) } { Impulse.kr(~clock.tempo) };
        var env  = Decay2.kr(trig, 0.001, 0.12);
        var sweep = EnvGen.kr(Env([1, 0], [0.06], curve: -8), trig);
        var sig   = SinOsc.ar(48 + 120*sweep) * env * 0.9
                  + BPF.ar(WhiteNoise.ar(0.15), 1200, 0.5) * env * 0.25;
        (sig ! 2) * 0.7
    }).play;
    "Ndef(kick) playing (4-on-the-floor).".postln;
};

///////////////////////////////////////////////////////////////////////////////
// 5) Diagnostics
///////////////////////////////////////////////////////////////////////////////
(
"SC/Tidal Sync ready.".postln;
("  s.latency  = " ++ s.latency.asString).postln;
("  clock      = TempoClock.default").postln;
("  cps-bridge = " ++ (~tidalCpsSync.notNil).asString).postln;
("  beat bus   = " ++ (~enableBeatBus).asString).postln;
("  kick ndef  = " ++ (~enableKick).asString).postln;
);
)

