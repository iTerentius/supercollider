Reaper {

	var <link, <ip, <port;

	*new { | ip, port |
		^super.newCopyArgs().init(ip, port)
	}

	init { | ip, port |
		link = NetAddr.new(ip, port);
	}


	add { |proxies|
		var name, num, cmdName, cmdArm, out = 0;
		link.sendMsg("/action/40035"); //Select all
		link.sendMsg("/action/40697"); //Delete all

		proxies.do{ |proxy, i|
			out = out + 2;
			proxy.set(\out, out);
			name = proxy.asCompileString;
			name.postln;
			num = i + out;
			num.postln;
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
		link.sendMsg("/action/40042"); //Restart
		link.sendMsg("/record", 1);
	}

	stop {
		link.sendMsg("/record", 0);
		link.sendMsg("/stop", 1);
		link.sendMsg("/action/40042"); //Restart
	}

}


