(
// Expects ~dirt already running
s.waitForBoot {
    if (~dirt.isNil) { "SuperDirt not started yet".warn; ^nil; };

    ~mixer = ~mixer ?? { SuperDirtMixer(~dirt) };
    s.sync;
    ~mixer.setMasterBus(0);
    ~mixer.gui; // comment out if you don’t want it to open on boot
};
)


// // Make sure SuperDirt is installed (or update it) and switch to develop
// Quarks.install("https://github.com/musikinformatik/SuperDirt");
// Quarks.checkout("SuperDirt", "develop");   // important for the mixer
// Quarks.update("SuperDirt");
//
// // Install JSONlib (for preset JSON)
// Quarks.install("https://github.com/musikinformatik/JSONlib");
//
// // **Important**: use the *thgrund* fork of EQui (remove any old EQui first)
// (   // remove old EQui once via GUI if present
//     Quarks.gui;  // Language → Quarks → locate EQui → open Local path → delete folder → Close
// );
// Quarks.install("https://github.com/thgrund/EQui");
//
// // (Optional) update SuperDirtMixer itself if you installed earlier
// Quarks.update("SuperDirtMixer");
//
// // Recompile the class library
// thisProcess.recompile;


