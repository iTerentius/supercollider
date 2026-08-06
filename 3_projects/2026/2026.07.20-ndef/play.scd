
///////////////////////////////////////////////////////////////////////////////////////////
"load.scd".loadRelative;
Ndef(\ins1)[0] = { | amp=1 | Ndef.ar(\kitA, 2) * amp };
Ndef(\ins2)[0] = {|amp=0.75| Ndef(\v1) * amp };
Ndef(\ins3)[0] = {|amp=0.75| Ndef(\b1) * amp };
Ndef(\ins4)[0] = {|amp=0.75| Ndef(\pm1) * amp };
Ndef(\ins4)[1] = {|amp=0.6| Ndef(\pedestrian) * amp };
Ndef(\ins4)[2] = {|amp=0.6| Ndef(\fm1) * amp };

~startDelugeClock.();
~link.tempo * 60
~midiInMap.(2, \bass8,   out: Ndef(\ins3).index);
~midiInMap.(3, \t1002,   out: Ndef(\ins4).index);

~fxSetSend.(\ins1,  \s1,  0.0);
~fxSetSend.(\ins2,  \s1,  1.0);
~fxSetSend.(\ins3,  \s1,  0.9);
~fxSetSend.(\ins4,  \s1,  0.8);

~fxSetSend.(\ins1,  \s2,  1.0);
~fxSetSend.(\ins2,  \s2,  0.5);
~fxSetSend.(\ins3,  \s2,  0.3);
~fxSetSend.(\ins4,  \s2,  0.0);

~fxSetSend.(\ins1,  \s3,  0.9);
~fxSetSend.(\ins2,  \s3,  0.5);
~fxSetSend.(\ins3,  \s3,  0.0);
~fxSetSend.(\ins4,  \s3,  0.0);

~fxSetSend.(\ins1,  \s4,  1.0);
~fxSetSend.(\ins2,  \s4,  0.5);
~fxSetSend.(\ins3,  \s4,  1.5);
~fxSetSend.(\ins4,  \s4,  1.0);
~fxRoute.(\fxsDistort, \fxsGreyhole,  1.0);
~fxUnroute.(\fxsDistort, \fxsGreyhole,  0.7);

Ndef(\lfo2, { LFPulse.ar(0.025)});

Ndef(\fxsMod).set(\rate,  0.25,  \depth, 0.005);
Ndef(\fxsGlitch).set(\rate, 8,  \mix, 1,   \amp,  2);
Ndef(\fxsGlitch).map(\freeze, Ndef(\lfo2));
Ndef(\b1).pause(3);
Ndef(\b1).resume;
Ndef(\fm1).pause(3);
Ndef(\fm1).resume;
Ndef(\v1).pause(3);
Ndef(\v1).resume;
Ndef(\pm1).pause;
Ndef(\pm1).resume;
Ndef(\pedestrian).pause(3);
Ndef(\pedestrian).resume;
~midiInStopAll.();     // frees the current unfiltered MIDIdefs
~midiInSrcID = MIDIClient.sources.detect { |ep| ep.device.containsi("Deluge") }.uid;
~reconnectMidi.()

Ndef(\v1).set(\wet3,  1.0,  \shift, 12, \time,  0.5,  \mix, 1,  \rmfreq,  800);
Ndef(\v1)[5] = \pset -> Pbind(\dur, 1,  \rmfreq,  Pseq([110,  220,  440], inf));
Ndef(\v1)[3] = nil;
Ndef(\v1).clear;
Ndef(\v1).pause;
Ndef(\v1).resume;
Scale.directory
~startDelugeClock.();
~link.tempo * 60
~midiInMap.(6, \bass8,   out: Ndef(\ins3).index);

Ndef(\lfo1, {LFSaw.ar(0.25)});

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
(
Ndef(\fxsGreyhole).set(
  \delayTime,  0.25, 
  \size,  0.8, 
  \damp,  0.5,  
  \diff,  0.8,  
  \feedback, 0.5,  
  \modDepth,  0.5,  
  \modFreq, 1.0,  
  \mix, 0.8,  
);
)
Ndef(\fxsGreyhole).clear;

Ndef(\fxsGreyhole).map(\modFreq,  { Ndef.kr(\lfo1).range(0.01,  2.0)});
Ndef(\fxsGreyhole).map(\size,  Ndef(\lfo1));
Ndef(\fxsGreyhold).map(\diff,  1/Ndef(\lfo1));

Ndef(\impact).set(\rate, 1); 
Ndef(\hh1).xset(\rate, 8); 
Ndef(\kk1).set(\rate, 1); 
Ndef(\kk1).unmap(\rate, { Ndef.ar(\brate,  1) });
(
Ndef(\kk1)[1] = \pset -> Pbind(
  \dur,  1, 
  \rate,  Pseq((-2..2),  inf), 
  // \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
);
Ndef(\impact)[1] = \pset -> Pbind(
  \dur,  1, 
  \rate,  Pseq((-2..2),  inf), 
  // \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
);
)
Ndef(\kk1)[1] = nil;
Ndef(\impact)[1] = nil;

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

Ndef(\fxsDistort).set(\brate, 1400, \bbits, 6, \bits, 6, \clock,  10000, \bmix, 0.0,  \wfmix, 1.0,  \gain,  2,  \naked, 1,   \dressed,  1);
Pdefn(\slow,  2);
Ndef(\fxsDistort).set(\clock, 8000, \bits,  6,  \fxMode,  1,  \shape, 3);
Ndef(\fxsDistort).clear;
~fxInit.();
~fxState[\tracks];
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
