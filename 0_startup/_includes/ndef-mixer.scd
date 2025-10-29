(
// =============================
// Ndef mixer (16×stereo) + 4 returns + multichannel stems + ffmpeg split
// =============================

// config
var numTracks = 16;
var numReturns = 4;

// state dictionary (public handle you can inspect)
~ndefMixer = IdentityDictionary.new;
~ndefMixer[\numTracks]  = numTracks;
~ndefMixer[\numReturns] = numReturns;
~ndefMixer[\trackSyms]  = (1..numTracks).collect { |i| ("t" ++ i).asSymbol };
~ndefMixer[\returnSyms] = (1..numReturns).collect { |i| ("r" ++ i).asSymbol };

~ndefMixer[\diskBufFrames] = 65536;
~ndefMixer[\recDir] = (Platform.userHomeDir +/+ "Music" +/+ "supercollider" +/+ "recordings").standardizePath;
{ File.mkdir(~ndefMixer[\recDir]) }.try;

// groups
~ndefMixer[\grp] = IdentityDictionary.new;
~ndefMixer[\grp][\root] = Group.head(s);
~ndefMixer[\grp][\src ] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\send] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\mix ] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\disk] = Group.after(s.defaultGroup);

// buses
~ndefMixer[\numChans] = numTracks * 2;
~ndefMixer[\stemBus]  = Bus.audio(s, ~ndefMixer[\numChans]);
~ndefMixer[\returnBuses] = Array.fill(numReturns, { Bus.audio(s, 2) });

// synthdefs
SynthDef(\ndef_route2_stereo, { |inbus, outbus|
    var sig = In.ar(inbus, 2);
    OffsetOut.ar(outbus, sig);
}).add;

// fixed-N multichannel disk writer (N = total stem bus channels)
var diskN = ~ndefMixer[\numChans];  // e.g., 32 for 16 stereo tracks
var diskDefName = ("ndef_diskout_" ++ diskN).asSymbol;

SynthDef(diskDefName, { |bufnum, bus|
    var sig = In.ar(bus, diskN);     // literal integer captured at build time
    sig = Limiter.ar(sig, 0.99, 0.01);
    DiskOut.ar(bufnum, sig);
}).add;

~ndefMixer[\diskDefName] = diskDefName;  // remember the name we just built

// returns r1..rN
~ndefMixer[\returnSyms].do { |rsym, ridx|
  var rb = ~ndefMixer[\returnBuses][ridx];

  Ndef(rsym).clear;
  Ndef(rsym).ar(2);
  Ndef(rsym).set(\level, 1.0);

  Ndef(rsym).source = {
    var lvl = \level.kr(1.0).clip(0, 4);
    var inp = In.ar(rb, 2);
    inp * lvl
  };

  // change outbus if your main outs aren't 0/1
  Ndef(rsym).play(outbus: 0, group: ~ndefMixer[\grp].mix);
};

// tracks t1..tN
~ndefMixer[\trackSyms].do { |tsym, tidx|
  var trackBus = Bus.audio(s, 2);
  var stemIndex = tidx * 2;

  Ndef(tsym).clear;
  Ndef(tsym).ar(2);

  // defaults
  Ndef(tsym).set(\level, 1.0, \pan, 0.0, \mute, 0);
  ~ndefMixer[\returnSyms].do { |rs, i|
    Ndef(tsym).set(("sendPre"  ++ (i+1)).asSymbol, 0.0);
    Ndef(tsym).set(("sendPost" ++ (i+1)).asSymbol, 0.0);
  };

  // audio graph
  Ndef(tsym).source = {
    var sig = Silent.ar(2);              // replace via helpers or direct assignment
    var lvl = \level.kr(1.0).clip(0, 4); // NamedControls so .set works
    var pan = \pan.kr(0.0).clip(-1, 1);
    var mut = \mute.kr(0).round(1);

    var dry = Balance2.ar(sig[0], sig[1], pan, 1) * lvl * (1 - mut);

    // sends (pre/post) to return buses
    ~ndefMixer[\returnBuses].do { |rb, i|
      var preAmt  = (("sendPre"  ++ (i+1)).asSymbol).kr(0.0).clip(0, 2);
      var postAmt = (("sendPost" ++ (i+1)).asSymbol).kr(0.0).clip(0, 2);
      var preSig  = preAmt  * sig;
      var postSig = postAmt * dry;
      OffsetOut.ar(rb, preSig + postSig);
    };

    OffsetOut.ar(trackBus, dry);
    dry
  };

  // route fixed slot into stem bus
  Synth(\ndef_route_to_stembus, [
    \inbus, trackBus,
    \outbus, ~ndefMixer[\stemBus].index + stemIndex,
    \numch, 2
  ], ~ndefMixer[\grp].mix);
};

