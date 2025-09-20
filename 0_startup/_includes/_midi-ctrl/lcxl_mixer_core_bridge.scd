(
// LCXL → Mixer bridge  (banks 0..2)
// faders control level (dB), Row 3 controls pan

var dbSpec      = ControlSpec(-inf, 0.0, \db);
var panSpec     = ControlSpec(-1, 1, \linear);
var bankCount   = 3;     // banks: 0,1,2  => 24 slots, we use first 16
var slotsPerBank= 8;

// fetch ~m36_tr1 .. ~m36_tr16 from the current Environment
var trackAt = { |zeroBasedIndex|
    // zeroBasedIndex: 0..15
    var sym = ("m36_tr" ++ (zeroBasedIndex + 1)).asSymbol;
    currentEnvironment.at(sym)  // returns nil if not present
};

// bank/slot helpers
var trackIndexFor = { |bank, slot|  (bank * slotsPerBank) + (slot - 1) }; // slot is 1..8

var bindOne = { |bank, slot|
    var tr = trackAt.(trackIndexFor.(bank, slot));
    if (tr.notNil) {
        // fader b{bank}_f{slot} → level (dB)
        ~ccBind.(("b" ++ bank ++ "_f" ++ slot).asSymbol, { |val|
            tr.level_(dbSpec.map(val));
        });
        // Row3 b{bank}_t{slot}_r3 → pan (-1..1)
        ~ccBind.(("b" ++ bank ++ "_t" ++ slot ++ "_r3").asSymbol, { |val|
            tr.pan_(panSpec.map(val));
        });
    };
};

var b = 0, s;

if (~ccBind.notNil) {
    // bind all banks (0..2)
    while { b < bankCount } {
        s = 1;
        while { s <= slotsPerBank } {
            bindOne.(b, s);
            s = s + 1;
        };
        b = b + 1;
    };
    "[bridge] faders→level (dB) & row3→pan bound for banks 0..2".postln;
} {
    "[bridge] ~ccBind not found; router must load first".postln;
};
)

