(
s.waitForBoot({
    SynthDef(\click, { |freq=400, amp=0.2|
        var sig = SinOsc.ar(freq, 0.5pi) *
            Env.perc(0.001,0.06).ar(Done.freeSelf, levelScale: amp);
        OffsetOut.ar(0, sig.dup)
    }).add;
});
)

// create a synchronized clock
l = LinkClock(1).latency_(Server.default.latency);

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

// now launch a program using Ableton Link to test synchronization

// patterns automatically apply server latency,
// so this should be in sync
p = Pbind(\type, \composite, \types, [\midi, \note], \midiout, m, \instrument, \click, \freq, Pseq([900, Pn(400,3)], inf)).play(l, quant:-1);

// In Tasks, you should handle latency yourself:
(
r = Task {
    loop {
        s.makeBundle(s.latency, {
            Synth(\click, [freq: exprand(500, 1200)])
        });
        1.wait;
    }
}.play(l, quant: -1);
)

// changing the tempo in another application should affect tempo in SC
// changing the tempo in SC should affect every connected application
l.tempo = 90/60;

// start/stop notifications
// the remote peer should enable start/stop sync
(
q = nil;
c = SimpleController(l)
.put(\linkStart, {
    if(q.isNil) {
        q = Pbind(
            \degree, Pn(Pseries(0, 1, 8), inf),
            \dur, 0.25
        ).play(l, quant: -1);
    }
})
.put(\linkStop, {
    q.stop;
    q = nil;
})
.put(\stop, { c.remove });  // clean up if clock stops
)

p.stop;
r.stop;
l.stop;