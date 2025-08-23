// orbit_outbus_gate_master.scd  — built 2025-08-23 23:26 America/Chicago
(
// Per-orbit dry mute right on each Dirt orbit's *hardware* outBus.
// Adds smooth fades + true mix (0..1). Also includes a tiny Tidal bridge (ctrl_gate).

s.waitForBoot {
  fork {
    var nCh, outIdx, oCount;

    // wait for SuperDirt
    while { ~dirt.isNil } { 0.2.wait };

    // clean up any previous instance/bridge
    ~masterFXOnlySynth.tryPerform(\free);
    ~fxgateOSC !? _.free;

    // capture current mapping
    nCh    = ~dirt.numChannels;
    outIdx = ~dirt.orbits.collect({ |o| o.outBus });   // per-orbit hardware out bus start index
    oCount = outIdx.size;

    // gate values (0 = normal, 1 = FX-only); keep/resize if already set
    ~fxonlyGates = (~fxonlyGates ? Array.fill(oCount, 0.0)).copyRange(0, oCount-1);
    if(~fxonlyGates.size != oCount) { ~fxonlyGates = Array.fill(oCount, 0.0) };

    // default fades (seconds)
    ~fxonlyFadeU = (~fxonlyFadeU ? 0.12);  // time to go up toward 1 (mute-on)
    ~fxonlyFadeD = (~fxonlyFadeD ? 0.12);  // time to go down toward 0 (mute-off)

    // Master: read each orbit's outBus and overwrite it with src * (1 - smoothedGate)
    SynthDef(\dirtOutBusGateMaster, {
      var gates = NamedControl.kr(\gates, Array.fill(oCount, 0));
      var fadeU = NamedControl.kr(\fadeU, 0.12);
      var fadeD = NamedControl.kr(\fadeD, 0.12);
      var g = LagUD.kr(gates, fadeU, fadeD).clip(0, 1);  // smoothed per-orbit gate

      oCount.do { |i|
        var src = In.ar(outIdx[i], nCh);
        ReplaceOut.ar(outIdx[i], src * (1 - g[i]));      // 1=FX-only, 0=normal, between=mix
      };
    }).add;

    s.sync;

    // (re)start at tail so nothing can write after us
    ~masterFXOnlySynth = Synth.tail(nil, \dirtOutBusGateMaster,
      [\gates, ~fxonlyGates, \fadeU, ~fxonlyFadeU, \fadeD, ~fxonlyFadeD]);
    "[dirtOutBusGateMaster] active (tail of RootNode)".postln;

    // ---- Simple SC helpers ----
    ~fxonlySet  = { |i=0, v=0|
      if(i >= 0 and: { i < ~fxonlyGates.size }) {
        ~fxonlyGates[i] = v.clip(0,1);
        ~masterFXOnlySynth.setn(\gates, ~fxonlyGates);
        ("[FX-only] orbit " ++ i ++ " -> " ++ ~fxonlyGates[i]).postln;
      }{
        ("[FX-only] invalid orbit index: " ++ i).warn;
      }
    };
    ~fxonlyOn   = { |i=0| ~fxonlySet.(i, 1) };    // FX-only (dry muted)
    ~fxonlyOff  = { |i=0| ~fxonlySet.(i, 0) };    // normal (dry audible)
    ~fxonlySetFade = { |up=0.12, down=0.12|
      ~fxonlyFadeU = up.max(0); ~fxonlyFadeD = down.max(0);
      ~masterFXOnlySynth.set(\fadeU, ~fxonlyFadeU, \fadeD, ~fxonlyFadeD);
      ("[FX-only] fades: up=" ++ ~fxonlyFadeU ++ "s, down=" ++ ~fxonlyFadeD ++ "s").postln;
    };

    // ---- Refresh if orbit count changes mid-session ----
    ~fxonlyRefresh = {
      fork {
        var nCh2, outIdx2, oCount2;
        while { ~dirt.isNil } { 0.2.wait };
        ~masterFXOnlySynth.tryPerform(\free);

        nCh2    = ~dirt.numChannels;
        outIdx2 = ~dirt.orbits.collect({ |o| o.outBus });
        oCount2 = outIdx2.size;
        ~fxonlyGates = Array.fill(oCount2, 0.0);

        SynthDef(\dirtOutBusGateMaster, {
          var gates = NamedControl.kr(\gates, Array.fill(oCount2, 0));
          var fadeU = NamedControl.kr(\fadeU, ~fxonlyFadeU ? 0.12);
          var fadeD = NamedControl.kr(\fadeD, ~fxonlyFadeD ? 0.12);
          var g = LagUD.kr(gates, fadeU, fadeD).clip(0, 1);
          oCount2.do { |i|
            var src = In.ar(outIdx2[i], nCh2);
            ReplaceOut.ar(outIdx2[i], src * (1 - g[i]));
          };
        }).add;
        s.sync;
        ~masterFXOnlySynth = Synth.tail(nil, \dirtOutBusGateMaster,
          [\gates, ~fxonlyGates, \fadeU, ~fxonlyFadeU, \fadeD, ~fxonlyFadeD]);
        "[dirtOutBusGateMaster] refreshed".postln;
      };
    };

    // ---- Optional: Tidal bridge (use 'oid' instead of 'orbit') ----
    SynthDef(\ctrl_gate, { |oid=0, omute=1, sustain=0.05|
      var trig = Impulse.kr(20) * (Line.kr(1,0,sustain) > 0);
      SendReply.kr(trig, '/fxgate', [oid, omute]);
      Out.ar(0, Silent.ar(~dirt.numChannels));
      EnvGen.kr(Env.linen(0.001, sustain, 0.001), doneAction: 2);
    }).add;
    s.sync; ~dirt.soundLibrary.addSynth(\ctrl_gate);

    ~fxgateOSC = OSCdef(\fxgate, { |msg|
      if(msg[2] == '/fxgate') {
        var i = msg[3].round.asInteger;
        var v = msg[4].asFloat.clip(0,1);
        if(i >= 0 and: { i < ~fxonlyGates.size }) {
          ~fxonlyGates[i] = v;
          ~masterFXOnlySynth.setn(\gates, ~fxonlyGates);
          ("[FX-only] orbit " ++ i ++ " -> " ++ v).postln;
          ~masterFXOnlySynth.tryPerform(\moveToTail);
        };
      };
    }, '/reply', srcID: s.addr);

    // mapping printout
    "~dirt.orbits map: [idx outBus]".postln;
    ~dirt.orbits.collect({ |o| [o.orbitIndex, o.outBus] }).do(_.postln);
  };
};
)

