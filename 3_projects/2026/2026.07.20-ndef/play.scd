
///////////////////////////////////////////////////////////////////////////////////////////
"load.scd".load;
Ndef(\ins1)[0] = { | amp=1 | Ndef.ar(\kitA, 2) * amp };
Ndef(\ins2)[0] = {|amp=0.75| Ndef(\v1) * amp };
Ndef(\ins3)[0] = {|amp=0.75| Ndef(\b1) * amp };
Ndef(\ins4)[0] = {|amp=0.75| Ndef(\pm1) * amp };
Ndef(\ins4)[1] = {|amp=0.8| Ndef(\pedestrian) * amp };
Ndef(\ins4)[2] = {|amp=0.8| Ndef(\fm1) * amp };

Ndef(\b1).pause;
Ndef(\b1).resume;
Ndef(\fm1).pause;
Ndef(\fm1).resume;
Ndef(\pm1).pause;
Ndef(\pm1).resume;
Ndef(\pedestrian).pause;
Ndef(\pedestrian).resume;
~midiInStopAll.();     // frees the current unfiltered MIDIdefs
~midiInSrcID = MIDIClient.sources.detect { |ep| ep.device.containsi("Deluge") }.uid;
~reconnectMidi.()

Ndef(\v1).set(\wet3,  0.5);
Ndef(\v1).pause;
Ndef(\v1).resume;
Scale.directory
~startDelugeClock.();
~link.tempo * 60
~midiInMap.(6, \bass8,   out: Ndef(\ins3).index);

Ndef(\lfo1, {LFPulse.ar(1.5) + SinOsc.ar(1)});

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
(
Ndef(\fxsGreyhole).set(
  \delayTime,  0.25, 
  \size,  0.8, 
  \damp,  0.1,  
  \diff,  0.7,  
  \feedback, 0.5,  
  \modDepth,  0.5,  
  \modFreq, 4.0,  
  \mix, 0.8,  
);
)

~apcBindParam.(\b0_ds1_k1, { |x| Ndef(\fxsBitcrush).set(\wet4,  x)});
Ndef(\kitA).map(\modFreq,  { 1/ Ndef(\lfo1,  1).max(0.1) });
Ndef(\kitA).map(\size,  Ndef(\lfo1));
Ndef(\kitA).map(\diff,  Ndef(\lfo1));

Ndef(\impact).set(\rate, 1); 
Ndef(\hh1).set(\rate, 8); 
Ndef(\kk1).set(\rate, 1); 
Ndef(\kk1).unmap(\rate, { Ndef.ar(\brate,  1) });
(
Ndef(\kk1)[1] = \pset -> Pbind(
  \dur,  1/2, 
  \rate,  Pseq((-2..2),  inf), 
  \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
);
)
Ndef(\kk1)[1] = nil;

Ndef(\kitA).set(\wet7, 0.0);

Ndef(\impact).pause;
Ndef(\impact).resume;
Ndef(\impact).clear;

Ndef(\hh1).pause;
Ndef(\hh1).resume;
Ndef(\hh1).clear;

Ndef(\kk1).pause;
Ndef(\kk1).resume;
Ndef(\kk1).clear;

Ndef(\kitA).pause;
Ndef(\kitA).resume;
Ndef(\kitA).clear;

Ndef(\pmBell).set(\trigRate, 20);
Ndef(\pmBell).set(\wet1, 0.0);
Ndef(\pmBell).play;
Ndef(\pmBell).clear;
Ndef(\pmBell).stop;
Ndef(\pmBell).set(\t_trig, 0); // retriggers the perc envelope every time

Ndef(\fxsBitcrush).set(\brate, 14000, \bits, 8, \mix, 1);
Ndef(\fxsBiscuit).set(\clock, 8000, \bits,  6,  \fxMode,  1,  \shape, 3);
Ndef(\fxsBiscuit)[1] = \pset -> Pbind(\dur, 1/8,  \bits,  Pseg((4..8), [4], \lin, inf));
Ndef(\fxsBiscuit)[1] = nil;
~fxSetSend.(\ins1,  \s1,  1.0);
~fxSetSend.(\ins2,  \s1,  1.0);
~fxSetSend.(\ins3,  \s1,  0.9);
~fxSetSend.(\ins4,  \s1,  0.5);
~fxSetSend.(\ins1,  \s2,  0.0);
~fxSetSend.(\ins2,  \s2,  0.0);
~fxSetSend.(\ins3,  \s2,  0.0);
~fxSetSend.(\ins4,  \s2,  0.0);
Ndef(\brate,   { SinOsc.ar(0.5) });
Ndef(\fxsBitcrush).unmap(\brate, { Ndef.kr(\brate, 1).range(10, 100) });
(
~stemStop = ~stemDiskStart.(
    tracks:  [
      ~ndefAsChan.(Ndef(\impact)),  
      ~ndefAsChan.(Ndef(\hh1)),  
      ~ndefAsChan.(Ndef(\kk1)),  
      ~ndefAsChan.(Ndef(\ins1)),  
    ],    // MixerChannels to record
    returns: [
      ~ndefAsChan.(Ndef(\fxsBitcrush)),  
    ],               // return channels
    fileBase: "2026.07.20",                   // filename prefix
    dirPath: "~/Music/recordings",     // output directory (auto-created)
    clock: ~link,                      // for beat-synced start (nil = default)
    autoSplit: true,                   // auto-split interleaved WAV into stems via ffmpeg
    splitCodec: \pcm_s24le,            // codec for split files
    captureHistory: true,              // saves jam_<timestamp>.history.scd (live code log)
    captureMidi: true                  // saves jam_<timestamp>.mid (one track per stem)
);
)
// --- Stop recording (scheduled, on beat) ---
~stemStop.(beats: 4);                 // stop 4 beats from now

// --- Stop immediately ---
~stemStopNow.();

History.loadStory("/Users/isaaclinder/Music/recordings/2026.07.20_2026-07-26_07-14-28/2026.07.20_2026-07-26_07-14-28.history.scd")
History.play
History.stop
