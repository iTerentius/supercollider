Reaper {

	var <link, <ip, <port;

	*new { | ip, port |
		^super.newCopyArgs().init(ip, port)
	}

	init { | ip, port |
		link = NetAddr.new(ip, port);
	}


	add { |proxies, midis |
		var name, num, cmdName, cmdArm, out = 0;
		link.sendMsg("/action/40296"); //Select all
		link.sendMsg("/action/40697"); //Delete all

		proxies.do{ |proxy, i|
			name = proxy.asCompileString;
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
			link.sendMsg("/action/40001"); //Insert Track
			link.sendMsg(cmdName, name); //Insert Track
			link.sendMsg(cmdArm, 1);
			link.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");
		};
		link.sendMsg("/action/40042"); //Restart
	}


	record {
		var t = MIDIClockOut("Virtual Raw MIDI 0-1", "VirMIDI 0-1", tempoClock: TempoClock.default);

		link.sendMsg("/action/40042"); //Restart
		link.sendMsg("/pause/", 1);
		link.sendMsg("/record", 1);

	}

	stop {
		link.sendMsg("/record", 0);
		link.sendMsg("/stop", 1);
		link.sendMsg("/action/40042"); //Restart
	}

}

