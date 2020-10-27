HypoRecorder {

	var <>nodes;
	var <>midi;
	var <>smf;
	var <>folder;
	var <>mclock;
	var <>headerFormat = "aiff", <>sampleFormat = "float";

	*new { |subfolder = nil |
		^super.newCopyArgs().init(subfolder)
	}

	init { | subfolder = nil |
		nodes = ();
		if(subfolder != nil,
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title +/+ subfolder },
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title  }
		);

		File.mkdir(folder);

		Event.addEventType(
			\midi,
			Event.eventTypes[\midi].addFunc({
				if (~recordTarget.notNil) {
					~recordTarget.addNote(
						noteNumber: ~midinote,
						velo: ~amp.range(0, 127),
						startTime: ~mclock.beats,
						dur: ~dur,
						channel: ~chan,
						track: ~chan,
					);
					~recordTarget.midiEvents.dopostln;
				}
			}),
			() // if you want some recording-related properties to have default values, pass them here
		);


	}

	free {
		nodes.do(_.clear);
		nodes = nil;
	}

	add { |proxies, midis |
		midi = midis;
		this.prepareNodes(proxies);
		{ this.open(proxies, midis) }.defer(0.5);
	}

	prepareNodes { |proxies|
		proxies.do{ |proxy, i|
			var n = Ndef(proxy);
			n.play;
			n.postln;
			nodes.add(
				i -> RecNodeProxy.newFrom(n, 2)
			);
		}
	}

	open { |proxies, midis = 2, mclock|
		var dateTime  = Date.getDate.format("%Y%m%d-%Hh%m");
		proxies.do{ |proxy, i|
			var fileName  = ("%/%-%.%").format(
				folder, dateTime, proxy.asCompileString, headerFormat
			);

			nodes[i].open(fileName, headerFormat, sampleFormat);
		};
		smf = SimpleMIDIFile(folder +/+ dateTime ++ "midi.mid");
		smf.init1(midi, TempoClock.default.tempo * 60, "4/4");
		smf.timeMode = \seconds;
	}

	record { |paused=false, mclock=nil |
		if(mclock.isNil, { mclock = TempoClock.default });
		smf.init1(midi, mclock.tempo * 60, "4/4");
		nodes.do(_.record(paused, mclock, -1));
	}

	stop {
		this.close
	}

	close {
		nodes.do(_.close);
		smf.midiEvents.dopostln;
		smf.adjustEndOfTrack;
		smf.metaEvents.dopostln;
		smf.write;
	}

	pause {
		nodes.do(_.pause)
	}

	unpause {
		nodes.do(_.unpause)
	}

	closeOne { |node|

	}
}


