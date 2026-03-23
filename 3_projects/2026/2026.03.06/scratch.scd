// Scratch
(
~m1_ilfx_1.free;
~m1_ilfx_1 = ~m1.playfx({|in|
    var sig = In.ar(~m1.inbus, 2);
    var mod = \mod.kr(1);
    var mix = \mix.kr(0);      // 0 = dry, 1 = wet
    var amp = \amp.kr(1);
    var gate = K2A.ar(LFPulse.kr(mod).lag(0.005));
    var wet = gate * sig;
    XFade2.ar(sig, wet, mix.linlin(0, 1, -1, 1)) * amp;
});
)
~m1_ilfx_1.set(\level,  0);
(
Pdef(\modCtl, Pbind(
  \type,   \set,  
  \id,   ~m1_ilfx_1.nodeID,  
  \args,  #[\mod, \width, \mix, \amp],  
  \mod, Pser((10..30), inf),
  \width,  Pseg([0.1, 1.0,  0.1],[2,  4], \sin, inf ),  
  \amp,  1, 
  \mix, Pseg([0.0,  0.5,  1.0], [2, 4],  \sin, inf),  
  // \mix,  0, 
  // \delta, 1/4,  
  \dur,  1/32, 
));
)
Pdef(\modCtl).play;
Pdef(\modCtl).stop;

// Create a control bus
~lfoBus = Bus.control(s, 1);

// LFO synth — runs before the target synth in node order
~lfoSynth = {
    arg rate = 0.5, lo = 400, hi = 600;
    Out.kr(~lfoBus, LFTri.kr(rate).range(lo, hi));
}.play(s, addAction: \addToHead);

// Target synth reads from the bus via `In.kr`
SynthDef(\bussedSynth, {
    arg freqBus = 0;
    var freq = In.kr(freqBus);
    var sig = SinOsc.ar(freq);
    Out.ar(0, sig * 0.2 ! 2);
}).add;

~targetSynth = Synth(\bussedSynth, [\freqBus, ~lfoBus]);

~bd1_ilfx_1.set(\lpfreq,  1000,  \rq, 2.0,  \hpfreq,  500,  \hprq,  2.0);
// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~

(
~m1_revs_fx.free;
~m1_revs_fx = ~m1.playfx({|in|
  var sig = In.ar(~m1.inbus,  2);
  var wet = Greyhole.ar(
    in:  sig,
    delayTime: 2.5,  
    damp:  0.0,  
    size:  3.0,  
    diff:  0.707,  
    feedback:  0.1,  
    modDepth:  0.1,  
    modFreq: 2.0,  
  );
  wet;
});)
~bd1_revs_fx.level_(0.5);

OSCFunc.trace(true)
OSCFunc.trace(false)

~catDate = "AAA-" ++ Date.localtime.format("%Y%m%d_%H%M%S");
~catDate.postln;

