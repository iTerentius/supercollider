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
