Bitwig {

	var <link, <ip, <port, <>clock;

	*new { | ip, port |
		^super.newCopyArgs().init(ip, port)
	}

	init { | ip, port, clock |
		link = NetAddr.new(ip, port);
		clock = clock;
	}

	add { |proxies, midis |
		var name, num, cmdName, cmdArm, out = 0;

		proxies.do{ |proxy, i|
			name = proxy.asString;
			out = out + 2;
			out.postln;
			Ndef(proxy).play;
			// Ndef(proxy).stop;
			Ndef(proxy).set(\out, out);
			name.postln;
			num = i + 1;

			// num.postln;
			cmdName = "/track/"++num++"/name";
			cmdArm = "/track/"++num++"/recarm";
			cmdArm.postln;
			// link.sendMsg(cmdName, name); //Name
			// link.sendMsg(cmdArm, 1);
		};
		link.sendMsg("/stop", 1); //Restart
	}


	record {
		// var t = MIDIClockOut("Virtual Raw MIDI 0-1", "VirMIDI 0-1", tempoClock: clock);

		// link.sendMsg("/stop", 1); //Restart
		link.sendMsg("/record", 1);
		// link.sendMsg("/playbutton", 1);

	}

	stop {
		link.sendMsg("/record", 0);
		link.sendMsg("/stop", 1);
	}

}

