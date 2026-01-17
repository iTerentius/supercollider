
(
Pdefn(\kit_1_deg_0, 
  Pseq([
    [0], [\],  [\], [0], [\], [\],  [\], [\],
    [\], [\],  [\], [0], [1], [\],  [\], [\],
  ], 1));  

Pdefn(\kit_1_deg_1, 
  Pseq([
    [0], [\],  [\], [0], [0], [4],  [1], [4],  
    [\], [1],  [\], [\], [0], [1],  [0], [3],  
  ], 1));  

Pdefn(\kit_1_deg_2, 
  Pseq([
    [0], [\],  [\], [\], [0], [\],  [\], [\],  
    [\], [\],  [\], [\], [0], [\],  [0], [\],  
  ], 1));  
  
Pdefn(\hats_1_deg_0, 
  Pseq([
    [2], [\],  [2], [\],  
    [\], [2],  [\], [3],  
  ], 
  1));  

Pdefn(\hats_1_deg_1, 
  Pseq([
    [2], [2],  [3], [\],  
    [\], [\],  [2], [2],  
  ], 
  1));  

Pdefn(\hats_1_deg_2, 
  Pseq([
    [2], [\],  [\], [\],  
    [2], [\],  [\], [\],  
  ], 
  1));  

Pdefn(\hats_1_deg_3, 
  Pseq([
    [2], [\],  [\], [\],  
    [2], [\],  [\], [\],  
  ], 
  1));  

Pdefn(\kit_1_degs,  
Pseq([
  Pn(Pdefn(\kit_1_deg_1),  4),  
  Pn(Pdefn(\kit_1_deg_0),  4), 
  Pn(Pdefn(\kit_1_deg_2),  4), 
],  1));

Pdefn(\hats_1_degs,  
Pseq([
  Pn(Pdefn(\hats_1_deg_1),  4),  
  Pn(Pdefn(\hats_1_deg_0),  4), 
  Pn(Pdefn(\hats_1_deg_2),  4), 
],  1));

Pbindef(\kit_1_pbd,  
  \type, \midi, \midiout, ~mOut, \chan, [0,/*  1,  2,  */],
  \scale, Scale.chromatic,
  \root,  0,  
  \octave,  3,  
  \degree, Pn(Pdefn(\kit_1_degs),  inf), 
  \amp,    Pn(Pseq([0.99, 0.6, 0.8, 0.7], 1), inf),  
  // \amp,  0.8, 
  \dur,    1/2, 
);
Pbindef(\hats_1_pbd, 
  \type, \midi, \midiout, ~mOut, \chan, [0,/*  3,  0,*/], 
  \scale, Scale.chromatic,
  \root,  0,  
  \octave,  3,  
  \degree, Pn(Pdefn(\hats_1_degs), inf), 
  \amp,    Pn(Pseq([0.8, 0.6, 0.8, 0.7], inf), inf),  
  // \dur,    Pn(Pdefn(\a000_durm0),  inf), 
  \dur,  1/4, 
);

Pdef(\perc_1_m, Ppar([
  Pbindef(\kit_1_pbd),
  Pbindef(\hats_1_pbd),
],  inf));

// Bindings
if(~lpMini.notNil){
  ~lpBind.([1, 1], \perc_1_m);
}

)
Pbindef(\mel_2).clear;
