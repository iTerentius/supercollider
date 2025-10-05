/* mb-override-taps.scd  date: 2025-10-04
   Tiny meter taps used by +MixingBoard extension
*/

(
// declare locals at the top
var have1, have2;

have1 = SynthDescLib.global.at(\mbTap1).notNil;
have2 = SynthDescLib.global.at(\mbTap2).notNil;

if(have1.not) {
    SynthDef(\mbTap1, { |tapBus=0, rate=30, id=0|
        var sig, l, trig;
        sig = In.ar(tapBus, 1);
        l = Amplitude.kr(sig, 0.01, 0.06).clip(0, 1);
        trig = Impulse.kr(rate);
        SendReply.kr(trig, "/mb/ovmeter", [id, l, l]);
        Silent.ar(0)
    }).add;
};

if(have2.not) {
    SynthDef(\mbTap2, { |tapBus=0, rate=30, id=0|
        var sig, l, r, trig;
        sig = In.ar(tapBus, 2);
        l = Amplitude.kr(sig[0], 0.01, 0.06).clip(0, 1);
        r = Amplitude.kr(sig[1], 0.01, 0.06).clip(0, 1);
        trig = Impulse.kr(rate);
        SendReply.kr(trig, "/mb/ovmeter", [id, l, r]);
        Silent.ar(0)
    }).add;
};
)
/* mixingboard-modern-meters-include-2025-10-04.scd
   Adds tall, built-in-looking stereo meters to each strip on newer ddwMixerChannel.
   Works by injecting a small meter bar at the top of each MixerChannelGUI strip
   and pushing existing controls down. No class files or skin subclasses required.
   ------------------------------------------------------------ */

