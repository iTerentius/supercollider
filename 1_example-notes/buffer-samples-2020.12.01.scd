~roll = Array.new;
// ~folder = PathName.new("/home/hypostatic/Music/samples/_MM - Field Recordings/roll_door_2");
~folder = PathName.new("/home/hypostatic/Music/supercollider/_samples/Hoarder/hoarder");

(
~folder.entries.do({ | path |
	~roll = ~roll.add(Buffer.read(s, path.fullPath));
});
)

(
Ndef(\r1, { | amp=1, out=0, buf, rate=1, start=0, da=2, chan=1 |
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, startPos: start, loop: 1, doneAction: da);
	sig = [sig.abs, sig] * amp;
	Out.ar(out, sig);
}).play(out: 2, clock: );
)

Ndef(\r1).set(\buf, ~roll[3], \rate, Ndef(\rlfo), \start);

Ndef(\rlfo, { SinOsc.kr(LFNoise2.kr(Impulse.kr(0.5, 0, 2 ,10))).range(-1, 1); });

Ndef(\r1).clear(fadeTime: 5);

s.prepareForRecord;
s.record;