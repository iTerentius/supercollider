/* Compatibility shim for SuperDirtMixer ↔ GlobalDirtEffect (older SuperDirt builds)
   - Adds .synth accessor
   - Adds .active / .active_ for UI toggles
   - Guards against calling .set/.resume before the synth exists
*/

+GlobalDirtEffect {

    // Accessor some mixer UIs expect
    synth { ^synth }

    // Find a parameter that starts with "active" (e.g. \activeCompressor, \activeEq)
    findActiveKey {
        ^paramNames.detect { |p| p.asString.beginsWith("active") };
    }

    // Getter (Boolean)
    active {
        var key = this.findActiveKey;
        if (key.notNil) {
            var v = state.tryPerform(\at, key);  // state is an Event
            ^((v ?? alwaysRun).asBoolean);
        }{
            ^alwaysRun.asBoolean;
        };
    }

    // Setter used by the UI
    active_ { |bool|
        var key = this.findActiveKey;
        var val = bool.if(1, 0);
        if (key.notNil) {
            // Persist desired state locally
            state.put(key, val);

            // Only push to the running effect if the synth already exists.
            // (During GUI init, synth is nil; pushing would call resume → nil.run)
            if (this.synth.notNil) {
                var ev = Event.new; ev.put(key, val);
                this.set(ev);   // safe now; effect has a synth
            };
        }{
            // No "active*" param on this effect: fall back to alwaysRun
            alwaysRun = bool;
        };
        ^bool
    }
}

