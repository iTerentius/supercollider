// TouchOSC OSC Router
// Globals:
//   ~oscParam    — IdentityDictionary: Symbol(path) → Function { |val| } (val 0.0-1.0)
//   ~toscAddr    — NetAddr to tablet for feedback; edit IP before using
//   ~toscRecvFunc — stored ref for teardown via thisProcess.removeOSCRecvFunc
//
// TouchOSC config:
//   Send to:    [this machine's IP] : 57120   (SC default receive port)
//   Receive on: [tablet IP]         : 9000    (TOSC default, matches ~toscAddr below)
//
// OSC address convention mirrors LCXL key naming:
//   /tosc/b{bank}/s{strip}/f    — fader (level)
//   /tosc/b{bank}/s{strip}/r1   — knob row 1 (HPF)
//   /tosc/b{bank}/s{strip}/r2   — knob row 2 (LPF)
//   /tosc/b{bank}/s{strip}/r3   — knob row 3 (pan)
//   /tosc/master/f              — master fader
// TOSC page = bank, column = strip.

(

// Teardown previous instance on reload
if(~toscRecvFunc.notNil) {
    thisProcess.removeOSCRecvFunc(~toscRecvFunc);
    "TouchOSC: removed previous OSC receiver".postln;
};

~oscParam = IdentityDictionary.new;

// Feedback address — set tablet IP here
// TouchOSC default receive port: 9000
~toscAddr = NetAddr("192.168.1.100", 9000);

// Global dispatcher — routes all incoming OSC to ~oscParam callbacks
~toscRecvFunc = { |msg, time, replyAddr, recvPort|
    ~oscParam[msg[0]] !? { |cb| cb.(msg[1].asFloat) };
};
thisProcess.addOSCRecvFunc(~toscRecvFunc);

"TouchOSC router ready. SC listening on port" + NetAddr.localAddr.port ++ ".".postln;
"Edit ~toscAddr IP before using feedback.".postln;

)
