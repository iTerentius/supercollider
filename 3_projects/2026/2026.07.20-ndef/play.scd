
///////////////////////////////////////////////////////////////////////////////////////////
"load.scd".loadRelative;
Ndef(\ins1)[0] = { | amp=1 | Ndef.ar(\kitA, 2) * amp };
Ndef(\ins2)[0] = {|amp=0.75| Ndef(\v1) * amp };
Ndef(\ins3)[0] = {|amp=0.45| Ndef(\b1) * amp };
Ndef(\ins4)[0] = {|amp=0.75| Ndef(\pm1) * amp };
Ndef(\ins4)[1] = {|amp=0.6| Ndef(\pedestrian) * amp };
Ndef(\ins4)[2] = {|amp=0.6| Ndef.ar(\fm1, 2) * amp };
Ndef(\ins4)[3] = {|amp=0.1| Ndef.ar(\iRadio, 2) * amp };
Ndef(\ins5)[0] = {|amp=1.9| Ndef(\midiV3) * amp };
~insSlotsClear.();
~insSlotsCheck.();

(
Ndef(\iRadio).set(\amp, 0.1,  \mute,  0);
Ndef(\iRadio)[4] = \filter -> {|in| ~fxg[\glitch].(in,  5)};
Ndef(\iRadio)[5] = \filter -> {|in| ~fxg[\shimmer].(in, 2)};
// Ndef(\iRadio)[6] = \filter -> {|in| ~fxg[\stutter].(in, 2, 0.7,  1)};
Ndef(\iRadio)[4] = nil;
// Ndef(\iRadio)[4] = \filter -> {|in| In.ar(in) * SinOsc.ar(1,  add:2pi)};
Ndef(\iRadio)[7] = \filter -> { |in | ~fxg[\duck].(in, Ndef.ar(\ins1), threshold: 0.7, ratio:2, release:0.3,  makeup:1.3 );  };
)
~radioSwap.("http://npr-ice.streamguys1.com/live.mp3")
~radioSwap.("https://www.youtube.com/watch?v=Vfpas9Fn24Q&t=1s")
Ndef(\iRadio)[4] = nil;
Ndef(\kitA)[0] = nil;
Ndef(\iRadio).set(\wet1,  1);

~startDelugeClock.();
~stopDelugeClock.();
~link.tempo * 60
~link.tempo = 100/60;
~midiInMap.(2, \bass8,   out: Ndef(\ins3).index,  args:[\amp, 0.45]);
~midiInMap.(4, \fmSaw,   out: Ndef(\ins4).index); 
~midiInMap.(5, \pm1,   out: Ndef(\ins4).index); 
~midiInMap.(5, \fm3,   out: Ndef(\ins4).index); 
~midiInMap.(5, \v1,   out: Ndef(\ins2).index);
~midiBus3 = Bus.audio(s,  2); 
~midiInMap.(3, \stretchedFragments,   out: ~midiBus3.index); 
Ndef(\midiV3)[0] = { | amp=1.5 | In.ar(~midiBus3.index, 2) * amp };
// Ndef(\midiV3)[1] = \filter -> { |in | ~fxg[\duck].(in, Ndef.ar(\kitA), 0.1, ratio:2, release:0.3,  makeup:1.3 );  };
Ndef(\midiV3)[1] = \filter -> { |in | ~fxg[\duck].(in, Ndef.ar(\ins1), threshold: 0.4, ratio:3, release:0.1,  makeup:1.3 );  };
Ndef(\ins5)[1] = \filter -> { |in | ~fxg[\duck].(in, Ndef.ar(\ins1), threshold: 0.7, ratio:2, release:0.3,  makeup:1.3 );  };
Ndef(\midiV3)[2] = \filter -> { |in | ~fxg[\shimmer].(in, \shift.kr(12));  };
Ndef(\midiV3).set(\wet2,  0.3);
Ndef(\midiV3)[1] = nil;
Ndef(\ins5)[1] = nil;
Ndef.gui(s);
NdefMixer(s).front;
(
~midiInPsetStop.(3);
~midiInPset.(3, [\buf,  \stret, \time,  \amp], Pbind(
  \buf, Pseq(~sTree[\jttcot].values, inf), 
  \stret, Pseq([2,  1,  4].scramble, inf),
  // \stretch, 4,  
  \time,    Pseq([4,  2,  1].scramble, inf),
  // \time,  4,  
  \dur,     1/4,  
  \amp, 1.5,  
));
)

~fxSetSend.(\ins1,  \s1,  0.4);
~fxSetSend.(\ins2,  \s1,  1.0);
~fxSetSend.(\ins3,  \s1,  0.9);
~fxSetSend.(\ins4,  \s1,  0.8);
~fxSetSend.(\ins5,  \s1,  0.8);

~fxSetSend.(\ins1,  \s2,  0.9);
~fxSetSend.(\ins2,  \s2,  0.5);
~fxSetSend.(\ins3,  \s2,  0.3);
~fxSetSend.(\ins4,  \s2,  0.9);
~fxSetSend.(\ins5,  \s2,  0.9);

