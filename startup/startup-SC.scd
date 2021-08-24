// (
// "killall scsynth".unixCmd;
// s.options.numBuffers = 1024 * 64; // increase if you need to load more samples
// s.options.memSize = 8192 * 256; // increase if you get "alloc failed" messages
// s.options.maxNodes = 1024 * 32; // increase if drop outs and the message "too many nodes"
// // s.options.sampleRate= 44100;
// s.options.numOutputBusChannels = 2; // OUTPUT CHANNELS GO HERE
// s.recSampleFormat = "int24";
// s.recHeaderFormat="wav";
// s.options.numInputBusChannels = 2; // set to hardware input channel size, if necessary
// s.latency = 0.3;
// // MIDIClient.init; // Untoggle this when you want to do MIDI
// // m = MIDIOut.new(0); // Maybe yours is different?
// // m.latency = 0; // Faster is better so fastest is bestest right?
//
// /*// scnvim
// if (\SCNvim.asClass.notNil) {
// Server.default.doWhenBooted {
// \SCNvim.asClass.updateStatusLine(1, 9670);
// }
// };*/
//
// // A simple triangle wave synth in stereo with panning and a simple low pass filter
// // This synthDef was created by Mads Kjeldgaard and requires the sc3 plugins
// /*s.doWhenBooted{
// SynthDef.new(\default, {
// arg dur, attack=0.01, release=1.0,
// t_gate=1, out, freq=442, cutoff=5500,
// rq=1, pan=0.0, amp=0.5;
//
// var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
// var sig = DPW3Tri.ar(freq: freq, mul: env);
// sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
// sig = Pan2.ar(sig, pan);
// Out.ar(out, sig * amp);
// }).add;
// };*/
//
// s.waitForBoot {
// 	~clean = SuperClean(2, s); // two output channels, increase if you want to pan across more channels
// 	// ~clean.loadSoundFiles; // hot swap in samples from anywhere!
// 	// for example:
// 	~clean.loadSoundFiles("~/Downloads/mmd*");
// 	s.sync; // optionally: wait for samples to be read
// 	~clean.start(57120, [0]); // first 8 out looks like [0,2,4,6]
// 	SuperClean.default = ~clean; // make the clean key sequanceable inside of SUperCollider
// };
// )


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


/*s.waitForBoot {
~clean = SuperClean(2, s);
~clean.loadSoundFiles;
s.sync;a
~clean.start([0]);
SuperClean.default = ~clean;
};*/



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
	/*("SynthDefs.scd").loadRelative;
	loads snippets from setup folder
	("Snippets.scd").loadRelative;*/
	// wait, because otherwise it won't work for some reason
	3.wait;
	// activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;
	MIDIClient.init;
	5.wait;
	// m = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
	// m = MIDIOut.newByName("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
	m = MIDIOut(0, MIDIClient.destinations[0].uid);
	// m = MIDIOut(MIDIEndPoint("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
	m.latency(0);
	3.wait;
	"Setup done!".postln;
}).start;

SynthDef(\bplay,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, pos = 0, rel=15;
		var sig,env=1 ;
		sig = Mix.ar(PlayBuf.ar(2 ,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2));
		env = EnvGen.ar(Env.linen(0.0,rel,0),doneAction:0);
		sig = sig * env;
		sig = sig * amp;
		OffsetOut.ar(out,Pan2.ar(sig.dup,pan));
}).add;


)


