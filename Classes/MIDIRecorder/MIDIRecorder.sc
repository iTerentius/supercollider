// requires SimpleMIDI from wslib quark
"wslib".include;

MIDIClient.init;
MIDIIn.connectAll;

/*
MIDIFunc.trace; // show all MIDI messages coming in
MIDIFunc.trace(false); // show all MIDI messages coming in
*/

q = ();

(

q.data = [];

// an array of the form
// [
//  [ 0 , type, channel, val1, val2 ],
//  [ dt, type, channel, val1, val2 ],
//  ...
// ]

q.startTime = nil;
q.responders = [\noteOn, \noteOff, \polytouch, \cc, \program, \touch, \bend].collect{|msgType|
	MIDIFunc({|...args|
		var time = Date.getDate.rawSeconds;
		var val, ctlNum, chan, src;

		msgType.postln;
		// handle arguments for different msgTypes
		[\noteOn, \noteOff, \control, \polytouch ].includes(msgType).if({
			# val, ctlNum, chan, src = args;
			args.postln;
		},{
			# val, chan, src = args;
		});


		// correct message type to correspond to SimpleMIDIFile format
		// [msgType, val, ctlNum, chan, src].postln;

		// for first element, set startTime to current raw seconds
		q.startTime.isNil.if({
			q.startTime = time;
		});

		// for each MIDI message, write an array to data:
		q.data = q.data.add(
			// [ time, type, channel, val1, val2 ]
			ctlNum.notNil.if({
				[ time - q.startTime, msgType, chan, ctlNum, val ]
			}, {
				[ time - q.startTime, msgType, chan, val]
			})
		);
	}, msgType: (msgType == \cc).if({\control}, {msgType});
	)
}
)


// all your data
// belongs to us
q.data.printAll;

// write data to MIDI file (requires wslib)
q.writeData = {
	var filePath = thisProcess.nowExecutingPath.dirname +/+ "MIDI-%.mid".format(Date.getDate.stamp);
	var mFile = SimpleMIDIFile( filePath ); // create empty file

	mFile.init1( 1, 120, "4/4" );	// init for type 1 (multitrack); 3 tracks, 120bpm, 4/4 measures
	mFile.timeMode = \seconds;  // change from default to something useful
	// m.pitchBendMode = ??? TODO
	mFile.addAllMIDIEvents(
		q.data.collect{|row| [0] ++ row }, true
	);
	mFile.adjustEndOfTrack;

	// mFile.midiEvents.dopostln; // all midi events
	// mFile.metaEvents.dopostln; // notice the incorrect 'endOfTrack' events for track 1 & 2;

	mFile.write(filePath)
}

////////////////////// WRITE DATA


q.writeData
// after usage, remove responders
q.responders.do(_.free)


////////////////////// TEST

/*
MIDIClient.destinations; // list array of destinations
*/

m = MIDIOut(0);
m.connect
m.latency = 0


m.control(chan: 1, ctlNum: 2, val: 127.rand);
m.noteOn(16, 127.rand, 128.rand);
m.noteOff(16, 61, 60);
m.allNotesOff(16);