(
// [2025-10-29 11:58 CDT] Ndef → ddwMixerChannel routing helpers (fixed: no `.not`, no touching \out)

// ——— TEMP one-shot: clear older buggy helpers (safe if they don't exist) ———
~ndefAttachToChan = nil;
~ndefDetach = nil;
~ndefAttachMany = nil;
~ndefMap = nil;

// ——— State ———
~ndefMap = IdentityDictionary.new;   // ndefKey -> (mode:\gen|\fx, chan:MixerChannel, synth:Synth?)

// ——— Attach: route an Ndef into a MixerChannel ———
~ndefAttachToChan = { |ndefKey, chan, chans = 2|
	var nkey, rec, useChans, isEmpty, fxSynth;
	nkey = ndefKey.asSymbol;
	useChans = chans;

	// already attached?
	rec = ~ndefMap[nkey];
	rec.isNil.if({
		isEmpty = chan.synth.isNil;

		isEmpty.if({
			// Channel empty: install Ndef tap as the channel generator
			chan.play({
				var sig;
				sig = Ndef(nkey).ar(useChans);
				sig = sig.isArray.if({ sig.flat }, { sig });  // avoid [[a,a],[a,a]] → flat
				sig
			});
			~ndefMap[nkey] = (mode: \gen, chan: chan);
		}, {
			// Channel already has a generator: mix Ndef as an FX layer
			fxSynth = chan.playfx({ |outbus|
				var sig;
				sig = Ndef(nkey).ar(useChans);
				sig = sig.isArray.if({ sig.flat }, { sig });
				Out.ar(outbus, sig);
			});
			~ndefMap[nkey] = (mode: \fx, chan: chan, synth: fxSynth);
		});
	}, {
		("~ndefAttachToChan: \\%" ++ nkey ++ " already attached to " ++ rec[\chan].name).postln;
	});
};

// ——— Detach: remove routing created by ~ndefAttachToChan ———
~ndefDetach = { |ndefKey|
	var nkey, rec, mode, chan, synth;
	nkey = ndefKey.asSymbol;
	rec = ~ndefMap[nkey];
	rec.notNil.if({
		mode = rec[\mode];
		chan = rec[\chan];
		synth = rec[\synth];
		(mode == \fx).if({
			synth.notNil.if({ synth.free });
		}, {
			// If you want to explicitly silence the channel after detaching a \gen tap, uncomment:
			// chan.play({ Silent.ar(chan.numChannels) });
		});
		~ndefMap.removeAt(nkey);
	}, {
		("~ndefDetach: nothing recorded for \\" ++ nkey).postln;
	});
};

// ——— Convenience: many keys to one channel ———
~ndefAttachMany = { |ndefKeys, chan, chans = 2|
	var keys;
	keys = ndefKeys.collect(_.asSymbol);
	keys.do({ |k| ~ndefAttachToChan.(k, chan, chans) });
};

CmdPeriod.doOnce({
    // ~t1.free;
    Ndef.clear;
});

)
