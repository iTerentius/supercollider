(
~startMIDIRec = { | channels |
	var inputs;
	inputs = List.new(channels.size);
	channels.do{ | channel, i |
		inputs.add(Dictionary());
		inputs[i].data = [];
		inputs[i].startTime = nil;
		inputs[i].responders = [\noteOn, \noteOff, \polytouch, \cc, \program, \touch, \bend].collect{|msgType|
			MIDIFunc({|...args|
				if( chan == channel) {
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

					inputs[i].startTime.isNil.if({
						inputs[i].startTime = time;
					});

					inputs[i].data = inputs[i].data.add(
						// [ time, type, channel, val1, val2 ]
						ctlNum.notNil.if({
							[ time - dict.startTime, msgType, chan, ctlNum, val ]
						}, {
							[ time - dict.startTime, msgType, chan, val]
						})
					);
				}, msgType: (msgType == \cc).if({\control}, {msgType});
			})
		}
		inputs[i].writeData = {
			var filePath = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title +_+ chan +_+"MIDI-%.mid".format(Date.getDate.stamp);

			var mFile = SimpleMIDIFile( filePath );


			inputs[i].responders.do(_.free);
			mFile.init1( 1, 120, "4/4" );
			mFile.timeMode = \seconds;
			mFile.addAllMIDIEvents(
				inputs[i].data.collect{|row| [0] ++ row }, true
			);
			mFile.adjustEndOfTrack;
			mFile.write(filePath);
			inputs[i].midiFile = mFile;
			mFile
		};
		inputs[i]
};
)

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