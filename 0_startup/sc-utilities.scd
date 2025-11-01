// **************************************************************** //
// RECORDING
// **************************************************************** //

// --- ddwMixerChannel Stem Recording --- //
~stopStems = ~stemDiskStart.(
  [~t2, ~t3, ~t4],   // track stems (dry)
  [~r1],            // return stem (this is the reverb bus)
  "songB"           // file base name
);

// when you want to stop, on a musical offset
~stopStems.(1);
// or manual immediate stop at any time
~stemStopNow.();

// --- Normal Output Quant Recording (needs include enabled) --- //
(
~prepRecord = {
  ~recPath = Platform.userHomeDir +/+ "Music/SuperCollider\ Recordings";
  // ~recPath = Platform.userHomeDir +/+ "/Volumes/Hypostatic\ Work/Hypostatic\ Sound/sc_recordings/";
  ~recFileName = "jam";
  ~recChannels = 4;
}
// Example (using your ~vars set above):

// start on the next bar; stop manually whenever you want
~quantRecord.(nil, ~recChannels, ~recPath, ~recFileName);
) 

s.stopRecording; // stop recording


// **************************************************************** //
// MIDI DEVICE BINDING
// **************************************************************** //

// map a couple pads to patterns
Pdef(\kick2, Pbind(\instrument, \default, \degree, 0, \dur, 0.25, \amp, 0.15, \out, ~t1.inbus.index));
Pdef(\hat2,  Pbind(\instrument, \default, \degree, 7, \dur, 0.125, \amp, 0.12, \out, ~t2.inbus.index));

// --- APC40mkII --- //
~apcBindParam.(\b1_s1_r1, {|x| ("[APC] \b1_s1_r1: "++x).postln;});
~apcBindParam.(\b1_d2, {|x| ("[APC] \b1_d2: "++x).postln;});
~apcBindParam.(\b1_s1_f, {|x| ("[APC] \b1_s1_f: "++x).postln;});
~apcAssignPad.(32, \kick2);

// --- LC/LCXL --- //
~lcn[\b1_s1_r2] = { |val| ("LC strip 1, row2: %\n".format(val)).post };
~lcxlParam[\b3_s5_r3] = { |val| ("LCXL b3_s5_r3: %\n".format(val)).post };
~lcxlParam[\b1_s1_f] = { |val| ("LCXL b1_s1_f: %\n".format(val)).post };
~lcxlBindPdef.(\b1_s3_p, \kick2);  // maps bank 0, button 3 to Pdef(\drums)


// **************************************************************** //
// SAMPLE LOADING & USAGE
// **************************************************************** //
~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Neutron_12/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Hoarder/hoarder/");

~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/AKWF/AKWF_0001/");
~loadSamplesRecursive.("~/Music/supercollider/_samples/Cat-Water/");

~samp = ~samplesTree[\bass_drums][\SHD_808BD_03];
~samp = ~samplesTree[\field][\cat_food];
~samp = ~samplesTree[\neutron_12][\121];
~samples = ~samplesTree.at(\neutron_12);
~samples = ~samplesTree.at(\hoarder);
~samples = ~samplesTree.at(\bass_drums);
~samples = ~samplesTree.at(\cat_water);
~samples = ~samplesTree.at(\akwf_0001);
~samples.postln; 

// --- Pdef with multiple samples --- //
~loadSamplesRecursive.("~/Music/supercollider/_samples/808s_by_SHD/808_kit/");
(
~bd1 = ~samplesTree.at(\bass_drums).asArray;
Pdef(\bd1).quant = 1;
Pdef(\bd1,
    ~pBuf.(
        Pbind(
            \buf,   Prand(~bd1, inf),          // your Buffer object
            \bufnum, Pkey(\buf),   // SC uses the Buffer’s bufnum
            \dur,    Pbjorklund2(3, 8)/4,
            \amp,   2.0,
            \rate,  1,
            \out,   ~pbd1.inbus.index
        )
    )
);
~apcAssignPad.(32, \bd1);
~lcxlBindPdef.(\b0_s1_p, \bd1);
)
Pdef(\bd1).play;
Pdef(\bd1).stop(3);
Pdef(\bd1).clear;

// --- Pdef End --- //

// **************************************************************** //
// MIXER CHANNEL SETUP
// **************************************************************** //

