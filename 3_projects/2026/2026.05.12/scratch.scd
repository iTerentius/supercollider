// scratch.scd — experimental workspace, not loaded by score.scd

// Quick inline FX deploy/swap:
// ~ilfx[\v1_crush] = ~fxLib[\bitcrush].(~t1);
// ~ilfx[\v1_crush].set(\bits, 6, \rate, 8000);
// ~ilfx[\v1_crush].free; ~ilfx[\v1_crush] = nil;

// Check what's running:
// Pdef.all;
// ~ilfx;
// ~fxSendStop;

// Manual send (bypass LP/APC toggle):
// ~ensurePostSend.(~t1, ~r1, 0.3);
//
~song[1].stop;

~toggle.(\bassline);
~toggle.(\arp);

Pdef(\bassline).stop;

~link.tempo = 90/60;

~link.tempo * 60;
~startDelugeClock.()

MIDIdef(\clockTest, { "tick".postln }, msgType: \midiClock);
MIDIClient.sources.do { |ep, i| [i, ep.device, ep.name].postln };
MIDIdef(\delugeAny, { |a, b, c, d| [a, b, c, d].postln }, msgType: \noteOn);
(
  var times = Array.new(24);
  var last;

  MIDIdef.midiClock(\delugeSync, {
      var now = Main.elapsedTime;
      if(last.notNil) {
          var dt = now - last;
          if(dt > 0.008 and: { dt < 0.125 }) {
              times = times.add(dt).keep(-24);
              if(times.size >= 8) {
                  ~link.tempo = 1.0 / (times.mean * 24);
              };
          };
      };
      last = now;
  });
  )
  (
   MIDIdef.cc(\lcxlDebug, { |val, num, chan|
      [chan, num, val].postln;
  }, srcID: ~lcxlSrcUid);
)
~lcxlSrcUid.postln;   // nil means LCXL wasn't detected
  ~delugeCtrl.postln;   // nil means Deluge wasn't found

  If both are set, try sending a single CC manually:

  ~delugeCtrl.control(0, 13, 127);  // ch 1, CC 13, mid value

