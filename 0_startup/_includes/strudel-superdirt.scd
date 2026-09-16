// Strudel/SuperDirt bridge — OSC output backend for nvim-strudel.
//
// Attaches SuperDirt to the server that's already booted (`s`), in place.
// Does NOT reboot the server, does NOT run Server.killAll, and does not
// touch any of the mixer/synth/sample setup loaded above. This deliberately
// replaces nvim-strudel's own `auto_superdirt` launcher (lua config:
// audio.auto_superdirt = false), which spawns a second competing sclang
// process and runs Server.killAll — killing this session's own scsynth.
//
// Requires: s.options.numWireBufs = 128 set BEFORE boot (see the hypo-fm
// branch above) — SuperDirt's per-orbit synth chain needs more interconnect
// buffers than the default 64, or synthdef loading fails with "exceeded
// number of interconnect buffers". Confirmed sufficient for 4 concurrent
// orbits (2026-09-10); now at 12 orbits (see ~strudelVoiceNames below) — if
// "exceeded number of interconnect buffers" comes back under heavier
// polyphony, bump numWireBufs further (256, then 512, ...) and reboot.
//
// To disable entirely: comment out this file's .load line in startup.scd.

(
~dirt = SuperDirt(2, s);

// Per-voice mixing: one audio bus per SuperDirt orbit, feeding straight into
// EXISTING ins9-12 channel strips (already built + already wired into
// dry_mix/master by ndef-channel-16s.scd's own cold-boot ~fxInit call), one
// hop, exactly like plugging in any other instrument per that file's own
// convention: `Ndef(\ins1).source = { PlayBuf.ar(...) };`
//
// Previously this used a separate \iStrudelN proxy that you then had to
// manually reference from Ndef(\ins1)'s own source by hand each session
// (Ndef(\ins1)[0] = { Ndef(\iStrudel1, 2) * amp }) — that double hop turned
// out to be fragile in practice (2026-09-10: worked for exactly one cycle,
// only in one specific eval order, then permanent silence). Setting an
// already-integrated ins slot's source directly avoids both the fragility
// and the manual step.
//
// In a pattern, `.orbit(0)` (or no .orbit() at all) goes to the first name
// below (ins1), `.orbit(1)` to the second (ins2), etc. — 0-indexed, same
// order as this array.
//
// Claims ALL of ins1-12 for Strudel while this include is active, on the
// reasoning that pattern-based Ndefs can't run alongside Strudel anyway
// (no clock sync between them — see conversation history) without slowly
// drifting out of phase, so there's nothing non-time-based competing for
// these slots in a Strudel session. Genuinely live/non-pattern sources
// (MIDI-played instruments, \iRadio, etc.) were never ins-prefixed in the
// first place, so they're unaffected either way. Trim this list if you
// want to hold some ins slots back for something else.
~strudelVoiceNames = (1..12).collect { |i| ("ins" ++ i).asSymbol };

// Free buses from any previous live re-eval of this file first, so
// re-running it doesn't leak buses or leave old sources pointing at stale
// bus indices.
if(~strudelBuses.notNil) { ~strudelBuses.do(_.free) };
~strudelBuses = ~strudelVoiceNames.collect({ Bus.audio(s, 2) });

~strudelVoiceNames.do({ |name, i|
    Ndef(name)[0] = { In.ar(~strudelBuses[i].index, 2) };
});

fork {
    // Dirt-Samples quark, if ever installed (not currently — see CLAUDE.md/
    // conversation history: skipped as an unnecessary ~450MB download since
    // nvim-strudel fetches its own samples on demand below). Harmless no-op
    // otherwise, just posts a "no folders found" warning.
    ~dirt.loadSoundFiles;

    // nvim-strudel's own on-demand sample cache — populated lazily as you
    // evaluate patterns that reference sample names it hasn't fetched yet.
    ~strudelSamplesPath = Platform.userHomeDir +/+ ".local/share/strudel-samples";
    if(File.exists(~strudelSamplesPath), {
        ~dirt.loadSoundFiles(~strudelSamplesPath +/+ "*");
    });

    s.sync;
    // One orbit per entry in ~strudelBuses, routed to that bus instead of
    // straight to hardware out — see ~strudelVoiceNames above.
    ~dirt.start(57120, ~strudelBuses.collect(_.index));

    // Auto-load hook: if nvim-strudel fetches a NEW sample after this point
    // (one not present in ~strudelSamplesPath at boot time), SuperDirt would
    // otherwise silently fail to find it until the next full reboot. This
    // hook (adapted from StrudelDirt's own scripts/auto-load-samples.scd)
    // retries loading it the first time it's referenced and not found.
    // Uses environment vars (~) rather than `var` since `var` declarations
    // must be the first statements in an enclosing function/block in SC,
    // and this sits after other statements inside the fork block above.
    ~strudelDirtLoadFailed = Set.new;
    ~strudelDirtAutoLoad = { |sound|
        if(~strudelDirtLoadFailed.includes(sound).not) {
            ~strudelDirtLoadFailed.add(sound);
            ~dirt.loadOnly([sound], ~strudelSamplesPath);
            if(~dirt.buffers.at(sound).notNil) { ~strudelDirtLoadFailed.remove(sound) };
        } {
            "[strudel] couldn't load soundfile for %\n".format(sound).postln;
        };
    };
    ~dirt.set(\notFound, { ~strudelDirtAutoLoad.(~s) });

    // ========================================
    // Strudel Soundfont SynthDefs — ported from nvim-strudel's own
    // auto_superdirt launcher (server/src/superdirt-launcher.ts), which we
    // don't use (it runs Server.killAll - see file header). That launcher
    // was the ONLY place these ever got defined, so GM soundfont playback
    // (s("gm_telephone") etc.) was silently missing this whole layer until
    // now - failed with "SynthDef strudel_soundfont_2_2 not found" plus a
    // cascading "Message 'flop' not understood" (2026-09-13). These loop
    // samples + apply ADSR envelope; regular one-shot samples still use
    // StrudelDirt's own default dirt_sample SynthDefs, untouched.
    // ========================================
    (1..SuperDirt.maxSampleNumChannels).do { |sampleNumChannels|
        var name = format("strudel_soundfont_%_%", sampleNumChannels, 2);
        SynthDef(name, { |out, bufnum, sustain = 1, begin = 0, end = 1, speed = 1, endSpeed = 1,
                          freq = 440, pan = 0, sfSustain = 1,
                          sfLoopBegin = 0, sfLoopEnd = 0|
            var sound, rate, phase, numFrames, env, phasorRate;
            var hasLoop, loopStartFrame, loopEndFrame, loopLen;
            var rawPos, loopOffset, modPos;

            numFrames = BufFrames.ir(bufnum).max(1);
            rate = Line.kr(speed, endSpeed, sfSustain);
            phasorRate = rate * BufRateScale.ir(bufnum);

            hasLoop = (sfLoopEnd > sfLoopBegin) * (sfLoopEnd > 0);
            loopStartFrame = sfLoopBegin * numFrames;
            loopEndFrame = sfLoopEnd * numFrames;
            loopLen = (loopEndFrame - loopStartFrame).max(1);

            rawPos = Phasor.ar(0, phasorRate, 0, 1e9, 0);
            loopOffset = (rawPos - loopEndFrame).max(0);
            modPos = loopStartFrame + (loopOffset % loopLen);

            phase = Select.ar(hasLoop, [
                Phasor.ar(0, phasorRate, begin * numFrames, end * numFrames, begin * numFrames),
                Select.ar(rawPos >= loopEndFrame, [rawPos, modPos])
            ]);

            sound = BufRd.ar(
                numChannels: sampleNumChannels,
                bufnum: bufnum,
                phase: phase,
                loop: 0,
                interpolation: 2
            );

            env = EnvGen.kr(Env.new([1, 1], [sfSustain + 0.1], \lin), doneAction: 2);
            sound = sound * env;
            sound = DirtPan.ar(sound, 2, pan) * sqrt(2);

            Out.ar(out, sound)
        }, [\ir, \ir, \ir, \ir, \ir, \ir, \ir, \ir, \kr, \ir, \ir, \ir]).add;
    };

    // SuperDirt's 'sound' module hardcodes the args it passes to sample
    // synths, so our sfLoopBegin/sfLoopEnd never reach the synth otherwise.
    // This diversion intercepts soundfont instruments before 'sound' runs
    // (see orderModules below) and plays them directly with all params.
    ~dirt.addModule('strudel_soundfont_diversion',
        { |dirtEvent|
            if(~instrument.asString.beginsWith("strudel_soundfont") and: { ~buffer.notNil }, {
                var desc = SynthDescLib.global.at(~instrument.asSymbol);
                if(desc.notNil, {
                    ~bufnum = ~buffer;
                    dirtEvent.sendSynth(~instrument, desc.msgFunc.valueEnvir);
                    ~buffer = nil;
                    ~diversion = { true };
                });
            });
        },
        { ~instrument.asString.beginsWith("strudel_soundfont") }
    );

    Spec.add(\sfLoopBegin, [0, 1]);
    Spec.add(\sfLoopEnd, [0, 1]);
    Spec.add(\sfAttack, [0.001, 10, \exp]);
    Spec.add(\sfRelease, [0.001, 10, \exp]);
    Spec.add(\sfSustain, [0.001, 60, \exp]);

    // strudel_soundfont_diversion MUST run before 'sound' - safe to list
    // modules we haven't defined (strudel_tremolo/strudel_filter/
    // strudel_convrev - not ported, no current use case for them): SuperDirt
    // silently drops any name here that isn't a real registered module.
    ~dirt.orderModules([
        'strudel_soundfont_diversion',
        'sound', 'vowel', 'shape', 'hpf', 'bpf', 'crush', 'coarse', 'lpf',
        'pshift', 'envelope', 'grenvelo', 'tremolo', 'phaser', 'waveloss',
        'squiz', 'fshift', 'triode', 'krush', 'octer', 'ring', 'distort',
        'spectral-delay', 'spectral-freeze', 'spectral-comb', 'spectral-smear',
        'spectral-scram', 'spectral-binshift', 'spectral-hbrick', 'spectral-lbrick',
        'spectral-conformer', 'spectral-enhance', 'dj-filter', 'compressor',
        'strudel_tremolo', 'strudel_filter', 'strudel_convrev',
        'out_to', 'map_from'
    ]);

    s.sync;

    // Proactive responder for nvim-strudel's OWN load-confirmation protocol,
    // verbatim from superdirt-launcher.ts (more correct than an earlier,
    // simpler version here: guards against a missing directory, and
    // actually waits with s.sync for the buffer read to finish server-side
    // before confirming - sending the confirmation too early could let the
    // first play attempt race a not-yet-loaded buffer). Whenever nvim-strudel
    // fetches a sample it's never cached before (GM soundfont, drum machine,
    // anything new), it sends this and BLOCKS evaluation for up to 30s
    // waiting for a reply; the installed StrudelDirt quark has no responder
    // for it at all otherwise, so every first-time sample load failed with
    // "did not confirm updated bank ... before evaluation" until this was
    // added (2026-09-13).
    OSCdef(\strudelLoadSamples, { |msg|
        var path = msg[1].asString.standardizePath;
        var replyPort = if(msg[2].notNil, { msg[2].asInteger }, { 0 });
        if(PathName(path).isFolder, {
            fork {
                ~dirt.loadSoundFileFolder(path, PathName(path).fileName);
                s.sync;
                if(replyPort > 0, {
                    NetAddr("127.0.0.1", replyPort).sendMsg('/strudel/samplesLoaded', path);
                });
            };
        }, {
            "Strudel: refusing missing sample-bank directory: %".format(path).warn;
        });
    }, '/strudel/loadSamples');

    // Native panic: free every orbit's synths without depending on a
    // WebAudio context reset. hush() (exposed to your patterns) sends this.
    OSCdef(\strudelHush, {
        ~dirt.orbits.do { |orbit| orbit.freeSynths };
    }, '/strudel/hush');

    ("[strudel] SuperDirt ready on port 57120, % orbits -> %."
        .format(~strudelVoiceNames.size, ~strudelVoiceNames)).postln;
};
)
