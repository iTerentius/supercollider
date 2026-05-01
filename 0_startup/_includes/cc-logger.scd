// cc-logger.scd — debounced CC/OSC parameter change logger
//
// NOT auto-loaded. Evaluate once per session (or add to startup).
//
// When History is running, settled CC values are injected automatically via
// History.enter — no manual trigger needed. They appear in History playback
// and saveStory output, tagged with id \cc.
//
// Optionally also writes a .cc.scd file when ~ccLogFile is open (used by
// stemDiskStart captureCC:true for a standalone file copy).
//
// ~ccLog.(key, line)    — queue a settled write (debounced per key)
// ~ccLogOpen.(path)     — open a companion .cc.scd file (optional)
// ~ccLogClose.()        — flush + close that file
// ~ccLogDebounce        — seconds after last change before writing (default 1.5)

(
~ccLogDebounce  = 1.5;
~ccLogFile      = nil;
~ccLogPending   = Dictionary.new;
~ccLogScheduled = Dictionary.new;

~ccLogOpen = { |path|
    if(~ccLogFile.notNil) { ~ccLogFile.close };
    ~ccLogFile = File.new(path, "w");
    ~ccLogFile.write("// CC parameter log — cc-logger.scd\n");
    ~ccLogFile.write("// Re-evaluate selections to restore FX state\n\n");
    ~ccLogFile.flush;
    ("[ccLog] opened: " ++ path).postln;
};

~ccLogClose = {
    AppClock.sched(~ccLogDebounce + 0.2, {
        if(~ccLogFile.notNil) {
            ~ccLogFile.flush;
            ~ccLogFile.close;
            ~ccLogFile = nil;
            "[ccLog] closed.".postln;
        };
        nil
    });
};

~ccLog = { |key, line, tag=\cc|
    var pending = ~ccLogPending[key];
    ~ccLogPending[key] = (line: line, tag: tag);
    if(~ccLogScheduled[key].isNil) {
        ~ccLogScheduled[key] = true;
        AppClock.sched(~ccLogDebounce, {
            var entry = ~ccLogPending.removeAt(key);
            ~ccLogScheduled.removeAt(key);
            if(entry.notNil) {
                if(History.started) { History.enter(entry[\line], entry[\tag]) };
                if(~ccLogFile.notNil) {
                    ~ccLogFile.write(entry[\line] ++ "\n");
                    ~ccLogFile.flush;
                };
            };
            nil
        });
    };
};
)
