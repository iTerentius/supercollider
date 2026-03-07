(
// Quantized recording: channels, path, name, auto-dir, timestamp
~quantRecord = { |clock=nil, numChannels=2, path="", fileName="take"|
    var startBeat, timestamp, fullPath, d;

    clock = clock ? TempoClock.default;

    if(path.isNil or: { path == "" }) {
        path = Platform.userHomeDir +/+ "recordings";
    };

    if(File.exists(path).not) {
        File.mkdir(path);
        "📂 Created directory: %".format(path).postln;
    };

    // build timestamp manually (use STRING "0", not CHAR $0)
    d = Date.getDate;
    timestamp =
        d.year.asString.padLeft(4, "0") ++ "-" ++
        d.month.asString.padLeft(2, "0") ++ "-" ++
        d.day.asString.padLeft(2, "0") ++ "_" ++
        d.hour.asString.padLeft(2, "0") ++ "-" ++
        d.minute.asString.padLeft(2, "0") ++ "-" ++
        d.second.asString.padLeft(2, "0");

    fullPath = path +/+ (fileName ++ "_" ++ timestamp ++ ".wav");

    s.prepareForRecord(numChannels: numChannels, path: fullPath);

    startBeat = clock.nextBar;
    clock.schedAbs(startBeat, {
        "⏺ start recording @ beat %, file:\n%".format(startBeat, fullPath).postln;
        s.record;
        nil
    });
};
)