// (
// /* ---------- config ---------- */
// ~mbm_defaultHeight = 75;   // pixels for the vertical meters
// ~mbm_labelHeight   = 14;   // name label height above the meters
// ~mbm_gapY          = 6;    // spacing below meters
// ~mbm_rate          = 30;   // GUI refresh rate via SendReply/OSC
//
// /* ---------- ensure tiny tap SynthDefs (post-fader by default) ---------- */
// ~mbm_ensureDefs = {
//     var have1, have2;
//     have1 = SynthDescLib.global.at(\mbmTap1).notNil;
//     have2 = SynthDescLib.global.at(\mbmTap2).notNil;
//     if(have1.not) {
//         SynthDef(\mbmTap1, { |tapBus=0, rate=30, id=0|
//             var sig, l, trig;
//             sig  = In.ar(tapBus, 1);
//             l    = Amplitude.kr(sig, 0.01, 0.06).clip(0, 1);
//             trig = Impulse.kr(rate);
//             SendReply.kr(trig, "/mbm/meter", [id, l, l]);
//             Silent.ar(0)
//         }).add;
//     };
//     if(have2.not) {
//         SynthDef(\mbmTap2, { |tapBus=0, rate=30, id=0|
//             var sig, l, r, trig;
//             sig  = In.ar(tapBus, 2);
//             l    = Amplitude.kr(sig[0], 0.01, 0.06).clip(0, 1);
//             r    = Amplitude.kr(sig[1], 0.01, 0.06).clip(0, 1);
//             trig = Impulse.kr(rate);
//             SendReply.kr(trig, "/mbm/meter", [id, l, r]);
//             Silent.ar(0)
//         }).add;
//     };
// };
//
// /* ---------- storage & helpers ---------- */
// ~mbm_registry   = ~mbm_registry   ?? { IdentityDictionary.new }; // gui -> meter bundle
// ~mbm_oscName    = \mbmMeters;     // one OSCdef that handles all strips
//
// ~mbm_findStripView = { |gui|
//     var view;
//     // Newer ddw often exposes .view or .views[0]
//     view = gui.tryPerform(\view);
//     view = view ?? { gui.tryPerform(\views).tryPerform(\at, 0) };
//     ^view
// };
//
// /* ---------- core attach ---------- */
// ~mbMetersAttachModern = { |board=nil, meterHeight, prePost=\post|
//     var meterClass, guis, chans, h, labelH, gapY, rate, attachedCount;
//     var ensureOsc, stripView, bundle, viewChildren, label, lpk, rpk, left, w, nameStr;
//     var meterW, topY, ch, tapBus, chansN, grp, synthName, idInt;
//     var view, stripCount, stripW, pad, topPanel, oscName, ids, synths, i;
//
//     meterHeight   = meterHeight ? ~mbm_defaultHeight;
//     labelH        = ~mbm_labelHeight;
//     gapY          = ~mbm_gapY;
//     rate          = ~mbm_rate;
//     h             = labelH + meterHeight + gapY;
//     attachedCount = 0;
//
//     ~mbm_ensureDefs.value;
//
//     meterClass = \MixerChannelGUI.asClass;
//
//     // collect GUIs from board.mixers first
//     guis = [];
//     if(board.notNil) {
//         chans = board.tryPerform(\mixers) ? [];
//         if(chans.notNil) {
//             guis = chans.collect { |c|
//                 c.tryPerform(\mcgui) ?? { c.tryPerform(\gui) } ?? { c.tryPerform(\mcGUI) }
//             }.select(_.notNil);
//         };
//     };
//
//     // if still empty and class is available, try class registry and filter to this board
//     if(guis.isEmpty and: { meterClass.notNil and: { meterClass.respondsTo(\all) } }) {
//         guis = meterClass.all ? [];
//         if(board.notNil) {
//             guis = guis.select { |g| g.tryPerform(\board) === board };
//         };
//     };
//
//     // fallback if no GUIs are visible in this ddw build
//     if(guis.isEmpty) {
//         "mbm: channel GUIs not exposed in this ddw version — using fallback top bar meters.".postln;
//
//         view = board.tryPerform(\w).tryPerform(\view);
//         stripCount = board.tryPerform(\mixers).size ? 0;
//         stripW = (board.tryPerform(\skin).tryPerform(\stripWidth) ? 50).asInteger;
//         pad = 6;
//         meterW = ((stripW - 6) * 0.46).asInteger.max(6);
//         topPanel = nil; oscName = \mbm_fallback_osc;
//         ids = Array.newClear(stripCount);
//         synths = Array.newClear(stripCount);
//
//         if(view.isNil or: { stripCount <= 0 }) { ^nil };
//
//         if(OSCdef(oscName).isNil) {
//             OSCdef(oscName, { |msg|
//                 var idx, l, r, pair;
//                 idx = msg[3].asInteger;
//                 l = msg[4].clip(0, 1);
//                 r = msg[5].clip(0, 1);
//                 pair = (idx < ids.size).if({ ids[idx] }, { nil });
//                 if(pair.notNil) { { pair[0].value = l; pair[1].value = r }.defer };
//             }, "/mbm/meter");
//         };
//
//         topPanel = CompositeView(view, Rect(2, 2, (stripW + pad) * stripCount, h))
//             .background_(Color.gray(0.92));
//
//         stripCount.do { |ii|
//             var x, chn, bus;
//             x = ii * (stripW + pad);
//             StaticText(topPanel, Rect(x+2, 0, stripW-4, labelH))
//                 .string_(board.mixers[ii].name.asString);
//             lpk = LevelIndicator(topPanel, Rect(x+2, labelH+2, meterW, meterHeight)).warning_(0.7).critical_(0.9);
//             rpk = LevelIndicator(topPanel, Rect(x+4+meterW, labelH+2, meterW, meterHeight)).warning_(0.7).critical_(0.9);
//             ids[ii] = [lpk, rpk];
//
//             chn = board.mixers[ii];
//             if(prePost == \pre) {
//                 bus = chn.inbus.index; chansN = chn.inbus.tryPerform(\numChannels) ? 2; grp = chn.synthgroup;
//             }{
//                 bus = chn.outbus.index; chansN = chn.outbus.tryPerform(\numChannels) ? 2; grp = chn.fadergroup ? chn.synthgroup;
//             };
//             chansN = (chansN ? 2).asInteger.clip(1,2);
//             synthName = (chansN == 1).if(\mbmTap1, \mbmTap2);
//             synths[ii] = Synth.tail(grp, synthName, [\tapBus, bus, \rate, rate, \id, ii]);
//         };
//
//         {
//             var win, prev;
//             win = board.tryPerform(\w);
//             if(win.notNil and: { win.respondsTo(\onClose) }) {
//                 prev = win.onClose;
//                 win.onClose = {
//                     synths.do(_.free);
//                     OSCdef(oscName).free;
//                     { topPanel.remove }.defer;
//                     if(prev.notNil) { prev.value };
//                 };
//             };
//         }.value;
//
//         ^stripCount;
//     };
//
//     // shared OSC for the normal GUI-attached path
//     ensureOsc = {
//         if(OSCdef(~mbm_oscName).isNil) {
//             OSCdef(~mbm_oscName, { |msg|
//                 var id, l, r, bb;
//                 id = msg[3].asInteger;
//                 l  = msg[4].clip(0, 1);
//                 r  = msg[5].clip(0, 1);
//                 bb = ~mbm_registry[id];
//                 if(bb.notNil) { { bb[\lpk].value = l; bb[\rpk].value = r }.defer };
//             }, "/mbm/meter");
//         };
//     };
//     ensureOsc.value;
//
//     // attach to each GUI strip
//     guis.do { |gui|
//         // skip if already attached
//         if(~mbm_registry.any({ |k, v| v[\gui] === gui })) { ^nil };
//
//         // find a view to anchor
//         stripView = gui.tryPerform(\view) ?? { gui.tryPerform(\views).tryPerform(\at, 0) };
//         if(stripView.isNil) { ^nil };
//
//         // geometry
//         left = 2;
//         w = (gui.tryPerform(\skin).tryPerform(\channelSize).tryPerform(\x) ? 50) - 6;
//         meterW = (w * 0.46).asInteger.max(6);
//         topY = labelH + 2;
//         nameStr = gui.tryPerform(\mixer).tryPerform(\name).asString;
//
//         // build container at top of strip
//         bundle = IdentityDictionary.new;
//         bundle[\gui]   = gui;
//         bundle[\view]  = stripView;
//         bundle[\panel] = CompositeView(stripView, Rect(0, 0, stripView.bounds.width, h))
//             .background_(Color.gray(0.92));
//
//         label = StaticText(bundle[\panel], Rect(left, 0, w, labelH)).string_(nameStr);
//         lpk = LevelIndicator(bundle[\panel], Rect(left, topY, meterW, meterHeight)).warning_(0.7).critical_(0.9);
//         rpk = LevelIndicator(bundle[\panel], Rect(left + meterW + 4, topY, meterW, meterHeight)).warning_(0.7).critical_(0.9);
//         bundle[\lpk] = lpk; bundle[\rpk] = rpk;
//
//         // push original controls down
//         viewChildren = stripView.children.copy;
//         viewChildren.do { |v|
//             if(v !== bundle[\panel]) {
//                 v.bounds = Rect(v.bounds.left, v.bounds.top + h, v.bounds.width, v.bounds.height);
//             };
//         };
//         stripView.bounds = Rect(stripView.bounds.left, stripView.bounds.top, stripView.bounds.width, stripView.bounds.height + h);
//
//         // audio tap
//         ch = gui.tryPerform(\mixer);
//         if(prePost == \pre) {
//             tapBus = ch.inbus.index; chansN = ch.inbus.tryPerform(\numChannels) ? 2; grp = ch.synthgroup;
//         }{
//             tapBus = ch.outbus.index; chansN = ch.outbus.tryPerform(\numChannels) ? 2; grp = ch.fadergroup ? ch.synthgroup;
//         };
//         chansN = (chansN ? 2).asInteger.clip(1,2);
//         synthName = (chansN == 1).if(\mbmTap1, \mbmTap2);
//
//         idInt = gui.identityHash;
//         bundle[\id]    = idInt;
//         bundle[\synth] = Synth.tail(grp, synthName, [\tapBus, tapBus, \rate, rate, \id, idInt]);
//
//         ~mbm_registry[idInt] = bundle;
//         attachedCount = attachedCount + 1;
//     };
//
//     ("mbm: meters attached on " ++ attachedCount ++ " strips (" ++ prePost ++ ")").postln;
//     ^attachedCount
// };
//
// /* ---------- detach & cleanup ---------- */
// ~mbMetersKillModern = {
//     var ids;
//     ids = ~mbm_registry.keys;
//     ids.do { |id|
//         var b;
//         b = ~mbm_registry[id];
//         if(b.notNil) {
//             if(b[\synth].notNil) { b[\synth].free };
//             if(b[\panel].notNil) { { b[\panel].remove }.defer };
//         };
//         ~mbm_registry.removeAt(id);
//     };
//     if(OSCdef(~mbm_oscName).notNil) { OSCdef(~mbm_oscName).free };
//     "mbm: meters removed".postln;
// };
// )
//
