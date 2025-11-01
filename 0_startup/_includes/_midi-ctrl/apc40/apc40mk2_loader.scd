"apc_boot_all.scd".loadRelative;  // NEW grid inclu
"apc_device_knobs.scd".loadRelative;  // NEW grid inclu

// // map a couple pads to patterns
// Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
// Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.125, \amp, 0.12, \out, ~t2.inbus.index));
// ~apcAssignPad.(32, \kick2);
// ~apcAssignPad.(33, \hat2);
//
// // bind faders
// ~apcBindParam.(\b0_s1_f, { |x| ~t1.level_(x) });
// ~apcBindParam.(\b0_s2_f, { |x| ~t2.level_(x) });
// ~apcBindParam.(\master_f, { |x| ~m1.level_(x) });
// /* 2025-10-19 — examples */
// /* volume faders already use \bN_sM_f and \master_f from earlier */
//
// ~apcBindParam.(\b0_s1_r1, { |x| ~t1.pan_(x.linlin(0,1,-1,1)) });     // Pan row: strip 1 pan
// ~apcBindParam.(\b1_s1_r2, { |x| ("b1_s1_r2:" ++ x).postln});                  // Sends row: send A
// ~apcBindParam.(\b0_s1_r3, { |x| ("b0_s1_r3:" ++ x).postln});            // User row: your custom
//
// ~apcBindParam.(\b0_d1, { |x| ("b0_d1:" ++ x).postln});            // User row: your custom
// ~apcBindParam.(\b1_d2, { |x| ("b1_d2:" ++ x).postln});            // User row: your custom
// Pdef stays the same
//
//
//
//
// Pdef as before
Pdef(\kick2, Pbind(\dur, 0.25, \degree, 0, \amp, 0.15));
~apcAssignPad.(32, \kick2, "p");

// Ndef using stop/play toggle
Ndef(\droneA, { LFTri.ar(70).dup * 0.08 });
Ndef(\droneA).fadeTime = 0.01;
// prime the output bus once if you route through a mixer, e.g.
// Ndef(\droneA).play(out: ~m1.inbus); Ndef(\droneA).stop;

~apcAssignPad.(24, \droneA, "n");  // press 24 to start, press again to stop
// set a global default so all Ndefs go to your mixer by default
~apcNdefDefaultOut = ~m1.inbus;

// or per-ndef, optional
~apcSetNdefOut.(\droneA, ~m1.inbus);
// If you route through a mixer, prime once so future .play() uses the same bus
 Ndef(\droneA).play(out: ~m1.inbus); Ndef(\droneA).stop;
// make sure the Ndef exists
Ndef(\droneA, { LFTri.ar(70).dup * 0.08 });
Ndef(\droneA).fadeTime = 0.01;

// bind pad as Ndef
~apcAssignPad.(24, \droneA, "n");
Ndef(\droneA)
(
/* 2025-11-01 10:58 — APC Ndef pad fix: binder + assign w/ kind + LED refresh
   one-shot patch; safe to eval. Add these permanently to apc_boot_all.scd. */

/* ensure dict exists */
~apcNdefPadBinds = ~apcNdefPadBinds ?? IdentityDictionary.new;

/* LED helper compatible with your file */
~apcPadLEDCompat = ~apcPadLEDCompat ?? { |note, isOn=true, onColor=\green, offColor=\off|
	var want, did, outChan, vel;
	want = isOn.if(onColor, offColor);
	outChan = ~apcCfg!?\gridChan ? 0;
	did = false;
	if(~apcPadLED.notNil) { ~apcPadLED.(note, want, outChan); did = true }{
		if(~apcSetGridLED.notNil) { ~apcSetGridLED.(note, isOn.if(\on, \off)); did = true };
	};
	if(did.not and: { ~apcColors.notNil }) {
		vel = ~apcColors[want] ? 0;
		(~apcOut ? MIDIOut.default).noteOn(outChan, note, vel);
	};
};

/* binder for Ndef pads (note -> {key,onColor,offColor}) */
~apcBindNdefPad = { |note, key, onColor=\green, offColor=\amber|
	var k = key.asSymbol, playing;
	~apcNdefPadBinds[note.asInteger] = (key: k, onColor: onColor, offColor: offColor);
	playing = try { Ndef(k).isPlaying } { false };
	~apcPadLEDCompat.(note.asInteger, playing, onColor, offColor);
	("[APC ndef bound] note: " ++ note ++ "  ->  " ++ k).postln;
	note.asInteger
};

/* repaint all Ndef pad LEDs (call on recompile or panic) */
~apcRefreshNdefPadLEDs = {
	~apcNdefPadBinds.keysValuesDo { |n, meta|
		var k = meta[\key], onC = meta[\onColor], offC = meta[\offColor], on;
		on = try { Ndef(k).isPlaying } { false };
		~apcPadLEDCompat.(n, on, onC, offC);
	};
	"apc_ndef_pads repainted".postln;
};

/* REPLACE your existing 2-arg ~apcAssignPad with this 3-arg version.
   It keeps Pdef behavior, and for kind 'n' also writes ~apcNdefPadBinds. */
~apcAssignPad = { |note, key, kind=\p|
	var colors, ksym, kindSym, n;
	colors  = ~apcColors;
	ksym    = key.asSymbol;
	kindSym = case
	{ kind == "n" } { \n }
	{ kind == "p" } { \p }
	{ kind == \n  } { \n }
	{ kind == \p  } { \p }
	{ true }        { \p };
	n = note.asInteger;

	// always remember the logical key mapping for Pdef side features
	~apcPadMap[n] = ksym;

	if(kindSym == \n) {
		// also register in the Ndef map so your grid listener hits the Ndef branch
		~apcNdefPadBinds[n] = (key: ksym, onColor: \green, offColor: \amber);

		// LED reflects current Ndef state
		~apcPadLEDCompat.(n, try { Ndef(ksym).isPlaying } { false }, \green, \amber);
	} {
		// Pdef: keep your previous amber-on-assign then row/stop painters refresh state
		~apcLEDSet !? { ~apcLEDSet.(n, colors[\amber]) };
	};

	["map[" ++ n ++ "], " ++ ksym ++ " kind " ++ kindSym].postln;
	n
};
)
