//At Best Ndef synths only provide xfade for Pdefs - re-evaluation still needs the re-setting of of the Pdef.
//Synth Def may work better. */
Ndef(\s1).play;

// adjusting the Ndef seems to reset and Pdef needs to be reapplied. Possibly along with all slots
(
Ndef(\s1, { | freq=110, freqmod=1, out=0, gate=1, amp=1, noise=4 |
	var e, s, f;
	f = Array.fill(12, { | i | i + freq + 10 });
	e = EnvGen.kr(Env.adsr(releaseTime: gate/2), gate, doneAction: 2);
	s = Pulse.ar(f/2+Pulse.kr(LFNoise0.kr(noise)).range(0, 20) * LFPulse.kr([0.5, 0.01, 2]/freqmod, 0.5).range(1, 10))* e;
	s = Splay.ar(s * e );
	Out.ar(out, s * amp *0.5);
});
)
Ndef(\s1).stop;
Ndef(\s1).fadeTime = 3;

(
Pdef(\s1, {
	Pbind(
		// \instrument, \s1,
		// \octave, Pxrand([3, 5], inf),
		\octave, 6,
		\degree, Prand((0..7), inf),
		\scale, Scale.minor,
		\out, {Ndef(\s1).out.bus},
		\group, {Ndef(\s1).group},
		// \dur, Pseq([0.5, Rest(1), 1, 2], inf),
		\dur, Pwhite(0, 2, inf)/Pbjorklund2(3, 5, inf)/4,
		\amp, Pseq([0.2, 0.3, 0.5], inf),
		\legato, Pxrand([0.2, 1, 0.23], inf),
		\freqmod, Pbrown(0.25, 4, inf),
	)
})
)

Pdef(\s1).play;
Pdef(\s1).stop;
Ndef(\s1).clear;

(
// Can't run two Pdefs... gives server errors - apparently they conflict
Pdef(\s1, {
	Pbind(
		// \instrument, \s1,
		\out, {Ndef(\s1).out.bus},
		\group, {Ndef(\s1).group},
		\octave, 5,
		\freq, Pstutter(2, Pseq([55, 2200],inf), inf),
		// \degree, Scale.minor,
		// \dur, Pseq([1, 2, 4], inf),
		\dur, Pwhite(0, 3, inf),
		\amp, Pseq([0.2, 0.3, 0.5], inf),
		\legato, Pseq([0.2, 1, 0.23], inf),
		\freqmod, Pseq([100, 3, 5, 7], inf),
	)
})
)



Ndef(\freqmod, { LFSaw.kr(100, 0.5, 2).range(0, 1)});


Ndef(\s1).map(\freqmod, Ndef(\freqmod));

Ndef(\s1)[1] = \xset -> Pdef(\s1).quant_(-1);
Ndef(\s1)[1] = \xset -> Pdef(\s2);

Ndef(\noise, { | in | Dust.kr(LFNoise1.kr(exprand(100,500))) });
Ndef(\s1).xset(\noise, Ndef(\noise));

//wrong
Ndef(\s1)[90] = \filter -> {| in | DelayC.ar(in, 5)};

l = LinkClock();






// GUI to watch status
(
var win = Window("LinkClock", Rect(200, 200, 500, 100)).front,
peersBox, tempoBox, barsBox, beatsBox,
font = Font.default.copy.size_(32),
boldFont = font.boldVariant,
controller, task;

win.layout = HLayout(
    StaticText().font_(font).string_("Peers:"),
    peersBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80),
    StaticText().font_(font).string_("Tempo:"),
    tempoBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(120),
    StaticText().font_(font).string_("Now:"),
    barsBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80),
    beatsBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80)
);

[peersBox, barsBox, beatsBox].do { |view| view.enabled_(false) };

tempoBox.action = { |view| l.tempo = view.value / 60 };
tempoBox.value = l.tempo * 60;
peersBox.value = l.numPeers;

task = Routine {
    var bars, beats;
    loop {
        bars = l.bar;
        beats = l.beatInBar;
        {
            barsBox.value = bars;
            beatsBox.value = beats;
        }.defer(l.latency);
        1.0.wait;
    }
}.play(l, quant: 1);

controller = SimpleController(l)
.put(\tempo, {
    defer { tempoBox.value = l.tempo * 60 }
})
.put(\numPeers, {
    defer { peersBox.value = l.numPeers }
})
.put(\stop, { defer { win.close } });

win.onClose = { task.stop; controller.remove };
)