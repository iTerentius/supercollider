HypoRecorder {

	var <>nodes;
	var <>midiTracks;
	var <>smf;
	var <>folder;
	var <>recClock;
	var <>startSeconds;
	var <>headerFormat = "aiff", <>sampleFormat = "float";

	*new { |subfolder = nil |
		^super.newCopyArgs().init(subfolder)
	}

	init { | subfolder = nil |
		nodes = ();
		recClock = nil;
		if(subfolder != nil,
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Date.getDate.format("%Y%m%d-%Hh%m") +/+ subfolder },
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Date.getDate.format("%Y%m%d-%Hh%m")  }
		);

		File.mkdir(folder);
		Event.addEventType( \note,
			Event.eventTypes[\note].addFunc({
			if (~midirec.notNil && ~midirec.smf.notNil, {
					if( ~midirec.smf.notNil){
						~midirec.smf.addNote(
							noteNumber: ~midinote.value,
							velo: ~amp.range(0, 127),
							startTime: ~midirec.recClock.beats,
							dur: ~dur,
							channel: ~chan,
							track: ~chan,
						)
					};
				}, { currentEnvironment.play; })

		})
		)
	}

	free {
		nodes.do(_.clear);
		nodes = nil;
	}

	add { |proxies, midis = 2, clock = nil |
		midiTracks = midis;
		if(clock.isNil, { recClock = TempoClock.default }, { recClock = clock });
		recClock.beats.postln;
		this.prepareNodes(proxies);
		{ this.open(proxies) }.defer(0.5);
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

	open { |proxies |
		var dateTime  = Date.getDate.format("%Y%m%d-%Hh%m");
		proxies.do{ |proxy, i|
			var fileName  = ("%/%-%.%").format(
				folder, dateTime, proxy.asString, headerFormat
			);

			nodes[i].open(fileName, headerFormat, sampleFormat);
		};
		smf = SimpleMIDIFile(folder +/+ dateTime ++ "midi.mid");
	}

	record { |paused=false |
		recClock.postln;
		startSeconds = recClock.beats;
		"statSeconds: " ++ startSeconds.postln;
		smf.init1(midiTracks, recClock.tempo * 60, "4/4");
		smf.timeMode = \seconds;
		nodes.do(_.record(paused, recClock, -1));
		History.clear.end;
		History.start;
	}

	stop {
		this.close;
		History.document;
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


