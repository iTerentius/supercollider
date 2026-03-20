// Scratch
(
~bd1_ilfx_1.free;
~bd1_ilfx_1 = ~pbd1.playfx({|in|
  var sig = In.ar(~pbd1.inbus,  2);
  var hpfreq = \hpfreq.kr(400);
  var hprq = \hprq.kr(1.0);
  var lpfreq = \lpfreq.kr(800);
  var lprq = \lprq.kr(1.0);
  var lpsig = LPF.ar(sig, lpfreq, lprq);
  var hpsig = HPF.ar(sig, hpfreq, hprq); 
  var wet = lpsig + hpsig; 
  wet; 
});
)

~bd1_ilfx_1.set(\lpfreq,  1000,  \rq, 2.0,  \hpfreq,  500,  \hprq,  2.0);
// Greyhole.ar(in, delayTime: 2.0, damp: 0.0, size: 1.0, diff: 0.707, feedback: 0.9, modDepth: 0.1, modFreq: 2.0) ~

(
~bd1_revs_fx.free;
~bd1_revs_fx = ~m1.playfx({|in|
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
});
)
~bd1_revs_fx.level_(0.5);

OSCFunc.trace(true)
OSCFunc.trace(false)

~toscSync.();
~toscStateSave.("2026_03_06".asSymbol);
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
