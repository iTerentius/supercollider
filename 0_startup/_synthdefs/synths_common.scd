(
SynthDef(\trigTest2, { |out, trig=0, freq=440|
    Out.ar(out, SinOsc.ar(freq+[0,1], 0, Decay2.kr(trig, 0.005, 1.0)));
    }, [0, \tr, 4]        // lag the freq lagtime: 4s, \tr creates a TrigControl for trig
).add;
);

(
SynthDef(\test, {
    | out, sustain=0.5, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset, noise=0 |
    var env    = Line.ar(1, 0, sustain, doneAction: Done.freeSelf);
	var osc    = SinOsc.ar(freq) * LFNoise0.kr(noise);
    var output = osc * env;
    OffsetOut.ar(out, Pan2.ar(in: output, pos: pan));
}).add;
);

(
SynthDef(\s1, { 
  | out, sustain=1, freq=110, speed=1, begin=0, end=1, pan, accelerate, offest, freqmod=1, gate=1, noise=4 |
	var e, f, s;
	f = Array.fill(5, { | i | i + freqmod/freq * 10});
	e = EnvGen.kr(Env.adsr(releaseTime: gate/2), gate, doneAction: 2);
	s = Pulse.ar(f/2*Pulse.kr(LFNoise0.kr(noise)).range(0, 10) * LFPulse.kr([0.5, 0.01, 2]/freqmod, 0.5).range(1, 10))* e;
	s = Splay.ar(s * e );
	Out.ar(out, s *0.5);
}).add;
);
// 
// var busses = ~dirt.orbits.collect { |x| x.dryBus };

// SynthDef\readorb, { |out, amp = 1, n = 0, obus = 0 | // number
// 	var bus, sound;
// 	bus = Select.krn, busses;
// 	sound = InFeedback.arbus, ~dirt.numChannels;
// 	//sound = CombL.arsound, 0.2, 0.03, 1;
// 	Out.arout,
// 		sound * amp * 2.5;
// 	
// }.add;
// ;

(
SynthDef(\t1002, {
	// arg out = 0, amp = 0.2, gate = 1, pan = 0, freq = 200, ph = 0;
	// |out,sustain=1,freq=440,speed=1,begin=0,end=1,pan,accelerate,offset,clamp=1,ph=0, noise=0|
	arg out = 0, amp = 0.6, gate = 1, pan = 0, freq = 200, offset, noise=0, ph=1;
	var sig, env;
	env = EnvGen.kr(Env.circle([0.1, 0.25, 0.5], [0.25, 0.75]), 1);
	sig = SinOsc.ar(freq + LFPulse.ar(freq: freq * 2, iphase: ph, add: ph )) * env * ph * 3;
	// sig = sig + LFNoise0.krnoise + freq;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
);

(
SynthDef(\ks_string, { 
	arg out = 0, sustain=1, amp = 0.6, begin=0,end=1, gate = 1, pan = 0, freq = 200, offset, rand=0.01, delayTime=0.5;
    var x, y, env;
    env = Env.new(#[1, 1, 0],#[2, 0.001]);
    // A simple exciter x, with some randomness.
    x = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar); 
     x = CombL.ar(x, 0.05, freq, delayTime, EnvGen.ar(env, doneAction:2)); 
    x = Pan2.ar(x, pan);
    Out.ar(out, LeakDC.ar(x));
}).add;
);

/*
// in tidal, e.g.:
d1 $ sound "can bd hh*5 bd" # pan "0" # up "{1 2 3 4}/4"
d2 $ sound "readorb:0 blip"
  # pan "1" # orbit "1"hoarder
  # delay "1" # delaytime "0.15" # delayfeedback "0.5"
  # bandf "{90 200 1450 9000}/3" # bandq "10"
d1 $ sound "can*2" # pan "0" # up "{1 2 3 4}/4"
*/

(

SynthDef(\bass8, {
	arg out = 0, amp = 0.1, gate = 1, pan = 0, freq = 200;
	var sig;
	var osc = Array.newClear(6);
	var env = Array.newClear(6);

	env[0] = EnvGen.kr(Env([0,1,0.051,0],[0.001,0.01,0.8], [4,-8]), 1);
	env[1] = EnvGen.kr(Env([0,1,0.051,0],[0.005,0.5,1.5], [0,-8], releaseNode:2), 1);
	env[2] = EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.2], [0,0,-4], releaseNode:2), gate);
	env[3] = EnvGen.kr(Env([0,1,0],[0.002,2.8], [0,-4]), 1);
	env[4] = EnvGen.kr(Env([0,1,1,0],[0.001,0.1,0.8], [4,0,-4], releaseNode:2), gate);
	env[5] = EnvGen.kr(Env([0,1,0],[0.001,3.0], [0,-4]), 1);

	freq = (freq / 4) * ((0..1)/1 - 0.5 * 0.0007 + 1);

	osc[0] = SinOsc.ar(freq * 11 + 0) * env[0];
	osc[1] = SinOsc.ar(freq * 6 * ( osc[0] * 2.5 + 1 )) * env[1];
	osc[2] = SinOsc.ar(freq * 2 * 1 + 0) * env[2];
	osc[3] = SinOsc.ar(freq * 1 * ( osc[2] * 2.5 + 1 ) + 0) * env[3];
	osc[4] = SinOsc.ar(freq * 1 * ( osc[1] * 2.5 + 1 ) * (osc[3] * 2.5 + 1)) * env[4];
	osc[5] = SinOsc.ar(freq * 2) * env[5];

	sig = osc * DC.ar([0.0, 0.0, 0.0,  0.0, 0.5, 0.5]);
	sig = sig * 0.5;
	sig = sig.flop.sum;
	sig = sig * EnvGen.ar(\adsr.kr( Env.adsr(0.001,0,1,0.01, 1,-1) ), gate, doneAction:2);
	sig = sig * AmpComp.kr(freq);
	sig = sig.sum;
	Out.ar(out, Pan2.ar(sig, pan, amp));

}).add;

);

