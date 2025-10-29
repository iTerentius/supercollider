(
// =============================
// Ndef mixer: 16×stereo tracks + 4 returns + multichannel stems + ffmpeg split
// =============================

// ---------- config ----------
var numTracks, numReturns, diskN, diskDefName;
numTracks  = 16;
numReturns = 4;

// ---------- state ----------
~ndefMixer = IdentityDictionary.new;
~ndefMixer[\numTracks]  = numTracks;
~ndefMixer[\numReturns] = numReturns;
~ndefMixer[\trackSyms]  = (1..numTracks).collect { |i| ("t" ++ i).asSymbol };
~ndefMixer[\returnSyms] = (1..numReturns).collect { |i| ("r" ++ i).asSymbol };
~ndefMixer[\diskBufFrames] = 65536;
~ndefMixer[\recDir] = (Platform.userHomeDir +/+ "Music" +/+ "supercollider" +/+ "recordings").standardizePath;
{ File.mkdir(~ndefMixer[\recDir]) }.try;

// ---------- groups (explicit, no Event literal) ----------
~ndefMixer[\grp] = IdentityDictionary.new;
~ndefMixer[\grp][\root] = Group.head(s);
~ndefMixer[\grp][\src ] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\send] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\mix ] = Group.after(s.defaultGroup);
~ndefMixer[\grp][\disk] = Group.after(s.defaultGroup);

// ---------- buses ----------
~ndefMixer[\numChans] = numTracks * 2; // stem bus = 2 ch per track
~ndefMixer[\stemBus]  = Bus.audio(s, ~ndefMixer[\numChans]);
~ndefMixer[\returnBuses] = Array.fill(numReturns, { Bus.audio(s, 2) });

// ---------- SynthDefs (fixed channel counts) ----------
SynthDef(\ndef_route2_stereo, { |inbus, outbus|
	var sig;
	sig = In.ar(inbus, 2);
	OffsetOut.ar(outbus, sig);
}).add;

diskN = ~ndefMixer[\numChans];
diskDefName = ("ndef_diskout_" ++ diskN).asSymbol;

SynthDef(diskDefName, { |bufnum, bus|
	var sig;
	sig = In.ar(bus, diskN);  // baked channel count
	sig = Limiter.ar(sig, 0.99, 0.01);
	DiskOut.ar(bufnum, sig);
}).add;

~ndefMixer[\diskDefName] = diskDefName;

// ---------- Returns (r1..rN) ----------
~ndefMixer[\returnSyms].do { |rsym, ridx|
	var rb;
	rb = ~ndefMixer[\returnBuses][ridx];

	Ndef(rsym).clear;
	Ndef(rsym).ar(2);
	Ndef(rsym).set(\level, 1.0);

Ndef(rsym).source = {
    var lvl, inp;
    lvl = \level.kr(1.0).clip(0, 4);  // ← named control, not Ndef.kr
    inp = In.ar(rb, 2);
    inp * lvl
};

	// change outbus if your main is not 0/1
  Ndef(rsym).play(group: ~ndefMixer[\grp][\mix]);  // defaults to main out 0/1
};

// ---------- Tracks (t1..tN) ----------
~ndefMixer[\trackSyms].do { |tsym, tidx|
	var trackBus, stemIndex;
	trackBus  = Bus.audio(s, 2);
	stemIndex = tidx * 2;

	Ndef(tsym).clear;
	Ndef(tsym).ar(2);

	// defaults
	Ndef(tsym).set(\level, 1.0, \pan, 0.0, \mute, 0);
	~ndefMixer[\returnSyms].do { |rs, i|
		Ndef(tsym).set(("sendPre"  ++ (i+1)).asSymbol, 0.0);
		Ndef(tsym).set(("sendPost" ++ (i+1)).asSymbol, 0.0);
	};

  Ndef(tsym).source = {
      var sig, lvl, pan, mut, dry;
      sig = Silent.ar(2);

      // named controls
      lvl = \level.kr(1.0).clip(0, 4);
      pan = \pan.kr(0.0).clip(-1, 1);
      mut = \mute.kr(0).round(1);

      dry = Balance2.ar(sig[0], sig[1], pan, 1) * lvl * (1 - mut);

      // dynamic send controls via NamedControl.kr
      ~ndefMixer[\returnBuses].do { |rb, i|
          var preName, postName, preAmt, postAmt, preSig, postSig;
          preName  = ("sendPre"  ++ (i+1)).asSymbol;
          postName = ("sendPost" ++ (i+1)).asSymbol;

          preAmt  = NamedControl.kr(preName,  0.0).clip(0, 2);
          postAmt = NamedControl.kr(postName, 0.0).clip(0, 2);

          preSig  = preAmt  * sig;
          postSig = postAmt * dry;

          OffsetOut.ar(rb, preSig + postSig);
      };

      OffsetOut.ar(trackBus, dry);
      dry
  };

	// route trackBus → fixed 2ch slot in stem bus
	Synth(\ndef_route2_stereo, [
		\inbus, trackBus,
		\outbus, ~ndefMixer[\stemBus].index + stemIndex
	], ~ndefMixer[\grp][\mix]);
};

