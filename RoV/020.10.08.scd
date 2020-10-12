//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 16;
b = NetAddr.new("192.168.1.132", 7772);
//boot the server
s.reboot;
//display the oscilloscope
// s.scope;
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 80/60;
Task({
	3.wait;
	d = Dictionary.new;
	d.add(\foldernames -> PathName("/home/hypostatic/Music/samples/808s_by_SHD/Classic").entries);
	for (0, d[\foldernames].size-1,
		{arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
			arg sf;
			Buffer.read(s,sf.fullPath);
		});
	)});
	// ("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	3.wait;
	//activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	MIDIClient.init;
	"Setup done!".postln;
}).start;
)


p.clock.tempo = 45/60;
p.fadeTime = 3;
p.quant = 1;

b.sendMsg("/tempo/raw", 60);
b.sendMsg("/track/1/recarm", 1).postln;
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/track/4/recarm", 1);
b.sendMsg("/time", 0);
b.sendMsg("/restart", 1);
b.sendMsg("/record", 1);

b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
b.sendMsg("/action/40001"); //Insert Track
b.sendMsg("/track/1/name", "test");
b.sendMsg("/track/1/select", 1);

b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");

(
b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
["lead", "dust", "hh", "b"].do { | i, c |
	var name, num, cmdName, cmdArm;
	name = i;
	name.postln;
	num = c + 1;
	num.postln;
	cmdName = "/track/"++num++"/name";
	cmdArm = "/track/"++num++"/recarm";
	cmdArm.postln;
	b.sendMsg("/action/40001"); //Insert Track
	b.sendMsg(cmdName, i); //Insert Track
	b.sendMsg(cmdArm, 1);
	b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");
};
)

(
SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,Pan2.ar(sig.dup,pan));
}).add
)

//
// (
// ~dust.play;
// ~rec.play;
// ~hh.play;
// ~b.play;
// )
//
// (
// r = ProxyRecorder(p);
//
// r.add([~hh, ~b, ~rec, ~dust]);
//
// )
//
// (
// ~dust.stop;
// ~rec.stop;
// ~hh.stop;
// ~b.stop;
// )
//
// r.record;
// r.stop;
//
// p.prepareForRecord;


(
~lead = { | out = 0, freq = 48, relTime = 2 |
	var sig = 0, temp, env, curv;
	out.postln;
	// curv = [\step, \sin, \wel].scramble;
	env = EnvGen.kr(Env.perc(0.5, releaseTime:relTime, curve: \step), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + Rand(0, i), LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env * 0.9;
		Out.ar(out, sig * 1/16);
	};
};

~lead[1] = \xset -> Pbind(
	\dur, Pseq([0.125, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(4), Rest(2), Rest(1)].scramble, inf),
	\degree, Pseq(Scale.hijaz.degrees.mirror.scramble -5, inf),
	\octave, Pwhite(2, 4, inf).round(1),
	\relTime, Pseq([1, 2, 3, 0.5], inf),
);

)

m = MIDIOut(0);
m.connect(1);

~lead.set(\out, 2);
~lead.play;
~lead.stop(fadeTime: 4);
~lead.end(fadeTime:5);
~lead.free;

~dust.play;

(
~dust = { | out = 4, freq = 110 |
	var sig, env;
	env = EnvGen.kr(Env.asr(), doneAction: 2);
	sig = SinOsc.ar(LFPar.kr(LFPulse.kr(1, 0.2, 0.5, 0.5),0.2, 1, 0.5) * freq * 3) * (LFPulse.kr(LFPulse.kr(1, 0, 0.5, 8, 10),0,0.5,4));
	Out.ar(out, Pan2.ar(sig) * 0.09 * env);
};
)

~dust.xset(\freq, Pseq(Scale.hijaz.degrees, inf).asStream);
~dust.xset(\freq, 110);
~dust.set(\gate, ~rec);


~dust.stop(fadeTime:10);
~dust.end(fadeTime:10);
~dust.release(fadeTime:10);

(
~hh = Pbind(
	\instrument, \bplay,
	\out, 5
	\buf, d["Hats"][1],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	// \dur,Pbjorklund2(Pseq(l, inf).asStream,12,inf)/8,
	\amp, 0.025,
);

~b = Pbind(
	\instrument, \bplay,
	\out, 6
	\buf, d["Bass Drums"][5],
	\dur, Pseq([0.25, 0.25, 0.5, 0.77, 0.25].scramble, inf),
	\amp, 0.2
);
)


~hh.play;
~hh.stop(fadeTime:4);
~hh.release(fadeTime:4);


~b.play;
~b.stop(fadeTime:4);
~b.release(fadeTime:4);