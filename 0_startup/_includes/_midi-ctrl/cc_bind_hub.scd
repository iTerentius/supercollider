(
// =====================================================================
// CC Bind Hub — one-liners for both controllers
// - ~ccb.(key, { |x| ... })                  -> bind on default device (see ~ccdev)
// - ~ccb.(\lc,  key, { |x| ... })            -> bind on Launch Control (non-XL)
// - ~ccb.(\lcx, key, { |x| ... })            -> bind on Launch Control XL (top-rows router)
// - ~ccu.(key)   or ~ccu.(\lcx, key)         -> unbind
// - ~ccdev.(\lcx | \lc)                      -> set default device for 2-arg ~ccb
// - ~ccshow.() or ~ccshow.(\lcx | \lc)       -> list current binds
//
// Requires these to be loaded first:
//   LCXL param router:  ~lcxlBindParam / ~lcxlUnbindParam  (and ~lcxlParam[\handlers])
//   LC  param router:   ~lcnBindParam  / ~lcnUnbindParam   (and ~lcn[\handlers])
// =====================================================================

~ccb_env = ~ccb_env ? ();
~ccb_env[\default] = ~ccb_env[\default] ? \lcx;   // default device; change via ~ccdev.(\lc)

// capability checks
~ccb_env[\hasLC]   = { ~lcnBindParam.notNil  and: { ~lcn.notNil } };
~ccb_env[\hasLCXL] = { ~lcxlBindParam.notNil and: { ~lcxlParam.notNil } };

// internal bind/unbind
~ccb_env[\doBind] = { |dev, key, fn|
    var ok = false;
    if(dev == \lc or: { dev == \lcn }) {
        if(~ccb_env[\hasLC].()) { ~lcnBindParam.(key, fn); ok = true }
        { "[ccb] Launch Control router not loaded.".postln };
    }{
    if(dev == \lcx or: { dev == \lcxl }) {
        if(~ccb_env[\hasLCXL].()) { ~lcxlBindParam.(key, fn); ok = true }
        { "[ccb] Launch Control XL router not loaded.".postln };
    }{
        ("[ccb] Unknown device: %".format(dev)).postln;
    }};
    ok;
};

~ccb_env[\doUnbind] = { |dev, key|
    var ok = false;
    if(dev == \lc or: { dev == \lcn }) {
        if(~ccb_env[\hasLC].()) { ~lcnUnbindParam.(key); ok = true };
    }{
    if(dev == \lcx or: { dev == \lcxl }) {
        if(~ccb_env[\hasLCXL].()) { ~lcxlUnbindParam.(key); ok = true };
    }{
        ("[ccb] Unknown device: %".format(dev)).postln;
    }};
    ok;
};

// --- public shorthands ---

// ~ccb.(key, fn)  OR  ~ccb.(\lcx, key, fn)
~ccb = { |a, b = nil, c = nil|
    var dev, key, fn;
    if(c.notNil) { dev = a; key = b; fn = c } { dev = ~ccb_env[\default]; key = a; fn = b };
    if(fn.isNil) { "[ccb] Missing function to bind.".postln } { ~ccb_env[\doBind].(dev, key, fn) };
};

// ~ccu.(key)  OR  ~ccu.(\lc, key)
~ccu = { |a, b = nil|
    var dev, key;
    if(b.notNil) { dev = a; key = b } { dev = ~ccb_env[\default]; key = a };
    ~ccb_env[\doUnbind].(dev, key);
};

// choose default device for 2-arg ~ccb
~ccdev = { |dev|
    if(dev == \lc or: { dev == \lcn } or: { dev == \lcx } or: { dev == \lcxl }) {
        ~ccb_env[\default] = (dev == \lcn).if({ \lc }, { dev });
        "[ccb] default device -> %".format(~ccb_env[\default]).postln;
    }{
        ("[ccb] Unknown device: %".format(dev)).postln;
    };
};

// show current binds
~ccshow = { |dev = nil|
    var show = { |tag, dict|
        var keys = dict.notNil.if({ dict.keys.asArray.sort }, { [] });
        (("[%] % binds: " ++ keys).format(tag)).postln;
    };
    if(dev.isNil) {
        show.(\LCXL, ~lcxlParam.notNil.if({ ~lcxlParam[\handlers] }, { nil }));
        show.(\LC,   ~lcn.notNil.if({ ~lcn[\handlers] }, { nil }));
    }{
        if(dev == \lc or: { dev == \lcn }) {
            show.(\LC, ~lcn.notNil.if({ ~lcn[\handlers] }, { nil }));
        }{
            show.(\LCXL, ~lcxlParam.notNil.if({ ~lcxlParam[\handlers] }, { nil }));
        };
    };
};
)

