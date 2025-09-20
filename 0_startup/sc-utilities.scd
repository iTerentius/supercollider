// Recording
(
~prepRecord = {
  ~recPath = Platform.userHomeDir +/+ "Music/SuperCollider\ Recordings";
  // ~recPath = Platform.userHomeDir +/+ "/Volumes/Hypostatic\ Work/Hypostatic\ Sound/sc_recordings/";
  ~recFileName = "jam";
  ~recChannels = 4;
}
// Example (using your ~vars set above):

// start on the next bar; stop manually whenever you want
~quantRecord.(nil, ~recChannels, ~recPath, ~recFileName);
)

s.stopRecording; // stop recording

// Launch Control XL learn and bind
// Run these in order if starting fresh
~lcxl_config[\midiChan] = 9
~installCCByNameRouter.();
~setBank.(0);
~learnFaders.();
~learnRow1.();
~learnRow2.();
~learnRow3.();
~printMapAll.();
~ccSanity.();

~lcxl_config[\midiChan] = 9;   // should match your LCXL template (9 == “10” on the device)
~ccClear.();                   // start with a blank map in memory
~installCCByNameRouter.();     // (re)create the named keys b0_f1, b0_t1_r3, etc.
~setBank.(0);                  // should print: [ bank  b0 ]
~printMapAll.();               // expect the header and 0 entries (blank, that’s fine pre-learn)
~lcxl_config;

~lcStartLearnRow.(1);

// Example bind
~ccBindParam.(\b0_f1, \track, \amp, ControlSpec(0, 0.5, \lin, 0, 0));

// Persist
~ccSave.();
~ccLoad.();

// Sample Loader
~loadSamplesRecursive.("~/Music/supercollider/_samples/Field/");

~printTree.();

NodeTreeView(s).start;
s.queryAllNodes;

// 2025-09-19  LCXL learn hotfix  ensure r[\defs] exists and safe-learn helpers
(
var ensureRouter, safeWrapLearn, safeRowLearner, safeFaderLearner;

// make sure ~ccRouter exists and has r[\defs]
ensureRouter = {
    var r;
    r = ~ccRouter ?? { if(~installCCByNameRouter.notNil) { ~installCCByNameRouter.() } { IdentityDictionary.new } };
    if(r[\defs].isNil) { r[\defs] = IdentityDictionary.new; "[fix] created router defs dict".postln };
    if(r[\ccMap].isNil) { r[\ccMap] = IdentityDictionary.new; "[fix] created router ccMap dict".postln };
    if(r[\bank].isNil) { r[\bank] = 0; "[fix] initialized bank 0".postln };
    if(r[\chan].isNil and: { ~lcxl_config.notNil }) { r[\chan] = ~lcxl_config[\midiChan] };
    ~ccRouter = r;
    r
};

// tiny wrapper to announce and return router
safeWrapLearn = { |fn|
    var r;
    r = ensureRouter.();
    "[ learning active — move the requested control now ]".postln;
    fn.value;
    r
};

// generalized row learner  uses chan+1 capture and frees old learnAny safely
safeRowLearner = { |label="Row", ccList, baseNames|
    var r, names, idx, def, wantChan, devUid, defaults;
    r = ensureRouter.();
    defaults = (13..20).asArray;
    ccList = ccList ?? { defaults };
    names = ~withBankNames.(baseNames);
    idx = 0;
    wantChan = r[\chan];  // your config expects 9 or 8 depending on template
    devUid = if(r[\device].notNil) { r[\device].uid } { nil };

    if(r[\defs].notNil and: { r[\defs][\learnAny].notNil }) { r[\defs][\learnAny].free };
    MIDIdef.cc(\lcxl_learn_any).free;

    ("LEARN " ++ label ++ " b" ++ ~getBank.() ++ " — move " ++ names[idx]).postln;

    def = MIDIdef.cc(\lcxl_learn_any, { |val, cc, chan, src|
        var okChan, okDev, name, entry, prev;
        okChan = ((wantChan == (chan+1)) or: { wantChan.isNil });
        okDev  = (devUid.isNil) or: { src == devUid };

        if(okChan and: { okDev }) {
            prev = if(idx > 0) { r[\ccMap][names[idx-1]] } { nil };
            if(prev.notNil and: { prev[\cc] == cc }) {
                ("[ skip duplicate cc:" ++ cc ++ " for " ++ names[idx] ++ " ]").postln;
            }{
                name  = names[idx];
                entry = ( 'cc': cc, 'chan': chan+1, 'uid': src );
                r[\ccMap][name] = entry;

                ("[ learned  " ++ name ++ " -> cc:" ++ cc
                    ++ " chan:" ++ (chan+1) ++ " uid:" ++ src ++ " ]").postln;

                idx = idx + 1;

                if(idx >= names.size) {
                    MIDIdef.cc(\lcxl_learn_any).free;
                    def.free;
                    r[\defs][\learnAny] = nil;
                    ("[ learn  ok " ++ label ++ " names:" ++ names ++ " ]").postln;
                }{
                    ("Move " ++ names[idx]).postln;
                };
            };
        };
    });

    def.permanent_(true);
    r[\defs][\learnAny] = def;
    r
};

// dedicated fader learner for \f1..\f8
safeFaderLearner = {
    var base, want;
    base = [\f1,\f2,\f3,\f4,\f5,\f6,\f7,\f8];
    want = [77,78,79,80,81,82,83,84];  // defaults if you just slide left to right
    safeRowLearner.("Faders", want, base);
};

// replace your public learn funcs with safe wrappers
~learnFaders = { safeWrapLearn.({ safeFaderLearner.() }) };
~learnRow1   = { safeWrapLearn.({ safeRowLearner.("Row1", [13,14,15,16,17,18,19,20], [\t1_r1,\t2_r1,\t3_r1,\t4_r1,\t5_r1,\t6_r1,\t7_r1,\t8_r1]) }) };
~learnRow2   = { safeWrapLearn.({ safeRowLearner.("Row2", [29,30,31,32,33,34,35,36], [\t1_r2,\t2_r2,\t3_r2,\t4_r2,\t5_r2,\t6_r2,\t7_r2,\t8_r2]) }) };
~learnRow3   = { safeWrapLearn.({ safeRowLearner.("Row3", [49,50,51,52,53,54,55,56], [\t1_r3,\t2_r3,\t3_r3,\t4_r3,\t5_r3,\t6_r3,\t7_r3,\t8_r3]) }) };

// quick print helpers
~printMapAll = {
    var r;
    r = ensureRouter.();
    "---- CC Map ALL KEYS ----".postln;
    r[\ccMap].keysValuesDo { |k, v| (k.asString ++ " -> cc:" ++ v[\cc] ++ " chan:" ++ v[\chan] ++ " uid:" ++ v[\uid]).postln };
    "---------------------------".postln;
};

"[hotfix ready] run ~setBank.(0) then ~learnFaders.() then rows".postln;
)
