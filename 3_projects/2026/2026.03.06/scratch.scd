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

