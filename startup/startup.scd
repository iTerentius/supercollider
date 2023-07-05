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



s.waitForBoot {
	// b = SoundFile.collectIntoBuffers("~/Music/supercollider/_samples/808s_by_SHD/Classic/C/*");
	// ("default_synthdefs.scd").loadRelative;
	// loads snippets from setup folder
	// ("Snippets.scd").loadRelative;
	// wait, because otherwise it won't work for some reason
	// activate StageLimiter - Part of the BatLib quark
	// StageLimiter.activate;

	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	// ~dirt.doNotReadYet = true;
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)

 // load mi-ugens.scd synthdefs
  load("/Users/isaaclinder/Music/supercollider/tidal/synths.scd");

	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/***");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/*");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/*");
	~dirt.loadSoundFiles("~/Music/supercollider/_samples/**/**/*");
	// ~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
	// s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24]);

	// optional, needed for convenient access from sclang:
	(
		~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
		~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
		~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
		~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		~d13 = ~dirt.orbits[12]; ~d14 = ~dirt.orbits[13]; ~d15 = ~dirt.orbits[14];
		~d16 = ~dirt.orbits[15]; ~d17 = ~dirt.orbits[16]; ~d18 = ~dirt.orbits[17];
		~d20 = ~dirt.orbits[19]; ~d21 = ~dirt.orbits[20]; ~d22 = ~dirt.orbits[21];
		~d23 = ~dirt.orbits[22]; ~d24 = ~dirt.orbits[23];
		~busses = ~dirt.orbits.do { |x| x.dryBus };
	);

	MIDIClient.init;
	5.wait;
	// m = MIDIOut.newByName("Virtual Raw MIDI 0-0", "VirMIDI 0-0");
	// m = MIDIOut.newByName("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");
	m = MIDIOut(0, MIDIClient.destinations[0].uid);
	// m = MIDIOut(MIDIEndPoint("MPK Mini Mk II", "MPK Mini Mk II MIDI 1");

	~dirt.soundLibrary.addMIDI(\midi, m);

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

	~clean = SuperClean(2, s);
	~clean.loadSoundFiles("~/Music/supercollider/_samples/Hoarder/hoarder");
	~clean.loadSoundFiles("~/Music/supercollider/_samples/*");
	~clean.loadSoundFiles("~/Music/supercollider/_samples/**");
	~clean.loadSoundFiles("~/Music/supercollider/_samples/**/*");
	~clean.loadSoundFiles("~/Music/supercollider/_samples/**/**/*");
	s.sync; // Wait for samples to be read.
	~clean.start([0,0,0]); // First 8 out looks like [0,2,4,6]
	SuperClean.default = ~clean; // Make the clean key sequenceable inside of SuperCollider.
	"[ SuperClean up + running ]".postln;

	// s.latency = 0.3; // increase this if you get "late" messages

	// // create a synchronized clock
	// l = LinkClock(1).latency_(Server.default.latency);

	// q = s.meter;
	// v = Stethoscope();
	// w = FreqScope();
	// x = s.plotTree;

	~dirtbusses = ~dirt.orbits.collect { |x| x.dryBus };

	SynthDef(\readorb, { |out, amp = 1, n = 0, obus = 0 | // number
		var bus, sound;
		bus = Select.kr(n, ~dirtbusses);
		sound = InFeedback.ar(bus, ~dirt.numChannels);
		//sound = CombL.ar(sound, 0.2, 0.03, 1);
		Out.ar(out,
			sound * (amp * 2.5);
		)
	}).add;

	m.latency(0);
	"Setup done!".postln;

};

)
