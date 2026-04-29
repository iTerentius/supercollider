// AutoFreeDict : dictionary that frees the old node before replacing a key.
// Lets ~ilfx[\key] = newSynth auto-free the previous synth at that key.
AutoFreeDict : IdentityDictionary {
    put { |key, val|
        var old = this.at(key);
        if (old.notNil && (old != val)) { old.tryPerform(\free) };
        super.put(key, val);
    }
}
