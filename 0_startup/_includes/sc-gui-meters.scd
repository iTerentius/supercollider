/* 2025-10-04 MixingBoard per-strip meters include
   Adds a meters bar aligned to MixingBoard strips
   Use ~mbMeters.attach.(board, channels, \post) then ~mbMeters.kill. */

(
~mbMeters = (~mbMeters.isNil).if({ IdentityDictionary.new }, { ~mbMeters });

// create the tap SynthDef once
~mbMeters.ensureSynthDef = {
    var have;
    have = SynthDescLib.global.at(\mbTap).notNil;
    if(have.not) {
        SynthDef(\mbTap, { |tapBus=0, chans=2, rate=30, id=0|
            var sig, trig, peakL, peakR;
            sig   = In.ar(tapBus, chans);
            peakL = Amplitude.kr(sig[0], 0.01, 0.06).clip(0, 1);
            peakR = Select.kr(chans > 1, [
                peakL,
                Amplitude.kr(sig[1], 0.01, 0.06).clip(0, 1)
            ]);
            trig  = Impulse.kr(rate);
            SendReply.kr(trig, "/mb_meter", [id, peakL, peakR]);
            Silent.ar(0)
        }).add;
    };
};

// attach meters to an existing MixingBoard window
~mbMeters.attach = { |board, channels, where=\post|
    var win, num, ids, taps, bar, meters, pad, colW, inner, osc, placeMeters;

    ~mbMeters.ensureSynthDef.value;

    (~mbMeters.at(\kill).notNil).if({ ~mbMeters[\kill].value });

    win    = board.window;
    num    = channels.size;
    ids    = Array.series(num, 5000, 1);
    taps   = Array.newClear(num);
    meters = Array.newClear(num);
    pad    = 8;

    inner = win.view.bounds;
    bar   = CompositeView(win.view, Rect(inner.left + pad, inner.top + pad, inner.width - pad*2, 24));
    bar.background_(Color.gray(0.92));

    colW = (bar.bounds.width / num);

    num.do { |i|
        var x, w, lpk, rpk, lbl;
        x   = i * colW;
        w   = colW - 6;
        lbl = StaticText(bar, Rect(x + 2, 2, w, 10)).string_(channels[i].name.asString);
        lpk = LevelIndicator(bar, Rect(x + 2, 12, (w - 4) * 0.48, 10)).warning_(0.7).critical_(0.9);
        rpk = LevelIndicator(bar, Rect(x + 2 + (w - 4) * 0.52, 12, (w - 4) * 0.48, 10)).warning_(0.7).critical_(0.9);
        meters[i] = [lpk, rpk];
    };

    osc = OSCdef(\mbMeters, { |msg|
        var id, l, r, idx;
        id  = msg[3].asInteger;
        l   = msg[4].clip(0, 1);
        r   = msg[5].clip(0, 1);
        idx = ids.indexOf(id);
        if(idx.notNil) {
            {
                meters[idx][0].value = l;
                meters[idx][1].value = r;
            }.defer;
        };
    }, "/mb_meter");

    num.do { |i|
        var ch, tapBus, chans, grp;
        ch     = channels[i];
        chans  = ch.outChannels ? 2;
        tapBus = (where == \pre).if({ ch.inbus.index }, { ch.bus.index });
        grp    = (where == \pre).if({ ch.sourceGroup }, { ch.postGroup ? ch.sourceGroup });
        taps[i] = Synth.tail(grp, \mbTap, [
            \tapBus, tapBus,
            \chans,  chans,
            \rate,   30,
            \id,     ids[i]
        ]);
    };

    placeMeters = {
        {
            var b;
            b = win.view.bounds;
            bar.bounds = Rect(b.left + pad, b.top + pad, b.width - pad*2, 24);
        }.defer;
    };
    win.onResize = placeMeters;

    ~mbMeters.kill = {
        taps.do { |sy| sy.notNil.if({ sy.free }) };
        OSCdef(\mbMeters).free;
        if(bar.notNil) { { bar.remove }.defer };
        ~mbMeters.removeAt(\kill);
    };

    ("MixingBoard meters attached " ++ where.asString).postln;
};
)

