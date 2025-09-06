Ndef(\sound).play;
Ndef(\sound).fadeTime = 1;
Ndef(\sound, { SinOsc.ar([600, 635], 0, SinOsc.kr(2).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 3, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, { SinOsc.ar([600, 635] * 2, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\sound, Pbind(\dur, 0.17, \freq, Pfunc({ rrand(300, 700) })));

Ndef(\lfo, { LFNoise1.kr(3, 400, 800) });
Ndef(\sound).map(\freq, Ndef(\lfo));
Ndef(\sound, { |freq| SinOsc.ar([600, 635] + freq, 0, SinOsc.kr(2 * 3).max(0) * 0.2) });
Ndef(\lfo, { LFNoise1.kr(300, 400, 800) });

//using Ndef inside other Ndefs
Ndef(\lfo2, { LFNoise1.kr(LFNoise1.kr(0.1).exprange(1, 300) ! 2, 400, 800) });
Ndef(\sound, { Blip.ar(Ndef.kr(\lfo2), 30) * 0.2 }).play;

Ndef(\lfo2, { [MouseX.kr(10, 300, 1), MouseY.kr(10, 300, 1)] });
// setting and mapping parameters
Ndef(\sound, { |freq = 56, numHarm = 10| Blip.ar(freq, numHarm, 30) * 0.2 }).play;
Ndef(\sound).set(\freq, 15);
Ndef(\sound).set(\freq, 15, \numHarm, 100);

Ndef(\lfo, { LFNoise2.kr(2).exprange(10, 200) });
Ndef(\sound).map(\numHarm, Ndef(\lfo));
Ndef(\sound).set(\numHarm, nil); // unmap.
Ndef(\sound).stop;

Ndef(\sound).fadeTime = 3;
(
Ndef(\sound, { |fadeTime = 1, gate = 1|
    var e = Env.adsr(fadeTime, 0.01, 0.4, fadeTime).ar(2, gate);
    SinOsc.ar(100 + (e * 700), SinOsc.ar(208) * (1 - e) * 6) * e * 0.1
}).play
)

(
Ndef(\sound, {
    RHPF.ar(
        \in1.ar([0, 0]) * \in2.ar([0, 0]),
        \freq.kr(6000, 2),
        \rq.kr(0.2)
    ) * 7
}).play;
Ndef(\sound).fadeTime = 0.2;    // avoid harsh clicks
)

Ndef(\a, { SinOsc.ar(MouseX.kr(300, 1000, 1) * [1, 1.2], \phase.ar([0, 0]) * 0.2) });
Ndef(\b, { LFDNoise3.ar(MouseY.kr(3, 1000, 1) * [1, 1.2]) });
Ndef(\c, { LFTri.ar(MouseY.kr(3, 10, 1) * [1, 1.2]).max(0) });
Ndef(\a).fadeTime = 0.2;    // avoid harsh clicks again

Ndef(\sound) <<>.in1 Ndef(\a);
Ndef(\sound) <<>.in2 Ndef(\b);
Ndef(\sound) <<>.in2 Ndef(\c);
Ndef(\a) <<>.phase Ndef(\sound);
Ndef(\a) <<>.phase nil;    // unmap
Ndef.clear(3);

Ndef.clear; // clear all Ndefs
