Psection : Pattern {
    var <>list, <>dur, <>init, <>sync, <>quant;

    *new { | list, dur, init = nil, sync = false, quant = 4 |
        ^super.newCopyArgs(list, dur, init, sync, quant);
    }

    embedInStream { | inval |
        var patterns, parallel, output;
        var calcDur;

        // 1. RUN INIT
        init.value;

        // 2. CALCULATE DURATION
        calcDur = case
        { dur.isKindOf(Function) } { dur.value }
        
        // If it is a Symbol, try to find the best match
        { dur.isKindOf(Symbol) } { 
            var proxy = Pdefn(dur); 
            if(proxy.source.respondsTo(\list)) {
                // It's a Pdefn with a list (Pseq, etc.)
                proxy.source.list.size 
            } {
                // Fallback: Is it a global variable (~myVal)?
                if(currentEnvironment[dur].notNil) {
                    currentEnvironment[dur]
                } {
                    // Last resort: Just assume 4 beats (or warn)
                    "Psection: Could not resolve duration for symbol '%'".format(dur).warn;
                    4 
                }
            }
        }
        // Default: It's just a number
        { true } { dur };

        // 3. SANITIZE LIST (Symbols -> Pdefs)
        patterns = list.collect { |item|
            if(item.isKindOf(Symbol)) { Pdef(item) } { item }
        };

        // 4. CREATE STACK
        parallel = Ppar(patterns);

        // 5. APPLY CONSTRAINT
        output = if(sync) {
            Psync(parallel, quant, calcDur)
        } {
            Pfindur(calcDur, parallel)
        };

        ^output.embedInStream(inval);
    }
}
