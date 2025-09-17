(
// example pattern to track 3
Pbind(
    \instrument, \default,
    \dur, 0.25,
    \degree, Pwhite(0,7,inf),
    \amp, 0.15,
    \out, ~m36_in.(2)
).play;
)

// set sends for that track
~m36_setSend.(2, 0, 0.9);   // to reverb
~m36_setSend.(2, 1, 0.25);  // to delay

// quick routing demo
~m36_demo.();  // plays a Blip on track 3 and raises sends to verb+delay

(
// or route your own patterns
Pbind(\instrument, \default, \dur, 0.25, \degree, Pwhite(0,7,inf), \amp, 0.12,
  \out, ~m36_in.(2)).play;

)

// raise sends
~m36_setSend.(2, 0, 0.6);  // reverb
~m36_setSend.(2, 1, 0.35); // delay

// master fader
~m36_masterLevel.(0.9);

// quick routing demo
~m36_demo.();  // plays a Blip on track 3 and raises sends to verb+delay

// or route your own patterns
Pbind(\instrument, \default, \dur, 0.25, \degree, Pwhite(0,7,inf), \amp, 0.12,
      \out, ~m36_in.(2)).play;

// raise sends
~m36_setSend.(2, 0, 0.6);  // reverb
~m36_setSend.(2, 1, 0.35); // delay

// master fader
~m36_masterLevel.(0.9);

// teardown if needed
~m36_freeAll.();

~m36_fxchans[0].scope;  // verb
~m36_fxchans[1].scope;  // delay

~m36_debug.();

ServerMeter(s);


~m36_probeFX1.();      // should hear a quiet beep with reverb on FX1 and see scope activity
~m36_fxchans[0].scope; // watch it move
// stop the probe
~m36_probeFXStop.();


~m36_demo.();  // Blip on track 3, raises sends to FX1+FX2
~m36_fxchans[0].scope;
~m36_fxchans[1].scope;

// 2025-09-16 20:55 America-Chicago  ddw minimal proof
(
s.waitForBoot({
    var m, r, snd;

    m = MixerChannel(\m_min, s, 2, 2, outbus: 0, level: 0.15);
    r = MixerChannel(\r_min, s, 2, 2, outbus: 0, level: 0.9);

    // source
    m.play({
        var trig, freq, eg, pan;
        trig = Impulse.ar(2.2);
        freq = TExpRand.ar(200, 800, trig);
        eg   = Decay2.ar(trig, 0.02, 0.15);
        pan  = TRand.ar(-0.6, 0.6, trig);
        Pan2.ar(SinOsc.ar(freq), pan) * eg * 0.2
    });

    // fx insert on the RETURN channel  returns processed signal
    r.playfx({ |out|
        var sig, wet;
        sig = In.ar(out, 2);
        wet = FreeVerb2.ar(sig[0], sig[1], 1, 0.97, 0.2);
        wet
    });

    // post fader send from source to return
    snd = m.newPostSend(r, 0.6);

    "ddw minimal ready".postln;
});
)
// 2025-09-16 20:55 America-Chicago  tap fx input to hardware 0 1
(
~m36_tapFxIn = { |which=0|
    var fx, bus;
    fx  = ~m36_fxchans.wrapAt(which);
    bus = fx.inbus;
    { Out.ar(0, In.ar(bus, 2) * 0.15) }.play;   // temporary monitoring tap
};
)

// route something into track 3, then raise a send
~m36_demo.();                     // or your own Pbind routed via ~m36_in.(2)
~m36_setSend.(2, 0, 0.8);         // crank a send to FX 1
~m36_tapFxIn.(0);                 // you should hear the raw send signal on 0 1
// 2025-09-16 20:55 America-Chicago  force FX on returns using inbus
(
// reverb on FX 1
~m36_fxchans[0].stop;  // clear any previous insert on that return
~m36_fxchans[0].play({
    var sig, wet, mix, room, damp;
    mix = 0.9; room = 0.9; damp = 0.2;
    sig = In.ar(~m36_fxchans[0].inbus, 2);     // read summed sends into this return
    wet = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    wet                                       // returned into the return's chain to master
});

// delay on FX 2
~m36_fxchans[1].stop;
~m36_fxchans[1].play({
    var sig, dl, time, fb, wetAmt, out;
    time = 0.33; fb = 0.42; wetAmt = 0.5;
    sig  = In.ar(~m36_fxchans[1].inbus, 2);
    dl   = LocalIn.ar(2);
    dl   = DelayC.ar(sig + (dl * fb), 1.0, [time, time * 1.12]);
    LocalOut.ar(dl);
    out  = XFade2.ar(sig, dl, (wetAmt * 2) - 1, 1);
    Limiter.ar(out, 0.95)
});
)

// now raise sends and scope
~m36_setSend.(2, 0, 0.8);
~m36_setSend.(2, 1, 0.5);
~m36_fxchans[0].scope;
~m36_fxchans[1].scope;