// ---------- Helpers ----------
~ndef_bind     = { |tsym, func| Ndef(tsym).source = func };
~ndef_level    = { |tsym, v|    Ndef(tsym).set(\level, v) };
~ndef_pan      = { |tsym, v|    Ndef(tsym).set(\pan, v) };
~ndef_mute     = { |tsym, on|   Ndef(tsym).set(\mute, on.asInteger) };
~ndef_sendPre  = { |tsym, idx1, amt| Ndef(tsym).set(("sendPre"  ++ idx1).asSymbol, amt) };
~ndef_sendPost = { |tsym, idx1, amt| Ndef(tsym).set(("sendPost" ++ idx1).asSymbol, amt) };

// ---------- Recorder (multichannel + optional ffmpeg split) ----------
~ndefMixer[\recordBuf]  = nil;
~ndefMixer[\diskSynth]  = nil;
~ndefMixer[\recordPath] = nil;
~ndefMixer[\lastNames]  = nil;

~stemsStart = { |name = "take", stemNames|
	var timestamp, base, multich, sidecar, lines;
	timestamp = Date.localtime.stamp.replace(":", "-");
	base = name ++ "_" ++ (~ndefMixer[\numChans]).asString ++ "ch_" ++ timestamp;
	multich = (~ndefMixer[\recDir] +/+ (base ++ ".wav")).standardizePath;

	~ndefMixer[\lastNames] = stemNames ?? { ~ndefMixer[\trackSyms].collect { |sym| sym.asString } };

	~ndefMixer[\recordBuf] = Buffer.alloc(s, ~ndefMixer[\diskBufFrames], ~ndefMixer[\numChans]);
	~ndefMixer[\recordBuf].write(multich, "wav", "int24", leaveOpen: true);
	~ndefMixer[\recordPath] = multich;

	~ndefMixer[\diskSynth] = Synth(~ndefMixer[\diskDefName], [
		\bufnum, ~ndefMixer[\recordBuf],
		\bus, ~ndefMixer[\stemBus].index
	], ~ndefMixer[\grp][\disk]);

	{
		sidecar = (~ndefMixer[\recDir] +/+ (base ++ ".stemnames.txt")).standardizePath;
		lines = ~ndefMixer[\lastNames].collect { |nm, i|
			var lch, rch;
			lch = (i*2)+1;  rch = (i*2)+2;
			nm ++ ": L " ++ lch.asString ++ ", R " ++ rch.asString
		}.join(Char.nl);
		File.use(sidecar, "w", { |f| f.write(lines) });
		("wrote stem name sidecar: " ++ sidecar).postln;
	}.defer(0.0);

	("stemDisk start → " ++ multich ++ "  chans " ++ ~ndefMixer[\numChans]).postln;
};

~stemsStopNow = {
	var p;
	p = ~ndefMixer[\recordPath];

	if(~ndefMixer[\diskSynth].notNil) { ~ndefMixer[\diskSynth].free; ~ndefMixer[\diskSynth] = nil; };
	if(~ndefMixer[\recordBuf].notNil) {
		~ndefMixer[\recordBuf].close;
		~ndefMixer[\recordBuf].free;
		~ndefMixer[\recordBuf] = nil;
	};
	("stems finalized: " ++ p).postln;

	if(p.notNil) {
		("which ffmpeg").unixCmd { |exit|
			if(exit == 0) {
				{ ~stemsSplit.(p, ~ndefMixer[\lastNames]) }.defer(0.0);
			} {
				"[split skipped] ffmpeg not found on PATH.".warn;
			};
		};
	};
	~ndefMixer[\recordPath] = nil;
};

~stemsSplit = { |multichPath, stemNames|
	var inPath, dir, base;
	inPath = multichPath.standardizePath;
	dir = PathName(inPath).parentPath;
	base = PathName(inPath).fileNameWithoutExtension;
	stemNames = stemNames ?? { ~ndefMixer[\trackSyms].collect { |sym| sym.asString } };

	("[[splitting]] → " ++ stemNames.size.asString ++ " stems").postln;

	stemNames.do { |nm, i|
		var lch, rch, out, cmd;
		lch = i*2;  rch = i*2 + 1;
		out = (dir +/+ (base ++ "__" ++ nm ++ ".wav")).standardizePath;

		cmd =
			"ffmpeg -y -hide_banner -loglevel error -i " ++ "'" ++ inPath ++ "'" ++
			" -filter_complex " ++ "'pan=stereo|c0=c" ++ lch.asString ++ "|c1=c" ++ rch.asString ++ "'" ++
			" -c:a pcm_s24le " ++ "'" ++ out ++ "'";

		cmd.unixCmd { |exit|
			if(exit == 0) { ("wrote stem: " ++ out).postln; }
			{ ("ffmpeg error (" ++ exit.asString ++ ") while writing " ++ out).warn; };
		};
	};
};

// ---------- ready banner ----------
"[[NdefMixer]] ready: ".post;
(numTracks.asString ++ " tracks, " ++ numReturns.asString
  ++ " returns, stemBus " ++ ~ndefMixer[\numChans].asString ++ "ch").postln;
)

