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
/*q = s.meter;
v = Stethoscope();
w = FreqScope();
x = s.plotTree;*/


/*s.waitForBoot {
~clean = SuperClean(2, s);
~clean.loadSoundFiles;
s.sync;a
~clean.start([0]);
SuperClean.default = ~clean;
};*/


s.waitForBoot {
	b = SoundFile.collectIntoBuffers("~/Music/supercollider/_samples/808s_by_SHD/Classic/C/*");
	("default_synthdefs.scd").loadRelative;
	// loads snippets from setup folder
	// ("Snippets.scd").loadRelative;
	// wait, because otherwise it won't work for some reason
	// activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;

	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	// ~dirt.doNotReadYet = true;
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/***");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/*");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/*");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/**/*");
	// ~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
	// s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14, 16]);

	// optional, needed for convenient access from sclang:
	(
		~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
		~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
		~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
		~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
	);

	MIDIClient.init;
	5.wait;
	// m = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
	// m = MIDIOut.newByName("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
	m = MIDIOut(0, MIDIClient.destinations[0].uid);
	// m = MIDIOut(MIDIEndPoint("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");

	~dirt.soundLibrary.addMIDI(\midi, ~midiOut);

	~osc = NetAddr.new("127.0.0.1", 6010);

	MIDIIn.connectAll;

	~on = MIDIFunc.noteOn({ |val, num, chan, src|
		~osc.sendMsg("/ctrl", num.asString, val/127);
		("CC: " + num + " : " + "Value: " + val).postln;
	});

	~off = MIDIFunc.noteOff({ |val, num, chan, src|
		~osc.sendMsg("/ctrl", num.asString, 0);
		("CC: " + num + " : " + "Value: " + val).postln;
	});

	~cc = MIDIFunc.cc({ |val, num, chan, src|
		~osc.sendMsg("/ctrl", num.asString, val/127);
		("CC: " + num + " : " + "Value: " + val).postln;
	});

	if (~stopMidiToOsc != nil, {
		~stopMidiToOsc.value;
	});

	~stopMidiToOsc = {
		~on.free;
		~off.free;
		~cc.free;
	};


	s.latency = 0.3; // increase this if you get "late" messages

	// create a synchronized clock
	l = LinkClock(1).latency_(Server.default.latency);

	q = s.meter;
	v = Stethoscope();
	w = FreqScope();
	x = s.plotTree;

	m.latency(0);
	"Setup done!".postln;
};

)


