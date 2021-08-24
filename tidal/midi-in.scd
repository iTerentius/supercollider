(
var on, off, cc;
var osc;

osc = NetAddr.new("127.0.0.1", 6010);

MIDIClient.init;
MIDIIn.connectAll;

on = MIDIFunc.noteOn({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, val/127);
	("CC: " + num + " : " + "Value: " + val).postln;
});

off = MIDIFunc.noteOff({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, 0);
	("CC: " + num + " : " + "Value: " + val).postln;
});

cc = MIDIFunc.cc({ |val, num, chan, src|
    osc.sendMsg("/ctrl", num.asString, val/127);
	("CC: " + num + " : " + "Value: " + val).postln;
});

if (~stopMidiToOsc != nil, {
    ~stopMidiToOsc.value;
});

~stopMidiToOsc = {
    on.free;
    off.free;
    cc.free;
};
)

// Evaluate the line below to stop it.
~stopMidiToOsc.value;