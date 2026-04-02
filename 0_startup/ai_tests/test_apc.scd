MIDIClient.init;
MIDIClient.destinations.do { |ep|
    ("DEV: " ++ ep.device ++ " | NAM: " ++ ep.name).postln;
};
0.exit;