~fxSetSend.(\ins1,  \s3,  0.0);
~fxSetSend.(\ins2,  \s3,  0.5);
~fxSetSend.(\ins3,  \s3,  0.0);
~fxSetSend.(\ins4,  \s3,  0.3);
~fxSetSend.(\ins5,  \s3,  1.0);

~fxSetSend.(\ins1,  \s4,  1.0);
~fxSetSend.(\ins2,  \s4,  0.5);
~fxSetSend.(\ins3,  \s4,  1.5);
~fxSetSend.(\ins4,  \s4,  1.0);
~fxSetSend.(\ins5,  \s4,  1.0);
~fxUnsetSend.(\kk1,  \s3,  0.2);
~fxRoute.(\fxsDistort, \fxsGreyhole,  1.0);
~fxUnroute.(\fxsDistort, \fxsGreyhole,  0.7);


Pbindef(\impact,  \dur, 1,  \nSlices, 32);
Pbindef(\hh1,  \dur, 1/4* Pdefn(\slow), \stretch, 1);
Pbindef(\kk1,  \dur, 1/2 * Pdefn(\slow), \stretch, 1);

// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~
(
Ndef(\fxsGreyhole).set(
  \delayTime,  0.5, 
  \size,  0.4, 
  \damp,  0.0,  
  \diff,  0.2,  
  \feedback, 0.5,  
  \modDepth,  0.8,  
  \modFreq, 0.5,  
  \mix, 1.0,  
);
)
Ndef(\lfo1, {LFSaw.ar(0.25)});
Ndef(\fxsGreyhole).map(\modFreq,  { Ndef.kr(\lfo1).range(0.01,  2.0)});
Ndef(\fxsGreyhole).map(\size,  Ndef(\lfo1));
Ndef(\fxsGreyhole).map(\diff,  Ndef(\lfo1));

(
Ndef(\lfoRate, {
  LFPulse.ar(1/16 + SinOsc.ar(8, 0.5),  2)
});
)

Ndef(\lfo2, { LFPulse.ar(0.025)});

(
Ndef(\fxsMod).set(\rate,  0.25,  \depth, 0.005);
Ndef(\fxsGlitch).set(\rate, 8,  \mix, 1,   \amp,  2);
Ndef(\fxsGlitch).map(\freeze, Ndef(\lfo2));
)

Ndef(\fxsDistort).xset(\brate, 11400, \bbits, 8, \bits, 6, \clock,  18000, \bmix, 0.8,  \wfmix, 1.0,  \shape,  3, \fxMode, 2,   \gain,  2,  \naked, 1,   \dressed,  1);
Ndef(\fxsDistort).xset(\clock, 8000, \bits,  6,  \fxMode,  1,  \shape, 3);
Ndef(\fxsDistort).clear;

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



Ndef(\impact).set(\rate, 1); 
Ndef(\hh1).map(\rate,  Ndef(\lfoRate)); 
Ndef(\hh1).set(\rate,  3); 
Ndef(\kk1).set(\rate, 1); 
Ndef(\kk1).unmap(\rate, { Ndef.ar(\brate,  1) });
(
Ndef(\kk1)[1] = \pset -> Pbindef(\kk1,  
  \dur,  1, 
  \rate,  Pseq((-2..2),  inf), 
  \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
);
Ndef(\impact)[1] = \pset -> Pbindef(\impact,  
  \dur,  1, 
  \rate,  Pseq((-2..2),  inf), 
  // \stretch, Pseq([1/4!3,   3.25].flat,   inf),  
  \stretch, 4,  
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


Pdefn(\slow,  4);
Pdefn(\slow,  Pseq([1,  2,  4], inf));
~fxInit.();
~fxState[\tracks];
(
~insSlotsCheck.();
~stemStop = ~stemDiskStart.(
    tracks:  [
      ~ndefAsChan.(Ndef(\impact)),  
      ~ndefAsChan.(Ndef(\hh1)),  
      ~ndefAsChan.(Ndef(\kk1)),  
      ~ndefAsChan.(Ndef(\ins1)),  
      ~ndefAsChan.(Ndef(\ins2)),  
      ~ndefAsChan.(Ndef(\ins3)),  
      ~ndefAsChan.(Ndef(\ins4)),  
      ~ndefAsChan.(Ndef(\ins5)),  
    ],    // MixerChannels to record
    returns: [
      ~ndefAsChan.(Ndef(\fxsBitcrush)),  
      ~ndefAsChan.(Ndef(\fxsDistort)),  
      ~ndefAsChan.(Ndef(\fxsGreyhole)),  
      ~ndefAsChan.(Ndef(\fxsMod)),  
      ~ndefAsChan.(Ndef(\fxsGlitch)),  
    ],               // return channels
    fileBase: "2026.07.20-b",                   // filename prefix
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

History.loadStory("/Users/isaaclinder/Music/recordings/2026.07.20_2026-07-26_07-14-28/2026.07.20-b_2026-08-22_22-39-20.history.scd")
History.play
History.stop
