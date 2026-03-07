
(
/* 2025-10-19 conditional MIDI include loader with precedence:
   1. APC40 mkII -> apc40mk2_loader.scd
   2. Launch Control / Launch Control XL -> launch_controls_loader.scd
*/

var hasEndpoint, loadInclude, chosen;

MIDIClient.init;

// helper to test if any MIDI source or dest matches a regex string
hasEndpoint = { |rx|
    MIDIClient.sources.any { |ep|
        ep.device.asString.matchRegexp(rx) or: { ep.name.asString.matchRegexp(rx) }
    } or: {
        MIDIClient.destinations.any { |ep|
            ep.device.asString.matchRegexp(rx) or: { ep.name.asString.matchRegexp(rx) }
        }
    }
};

// helper to safely load includes
loadInclude = { |path|
    if(PathName(path).isFile) {
        ("[MIDI loader] executing " ++ path).postln;
        // this.executeFile(path);
        path.loadRelative;
    }{
        ("[MIDI loader] include not found: " ++ path).warn;
    }
};

// main logic: APC40 wins over LaunchControl
if(hasEndpoint.("APC40 mkII")) {
    chosen = "/apc40/apc40mk2_loader.scd";
    ("[MIDI loader] APC40 mkII detected").postln;
    // loadInclude.(chosen);
    chosen.loadRelative;
} {
    if(hasEndpoint.("Launch Control") or: { hasEndpoint.("Launch Control XL") }) {
        chosen = "/launch-control/lc_loader.scd";
        ("[MIDI loader] Launch Control detected").postln;
        // loadInclude.(chosen);
        chosen.loadRelative;
    } {
        "[MIDI loader] No known controllers detected — skipping include".postln;
    }
};

// KeyStep 32 loads independently (keyboard, not a competing controller)
if(hasEndpoint.("KeyStep 32")) {
    "/arturia/arturia-keystep-32.scd".loadRelative;
};

// ROLI LUMI KEY loads independently (keyboard, not a competing controller)
if(hasEndpoint.("LUMI Keys BLOCK")) {
    "/roli/lumi-m-piano.scd".loadRelative;
};
)
