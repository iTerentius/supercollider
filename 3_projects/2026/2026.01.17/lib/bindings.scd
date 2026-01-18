// Launchpad Mini bindings
(
if(~lpMini.notNil) {
    // Percussion
    ~lpBind.([1, 1], \perc_1_m, 20, ~link, 4);

    // Melodic parts
    ~lpBind.([1, 2], \v1, 20, ~link, 4);
    ~lpBind.([1, 3], \bass_1, 21, ~link, 4);
    ~lpBind.([1, 4], \mel_1, 22, ~link, 4);
    ~lpBind.([1, 5], \mel_2, 23, ~link, 4);
    ~lpBind.([1, 6], \drone, 33, ~link, 4);
    ~lpBind.([1, 7], \chords, 34, ~link, 4);

    // CC modulators
    ~lpBind.([8, 1], \cc_mod_1, 45, ~link, 4);
    ~lpBind.([8, 2], \cc_mod_2, 45, ~link, 4);

    // Full arrangement
    ~lpBind.([8, 8], \score, 9, ~link, 4);

    // Variations (row 2)
    ~lpBind.([2, 8], { Pbindef(\bass_1_pbd, \degree, Pseq((0..7), inf)) });
    ~lpBind.([3, 8], { Pbindef(\bass_1_pbd, \dur, 1) });
    ~lpBind.([4, 8], { Pbindef(\bass_1_pbd, \dur, Pbjorklund2(Pkey(\step1), 8, inf)/Pkey(\div)) });
};
)
