// lcxl_force_rearm.v1.scd  2025-09-26 19:41
// Force-resolve LCXL UID, set channel, and re-arm CC + bank note defs
// Vars declared at top, no ) in comments
(
var ep, uid, ch0;

// detect endpoint and cache UID
ep  = MIDIClient.sources.detect { |x| x.device == "Launch Control XL" and: { x.name == "Launch Control XL" } };
uid = ep.notNil.if({ ep.uid }, { ~lcxlParam !? { ~lcxlParam[\srcID] } });
~lcxlParam = ~lcxlParam ? ();
~lcxlParam[\srcID] = uid;

// set expected channel and options
ch0 = ~lcxlParam[\chan0] ? 8;            // set to 8 unless already set
~lcxlParam[\chan0] = ch0;
~lcxlParam[\strictChan] = true;          // enforce channel match
~lcxlParam[\debug] = false;              // set true to print each CC
~lcxlParam[\prefix] = (~lcxlParam[\prefix] ? "");

// arm
~lcxlArmLocked !? { ~lcxlArmLocked.() };

// quick peek def to prove CC handler is hot
MIDIdef.free(\lcxl_cc_peek_once);
MIDIdef.cc(\lcxl_cc_peek_once, { |val, cc, chan, src|
    ["[LCXL PEAK]", "cc", cc, "val", val, "chan0", chan].postln;
    MIDIdef.free(\lcxl_cc_peek_once);
}, nil, ch0, uid);

"[LCXL FORCE] uid %, chan0 %, strict true  armed".format(uid, ch0).postln;
)
