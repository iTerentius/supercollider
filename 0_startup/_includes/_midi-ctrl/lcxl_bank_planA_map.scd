(
// ---- Plan A default map filler (only runs if no learned map present)

var put, uid, chan, m;

// router must be present
if(~lcxl.isNil) {
    "[planA] router not present — skipping default map install".postln;
    ^nil;
};

// if you already learned/saved, do nothing
m = ~lcxl[\ccMap];
if(m.notEmpty) {
    "[planA] existing learned map detected  skipping defaults".postln;
    ^nil;
};

// capture uid + channel once
uid  = MIDIClient.sources.detect { |s|
    (s.device == "Launch Control XL") or: { s.name == "Launch Control XL" }
}.tryPerform(\uid) ?? { 0 };

chan = ~lcxl_config[\midiChan] ? 9;

// helper to add entries
put = { |key, cc|
    m[key.asSymbol] = (cc: cc, chan: chan, uid: uid);
};

// (optional) seed a tiny default so bindings have something if you didn't learn yet
// comment these out if you truly never want defaults:
put.(\b0_f1, 77); put.(\b0_f2, 78); put.(\b0_f3, 79); put.(\b0_f4, 80);
put.(\b0_f5, 81); put.(\b0_f6, 82); put.(\b0_f7, 83); put.(\b0_f8, 84);

"[planA] defaults applied".postln;
)