// cello like sound
(
	SynthDef(\cello, {
		arg 
		out = 0, 
		sustain=0.5, 
		amp = 0.6, 
		begin=0,end=1, 
		gate = 1, 
		pan = 0, 
		freq = 200, 
		offset, 
		rand=0, 
		delayTime=0, 
		rq=0.1, 
		atk=0.01, 
		dcy=0.1, 
		rls=0.4, 
		aux=0, 
		auxsend=0.1, 
		dur=2;
		// |
		// freq=440, amp=1.0, out=0, pan=0.0, rq=0.1,
		// atk=0.01, dcy=0.1, sustain=0.5, rls=0.4, 
		// gate=1, dur=2,
		// aux=0, auxsend=0.1
		// |
		var sig, env,width;
		env = EnvGen.ar(Env.adsr(atk, dcy, sustain, rls), gate, doneAction:2);
		width = LFNoise2.kr(1).range(0.001, 0.01);
		sig = VarSaw.ar(freq+ SinOsc.ar(6,mul:Line.kr(0.0, 1, dur,doneAction:2)), width:width);
		sig = RLPF.ar(sig, freq*1, rq);
		sig = Decimator.ar(sig, 22050,2);
		sig = sig *env* amp;
		Out.ar(out, Pan2.ar(sig, pan));
		// Out.araux, sig*auxsend;
	}).add;
);
// One shot sample players
(
// --- SynthDefs (unchanged behavior, small consistency tweaks) ---
SynthDef(\pBs, { |out=0, bufnum=0, amp=0.2, rev=0, rate=1, pan=0, startPos=0, loop=0|
    var sig, sigL, sigR;  // declare vars at top
    rate = Lag.kr(rate, 0.05) * BufRateScale.kr(bufnum);
    # sigL, sigR = PlayBuf.ar(
        2, bufnum, rate,
        startPos: startPos,
        loop: loop,
        doneAction: 2
    );
    sig = Balance2.ar(sigL, sigR, pan, amp);
    Out.ar(out, sig);
}).add;
);
(
SynthDef(\pBm, { |out=0, bufnum=0, amp=0.2, rate=1, pan=0, startPos=0, loop=0|
    var sig;  // declare vars at top
    sig = PlayBuf.ar(
        1, bufnum, rate * BufRateScale.kr(bufnum),
        loop: loop,
        startPos: startPos,
        doneAction: 2
    );
    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;
);

// --- Helper 1: a tiny function that picks the right instrument symbol
~bufInstr = { |buf|
    // returns \pBs for stereo, \pBm for mono
    if(buf.notNil and: { buf.numChannels == 2 }) { \pBs } { \pBm }
};

// --- Helper 2: a pattern wrapper so you never type the selection again
~pBuf = { |pat|
    // injects \instrument based on \buf in each event
    pat.collect { |e|
        var buf;  // declare vars at top
        buf = e[\buf];
        e[\instrument] = ~bufInstr.(buf);
        e
    }
};

/* tidal-slice synthdefs 2025-10-08 */

(
// mono with spread + reverse
SynthDef(\slice_m, { |out=0, bufnum=0, sliceIndex=0, nSlices=8, amp=0.5, rate=1, pan=0, spread=0, rev=0|
    var sig, numFrames, startFrame, sliceFrames, sliceDur, playRate, startPos, altSign, panCalc;

    numFrames   = BufFrames.ir(bufnum);
    sliceIndex  = sliceIndex % max(1, nSlices);
    sliceFrames = numFrames / nSlices;

    // alternate -1 for even, +1 for odd slices
    altSign  = Select.kr(sliceIndex % 2, [-1, 1]);
    panCalc  = Clip.kr(pan + (spread * altSign), -1, 1);

    // reverse handling
    playRate = BufRateScale.kr(bufnum) * (rev > 0.5).if(rate.abs.neg, rate.abs);
    startPos = (rev > 0.5).if(
        ((sliceIndex + 1) / nSlices) * numFrames - 1,  // start at slice end for reverse
        (sliceIndex / nSlices) * numFrames             // start at slice start for forward
    );

    // duration in seconds is independent of direction
    sliceDur = (sliceFrames / BufSampleRate.ir(bufnum)) / max(0.0001, rate.abs);

    sig = PlayBuf.ar(
        1, bufnum,
        rate: playRate,
        startPos: startPos,
        loop: 0,
        doneAction: 0
    );

    sig = sig * EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), doneAction: 2);
    sig = Pan2.ar(sig, panCalc, amp);
    Out.ar(out, sig);
}).add;
);

