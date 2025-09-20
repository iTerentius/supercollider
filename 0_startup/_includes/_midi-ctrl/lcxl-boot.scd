// 2025-09-19  lcxl-boot v5  minimal config only  no install calls
(
var cfg, devName, chan;

// config  raw SC MIDI channel numbering 0..15
devName = "Launch Control XL";
chan    = 8;

// merge or set config without touching the router
cfg = ~lcxl_config ?? ();
cfg[\deviceName] = cfg[\deviceName] ? devName;
cfg[\midiChan]   = chan;
cfg[\mapPath]    = cfg[\mapPath] ? (Platform.userHomeDir +/+ "Music/supercollider/_lcxl_cc_map.txt");
~lcxl_config = cfg;

("router config set  device:" ++ cfg[\deviceName]
  ++ " chan raw:" ++ cfg[\midiChan]
  ++ " human:" ++ (cfg[\midiChan] + 1)).postln;

// do NOT call ~installCCByNameRouter here
// router include handles its own install

// if router is already present and an autoload function exists, try autoload once
if((~ccRouter ? nil).isKindOf(IdentityDictionary) and: { ~autoloadMap.notNil }) {
  try { ~autoloadMap.() } { };
};

"[lcxl-boot ready]".postln;
)