// Set up main channels (see mixer-channel-16s.scd)

// Channel to Send (~r1 is Reverb, ~t2 is Delay)
~yesorno_reverb = ~t5.newPostSend(~r1, 1.0);
~yesorno_reverb.free; // <-- Important to do before changing the above

~yesorno_delay = ~t5.newPostSend(~r2, 1.0);
~yesorno_delay.free;

~perc_reverb = ~perc.newPostSend(~r1, 0.5);
~perc_reverb.free;

// They don't take effect until you set the mix level
~r1.level_(0.3);
~r2.level_(0.5);

// This uses the handel var assigned to ~r2 to set params (might be possible to set on ~r2 as well)
~r2_fx.set(\mdt, 1,\dlt, 1, \dct, 1);
// Change the send amount
~perc_reverb.level_(0.5);

// Adding an inline fx insert
(
~t5_fx.free;
~t5_fx = ~t5.playfx{ | outbus, bot=30, wet=0.5|
  var sig = In.ar(outbus, 2);
  sig * Pulse.ar(bot) * wet;
};
)

Ndef(\mod_bot).fadeTime = 3;
Ndef(\mod_bot, {SinOsc.ar(0.5).range(20, 100)});
~t5_fx.set(\bot, Ndef(\mod_bot));
~t5_fx.set(\wet, 1.4);

(
~r4.playfx(\slice_s, [
    \bufSecs, 2,     // length of rolling buffer in seconds
    \nSlices, 64,     // number of slices across that window
    \mix, 1,         // 0 dry  1 wet
    \spread, 0.5,    // alternating pan offset
    \rate, 0.5,        // playback rate per slice
    \rev, 0,         // 0 forward  1 reverse
    \pan, 0,
    \amp, 1
]);
)

~perc_slice = ~t1.newPostSend(~r4, 1.0);
~perc_slice.free;
~r4.level_(1.0);
~perc_slice.level_(1);
~r1.set(\room, 0.1);
~slice_idx.set(0);
~slice_rev.set(0);      // 0 or 1
~slice_sp.set(0.5);     // spread amount
~slice_rate.set(0.5);
~slice_mix.set(1);
~slice_pan.set(0);

// --- Ndefs to mixer-channel-16s
// make sure your Ndef is audio-rate
Ndef(\droneA, {|mod=1, freq=200, amp=0.2, in=0| SinOsc.ar([freq+(mod*0.2), freq+(mod*0.1)], 0, PinkNoise.ar(mod * 0.2)) * amp ! 2 });   // stereo at audio rate
~apcBindParam.(\b0_d1, {|x| Ndef(\droneA).set(\mod, x.linlin(0, 1, 50, 200))});
~lcxlBindParam.(\b1_s2_r1, {|x| Ndef(\droneA).set(\mod, x.linlin(0, 127, 50, 200))});
~lcxlParam[\b1_s2_r1] = {|x| Ndef(\droneA).set(\mod, x.linlin(0, 127, 50, 200))};
Ndef(\droneA).set(\mod, 50);
~droneA_verb = ~r1.newPostSend(~t2, 1.0);
~droneA_delay = ~r2.newPostSend(~t2, 1.0);
// attach
~ndefAttachToChan.(\droneA, ~t2, 2);
Ndef(\sin, {|x=110| SinOsc.ar(x)!2});
~ndefAttachToChan.(\sin, ~t3, 2);
~lcxlParam[\b1_s3_r1] = {|x| Ndef(\sin).set(\x, x.linlin(0, 127, 100, 1400))}
// detach later
~ndefDetach.(\droneA);

// This also works but Ndef needs to be cleared or won't play again
Ndef(\mySine, {
    var freq = MouseX.kr(100, 1000, 1);
    var pan = MouseY.kr(-1, 1, 1);
    Pan2.ar(SinOsc.ar(freq, 0, 0.2), pan);
});
)
Ndef(\mySine).clear;
// 4. Play the Ndef through the ddwMixerChannel
~t1.play(Ndef(\mySine));
~t1.stop(Ndef(\mySine)); // doesn't work

// 5. Control the mixer channel (adjust volume, pan, etc.)
~t1.level = 0.5;
~t1.pan = -0.8;
(
// 6. Stop and free everything when finished
CmdPeriod.doOnce({
    // ~t1.free;
    Ndef(\mySine).clear;
});
)

