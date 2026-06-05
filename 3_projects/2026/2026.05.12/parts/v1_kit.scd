(
// var cut = Pseg([13,  7,  9, 7],[15,  3,  5], \lin,  inf).asStream;
var cut = Pstep(Pseq([9, 7,  9, 7], inf), Pseq([3,  4,  8,  4], inf)/4).asStream;
///////////////////////////////////////////////////////////////
// PDEF
///////////////////////////////////////////////////////////////

Pdefn(\kdiv, Pseq([5], inf));
// Pdefn(\str, Pstep(Pseq([1,  2,   4, 1/3], inf), Pseq([4,  4,  4,  1], 1)));
Pdefn(\str, 1);
Pdef(\v1_kit,
  Pn(Plazy({
    Pfindur(cut.next, 
      Ppar([
        Pbindef(\v1_kit_pb, 
          \instrument,  \kik808, 
          \scale,   Scale.major,
          \octave,  Pseq([2,  3], inf),  
          \stretch, Pdefn(\str) * 2,  
          \degree,  ~deg.("0-12-040",  inf),  
          \legato,  Pwhite(0.4, 1.8,  inf), 
          \dur,     1/Pdefn(\kdiv),  
          \amp,     0.3,  
          \out,     ~pbd1.inbus.index,  
          // \rel,     0.4,  
          \dist,    Pseg([0.8, 5.0, 0.8], [16,  16],  \step,  inf),  
          \pitchMod,  Pseq([0.2, -0.2], inf),  
          \clickAmp,  0.4,  
          \rel, Pseg([0.2,  1.0,  0.2], [3],  \exp, inf),  
          \pitchRel,  Pstep(Pseq([0.5,  2],  inf), 3),    
        ),  
        Pbind(
          \instrument,  \sn808, 
          \scale,   Scale.major,
          \octave,  3,  
          \stretch, 2 + Pdefn(\str),  
          \degree,  ~deg.("-------1",  inf),  
          // \degree,  0,  
          \dur,     1/Pdefn(\kdiv),  
          \amp,     0.3,  
          \out,     ~psd1.inbus.index,  
          \rel,     0.4,  
        ),  
        Pbind(
          \instrument,  Place([\hh808],  inf), 
          \scale,   Scale.major,
          \octave,  9,  
          \stretch, 1 + Pdefn(\str),  
          \degree,  ~deg.("---97-7-----",  inf),  
          // \degree,  0,  
          \legato,   0.005, 
          \dur,     1/Pdefn(\kdiv),  
          \amp,     0.3,  
          \out,     ~phh1.inbus.index,  
          \rel,     0.1,  
        ),  
      ]))
  }), inf)
);
)
