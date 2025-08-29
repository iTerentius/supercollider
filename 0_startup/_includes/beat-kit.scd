(
// ---------- SETTINGS ----------
s.waitForBoot {
    // 1) Point this at a drum folder with files named like: bd.wav, sd.wav, hhc.wav, hho.wav ...
    //    (any names work—these are just convenient defaults)
    ~drumFolder = PathName(Platform.userHomeDir +/+ "Music/samples/drums"); // change me

    // 2) Tempo
    TempoClock.default.tempo = 120/60; // 120 BPM

    // ---------- SAMPLE LOADER ----------
    ~samples = IdentityDictionary.new;
    ~loadSamples = {
        ~samples.do(_.value.free); // free old buffers
        ~samples = IdentityDictionary.new;

        if(~drumFolder.exists.not) {
            "⚠️ Folder does not exist:\n%".format(~drumFolder.fullPath).warn;
        } {
            ~drumFolder.entries.select(_.isFile).do { |pn|
                var name = pn.fileNameWithoutExtension.asSymbol;
                var buf  = Buffer.readChannel(s, pn.fullPath, channels:[0]); // mono
                ~samples[name] = buf;
            };
            "Loaded % samples: %".format(~samples.size, ~samples.keys.as(Array).sort).postln;
        };
    };

    ~loadSamples.();

    // Helpers to fetch buffers safely
    ~buf = { |sym, fallback=nil|
        var b = ~samples[sym] ?? { fallback.notNil.if({ ~samples[fallback] }, { ~samples.values.at(0) }) };
        b ?? { "⚠️ No samples loaded.".warn; nil };
    };

    // For round-robin sets like [\bd1, \bd2, \bd3]
    ~bufChoose = { |arr|
        var choices = arr.collect { |k| ~samples[k] }.reject(_.isNil);
        choices.isEmpty.if({ nil }, { choices.choose });
    };

    // ---------- INSTRUMENT ----------
    SynthDef(\samplerOneShot, { |out=0, bufnum=0, rate=1, startPos=0, amp=0.8, pan=0,
        atk=0.001, rel=0.15, bend=0, hp=20, lp=20000, crush=1, comp=0, compThresh=0.8, compSlope=0.5|
        var sr    = BufSampleRate.kr(bufnum);
        var sig   = PlayBuf.ar(
            1, bufnum, BufRateScale.kr(bufnum) * rate * (bend.midiratio),
            startPos: (startPos.clip(0,1) * BufFrames.kr(bufnum)),
            doneAction:2
        );

        // simple filter block
        sig = BHiPass4.ar(sig, hp.max(20), 0.707);
        sig = BLowPass4.ar(sig, lp.min(20000), 0.707);

        // bit crush (1 = off; >1 reduces resolution)
        sig = (crush <= 1).if({ sig }, { (sig * crush).round / crush });

        // soft comp
        sig = (comp > 0).if({
            var env = Amplitude.ar(sig).clip(1e-6, 1);
            var gain = (env > compThresh).if({
                (env / compThresh).pow(compSlope.neg).clip(0.0, 1.0)
            }, { 1.0 });
            sig * LinLin.kr(comp, 0, 1, 1, gain);
        }, { sig });

        sig = sig * Env.perc(atk, rel).ar(doneAction:2) * amp;
        sig = Pan2.ar(sig, pan);
        Out.ar(out, sig);
    }).add;

    // ---------- EVENT DEFAULTS ----------
    // We’ll drive \samplerOneShot with Pbinds using these keys
    Event.addEventType(\sampler, { |ev|
        ev.use {
            var buf = ev[\bufnum] ?? { ev[\buf] ?? { nil } };
            if(buf.isNil) { ^nil };
            Synth.after(s.defaultGroup, \samplerOneShot, [
                \bufnum, buf,
                \rate,   ev[\rate]  ? 1,
                \startPos, ev[\start] ? 0,
                \amp,    ev[\amp]   ? 0.8,
                \pan,    ev[\pan]   ? 0,
                \atk,    ev[\atk]   ? 0.001,
                \rel,    ev[\rel]   ? 0.12,
                \bend,   ev[\bend]  ? 0,
                \hp,     ev[\hp]    ? 20,
                \lp,     ev[\lp]    ? 20000,
                \crush,  ev[\crush] ? 1,
                \comp,   ev[\comp]  ? 0,
                \compThresh, ev[\compThresh] ? 0.8,
                \compSlope,  ev[\compSlope]  ? 0.5
            ]);
        };
    });

    // ---------- RHYTHM DSL: "x-xx----" ----------
    ~pattern = { |str, step=0.25| // step = 16th by default
        var chars = str.reject(_ == $\s);
        Pseq(chars.collect { |ch| (ch == $x).if({ step }, { Rest(step) }) }, inf)
    };

    // Quick accent helper (parallel amp pattern)
    ~accents = { |vals=#[1,1,1,1]| Pseq(vals, inf) };

    // Swing: positive values push the off-beats later (in seconds)
    ~swing = { |amount=0.0, step=0.25|
        // apply on every second step
        Pfunc { |ev|
            var stepIndex = (ev[\bar] * (1/step) + ev[\beat]/step).floor;
            ((stepIndex % 2) == 1).if({ amount }, { 0.0 });
        }
    };

    // ---------- PARTS (hot-swappable with Pdef) ----------
    // KICK
    Pdef(\bd,
        Pbind(
            \type, \sampler,
            \bufnum, Pfunc { ~buf(\bd) ? ~buf(\kick) ? (~buf(\bd1) ?? { ~bufChoose.([\bd1,\bd2,\bd3]) }) }.tryPerform(\bufnum),
            \dur, ~pattern.("x---x---x---x---", 0.25),       // 4 on the floor as a base
            \amp, 0.9 * ~accents.([1.2, 1, 1.1, 1]),
            \rel, 0.18,
            \hp,  25, \lp, 18000,
            \timingOffset, ~swing.(0.012, 0.25)              // light swing on 16ths
        )
    );

    // SNARE
    Pdef(\sd,
        Pbind(
            \type, \sampler,
            \bufnum, Pfunc { ~buf(\sd) ? ~buf(\snare) }.tryPerform(\bufnum),
            \dur, ~pattern.("----x-------x---", 0.25),       // backbeats on 2 & 4
            \amp, 0.85 * ~accents.([1, 1.15]),
            \rel, 0.22, \hp, 100, \lp, 14000,
            \timingOffset, ~swing.(0.012, 0.25)
        )
    );

    // HIHATS (closed & occasional open with probability)
    Pdef(\hh,
        Pbindf(
            Pbind(
                \type, \sampler,
                \bufnum, Pfunc {
                    // 1 in 8 chance to use open hat if available
                    if(1.0.rand < 0.125 and: { ~buf(\hho).notNil }) {
                        ~buf(\hho).bufnum
                    } {
                        (~buf(\hhc) ?? { ~buf(\hh) }).tryPerform(\bufnum)
                    }
                },
                \dur, ~pattern.("x-x-x-x-x-x-x-x-", 0.25),    // 8ths
                \amp, Pwhite(0.6, 0.9),                       // subtle randomization
                \rel, 0.08, \hp, 3000, \lp, 18000,
                \pan, Pwhite(-0.2, 0.2),
                \timingOffset, ~swing.(0.012, 0.25)
            ),
            // tiny “skip” prob on some offbeats
            \isRest, Pwrand([false, true], [0.9, 0.1], inf)
        )
    );

    // PERC (example: conga / rim / clap—use what you’ve got)
    Pdef(\perc,
        Pbind(
            \type, \sampler,
            \bufnum, Pfunc { ~bufChoose.([\rim, \clap, \perc, \tom]) }.tryPerform(\bufnum),
            \dur, ~pattern.("--x---x-----x---", 0.25),
            \amp, 0.6,
            \pan, Pwhite(-0.5, 0.5),
            \rel, 0.12, \hp, 200, \lp, 16000,
            \timingOffset, ~swing.(0.012, 0.25)
        )
    );

    // ---------- START / STOP ----------
    // quantize all parts to the bar
    [\bd, \sd, \hh, \perc].do { |k| Pdef(k).quant = 1; };

    // A convenience function to (re)start the groove
    ~go = {
        Pdef(\bd).play;
        Pdef(\sd).play;
        Pdef(\hh).play;
        // comment in/out as needed
        // Pdef(\perc).play;
    };

    ~stop = { [\bd, \sd, \hh, \perc].do { |k| Pdef(k).stop; }; };

    "Drum rig ready. Run: ~go.  Stop: ~stop.  Reload samples: ~loadSamples.()".postln;
};
)

