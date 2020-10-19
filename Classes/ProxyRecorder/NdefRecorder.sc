NdefRecorder {

	var <nodes;
	var <>folder;
	var <>headerFormat = "aiff", <>sampleFormat = "float";
/*	var dateTime  = Date.getDate.format("%Y%m%d-%Hh%m");
	dateTime.postln;*/

	*new { |subfolder = nil |
		^super.newCopyArgs().init(subfolder)
	}

	init { | subfolder = nil |
		nodes  = ();
		if(subfolder != nil,
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title +/+ subfolder },
			{folder = Platform.userAppSupportDir +/+ "Recordings" +/+ Document.current.title  }
		);

		File.mkdir(folder);
	}

	free {
		nodes.do(_.clear);
		nodes = nil;
	}

	add { |proxies|
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

	open { |proxies|
		proxies.do{ |proxy, i|
			var dateTime  = Date.getDate.format("%Y%m%d-%Hh%m");
			var fileName  = ("%/%-%.%").format(
				folder, dateTime, proxy.asCompileString, headerFormat
			);

			nodes[i].open(fileName, headerFormat, sampleFormat);
		}
	}

	record { |paused=false|
		nodes.do(_.record(paused, TempoClock.default, -1))
	}

	stop {
		this.close
	}

	close {
		nodes.do(_.close)
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


