~masO = MIDIOut.newByName("MASCHINE Plus",  "MASCHINE Plus");
// ~mas = MIDIOut.newByName("Maschine Plus",  "Maschine Plus");
// ~mas = MIDIOut.newByName("Maschine Plus Virtual",  "Maschine Plus Virtual");
// ~mas = MIDIOut.newByName("Maschine 3 Virtual Input",  "Maschine 3 Virtual Input");
~delO = MIDIOut.newByName("Deluge",  "OUT");

// MIDIIn has no newByName — startup already ran MIDIIn.connectAll.
// Find Deluge source UID to filter forwarding MIDIdefs.
~delSrcUID = MIDIClient.sources.detect({|s| s.device == "Deluge" }).uid;

MIDIdef.noteOn(\fwd,  {|vel,  note,   chan| ~masO.noteOn(chan,  note,   vel) }, srcID: ~delSrcUID);
MIDIdef.noteOff(\fwd,  {|vel,  note,   chan| ~masO.noteOff(chan,  note,   vel) }, srcID: ~delSrcUID);
MIDIdef.cc(\fwdCC,  {|val,  num,   chan| ~masO.control(chan,  num,   val) }, srcID: ~delSrcUID);

(
Pdefn(\degs,  Pseq([
  Pn(Pstep(Pseq([0, -1, -5, -4],  1), 4), 3), 
  Pn(Pseq([0, 0,  2,  3], 1), 1), 
],  1));
)
(
// 2025-10-06

Pdef(\midiNotes,
  Pbind(
      \type, \midi,
      \midiout,  ~mOut,
      \chan, 2,                 // MIDI channel 0..15
      \scale,  Scale.dorian,  
      \octave, 4,
      // \degree, Pstep(Pseq([0, -1, -5, -4], inf), 4),  
      \degree,  Pn(Pdefn(\degs),  inf), 
      \sustain, 1.5,  
      \dur, 1,               // pattern step duration
      \amp, Pwhite(0.76,  0.9, inf),                    // 0..1 mapped to velocity 1..127
      \stretch,  Pseq([1/4!4, 1].flat, inf),   
  ));
);
Pdef(\midiNotes).play(~link,  quant:4);
Pdef(\midiNotes).stop(~link);

~mas.control(9,  70,  50); 

