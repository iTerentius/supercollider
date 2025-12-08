
(
~play_bd_2025_12_08 = {
    var clock;
    clock = TempoClock.default;
    Pdef(\bd_main_2025_12_08).play(clock);
};

~stop_bd_2025_12_08 = {
    Pdef(\bd_main_2025_12_08).stop;
};

// Example live modifications
// Re eval only these small blocks during performance

// Variation 1 – change the main phrase dur structure

Pdefn(\bd1_phrase_main_2025_12_08,
    Pseq([
        Pn(Pdefn(\bd1_dur_a_2025_12_08), 1),
        Pn(Pdefn(\bd1_dur_c_2025_12_08), 2)
    ], inf)
);

// Variation 2 – change the underlying dur pattern

Pdefn(\bd1_dur_c_2025_12_08,
    Pseq([
        1/16 ! 4,
        1/8 ! 2,
        Rest(),
        1/4
    ].flat, 1)
);

// Variation 3 – change sample selection

Pdefn(\bd1_bufs_2025_12_08,
    Pn(
        Pser(
            ~samplesTree.at(\bass_drums).asArray.scramble,
            6
        ),
        inf
    )
);
)
