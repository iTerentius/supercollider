RecordMulti {
	var <folder;
	*new { |subfolder = nil |
		^super.newCopyArgs().init(subfolder)
	}

	init { | subfolder = nil |

		if(subfolder != nil,
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title +/+ subfolder },
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title  }
		);

		File.mkdir(folder);
	}


	add { |proxies|
		var name, num, cmdName, cmdArm, out = 0;

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
		};
	}


	record {
		var t = TempoClock.default;
		t.sched(4, {
			// s.record;
		});
	}

	stop {
		// s.stop;
	}

}

