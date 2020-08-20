// todo. expand(numChannels) message

p = ProxySpace.push(s.boot);
p.fadeTime = 3;
// some filters
~f1 = { |a_in=#[0,0], freq=500, dt=0.01| Ringz.ar(a_in, freq, dt) };
~f2 = { |a_in=#[0,0], dt=0.1| CombL.ar(a_in, 0.5, dt, 15 * dt) };
~f3 = { |a_in=#[0,0], freq=30| a_in * LFSaw.ar(freq.neg).max(0) };

// some sources
~x1 = { LFPulse.kr(SinOsc.kr(0.2).exprange(2, 200)) * PinkNoise.ar(0.5.dup) };
~x2 = { Dust.ar(SinOsc.kr(0.2, [0, pi]).exprange(2, 2000)) };

// the output
~out.play;
~out = { |a_in=#[0,0]| a_in };

// some mappings by hand:
~out.map(\a_in, ~x1);
~out.xmap(\a_in, ~x2);

~out.xmap(\a_in, ~f1); ~f1.xmap(\a_in, ~x1);
~out.xmapn(\a_in, ~f2); ~f2.xmapn(\a_in, ~x1);
~out.xmapn(\a_in, ~f2); ~f2.xmapn(\a_in, ~x1);
~f2.xset(\dt, 0.01);

~mx1 = { MouseX.kr(0.0001, 1, 1) };
~f2.xmap(\dt, ~mx1);

~out.xmap(\a_in, ~f3); ~f3.xmap(\a_in, ~f2); ~f2.xmap(\a_in, ~x1);
// this should maybe be:
// ~f2 --(\a_in)--> ~f3 --(\a_in)--> ~out

~mx1 = { LFNoise1.kr(0.1).exprange(0.0001, 1) };
~mF = { ~mx1.kr.linexp(0, 1, 1, 10000) };
~f3.xmap(\freq, ~mF);

~f1.mapn(\a_in, ~x2);
~f2.xmapn(\a_in, ~f1);

~f1.xmapn(\freq, ~mF, \dt, ~mx1);

~x2 = { Impulse.ar(SinOsc.kr(0.2, [0, pi]).exprange(2, 200)) };
~x1 = { Saw.ar(20, 0.5.dup) * ~x2.ar };
~out = ~x1;



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
Ndef.clear(3);        // fade out and clear all Ndefs