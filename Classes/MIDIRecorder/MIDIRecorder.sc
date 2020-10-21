MidiRecorder {
	var dict, <channels, inputs, folder;
	*new { | channels, subfolder = nil |
		^super.newCopyArgs().init(channels, subfolder)
	}

	init { | channels, subfolder |
		inputs = List[];
		channels.do{ | channel, i |
			inputs.add(());
			inputs[i].channel = channel;
			inputs[i].data = [];
			inputs[i].startTime = nil;
			inputs[i].responders = [\noteOn, \noteOff, \polytouch, \cc, \program, \touch, \bend].collect{ |msgType|
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

					inputs[i].startTime.isNil.if({
						inputs[i].startTime = time;
					});

					inputs[i].data = inputs[i].data.add(
						// [ time, type, channel, val1, val2 ]
						ctlNum.notNil.if({
							[ time - inputs[i].startTime, msgType, chan, ctlNum, val ]
						}, {
							[ time - inputs[i].startTime, msgType, chan, val]
						})
					);

				}, msgType: (msgType == \cc).if({\control}, {msgType});
			)
			}
		}
	}

	write {
		inputs.do{ | channel , i |

			var filePath = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title +/+ channel.channel ++ "MIDI-%.mid".format(Date.getDate.stamp);

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
		}

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