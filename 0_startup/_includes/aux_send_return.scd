/* =======================================================================
   Aux Send/Return for SuperDirt + Tidal
   - Per-orbit aux send control:  asend
   - Global wet (return level):   auxret  (read by mixer from a control bus)
   - FX params (optional):        auxroom, auxdamp, auxrate, auxdepth, auxtime, auxfb, auxwow
   - Swappable A/B return via ~setAuxFx.(\defName, [\paramBus, ~ctl[\...], ...])
   ======================================================================= */

~installAux = {
    s.doWhenBooted {
        fork {
            // ----- wait for SuperDirt (~dirt) -----
            while { ~dirt.isNil } { 0.2.wait };

            // ---------------- BUSES & GROUP ----------------
            ~auxBus   = ~auxBus   ? { Bus.audio(s, ~dirt.numChannels) }.value;
            ~retMixA  = ~retMixA  ? { Bus.audio(s, ~dirt.numChannels) }.value;
            ~retMixB  = ~retMixB  ? { Bus.audio(s, ~dirt.numChannels) }.value;

            ~ctl = ~ctl ? (  // control buses driven from Tidal via auxCtl
                auxret:  Bus.control(s, 1),
                auxroom: Bus.control(s, 1),
                auxdamp: Bus.control(s, 1),
                auxrate: Bus.control(s, 1),
                auxdepth:Bus.control(s, 1),
                auxtime: Bus.control(s, 1),
                auxfb:   Bus.control(s, 1),
                auxwow:  Bus.control(s, 1)
            );

            ~auxGroup = ~auxGroup ? Group.tail(s);

            // ---------------- SEND TAP (per channel count) ----------------
            (1..SuperDirt.maxSampleNumChannels).do { |n|
                SynthDef(("sendTap" ++ n), { |dryBus, effectBus, gate=1, asend=0|
                    var sig = In.ar(dryBus, n);
                    Out.ar(effectBus, sig);                     // passthrough
                    Out.ar(~auxBus, sig * asend.clip(0, 1));    // copy to shared aux
                    DirtPause.ar(Mix.ar(sig), graceTime: 4);       // keep node alive with Dirt
                    EnvGen.kr(Env.asr, gate, doneAction: 2);
                }, [\ir, \ir]).add;
            };

            // ---------------- MIXER (A/B crossfade, level from bus) ----------------
            SynthDef(\auxMixer, { |inA, inB, out=0, xfade=0, levelBus|
                var n = ~dirt.numChannels;
                var a = In.ar(inA, n), b = In.ar(inB, n);
                var x = Lag.kr(xfade.clip(0,1), 0.2);
                var level = Lag.kr(In.kr(levelBus, 1).clip(0, 2), 0.08);
                Out.ar(out, XFade2.ar(a, b, (x*2 - 1)) * level);
            }).add;

            // ---------------- EFFECTS (bus-driven params) ----------------
            SynthDef(\fx_hall_bus, { |inBus, outBus, roomBus, dampBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                var room = Lag.kr(In.kr(roomBus, 1), 0.2);
                var damp = Lag.kr(In.kr(dampBus, 1), 0.2);
                var wet  = NHHall.ar(sig, room, damp);
                Out.ar(outBus, Limiter.ar(wet, 0.95));
            }).add;

            SynthDef(\fx_chorus_bus, { |inBus, outBus, rateBus, depthBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                var rate  = Lag.kr(In.kr(rateBus, 1), 0.2);
                var depth = Lag.kr(In.kr(depthBus,1), 0.2).clip(0, 0.03);
                var mod   = SinOsc.kr(rate).range(0, depth);
                Out.ar(outBus, DelayC.ar(sig, 0.03, mod)); // pure wet
            }).add;

            SynthDef(\fx_tape_bus, { |inBus, outBus, timeBus, fbBus, wowBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                var time = Lag.kr(In.kr(timeBus, 1), 0.2).clip(0.001, 1);
                var fb   = Lag.kr(In.kr(fbBus,   1), 0.2).clip(0, 1);
                var wow  = Lag.kr(In.kr(wowBus,  1), 0.2).clip(0, 1);
                var dl   = CombC.ar(sig, 2, time, fb.linexp(0,1,0.1,8));
                var wowd = DelayC.ar(dl, 0.01, LFNoise2.kr(0.2!n).range(0, wow*0.01));
                Out.ar(outBus, tanh(wowd * 2));
            }).add;

            // ---------------- SUPER OBVIOUS TEST FX ----------------
            SynthDef(\fx_mute_bus, { |inBus, outBus|
                var n = ~dirt.numChannels;
                In.ar(inBus, n);                // read & discard
                Out.ar(outBus, Silent.ar(n));   // silence
            }).add;

            SynthDef(\fx_beep_bus, { |inBus, outBus|
                var n = ~dirt.numChannels;
                var tone = SinOsc.ar(660)!n * 0.2; // ignores input
                Out.ar(outBus, tone);
            }).add;

            SynthDef(\fx_crunch_bus, { |inBus, outBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                var holdRate = 800;                        // lower = nastier
                var held = Latch.ar(sig, Impulse.ar(holdRate));
                var q = 12;                                // fewer steps = harsher
                var crushed = (held * q).round / q;
                Out.ar(outBus, crushed * 0.9);
            }).add;

            SynthDef(\fx_chop_bus, { |inBus, outBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                var gate = LFPulse.kr(3, 0, 0.5).lag(0.01);
                Out.ar(outBus, sig * gate);
            }).add;

            SynthDef(\fx_pitchUp_bus, { |inBus, outBus|
                var n = ~dirt.numChannels, sig = In.ar(inBus, n);
                Out.ar(outBus, PitchShift.ar(sig, 0.2, 2.0, 0.0, 0.0));
            }).add;

            // ---------------- CONTROLLER (writes aux* params to buses) ----------------
            (1..SuperDirt.maxSampleNumChannels).do { |n|
                SynthDef(("auxCtl" ++ n), { |dryBus, effectBus,
                    auxret=0.6, auxroom=0.8, auxdamp=0.4, auxrate=0.3, auxdepth=0.015, auxtime=0.35, auxfb=0.5, auxwow=0.2|
                    var sig = In.ar(dryBus, n);
                    Out.ar(effectBus, sig);  // passthrough
                    Out.kr(~ctl[\auxret],   Lag.kr(auxret,  0.2));
                    Out.kr(~ctl[\auxroom],  Lag.kr(auxroom, 0.2));
                    Out.kr(~ctl[\auxdamp],  Lag.kr(auxdamp, 0.2));
                    Out.kr(~ctl[\auxrate],  Lag.kr(auxrate, 0.2));
                    Out.kr(~ctl[\auxdepth], Lag.kr(auxdepth,0.2));
                    Out.kr(~ctl[\auxtime],  Lag.kr(auxtime, 0.2));
                    Out.kr(~ctl[\auxfb],    Lag.kr(auxfb,   0.2));
                    Out.kr(~ctl[\auxwow],   Lag.kr(auxwow,  0.2));
                    DirtPause.ar(Mix.ar(sig), graceTime: 4);
                    EnvGen.kr(Env.asr, 1, doneAction: 2);
                }, [\ir, \ir]).add;
            };

            // -------- ensure all defs are on the server before using them --------
            s.sync;

            // ---------------- INSTALL TAP ON ALL ORBITS (append; alwaysRun=true) ----------------
            ~dirt.orbits.do { |o|
                o.globalEffects = o.globalEffects.add(
                    GlobalDirtEffect(\sendTap, [\asend], nil, true)
                );
                o.initNodeTree;
            };

            // ---------------- INSTALL CONTROLLER ON ORBIT 0 (prepend; alwaysRun=true) ----------------
            {
                var o = ~dirt.orbits[0];
                o.globalEffects = [GlobalDirtEffect(\auxCtl,
                    [\auxret, \auxroom, \auxdamp, \auxrate, \auxdepth, \auxtime, \auxfb, \auxwow],
                    nil, true
                )] ++ o.globalEffects;
                o.initNodeTree;
            }.value;

            // ---------------- START/RESTART MIXER (reads auxret bus) ----------------
            if(~mixer.notNil) { ~mixer.free };
            ~mixer = Synth.tail(~auxGroup, \auxMixer, [
                \inA, ~retMixA, \inB, ~retMixB, \out, 0, \levelBus, ~ctl[\auxret]
            ]);

            // ---------------- SWAP FUNCTION (write inactive slot, crossfade, cleanup) ----------------
            ~activeSlot = ~activeSlot ? 0;   // 0 = A active; 1 = B active
            ~currentFx  = ~currentFx  ? nil;
            ~pendingFx  = nil;
            ~currentFxName = ~currentFxName ? \none;

            ~setAuxFx = { |defName=\fx_hall_bus, args=#[]|
                var writeBus, xTo;

                if(~activeSlot == 0) { writeBus = ~retMixB; xTo = 1; } { writeBus = ~retMixA; xTo = 0; };

                if(~pendingFx.notNil) { ~pendingFx.free };

                ~pendingFx = Synth.tail(
                    ~auxGroup,
                    defName,
                    [\inBus, ~auxBus, \outBus, writeBus] ++ args
                );

                ~mixer.set(\xfade, xTo);

                SystemClock.sched(0.35, {
                    if(~currentFx.notNil) { ~currentFx.free };
                    ~currentFx = ~pendingFx; ~pendingFx = nil;
                    ~activeSlot = 1 - ~activeSlot;
                    ~currentFxName = defName;
                    ("[aux] now running: " ++ ~currentFxName.asString).postln;
                    nil
                });
            };

            // ---------------- PICK A SINGLE INITIAL EFFECT ----------------
            // Choose ONE line below. 'beep' is great to prove the chain is audible.
            ~setAuxFx.(\fx_beep_bus);
            // ~setAuxFx.(\fx_hall_bus,   [\roomBus, ~ctl[\auxroom], \dampBus, ~ctl[\auxdamp]]);
            // ~setAuxFx.(\fx_chorus_bus, [\rateBus, ~ctl[\auxrate], \depthBus, ~ctl[\auxdepth]]);
            // ~setAuxFx.(\fx_tape_bus,   [\timeBus, ~ctl[\auxtime], \fbBus, ~ctl[\auxfb], \wowBus, ~ctl[\auxwow]]);
        };
    };
};

// ---- auto-run on boot ----
~installAux.();

// ---- quick uninstall helper (keeps buses so reinstall is fast) ----
~uninstallAux = {
    if(~mixer.notNil) { ~mixer.free };
    if(~currentFx.notNil) { ~currentFx.free };
    if(~pendingFx.notNil) { ~pendingFx.free };
    "[aux] mixer and fx freed (buses left allocated)".postln;
};
