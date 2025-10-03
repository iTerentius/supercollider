// 2025-09-28 demo


// ProxySpace setup

// master channel
~master = MixerChannel(\master, s, 2);

// track channel routed to master
~trA = MixerChannel(\trA, s, 2, 2, \outbus, ~master);

// connect Proxy to mixer
Ndef(\drone).play(~trA); // instead of .play directly to out
Ndef(\drone, { LFSaw.ar([110, 111]) * 0.1 });
Ndef(\drone).play;

// GUI
MixerChannelGui(~master, 10);

// Start the server.
s.boot;

// Create a new stereo mixer named \myMixer.
// The mixer will automatically handle bus allocation and group order.
~myMixer = MixerChannel.new(\myMixer, s, 2, 2, outbus: 2);

// Optionally, open the mixer's GUI window to see the controls.
~myMixer.gui;
~myMixer.level_(0.6);

// Define a sound for the Ndef. Here we use a simple sine wave.
Ndef(\sine, { |freq=440, mod=1| SinOsc.ar([freq, freq+2], 0, 0.2) });
Ndef(\sine)[1] = \filter -> {|in| Decimator.ar(in, 100, 4) * in};
Ndef(\sine)[2] = \pset -> Pbind(\freq, Pseq([110, 220, 330, Rest(1)], inf), \dur, 1);
Ndef(\sine)[1] = nil; // Set the Ndef's output bus to the input bus of the mixer channel. This is the essential step for connecting the Ndef to the mixer.

Ndef(\lfo1, {Saw.kr(4)});
Ndef(\sine).map(\mod, Ndef(\lfo) );
// Play the Ndef.
Ndef(\sine).play(~myMixer.inbus);
Ndef.clear;
s.plotTree;
~myMixer.free;