(
// stereo with spread + reverse
SynthDef(\slice_s, { |out=0, bufnum=0, sliceIndex=0, nSlices=8, amp=0.5, rate=1, pan=0, spread=0, rev=0|
    var sig, numFrames, startFrame, sliceFrames, sliceDur, playRate, startPos, altSign, panCalc, l, r;

    numFrames   = BufFrames.ir(bufnum);
    sliceIndex  = sliceIndex % max(1, nSlices);
    sliceFrames = numFrames / nSlices;

    altSign  = Select.kr(sliceIndex % 2, [-1, 1]);
    panCalc  = Clip.kr(pan + (spread * altSign), -1, 1);

    playRate = BufRateScale.kr(bufnum) * (rev > 0.5).if(rate.abs.neg, rate.abs);
    startPos = (rev > 0.5).if(
        ((sliceIndex + 1) / nSlices) * numFrames - 1,
        (sliceIndex / nSlices) * numFrames
    );

    sliceDur = (sliceFrames / BufSampleRate.ir(bufnum)) / max(0.0001, rate.abs);

    sig = PlayBuf.ar(
        2, bufnum,
        rate: playRate,
        startPos: startPos,
        loop: 0,
        doneAction: 0
    );

    sig = sig * EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), doneAction: 2);
    l = sig[0]; r = sig[1];
    sig = Balance2.ar(l, r, panCalc, amp);
    Out.ar(out, sig);
}).add;
);

