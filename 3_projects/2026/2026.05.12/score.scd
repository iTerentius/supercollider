// score.scd — evaluate to load project
// Load order: samples → s.sync → config → fx → slots → parts → bindings
(
var dir = thisProcess.nowExecutingPath.dirname;
var safeLoad = { |path|
    try {
        (dir +/+ path).load;
    } { |err|
        ("Score: FAILED " ++ path).postln;
        err.errorString.postln;
    };
};
{
    // safeLoad.("samples.scd");
    // s.sync;  // wait for Buffer.read /done callbacks
    // safeLoad.("lib/config.scd");
    safeLoad.("fx.scd");
    safeLoad.("synths.scd");

    // safeLoad.("lib/slots.scd");       // define ~slots before parts + bindings
    // --- automation Pdefs (FX control, tempo, etc.) ---
    // safeLoad.("automation/ilfx/v1_crush.scd");
    // --- parts (one per voice, in any order) ---
    safeLoad.("patterns/all_pats.scd");
    safeLoad.("parts/v1_kit.scd");
    safeLoad.("parts/all.scd");
    safeLoad.("parts/all2.scd");
    safeLoad.("parts/v1.scd");
    safeLoad.("parts/v2.scd");
    safeLoad.("parts/v3.scd");
    safeLoad.("automation/biscuit.scd");
    safeLoad.("automation/spectral.scd");
    // safeLoad.("automation/ilfx/v1_crush.scd");
    safeLoad.("automation/ilfx/bass_crush.scd");
    // --- bindings last (reads ~slots + ~autoSlots + ~phrFns populated by parts) ---
    safeLoad.("bindings.scd");
    safeLoad.("tosc_biscuit.scd");
    // safeLoad.("conductor.scd");
    // --- optional: stem recording (loads ~stemDiskStart, ~stemMidiWrite) ---
    // "_includes/mixer-channel-stem-record.scd".loadRelative;
    "Score loaded.".postln;
}.fork(AppClock);
)
  ~deluge = MIDIOut.newByName("Deluge", "OUT");
  ~deluge.latency = 0;
  ~deluge.noteOn(0, 60, 100);  // channel 0 = ch 1
  ~deluge.noteOff(0, 60, 0);
  (
  ~deluge = MIDIOut.newByName("Deluge", "OUT");

  MIDIdef.cc(\lcxlToDeluge, { |val, num, chan|
      ~delugeOut.control(chan, num, val);
  }, ccNum: nil, chan: nil);  // nil = catch all CCs on all channels
  )
(
  Pdef(\del,  Pbind(
    \type,   \midi, 
    \midiout,  ~deluge, 
    \chan,  1, 
    \amp, 1,  
    \octave,  5,  
    \degree,  Pseq(
      [0,  0,  0,  1,  \,  \], inf), 
    \dur, 1/2,  
    // \stretch, Pseg([1,  1/2,  2], [2, 4], \lin, inf),  
    // \stretch,  Pseq([1, 1/4!3,  1.25].flat, inf), 
  ));
)
Pdef(\del).play;
Pdef(\del).stop;

MIDIClient.init;
~out = MIDIOut.newByName("IAC Driver", "Bus 2");

Tdef(\cc, )
~out.control(chan: 0, ctlNum: 74, val: 22); 
(
Tdef(\ccLearn, {
    loop {
        ~out.control(chan: 0, ctlNum: 74, val: 64);
        0.2.wait; // sends every 200ms - adjust if needed
    }
}).play;
)
// Stop it once Maschine has learned
Tdef(\ccLearn).stop;
