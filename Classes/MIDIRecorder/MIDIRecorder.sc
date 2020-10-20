MidiRecorder {
	var dict;
	*new {
		^super.newCopyArgs().init()
	}

	init {
		dict = ();
		dict.data = [];
		dict.startTime = nil;
		dict.responders = [\noteOn, \noteOff, \polytouch, \cc, \program, \touch, \bend].collect{|msgType|
			MIDIFunc({|...args|
				var time = Date.getDate.rawSeconds;
				var val, ctlNum, chan, src;
				[msgType, time].postln;
				// handle arguments for different msgTypes
				[\noteOn, \noteOff, \control, \polytouch ].includes(msgType).if({
					# val, ctlNum, chan, src = args;
					args.postln;
				},{
					# val, chan, src = args;
				});

				dict.startTime.isNil.if({
					dict.startTime = time;
				});

				dict.data = dict.data.add(
					// [ time, type, channel, val1, val2 ]
					ctlNum.notNil.if({
						[ time - dict.startTime, msgType, chan, ctlNum, val ]
					}, {
						[ time - dict.startTime, msgType, chan, val]
					})
				);
			}, msgType: (msgType == \cc).if({\control}, {msgType});
			)
		}
	}

	write {
		var filePath = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title ++ "MIDI-%.mid".format(Date.getDate.stamp);

		var mFile = SimpleMIDIFile( filePath );


		dict.responders.do(_.free);
		mFile.init1( 1, 120, "4/4" );
		mFile.timeMode = \seconds;
		mFile.addAllMIDIEvents(
			dict.data.collect{|row| [0] ++ row }, true
		);
		mFile.adjustEndOfTrack;
		mFile.write(filePath);
		dict.midiFile = mFile;
		mFile
	}

}

/*
filePath;

// connect your midi devices
MIDIIn.connectAll;

// start recording midi data
~midiRecordings = ~startMIDIRec.();

// stop recording and get the SimpleMIDIFile
~midiFile = ~midiRecordings.writeData;

// use the midifile to do what you want (see SimpleMIDIFile helpfile)
// for example convert to pattern and play
~midiFile.p.play;

// or extract controller events (didn't test)
~midiFile.controllerEvents;
*/