// stereo live-slice effect
(
SynthDef(\slice_fx, { |inbus=0, out=0, bufSecs=2, nSlices=8, sliceIndex=0, rate=1, pan=0, spread=0, rev=0, amp=1, mix=1, trig=1|
    var sigIn, sigPlay, numFrames, sliceFrames, sliceDur, buf, writePhase, startPos, playRate, altSign, panCalc, env, dry, wet, l, r;

    // input and buffer setup
    sigIn = In.ar(inbus, 2);
    buf = LocalBuf(SampleRate.ir * bufSecs, 2);
    numFrames = BufFrames.ir(buf);
    sliceFrames = numFrames / max(1, nSlices);

    // rolling write head and continuous record
    writePhase = Phasor.ar(0, 1, 0, numFrames);
    BufWr.ar(sigIn, buf, writePhase, loop: 1);

    // choose slice behind the head
    sliceIndex = sliceIndex % max(1, nSlices);
    startPos = (writePhase - (sliceIndex * sliceFrames)) % numFrames;

    // reverse and timing
    playRate = BufRateScale.kr(buf) * Select.kr(rev > 0.5, [rate.abs, rate.abs.neg]);
    sliceDur = (sliceFrames / BufSampleRate.ir(buf)) / max(0.0001, rate.abs);

    // play one slice per event
    sigPlay = PlayBuf.ar(2, buf, rate: playRate, startPos: startPos, loop: 0, doneAction: 0);
    env = EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), trig, doneAction: 2);
    sigPlay = sigPlay * env * amp;

    // spread alternates per slice
    l = sigPlay[0]; r = sigPlay[1];
    altSign = Select.kr(sliceIndex % 2, [-1, 1]);
    panCalc = Clip.kr(pan + (spread * altSign), -1, 1);
    wet = Balance2.ar(l, r, panCalc);
    dry = Balance2.ar(sigIn[0], sigIn[1], pan);

    // mix wet/dry to out
    Out.ar(out, XFade2.ar(dry, wet, (mix * 2) - 1));
}).add;
);
/* slice_fx for ddwMixerChannel .playfx stereo 2025-10-08 */

~sliceFX_makeCtrlBuses = {
    ~slice_idx  = ~slice_idx  ?? { Bus.control(s, 1) };
    ~slice_rev  = ~slice_rev  ?? { Bus.control(s, 1) };
    ~slice_sp   = ~slice_sp   ?? { Bus.control(s, 1) };
    ~slice_rate = ~slice_rate ?? { Bus.control(s, 1) };
    ~slice_mix  = ~slice_mix  ?? { Bus.control(s, 1) };
    ~slice_pan  = ~slice_pan  ?? { Bus.control(s, 1) };
    // defaults
    ~slice_idx.set(0);
    ~slice_rev.set(0);
    ~slice_sp.set(0.5);
    ~slice_rate.set(1);
    ~slice_mix.set(1);
    ~slice_pan.set(0);
};

~sliceFX_playfx_s = { |bufSecs=2, nSlices=8|
    { |outbus|
        var sigIn, sigPlay, buf, numFrames, sliceFrames, writePhase;
        var startPos, playRate, sliceDur, env, altSign, panCalc, l, r, wet, dry;
        var sliceIndex, rev, spread, rate, mix, pan;

        sliceIndex = In.kr(~slice_idx, 1);
        rev        = In.kr(~slice_rev, 1);
        spread     = In.kr(~slice_sp, 1);
        rate       = In.kr(~slice_rate, 1);
        mix        = In.kr(~slice_mix, 1);
        pan        = In.kr(~slice_pan, 1);

        sigIn = In.ar(outbus, 2);
        buf = LocalBuf(SampleRate.ir * bufSecs, 2);
        numFrames = BufFrames.ir(buf);
        sliceFrames = numFrames / max(1, nSlices);

        writePhase = Phasor.ar(0, 1, 0, numFrames);
        BufWr.ar(sigIn, buf, writePhase, loop: 1);

        sliceIndex = sliceIndex % max(1, nSlices);
        startPos = (writePhase - (sliceIndex * sliceFrames)) % numFrames;

        playRate = BufRateScale.kr(buf) * Select.kr(rev > 0.5, [rate.abs, rate.abs.neg]);
        sliceDur = (sliceFrames / BufSampleRate.ir(buf)) / max(0.0001, rate.abs);

        sigPlay = PlayBuf.ar(2, buf, rate: playRate, startPos: startPos, loop: 0, doneAction: 0);
        env = EnvGen.kr(Env.linen(0.001, sliceDur, 0.05), 1, doneAction: 0);
        sigPlay = sigPlay * env;

        l = sigPlay[0]; r = sigPlay[1];
        altSign = Select.kr((sliceIndex % 2).round(0), [-1, 1]);
        panCalc = Clip.kr(pan + (spread * altSign), -1, 1);
        wet = Balance2.ar(l, r, panCalc);
        dry = Balance2.ar(sigIn[0], sigIn[1], pan);

        Out.ar(outbus, XFade2.ar(dry, wet, (mix * 2) - 1));
    }
};

~sliceFX_makeCtrlBuses.();
