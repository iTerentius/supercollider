Ndef(\a1, {Out.ar(0!2, Saw.ar(LFTri.kr(MouseX.kr(50,100)), LFSaw.kr(MouseY.kr(100, 1000))))}).play;

s.prepareForRecord;
s.record;
s.stopRecording;