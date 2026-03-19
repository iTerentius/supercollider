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
//   TOSC may send /tosc/... or tosc/... — dispatcher normalises to no leading slash:
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
// ~toscAddr = NetAddr("192.168.0.22", 9000);
~toscAddr = NetAddr("192.168.0.62", 9000);
// ~toscAddr = NetAddr("127.0.0.1", 9000);

// ---- Multi-tablet: fan sendMsg to multiple addresses ----
// Replace ~toscAddr with an Event that dispatches to all addresses in ~toscAddrs.
// Usage (e.g. mixer on tablet 1, pads on tablet 2):
//   ~toscAddrs = [NetAddr("192.168.0.62", 9000), NetAddr("192.168.0.xx", 9000)];
//   ~toscAddr  = (sendMsg: { |self, path ...args| ~toscAddrs.do { |a| a.sendMsg(path, *args) } });
// Undo: ~toscAddr = NetAddr("192.168.0.62", 9000);

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

// Global dispatcher — updates ~oscState and routes to ~oscParam callbacks.
// Strips leading slash from path so both /tosc/... and tosc/... work.
// XY controls send two values; splits into key/x and key/y sub-keys.
~toscRecvFunc = { |msg, time, replyAddr, recvPort|
    var path = msg[0].asString;
    var key  = (if(path[0] == $/) { path[1..] } { path }).asSymbol;
    var normVal = { |v| if(v.isKindOf(Boolean)) { v.binaryValue.asFloat } { v.asFloat } };
    if(msg.size > 2) {
        var xKey = (key.asString ++ "/x").asSymbol;
        var yKey = (key.asString ++ "/y").asSymbol;
        var xVal = normVal.(msg[1]);
        var yVal = normVal.(msg[2]);
        ~oscState[xKey] = xVal; ~oscParam[xKey] !? { |cb| cb.(xVal) };
        ~oscState[yKey] = yVal; ~oscParam[yKey] !? { |cb| cb.(yVal) };
    } {
        var val = normVal.(msg[1]);
        ~oscState[key] = val;
        ~oscParam[key] !? { |cb| cb.(val) };
    };
};
thisProcess.addOSCRecvFunc(~toscRecvFunc);

"TouchOSC router ready. SC listening on port" + NetAddr.localAddr.port ++ ".".postln;

)
