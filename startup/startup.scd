//Boilerplate code for basic live coding functionality

(
//increase number of buffers the server has access to for loading samples
s.options.numBuffers = 1024 * 16;
//increase the memory available to the server
s.options.memSize = 8192 * 256;
s.options.numOutputBusChannels = 16;
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
r = Reaper.new("127.0.0.1", 7772);
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