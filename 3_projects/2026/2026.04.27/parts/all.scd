
(
// ~all_cut = Pseq([3,  5,  3,  9].mirror, inf).asStream;
~all_cut = Pstep(Pseq([9, 7,  9, 7], inf), Pseq([3,  4,  8,  4], inf)/4).asStream;
Pdefn(\all_div, Pstep(Pseq([5], inf), 1));
Pdefn(\kick_str, Pseq([4, 2,  1!8].flat, inf));
Pdef(\all,  
  Ppar([                                                    
    Pn(
      Plazy({
        Pfindur(~all_cut.next*2, Pbind(  
          // Pn(Pfin(Pdefn(\all_cut), Pbind(  
          \instrument,  \kik808,  
          \scale, Scale.dorian,
          \octave,  Pseq([1.5,2], inf),   
          // \dur, 1/Pdefn(\all_div)/Pseq([2,  1!1].flat, inf),  
          \dur, 1/Pdefn(\all_div),  
          \stretch, Pdefn(\kick_str)*1,  
          \degree,  Pseq([
            Pn(~deg.("0201-"),1),  
            // Pn(~deg.("040-1"),1),  
            // Pn(~deg.("--224-0---"), 1),    
            Pn(~deg.("0-14-2"),1),    
            Pn(~deg.("--0--"),1),    
          ],  inf),  
          \amp, 0.5,  
          \out, ~pbd1.inbus.index,  
        ))
      }),  
    inf),
    Pn(
      Plazy({
        Pfindur(~all_cut.next*4, Pbind(  
          // Pn(Pfin(Pdefn(\all_cut), Pbind(  
          \instrument,  \sn808,  
          \scale, Scale.dorian,
          \octave,  Pseq([2,2], inf),   
          \dur, 1/Pdefn(\all_div)/2,            // \dur, 1/Pdefn(\all_div),  
          \stretch, Pseq([4,  2],   inf),  
          \degree,  Pseq([
            Pn(~deg.("---0---4"),1),  
            Pn(~deg.("----04"),1),  
          ],  inf),  
          \amp, 0.0,  
          \snappy,  Pwhite(0.2, 1.0, inf),  
          \snapRel, 2,  
          \tonFreq, Pkey(\degree).midicps,  
          \out, ~psd1.inbus.index,  
        ))
      }),  
    inf),
    Pn(
      Plazy({
        Pfindur(~all_cut.next*2,   Pbind( 
          \instrument,  Pseq([\hh808, \t1002], inf),  
          \amp, 0.4,  
          \scale,  Scale.minor, 
          \octave,  9,  
          \degree,  ~deg.("-77-7"), 
          \legato,  0.005,  
          \pan, 0,  
          \dur, 1/Pdefn(\all_div),  
          \rel, Pseq([0.1!4, 0.2].flat),     
          \stretch, 2,  
          \out,  ~phh1.inbus.index, 
        ))
      }), 
    inf),                          
  ])
);
)