(
var savedDateStr = Date.localtime.format("%Y%m%d_%H%M%S").postcs;
var loadedDate = Date.fromString(savedDateStr, "%Y%m%d_%H%M%S").postln;
)
~toscSync.();
~toscStateSave.(("2026_03_06_" ++ Date.localtime.format()).asSymbol);
~toscPadPaintAll.();
  ~toscPads.size.postln;         // should be non-zero      
  ~toscPadPaintAll.();           // manually trigger repaint
    ~toscAddr = NetAddr("127.0.0.1", 9000);                   
  ~toscPadPaintAll.();                                                    

  ~toscAddr.sendMsg("/tosc/p1/1/1/color", 1.0, 0.0, 0.0, 1.0);
  ~toscAddr.sendMsg("/tosc/pad/state", 1, 1, 1, 0.0, 1.0, 0.0, 1.0);
  
  ~toscAddr.sendMsg("/tosc/p1/1/col1/color", 0.0, 1.0, 0.0, 1.0);
  ~toscAddr.sendMsg("/tosc/p1/1/col1/state", 1.0);  // should turn green
  ~toscAddr.sendMsg("/tosc/p1/1/col1/state", 0.0);  // should restore orange
    OSCdef(\toscDebug, { |msg| ("TOSC fired: " ++ msg).postln }, '/tosc/debug');
  ~toscAddr.sendMsg("/tosc/p1/1/col1/state", 1.0);
  ~toscAddr.sendMsg("/tosc/p1/1/col1/label", "bd1");

  // Set the slot label                                                                       
  ~toscFXLabel.(1, 1, "greyhole");                                                            
                                                                                              
  // Bind knobs (r1-r8), val is 0.0-1.0                                                       
  ~toscFXBind.(1, 1, \r1, { |v| Ndef(\verb).set(\mix,    v) }, "mix");                        
  ~toscFXBind.(1, 1, \r2, { |v| Ndef(\verb).set(\decay,  v.linlin(0,1, 0.1, 60)) }, "decay");
  ~toscFXBind.(1, 1, \r3, { |v| Ndef(\verb).set(\size,   v) }, "size");                       
                                                                                              
  // Bind fader                                                                               
  ~toscFXBind.(1, 1, \f,  { |v| Ndef(\verb).set(\amp, v) }, nil);                             
                                                                                              
  // Bind XY pad                                                                              
  ~toscFXBindXY.(1, 1, 1,
      { |v| Ndef(\verb).set(\diff, v) },    // x axis                                         
      { |v| Ndef(\verb).set(\damp, v) },    // y axis                                         
      "diff-damp"                                                                             
  );                                                                                          
                                                                                              
  // Bind toggle                                            
  ~toscFXBind.(1, 1, \t1, { |v| Ndef(\verb).set(\freeze, v.round) }, "freeze");               
                                                                               
  // Push initial values to TOSC (visual sync)                                                
  ~toscFXSync.(1, 1, \r1, 0.5);                                                               
  ~toscFXSync.(1, 1, \r2, 0.3);                                                               
  ~toscFXSync.(1, 1, \f,  0.8);                                                               
  ~toscFXSyncXY.(1, 1, 1, 0.5, 0.5);                                                          

  Ndef(\test, { |freq = 800, rq = 0.3, amp = 0.4, pan = 0, mute = 1|                          
      var sig = BPF.ar(WhiteNoise.ar(1), freq, rq) * 8;                                       
      sig = sig * Lag.kr(mute, 0.05);                                                         
      Pan2.ar(sig, pan, amp);                                                                 
  }).play;                                                                                    
                                                                                              
  ~toscFXLabel.(1, 1, "test filter");                                                         
  ~toscFXBind.(1, 1, \r1, { |v| Ndef(\test).set(\freq, v.linexp(0,1, 100, 8000)) }, "freq");  
  ~toscFXBind.(1, 1, \r2, { |v| Ndef(\test).set(\rq,   v.linlin(0,1, 0.02, 1.0)) }, "rq");    
  ~toscFXBind.(1, 1, \r3, { |v| Ndef(\test).set(\amp,  v) }, "amp");                          
  ~toscFXBindXY.(1, 1, 1,                                                                     
      { |v| Ndef(\test).set(\pan,  v.linlin(0,1, -1, 1)) },                                   
      { |v| Ndef(\test).set(\freq, v.linexp(0,1, 100, 8000)) },                               
      "pan|freq"                                                                              
  );                                                                                          
  ~toscFXBind.(1, 1, \t1, { |v| Ndef(\test).set(\mute, v.round) }, "mute");                   
  ~toscFXBind.(1, 1, \f,  { |v| Ndef(\test).set(\amp,  v) }, nil);                            
                                                                                              
  ~toscFXSync.(1, 1, \r1, 0.4);                                                               
  ~toscFXSync.(1, 1, \r2, 0.29);                                                              
  ~toscFXSync.(1, 1, \r3, 0.4);                                                               
  ~toscFXSyncXY.(1, 1, 1, 0.5, 0.4);                                                          
  ~toscFXSync.(1, 1, \t1, 1.0);                                                               
  ~toscFXSync.(1, 1, \f,  0.4);                                                               
  (                                                                                           
  ~toscFXLabel.(1, 1, "GREYHOLE");                                                         
                                                                                              
  ~toscFXBind.(1, 1, \r1, { |v| "r1: %".format(v).postln }, "r1");                            
  ~toscFXBind.(1, 1, \r2, { |v| "r2: %".format(v).postln }, "r2");                            
  ~toscFXBind.(1, 1, \r3, { |v| "r3: %".format(v).postln }, "r3");                            
                                                                                              
  ~toscFXBindXY.(1, 1, 1,                                                                     
      { |v| "xy1 x: %".format(v).postln },                                                    
      { |v| "xy1 y: %".format(v).postln },                                                    
      "xy1"                                                                                   
  );                                                                                          
                                                                                              
  ~toscFXBind.(1, 1, \t1, { |v| "t1: %".format(v).postln }, "t1");                            
  ~toscFXBind.(1, 1, \f,  { |v| "f: %".format(v).postln },  "f");
  )                                                                                           
  OSCFunc({ |msg| ("key=x val=" ++ msg[1]).postln }, '/test');  
  thisProcess.addOSCRecvFunc({ |msg, time, addr| [msg, addr].postln });    
  // === DIAGNOSTIC ===
  (
  "--- LP Mini ---".postln;
  ("~lpMini notNil: " ++ ~lpMini.notNil).postln;
  ("~lpMini[\\uid]: " ++ ~lpMini[\uid]).postln;
  ("lpMini_note MIDIdef: " ++ MIDIdef.all[\lpMini_note]).postln;
  ("bindings size: " ++ ~lpMini[\bindings].size).postln;
  ("bank 1 bindings: " ++ ~lpMini[\banks][0].keys).postln;

  "--- TOSC ---".postln;
  ("~toscPads size: " ++ ~toscPads.size).postln;
  ("~oscParam size: " ++ ~oscParam.size).postln;
  ("~toscAddr: " ++ ~toscAddr).postln;
  ("'tosc/p1/1/1' in oscParam: " ++
  ~oscParam['tosc/p1/1/1'].notNil).postln;
  )

  MIDIdef(\devSubProbe, { |vel,num,chan|                    
      if(vel > 0) { ["DEV BTN:", num, "ch", chan].postln }
  }, nil, nil, ~apcMidiUID);                                        

  ~t1_ilfx_2.set(\freeze, 1);
(
Pdef(\modCtl, Pbind(
  \type,   \set,  
  \id,   ~t1_ilfx_2.nodeID,  
  \args,  #[\freeze, \mix, \amp,  \chunk],  
  \chunk, Pseq([512,  1024, 2048, 4096],  inf), 
  \freeze,   Pwhite(0,  1,  inf), 
  \amp,  2, 
  // \mix, Pseg([0.0,  0.5,  1.0], [2, 4],  \sin, inf),  
  \mix,  0.9999999999, 
  // \delta, Pkey(\dur)/4,  
  // \dur,  Pseq([1/4, 1/2,  1,  2], inf),  
  // \dur,  pbjorklund(3, 8,  inf), 
  \dur,  Pseg([1/2,   1, 1/4], [2, 4], \sin,  inf), 
  // \dur, 1/16, 
));
)
Pdef(\modCtl).play;
Pdef(\modCtl).stop;


