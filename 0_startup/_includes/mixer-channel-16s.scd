// 2025-10-29 consolidated mixer include. master, tracks, returns, fx wiring, nil safe helpers
(
var chan;  // declare vars at top

// helper. resolve bus index from a MixerChannel safely
~busOf = { |chan|
    if(chan.notNil and: { chan.respondsTo(\inbus) }) { chan.inbus.index } { 0 }
};

// master
~m1.tryPerform(\free);
~m1 = MixerChannel.new(\m1, s, 2, 2, outbus: 0);
~apcBindParam.(\master_f, { |x| ~m1.level_(x) });

// tracks. all outbus -> master inbus
~t1  = MixerChannel.new(\t1,  s, 2, 2, outbus: ~m1.inbus);
~t2  = MixerChannel.new(\t2,  s, 2, 2, outbus: ~m1.inbus);
~t3  = MixerChannel.new(\t3,  s, 2, 2, outbus: ~m1.inbus);
~t4  = MixerChannel.new(\t4,  s, 2, 2, outbus: ~m1.inbus);
~t5  = MixerChannel.new(\t5,  s, 2, 2, outbus: ~m1.inbus);
~t6  = MixerChannel.new(\t6,  s, 2, 2, outbus: ~m1.inbus);
~t7  = MixerChannel.new(\t7,  s, 2, 2, outbus: ~m1.inbus);
~t8  = MixerChannel.new(\t8,  s, 2, 2, outbus: ~m1.inbus);
~t9  = MixerChannel.new(\t9,  s, 2, 2, outbus: ~m1.inbus);
~t10 = MixerChannel.new(\t10, s, 2, 2, outbus: ~m1.inbus);
~t11 = MixerChannel.new(\t11, s, 2, 2, outbus: ~m1.inbus);
~t12 = MixerChannel.new(\t12, s, 2, 2, outbus: ~m1.inbus);

// example controller binds. keep your originals if preferred
~lcxlBindParam.(\b0_s1_f, { |x| ~t1.level_(x) });
~lcxlBindParam.(\b0_s1_r3, { |x| ~t1.pan_(x.linlin(0, 1, -1, 1)) });
~apcBindParam.(\b0_s1_f,  { |x| ~t1.level_(x) });
~apcBindParam.(\b0_s1_r1, { |x| ~t1.pan_(x.linlin(0, 1, -1, 1)) });

~lcxlBindParam.(\b1_s2_f, { |x| ~t2.level_(x) });
~lcxlBindParam.(\b1_s2_r3, { |x| ~t2.pan_(x.linlin(0, 1, -1, 1)) });
~apcBindParam.(\b0_s2_f,  { |x| ~t2.level_(x) });
~apcBindParam.(\b0_s2_r1, { |x| ~t2.pan_(x.linlin(0, 1, -1, 1)) });

// returns. all outbus -> master inbus
~r1.tryPerform(\free);
~r2.tryPerform(\free);
~r3.tryPerform(\free);
~r4.tryPerform(\free);

~r1 = MixerChannel.new(\r1, s, 2, 2, outbus: ~m1.inbus);
~r2 = MixerChannel.new(\r2, s, 2, 2, outbus: ~m1.inbus);
~r3 = MixerChannel.new(\r3, s, 2, 2, outbus: ~m1.inbus);
~r4 = MixerChannel.new(\r4, s, 2, 2, outbus: ~m1.inbus);

// return faders
~lcxlBindParam.(\b2_s5_f, { |x| ~r1.level_(x) });
~apcBindParam.(\b1_s5_f,  { |x| ~r1.level_(x) });
~lcxlBindParam.(\b2_s6_f, { |x| ~r2.level_(x) });
~apcBindParam.(\b1_s6_f,  { |x| ~r2.level_(x) });

// r1 reverb. read bus explicitly and return wet. do not call Out or ReplaceOut here
~r1.playfx({ |in|
    var sig, wet;  // declare vars at top
    sig = In.ar(~r1.inbus.index, 2);
    wet = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.8, damp: 0.2);
    wet
});

// r2 delay. same pattern
~r2.playfx({ |in|
    var sig, wet;
    sig = In.ar(~r2.inbus.index, 2);
    wet = CombL.ar(sig, maxdelaytime: 0.4, delaytime: 0.25, decaytime: 0.6);
    wet
});

// submix example. perc feeds t1
~perc = MixerChannel.new(\perc, s, 2, 2, outbus: ~t1.inbus);
~pbd1 = MixerChannel.new(\pbd1, s, 2, 2, outbus: ~perc.inbus);
~pbd2 = MixerChannel.new(\pbd2, s, 2, 2, outbus: ~perc.inbus);
~phh1 = MixerChannel.new(\phh1, s, 2, 2, outbus: ~perc.inbus);

// convenience. create or replace a post send from any track to any return
~ensurePostSend = { |fromChan, toChan, level = 0.0|
    var h;
    if(fromChan.notNil and: { toChan.notNil }) {
        h = fromChan.newPostSend(toChan, level);
    }{
        h = nil;
    };
    h
};

// default faders
~m1.level_(1.0);
~t1.level_(1.0);
~t5.level_(1.0);
~r1.level_(0.6);
)

