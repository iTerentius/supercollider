// TouchOSC FX/Synth Parameter Binding
// Depends on tosc-router.scd (~oscParam, ~oscState, ~toscAddr).
//
// Globals:
//   ~toscFXLabel.(page, slot, name)               — set slot group label (e.g. "greyhole")
//   ~toscFXBind.(page, slot, ctrl, cb, label)      — bind knob/toggle/fader + set label
//   ~toscFXBindXY.(page, slot, xyN, xCb, yCb, label) — bind XY pad + set label
//   ~toscFXSync.(page, slot, ctrl, val)            — push initial value to TOSC
//   ~toscFXSyncXY.(page, slot, xyN, xVal, yVal)   — push initial XY values to TOSC
//
// OSC addresses (TOSC → SC):
//   tosc/fx/{page}/fx{slot}/r{n}        — knob    (val 0.0–1.0)
//   tosc/fx/{page}/fx{slot}/xy{n}       — XY pad  (splits to /x and /y)
//   tosc/fx/{page}/fx{slot}/t{n}        — toggle  (val 0.0 or 1.0)
//   tosc/fx/{page}/fx{slot}/f           — fader   (val 0.0–1.0)
//
// OSC addresses (SC → TOSC feedback):
//   /tosc/fx/{page}/fx{slot}/label          — slot name label
//   /tosc/fx/{page}/fx{slot}/r{n}/label     — knob label
//   /tosc/fx/{page}/fx{slot}/xy{n}/label    — XY label
//   /tosc/fx/{page}/fx{slot}/t{n}/label     — toggle label
//   /tosc/fx/{page}/fx{slot}/f/label        — fader label (if present)
//
// TOSC control Lua scripts — see ref_touchosc.scd for full scripts.
// All controls use self.tag for page number.

(

// ---- Set the slot name label (loose label inside fx1..fx5) ----
~toscFXLabel = { |page, slot, name|
    ~toscAddr.sendMsg("/tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/label", name);
};

// ---- Bind a knob (r1-r8), toggle (t1-t2), or fader (f) ----
// ctrl   : Symbol — \r1..\r8, \t1, \t2, \f
// cb     : Function { |val| }  val 0.0-1.0
// label  : String shown on control (nil to skip)
~toscFXBind = { |page, slot, ctrl, cb, label|
    var base = "tosc/fx/" ++ page ++ "/fx" ++ slot;
    var addr = (base ++ "/" ++ ctrl).asSymbol;
    ~oscParam[addr] = cb;
    if(label.notNil) {
        ~toscAddr.sendMsg("/tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/" ++ ctrl ++ "/label", label);
    };
};

// ---- Bind an XY pad (xy1, xy2) ----
// xyN    : Integer 1 or 2
// xCb    : Function { |val| }  x axis 0.0-1.0
// yCb    : Function { |val| }  y axis 0.0-1.0
// label  : String for the XY pad label (nil to skip)
~toscFXBindXY = { |page, slot, xyN, xCb, yCb, label|
    var base = "tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/xy" ++ xyN;
    ~oscParam[(base ++ "/x").asSymbol] = xCb;
    ~oscParam[(base ++ "/y").asSymbol] = yCb;
    if(label.notNil) {
        ~toscAddr.sendMsg("/tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/xy" ++ xyN ++ "/label", label);
    };
};

// ---- Push initial value to TOSC (knob/toggle/fader) ----
~toscFXSync = { |page, slot, ctrl, val|
    var addr = ("tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/" ++ ctrl).asSymbol;
    ~oscState[addr] = val;
    ~toscAddr.sendMsg("/tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/" ++ ctrl, val);
};

// ---- Push initial XY values to TOSC ----
~toscFXSyncXY = { |page, slot, xyN, xVal, yVal|
    var base = "tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/xy" ++ xyN;
    ~oscState[(base ++ "/x").asSymbol] = xVal;
    ~oscState[(base ++ "/y").asSymbol] = yVal;
    ~toscAddr.sendMsg("/tosc/fx/" ++ page ++ "/fx" ++ slot ++ "/xy" ++ xyN, xVal, yVal);
};

"TouchOSC FX router loaded.".postln;

)
