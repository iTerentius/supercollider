//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 18;
s.options.numInputBusChannels = 0;
/*s.latency = 0.5;*/
//boot the server
s.reboot;
//display the oscilloscope
// s.scope;
//start proxyspace
//p=ProxySpace.push(s);
//start tempo clock
//p.makeTempoClock;
//give proxyspace a tempo
//p.clock.tempo = 80/60;
// r = Reaper.new("127.0.0.1", 7772);
q = s.meter;
v = Stethoscope();
w = FreqScope();
x = s.plotTree;



Task({
	// 3.wait;
	// d = Dictionary.new;
	// d.add(\foldernames -> PathName("/home/hypostatic/Music/samples/808s_by_SHD/Classic").entries);
	// for (0, d[\foldernames].size-1,
	// {arg i; d.add(d[\foldernames][i].folderName -> d[\foldernames][i].entries.collect({
	// arg sf;
	// Buffer.read(s,sf.fullPath);
// });
// )});
	// ("SynthDefs.scd").loadRelative;
	//loads snippets from setup folder
	//("Snippets.scd").loadRelative;
	//wait, because otherwise it won't work for some reason
	// 3.wait;
	//activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	MIDIClient.init;
	5.wait;
	// m = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
	// m = MIDIOut.newByName("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
	m = MIDIOut(0, MIDIClient.destinations[0].uid);
	// m = MIDIOut(MIDIEndPoint("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
		m.latency(0);
	// 3.wait;
	"Setup done!".postln;
}).start;

/*SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2 ,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		OffsetOut.ar(out,Pan2.ar(sig.dup,pan));
	}).add;*/


)

