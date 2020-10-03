s.reboot;

a = {(LFPulse.ar(SinOsc.kr(Pseq([440, 55],inf).asStream), amp:0.05) - Gendy1.kr(LFSaw.kr(0.1),0.5, mul:0.2, ampScale: 0.1))!2 * 0.001}.play;