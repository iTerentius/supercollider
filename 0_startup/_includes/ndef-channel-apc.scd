// APC40 mkII bindings for the Ndef channel strips in ndef-channel-16s.scd.
// Mirrors ~apcMixBind from mixer-channel-16s.scd, adapted for NodeProxy
// named controls (.set) instead of MixerChannel (.level_/.pan_).
//
// NOT loaded by default. Load AFTER ndef-channel-16s.scd:
//   "_includes/ndef-channel-apc.scd".loadRelative;
//
// Globals: ~apcNdefChanBind
// Layout mirrors mixer-channel-16s.scd's APC scheme:
//   Bank 0: ins1-8 (fader + pan row1 + HPF row2 + LPF row3)
//   Bank 1: ins9-12, fxsVerb, fxsDelay (no pan on returns)
(
~apcNdefChanBind = { |bank, strip, name, pan = true|
    var b = "b" ++ bank ++ "_s" ++ strip;
    ~apcBindParam.((b ++ "_f").asSymbol, { |x| Ndef(name).set(\amp, x) });
    if(pan) {
        ~apcBindParam.((b ++ "_r1").asSymbol, { |x| Ndef(name).set(\pan, x.linlin(0, 1, -1, 1)) });
    };
    ~apcBindParam.((b ++ "_r2").asSymbol, { |x| Ndef(name).set(\hpfreq, x.linexp(0.001, 1.0, 20, 2000)) });
    ~apcBindParam.((b ++ "_r3").asSymbol, { |x| Ndef(name).set(\lpfreq, x.linexp(0.001, 1.0, 200, 20000)) });
};

if(~apcBindParam.notNil) {
    "Binding APC40 mkII controls to Ndef channels...".postln;

    ~apcBindParam.(\master_f, { |x| Ndef(\master).set(\amp, x.linlin(0, 1, 0, 4.0)) });

    // Bank 0: ins1-8
    ~apcNdefChanBind.(0, 1, \ins1);  ~apcNdefChanBind.(0, 2, \ins2);
    ~apcNdefChanBind.(0, 3, \ins3);  ~apcNdefChanBind.(0, 4, \ins4);
    ~apcNdefChanBind.(0, 5, \ins5);  ~apcNdefChanBind.(0, 6, \ins6);
    ~apcNdefChanBind.(0, 7, \ins7);  ~apcNdefChanBind.(0, 8, \ins8);

    // Bank 1: ins9-12, returns (no pan)
    ~apcNdefChanBind.(1, 1, \ins9);   ~apcNdefChanBind.(1, 2, \ins10);
    ~apcNdefChanBind.(1, 3, \ins11);  ~apcNdefChanBind.(1, 4, \ins12);
    ~apcNdefChanBind.(1, 5, \fxsVerb,  false);
    ~apcNdefChanBind.(1, 6, \fxsDelay, false);

    "APC40 mkII bindings complete (Ndef channels, banks 0-1).".postln;
} {
    "APC40 mkII not detected, skipping Ndef channel bindings.".postln;
};
)
