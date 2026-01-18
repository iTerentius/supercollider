// Launchpad bindings
(
if(~lpMini.notNil) {
    ~lpBind.([1, 1], \perc, 20, ~link, 4);
    ~lpBind.([1, 2], \v1, 21, ~link, 4);
    ~lpBind.([1, 3], \synth_layer, 22, ~link, 4);  // composite
    ~lpBind.([1, 4], \synth_midi, 23, ~link, 4);   // MIDI only
    ~lpBind.([1, 5], \synth_sc, 24, ~link, 4);     // SC only
    ~lpBind.([8, 1], \cc_mod_1, 45, ~link, 4);
    ~lpBind.([8, 8], \score, 9, ~link, 4);
};
)
