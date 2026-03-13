// TouchOSC OSC Router
// Globals:
//   ~oscParam    — IdentityDictionary: Symbol(path) → Function { |val| } (val 0.0-1.0)
//   ~oscState    — IdentityDictionary: Symbol(path) → Float  (last known normalized value)
//   ~toscAddr    — NetAddr to tablet; edit IP before using
//   ~toscRecvFunc — stored ref for teardown via thisProcess.removeOSCRecvFunc
//
//   ~toscSend.(addr, val) — apply callback + store in ~oscState + send to TOSC
//   ~toscSync.()          — push all ~oscState to TOSC (call after reboot or page switch)
//   ~toscStateSave.(key)  — save ~oscState to Archive.global under key (default: \default)
//   ~toscStateLoad.(key)  — restore from Archive, apply and sync to TOSC
//
// TouchOSC config:
//   Send to:    [this machine's IP] : 57120   (SC default receive port)
//   Receive on: [tablet IP]         : 9000    (TOSC default, matches ~toscAddr below)
//
// OSC address convention mirrors LCXL key naming:
//   TOSC sends /tosc/b{n}/s{n}/f — SC strips leading slash, dict keys have none:
//   tosc/b{bank}/s{strip}/f    — fader (level)
//   tosc/b{bank}/s{strip}/r1   — knob row 1 (HPF)
//   tosc/b{bank}/s{strip}/r2   — knob row 2 (LPF)
//   tosc/b{bank}/s{strip}/r3   — knob row 3 (pan)
//   tosc/master/f              — master fader
// TOSC page = bank, column = strip.

(

// Teardown previous instance on reload
if(~toscRecvFunc.notNil) {
    thisProcess.removeOSCRecvFunc(~toscRecvFunc);
    "TouchOSC: removed previous OSC receiver".postln;
};

~oscParam = IdentityDictionary.new;
~oscState = IdentityDictionary.new;

// Feedback address — set tablet IP here
// TouchOSC default receive port: 9000
~toscAddr = NetAddr("192.168.0.22", 9000);

// Send a value to TOSC, apply its callback, and store in ~oscState.
// addr: Symbol (no leading slash). TOSC receives with leading slash prepended.
~toscSend = { |addr, val|
    ~oscState[addr] = val;
    ~toscAddr.sendMsg("/" ++ addr.asString, val);
    ~oscParam[addr] !? { |cb| cb.(val) };
};

// Push all tracked state to TOSC. Call on startup or after TOSC reconnects.
~toscSync = {
    ~oscState.keysValuesDo { |addr, val|
        ~toscAddr.sendMsg("/" ++ addr.asString, val);
    };
    ("TouchOSC: synced" + ~oscState.size + "controls.").postln;
};

// Archive helpers — key is a Symbol, e.g. \myProject
~toscStateSave = { |key = \default|
    Archive.global.put((\toscState_ ++ key).asSymbol, ~oscState.copy);
    ("TouchOSC state saved:" + key).postln;
};

~toscStateLoad = { |key = \default|
    var state = Archive.global.at((\toscState_ ++ key).asSymbol);
    if(state.notNil) {
        state.keysValuesDo { |addr, val| ~toscSend.(addr, val) };
        ("TouchOSC state loaded:" + key + "(" ++ state.size ++ "controls).").postln;
    } {
        ("TouchOSC state not found:" + key).warn;
    };
};

// Global dispatcher — updates ~oscState and routes to ~oscParam callbacks
~toscRecvFunc = { |msg, time, replyAddr, recvPort|
    var val = msg[1].asFloat;
    ~oscState[msg[0]] = val;
    ~oscParam[msg[0]] !? { |cb| cb.(val) };
};
thisProcess.addOSCRecvFunc(~toscRecvFunc);

"TouchOSC router ready. SC listening on port" + NetAddr.localAddr.port ++ ".".postln;

)
