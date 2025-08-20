(
// ======================================================================
// 16‑channel “record everything” — bar‑aligned, explicit bus capture
// ======================================================================

s.notify(true);

// ---------- settings ----------
~recConfig = (
    chans: 16,
    header: 'wav',
    sampleFmt: 'int24',
    basePath: Platform.userHomeDir +/+ "Music/recordings"
);
File.mkdir(~recConfig[\basePath]);  // ensure folder exists

// ---------- clock resolver (works across Dirt variants) ----------
~recClock = {
    var clk = nil;
    if(~dirt.notNil) {
        try { clk = ~dirt.tempoClock } { };
        if(clk.isNil) { try { clk = ~dirt.clock } { } };
        if(clk.isNil and: { ~dirt.orbits.notNil and: { ~dirt.orbits.size > 0 } }) {
            try { clk = ~dirt.orbits[0].clock } { };
        };
    };
    if(clk.isKindOf(TempoClock).not) { clk = TempoClock.default };
    clk
};

// ---------- path helper ----------
~recNewFilePath = {
    var stamp = Date.getDate.stamp.replace($:, $_);
    ~recConfig[\basePath] +/+ ("sc_rec_" ++ stamp ++ ".wav")
};

// ---------- bar‑aligned record controls (explicit bus/width) ----------
~recStartOnBar = { |barsAhead=1, prepLead=0.05, chans, header, sampleFmt|
    var clk = ~recClock.();
    var tBar = clk.nextTimeOnGrid(barsAhead);
    var path = ~recNewFilePath.();
    var nCh = chans ? ~recConfig[\chans];
    var fmtH = header ? ~recConfig[\header];
    var fmtS = sampleFmt ? ~recConfig[\sampleFmt];

    // sanity: warn if the server was booted with fewer output busses
    if(s.options.numOutputBusChannels < nCh) {
        ("[rec] WARN: server has only % output busses; "
        ++ nCh ++ "‑ch file will include % real channels and % silent."
        ).format(s.options.numOutputBusChannels, s.options.numOutputBusChannels, nCh - s.options.numOutputBusChannels).postln;
    };

    // prepare slightly before the bar (non‑blocking)
    clk.schedAbs(tBar - prepLead, {
        ("[rec] prepare " ++ nCh ++ "ch → " ++ path).postln;
        // prepare the file with the target width
        s.prepareForRecord(path, nCh, fmtH, fmtS);
        nil
    });

    // start exactly on the bar — record explicitly from bus 0 with width nCh
    clk.schedAbs(tBar, {
        s.record(bus: 0, numChannels: nCh);
        "[rec] RECORDING (on bar, bus 0, " ++ nCh ++ "ch)".postln;
        nil
    });

    "[rec] armed — will start on the next bar".postln;
};

~recStopOnBar = { |barsAhead=1|
    var clk = ~recClock.();
    var tBar = clk.nextTimeOnGrid(barsAhead);
    clk.schedAbs(tBar, {
        s.stopRecording;
        "[rec] stopped (on bar)".postln;
        nil
    });
};

~recSplitOnBars = { |stopIn=1, startIn=2, prepLead=0.05|
    ~recStopOnBar.(stopIn);
    ~recStartOnBar.(startIn, prepLead);
};

// ---------- shorthands ----------
~recNextBar   = { ~recStartOnBar.(1) };
~stopNextBar  = { ~recStopOnBar.(1) };
~splitNextBar = { ~recSplitOnBars.(1, 2) };

// ---------- optional: Tidal OSC triggers (bar‑aligned) ----------
SynthDef(\recstart, { var t=Impulse.kr(1); SendReply.kr(t, '/rec/start', []); FreeSelf.kr(t); OffsetOut.ar(0, Silent.ar(2)) }).add;
SynthDef(\recstop,  { var t=Impulse.kr(1); SendReply.kr(t, '/rec/stop',  []); FreeSelf.kr(t); OffsetOut.ar(0, Silent.ar(2)) }).add;
SynthDef(\recsplit, { var t=Impulse.kr(1); SendReply.kr(t, '/rec/split', []); FreeSelf.kr(t); OffsetOut.ar(0, Silent.ar(2)) }).add;

s.sync;
OSCdef(\recStartReply, { ~recNextBar.()   }, '/rec/start');
OSCdef(\recStopReply,  { ~stopNextBar.()  }, '/rec/stop');
OSCdef(\recSplitReply, { ~splitNextBar.() }, '/rec/split');

// ---------- self‑test (preinstalled def; no sync inside schedAbs) ----------
SynthDef(\_recBeep, { |out=0|
    var sig = SinOsc.ar(440) * Env.perc(0.005, 0.2).ar(doneAction:2);
    OffsetOut.ar(out, sig!2);
}).add;
s.sync;

~recSelfTestOnBar = {
    var clk = ~recClock.();
    var t  = clk.nextTimeOnGrid(1) + 0.1;
    ~recNextBar.();                           // start next bar
    clk.schedAbs(t, { Synth(\_recBeep) });    // make a short ping after downbeat on out 0/1
    ~recStopOnBar.(2);                        // stop one bar later
};

("[rec] Loaded. Output busses available: " ++ s.options.numOutputBusChannels
 ++ "  | recording: bus 0 → " ++ ~recConfig[\chans] ++ " channels").postln;
)

