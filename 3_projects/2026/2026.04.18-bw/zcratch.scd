// This will tell us if 9001 is free or busy
(
try { 
    n = OSCFunc({ |msg| msg.postln }, '/test', recvPort: 8000); 
    "Port 9001 is OPEN and working".postln;
    n.free;
} { 
    "Port 9001 is BLOCKED by another app".postln; 
};
)
OSCFunc.trace(false);
~link.tempo = 120/60;
(
~next = Pgeom(1, 3,  15).asStream;
Pdef(\t,  
  Pn(
  Plazy({
    Pfin(~next.next, 
      Pbind(
        \type, \midi, \midiout, ~mOut, \chan, 0, 
        \scale, Scale.chromatic,  
        \octave,  Pseq([3], inf),   
        \degree,  Pseq([
          // Pslide([[0],  [4, 3], [4, 6, 2]],  inf, 3,  1), 
          Pslide([
            [0], [\],  [4, 2],  [\], [4,  1], [\],  [\],  [0, 4], [1],     
          ],  inf,  15,  3), 
          // Pseq([Prand((0..4),  inf), Prand((3..5), inf), Prand((1..4), inf)], inf), 
          // Pn(Rest(),  2)
        ], inf),
        // \dur, Pseg([1/4,  1/8], [Pseq([4], 1), 8],  \sin,  inf),  
        \dur, 1/2,  
        \stretch, 1,  
        // \stretch, Pseq([Pseg([1, 1/4],[4],  \lin,   1), Pseq([4,  2], 1)],  inf),    
      ))
  })
), inf);
)
Pdef(\t).play(~link);
Pdef(\t).stop;
(
Pdef(\s,  
  Pbind(\type, \midi, \midiout, ~mOut, \chan, 3, 
  \scale, Scale.chromatic,  
  \octave,  Pstep(Pseq([4], inf),  3),   
  \degree,  Pseq([
    // Pslide([[0],  [4, 3], [4, 6, 2]],  inf, 3,  3), 
    Pshuf((0..16),  inf), 
    Pn(Rest(),  Pkey(\stretch))], inf),
  \dur, Pseg([1,  2,  4], [Pseq([2, 4], 1), Pkey(\stretch)*4],  \sin,  inf),  
  \stretch, Pseq([1/2, 1, 1/4],  inf),   
));
)
Pdef(\s).play(~link);
Pdef(\s).stop;

~mOut.control(16, 1, 127);
