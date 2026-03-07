+ Pattern {
	// Apply swing by offsetting events that land on off-beats of the quant grid.
	// amount: timing offset in beats (e.g. 0.05)
	// quant:  grid subdivision to swing (e.g. 0.25 for quarter-note swing)
	swing { |amount = 0.05, quant = 0.25|
		^Prout({ |inval|
			var stream = this.asStream;
			var phase = 0.0;
			var event;
			while { (event = stream.next(inval)).notNil } {
				if ((phase - quant).abs < 1e-6) {
					event = event.copy;
					event[\timingOffset] = (event[\timingOffset] ? 0) + amount;
				};
				phase = (phase + event[\dur]) mod: (2 * quant);
				inval = yield(event);
			};
		});
	}

	fitToBar { |barDur=4.0|
		^Prout({ |ev|
			var stream = this.asStream;
			var val, sum = 0.0;
			
			// 1. Play the source pattern
			while { (val = stream.next(ev)).notNil } {
				// Handle both raw numbers and Rest objects for summation
				var durVal = if(val.isRest) { val.dur } { val };
				sum = sum + durVal;
				
				// Optional: Cut short if we exceed barDur? 
				// For now, let's just yield everything.
				yield(val);
			};

			// 2. If we are short, pad with a Rest
			if(sum < barDur) {
				var remainder = barDur - sum;
				// Rounding errors can occur, so we ensure positive
				if(remainder > 0.000001) {
					yield(Rest(remainder));
				};
			};
		});
	}
}