// helpers (plain, no magic)
~ndef_bind     = { |tsym, func| Ndef(tsym).source = func };
~ndef_level    = { |tsym, v|    Ndef(tsym).set(\level, v) };
~ndef_pan      = { |tsym, v|    Ndef(tsym).set(\pan, v) };
~ndef_mute     = { |tsym, on|   Ndef(tsym).set(\mute, on.asInteger) };
~ndef_sendPre  = { |tsym, idx1, amt| Ndef(tsym).set(("sendPre"  ++ idx1).asSymbol, amt) };
~ndef_sendPost = { |tsym, idx1, amt| Ndef(tsym).set(("sendPost" ++ idx1).asSymbol, amt) };

// recorder
~ndefMixer[\recordBuf]  = nil;
~ndefMixer[\diskSynth]  = nil;
~ndefMixer[\recordPath] = nil;
~ndefMixer[\lastNames]  = nil;

~stemsStart = { |name = "take", stemNames|
  var timestamp = Date.localtime.stamp.replace(":", "-");
  var base = name ++ "_" ++ (~ndefMixer[\numChans]).asString ++ "ch_" ++ timestamp;
  var multich = (~ndefMixer[\recDir] +/+ (base ++ ".wav")).standardizePath;

  ~ndefMixer[\lastNames] = stemNames ?? { ~ndefMixer[\trackSyms].collect { |sym| sym.asString } };

  ~ndefMixer[\recordBuf] = Buffer.alloc(s, ~ndefMixer[\diskBufFrames], ~ndefMixer[\numChans]);
  ~ndefMixer[\recordBuf].write(multich, "wav", "int24", leaveOpen: true);
  ~ndefMixer[\recordPath] = multich;

  ~ndefMixer[\diskSynth] = Synth(\ndef_diskout, [
    \bufnum, ~ndefMixer[\recordBuf],
    \bus, ~ndefMixer[\stemBus].index,
    \chans, ~ndefMixer[\numChans]
  ], ~ndefMixer[\grp].disk);

  {
    var sidecar = (~ndefMixer[\recDir] +/+ (base ++ ".stemnames.txt")).standardizePath;
    var lines = ~ndefMixer[\lastNames].collect { |nm, i|
      var lch = (i*2)+1;
      var rch = (i*2)+2;
      nm ++ ": L " ++ lch.asString ++ ", R " ++ rch.asString
    }.join(Char.nl);
    File.use(sidecar, "w", { |f| f.write(lines) });
    ("wrote stem name sidecar: " ++ sidecar).postln;
  }.defer(0.0);

  ("stemDisk start → " ++ multich ++ "  chans " ++ ~ndefMixer[\numChans]).postln;
};

~stemsStopNow = {
  var p = ~ndefMixer[\recordPath];

  if(~ndefMixer[\diskSynth].notNil) { ~ndefMixer[\diskSynth].free; ~ndefMixer[\diskSynth] = nil; };
  if(~ndefMixer[\recordBuf].notNil) {
    ~ndefMixer[\recordBuf].close;
    ~ndefMixer[\recordBuf].free;
    ~ndefMixer[\recordBuf] = nil;
  };
  ("stems finalized: " ++ p).postln;

  if(p.notNil) {
    ("which ffmpeg").unixCmd { |exit|
      if(exit == 0) { { ~stemsSplit.(p, ~ndefMixer[\lastNames]) }.defer(0.0); }
      { "[split skipped] ffmpeg not found on PATH.".warn; };
    };
  };
  ~ndefMixer[\recordPath] = nil;
};

~stemsSplit = { |multichPath, stemNames|
  var inPath = multichPath.standardizePath;
  var dir = PathName(inPath).parentPath;
  var base = PathName(inPath).fileNameWithoutExtension;

  stemNames = stemNames ?? { ~ndefMixer[\trackSyms].collect { |sym| sym.asString } };

  ("[[splitting]] → " ++ stemNames.size.asString ++ " stems").postln;

  stemNames.do { |nm, i|
    var lch = i*2;
    var rch = i*2+1;
    var out = (dir +/+ (base ++ "__" ++ nm ++ ".wav")).standardizePath;

    // quote paths with single quotes (safer than escapeChar)
    var cmd =
      "ffmpeg -y -hide_banner -loglevel error -i " ++ "'" ++ inPath ++ "'" ++
      " -filter_complex " ++ "'pan=stereo|c0=c" ++ lch.asString ++ "|c1=c" ++ rch.asString ++ "'" ++
      " -c:a pcm_s24le " ++ "'" ++ out ++ "'";

    cmd.unixCmd { |exit|
      if(exit == 0) { ("wrote stem: " ++ out).postln; }
      { ("ffmpeg error (" ++ exit.asString ++ ") while writing " ++ out).warn; };
    };
  };
};

// ready banner
"[[NdefMixer]] ready: ".post;
(numTracks.asString ++ " tracks, " ++ numReturns.asString
  ++ " returns, stemBus " ++ ~ndefMixer[\numChans].asString ++ "ch").postln;
)

