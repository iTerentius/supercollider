// m36_meters_min.scd  updated 2025-09-21  America/Chicago
(
// ---------- meter taps  mono and stereo ----------
SynthDef(\m36_meterTap1, { |inbus=0, id=0, rate=20|
    var sig, mono, peak, rms, trig;  // vars at top
    sig  = In.ar(inbus, 1);
    mono = sig;
    peak = Amplitude.kr(mono, 0.001, 0.999);
    rms  = Amplitude.kr(mono, 0.02,  0.20);
    trig = Impulse.kr(rate.max(2));
    SendReply.kr(trig, '/m36/mtr', [id, peak.clip(0,1), rms.clip(0,1)]);
}).add;

SynthDef(\m36_meterTap2, { |inbus=0, id=0, rate=20|
    var sig, mono, peak, rms, trig;  // vars at top
    sig  = In.ar(inbus, 2);
    mono = (sig[0] + sig[1]) * 0.5;
    peak = Amplitude.kr(mono, 0.001, 0.999);
    rms  = Amplitude.kr(mono, 0.02,  0.20);
    trig = Impulse.kr(rate.max(2));
    SendReply.kr(trig, '/m36/mtr', [id, peak.clip(0,1), rms.clip(0,1)]);
}).add;

// ---------- tiny state ----------
~m36Meters = ( win: nil, inds: nil, taps: nil, oscName: \m36MetersOSC, rate: 20 );

// ---------- set sources helper ----------
~m36_setMeterSources = {
    var trk, mst, rets;  // vars at top
    trk = ~m36_tracks ? [];
    mst = ~m36_master ? [];
    rets = ~m36_returns ? (~m36_fxchans ? (~m36_returnChans ? []));
    ~m36_meterSources = trk ++ (mst.isArray.if({ mst }, { [mst] })) ++ rets;
    ("[m36 meters] sources set  " ++ ~m36_meterSources.size ++ " channels").postln;
    ~m36_meterSources.do { |ch, i|
        var nm, bi, nc;  // vars at top
        nm = ch.tryPerform(\key) ?? { ch.tryPerform(\name) ?? { "ch" ++ i } };
        bi = ch.inbus.index;
        nc = ch.inbus.numChannels ? 2;
        ("  " ++ i ++ "  " ++ nm ++ "  inbus " ++ bi ++ "  chans " ++ nc).postln;
    };
    ~m36_meterSources
};

// ---------- open meters for ~m36_meterSources ----------
// 2025-09-22 robust open with verbose logs and a basic fallback

// basic sanity window  no taps  helps confirm GUI works
~m36_openMeters_basic = {
    var st, chans, count, w, colW, colH;  // vars at top
    st = ~m36Meters;
    chans = ~m36_meterSources ? [];
    count = chans.size;
    colW = 72; colH = 150;

    ~m36_closeMeters.();
    ("[m36 meters] basic opening  count " ++ count).postln;

    if(count == 0) {
        "m36 meters  no sources  run ~m36_setMeterSources.() first".warn;
        ^nil
    };

    AppClock.sched(0, {
        var content, i, ch, name, col;  // vars at top
        st.inds = Array.newClear(count);
        st.taps = Array.newClear(count);

        w = Window("m36 meters  basic  2025-09-22",
            Rect(180, 160, (count * colW) + 28, colH + 80)).front;
        w.view.layout_(VLayout(4));
        StaticText(w.view).string_("m36 basic  no taps").align_(\left);
        content = CompositeView(w.view, Rect(0, 0, (count * colW) + 8, colH)).layout_(HLayout(4));

        count.do { |ii|
            var label;  // vars at top
            i = ii; ch = chans[i];
            name = ch.tryPerform(\key) ?? { ch.tryPerform(\name) ?? { "ch" ++ i } };
            col = CompositeView(content, Rect(0, 0, colW, colH)).layout_(VLayout(2));
            label = StaticText(col).string_(name).align_(\center);
            st.inds[i] = LevelIndicator(col)
                .warning_(0.8).critical_(0.95).drawsPeak_(true).numTicks_(6);
        };

        w.onClose_({ ~m36_closeMeters.() });
        st.win = w;
        "[m36 meters] basic open ok".postln;
        nil
    });

    ^nil
};

// full meters with taps and verbose logging
~m36_openMeters = {
    var st, chans, count, rate, colW, colH;  // vars at top

    ~m36_closeMeters.();  // this prints once

    st   = ~m36Meters;
    rate = st.rate ? 20;

    if(~m36_meterSources.isNil or: { ~m36_meterSources.size == 0 }) {
        "[m36 meters] no sources  running ~m36_setMeterSources".postln;
        ~m36_setMeterSources.();
    };

    chans = ~m36_meterSources ? [];
    count = chans.size;
    colW = 72; colH = 150;

    ("[m36 meters] opening  count " ++ count).postln;
    if(count == 0) {
        "m36 meters  no sources  run ~m36_setMeterSources.() first".warn;
        ^nil
    };

    AppClock.sched(0, {
        var w, content;  // vars at top
        {
            var i, ch, name, col, li, inbusIndex, chansN, defName;  // vars at top

            st.inds = Array.newClear(count);
            st.taps = Array.newClear(count);

            w = Window("m36 meters  peak top bar  rms fill  2025-09-22",
                Rect(180, 160, (count * colW) + 28, colH + 80)).front;
            w.view.layout_(VLayout(4));
            StaticText(w.view).string_("m36 tracks  master  returns").align_(\left);

            // osc receiver early, to not drop first replies
            st.oscName = (\m36MetersOSC_ ++ thisProcess.identityHash).asSymbol;
            OSCdef(st.oscName, { |msg|
                var id, peak, rms;  // vars at top
                id   = msg[3].asInteger;
                peak = msg[4].clip(0, 1);
                rms  = msg[5].clip(0, 1);
                {
                    var li2;  // vars at top
                    li2 = st.inds.tryAt(id);
                    if(li2.notNil) { li2.value_(rms); li2.peakLevel_(peak) };
                }.defer;
            }, '/m36/mtr');

            content = CompositeView(w.view, Rect(0, 0, (count * colW) + 8, colH));
            content.layout_(HLayout(4));

            count.do { |ii|
                i = ii; ch = chans[i];
                name = ch.tryPerform(\key) ?? { ch.tryPerform(\name) ?? { "ch" ++ i } };

                col = CompositeView(content, Rect(0, 0, colW, colH)).layout_(VLayout(2));
                StaticText(col).string_(name).align_(\center);
                li = LevelIndicator(col)
                    .warning_(0.8)
                    .critical_(0.95)
                    .drawsPeak_(true)
                    .numTicks_(6)
                    .value_(0.0)
                    .peakLevel_(0.0);
                st.inds[i] = li;

                inbusIndex = ch.inbus.index;
                chansN = ch.inbus.numChannels ? 2;
                defName = (chansN == 1).if({ \m36_meterTap1 }, { \m36_meterTap2 });

                st.taps[i] = Synth(defName, [\inbus, inbusIndex, \id, i, \rate, rate],
                    target: ch.synthgroup, addAction: \addAfter);

                ("[m36 meters] tap " ++ i ++ " bus " ++ inbusIndex
                    ++ " chans " ++ chansN ++ " def " ++ defName).postln;
            };

            w.onClose_({ ~m36_closeMeters.() });
            st.win = w;
            ("[m36 meters] open ok  tracks " ++ count).postln;
        }.protect { |err|
            "[m36 meters] exception while opening".postln;
            err.reportError;
        };
        nil
    });

    ^nil
};

// ---------- close ----------
~m36_closeMeters = {
    var st;  // vars at top
    st = ~m36Meters;
    if(st.taps.notNil) { st.taps.do { |syn| syn.tryPerform(\free) } };
    if(st.oscName.notNil) { OSCdef.free(st.oscName) };
    if(st.win.notNil) { st.win.close };
    st.win = nil; st.inds = nil; st.taps = nil;
    "m36 meters closed".postln;
    ^nil
};
)

