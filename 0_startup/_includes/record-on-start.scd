(
// ---- Auto record via /n_go and /n_end (OSC), 16ch-ready ----
s.waitForBoot {
    ~autoRecOSC = (
        armed: false, started: false,
        channels: 16,                // your multichannel file width
        header: 'wav',
        sampleFmt: 'int24',          // 'float' if you prefer
        filePath: {
            var stamp = Date.getDate.stamp.replace($:, $_);
            Platform.userHomeDir +/+ ("sc_autorec_" ++ stamp ++ ".wav")
        }.value,
        liveSynths: IdentitySet.new,

        startFn: { |self|
            if(self.started.not) {
                s.prepareForRecord(self.filePath, self.channels, self.header, self.sampleFmt);
                s.record;
                self.started = true;
                ("[autoRec] Recording (" ++ self.channels
                    ++ "ch " ++ self.header ++ " " ++ self.sampleFmt
                    ++ ") → " ++ self.filePath).postln;
            }
        },

        stopFn: { |self|
            if(self.started) {
                s.stopRecording;
                self.started = false;
                "[autoRec] Recording stopped.".postln;
            }
        },

        arm: { |self|
            if(self.armed) { ^"[autoRec] Already armed.".postln };

            // synth appeared
            OSCdef(\autoRec_n_go, { |msg|
                // [/n_go, nodeID, parent, prev, isGroup(1/0), head, tail]
                var nodeID = msg[1].asInteger;
                var isGroup = msg[4].asInteger;
                if(isGroup == 0) { // it's a synth node
                    self.liveSynths.add(nodeID);
                    if(self.liveSynths.size == 1) { self[\startFn].value(self) };
                }
            }, '/n_go', s.addr);

            // synth freed
            OSCdef(\autoRec_n_end, { |msg|
                // [/n_end, nodeID]
                var nodeID = msg[1].asInteger;
                if(self.liveSynths.remove(nodeID).notNil) {
                    if(self.liveSynths.isEmpty) { self[\stopFn].value(self) };
                }
            }, '/n_end', s.addr);

            // synth released (ignore; we'll stop on /n_end)
            OSCdef(\autoRec_n_off, { |msg| }, '/n_off', s.addr);

            self.armed = true;
            "[autoRec] Armed (OSC, 16ch).".postln;
        },

        disarm: { |self|
            [\autoRec_n_go, \autoRec_n_end, \autoRec_n_off].do { |k| OSCdef(k).free };
            self[\stopFn].value(self);
            self.liveSynths.clear;
            self.armed = false;
            "[autoRec] Disarmed.".postln;
        }
    );

    // invoke functions stored in the dict via symbol lookup + value(self)
    ~autoRecOSC[\arm].value(~autoRecOSC);
};
)

