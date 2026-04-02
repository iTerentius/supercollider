MIDIClient.init;
var out, dev, nam;
out = nil;
MIDIClient.destinations.do { |ep|
    dev = ep.device !? { ep.device.asString } ?? "";
    nam = ep.name !? { ep.name.asString } ?? "";
    if(out.isNil and: { (dev == "APC40 mkII") and: { nam == "APC40 mkII" } }) {
        out = MIDIOut.newByName(ep.device, ep.name);
        "Found by exact match".postln;
    };
};
if(out.isNil) {
    MIDIClient.destinations.do { |ep|
        dev = ep.device !? { ep.device.asString } ?? "";
        nam = ep.name !? { ep.name.asString } ?? "";
        if(out.isNil and: { dev.contains("APC") or: { nam.contains("APC") } }) {
            out = MIDIOut.newByName(ep.device, ep.name);
            "Found by substring match".postln;
        };
    };
};
if(out.isNil) { "[APC] could not open APC out".warn; } { out.postln; };
0.exit;
