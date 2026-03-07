// Pswing wraps a pattern and applies swing timing to events that land on
// off-beats of the quant grid.
//
// pattern: source event pattern (e.g. Pbind)
// amount:  timing offset in beats (e.g. 0.05)
// quant:   grid subdivision to swing (e.g. 0.25 for quarter-note swing)
//
// Example:
//   Pswing(Pbind(\degree, Pseq([0,2,4,7], inf), \dur, 0.25), 0.05, 0.25).play

Pswing : FilterPattern {
	var <>amount, <>quant;

	*new { |pattern, amount = 0.05, quant = 0.25|
		^super.new(pattern).init(amount, quant)
	}

	init { |a, q|
		amount = a;
		quant = q;
		^this
	}

	embedInStream { |inval|
		var stream = pattern.asStream;
		var phase = 0.0;
		var event;
		while { (event = stream.next(inval)).notNil } {
			if ((phase - quant).abs < 1e-6) {
				event = event.copy;
				event[\timingOffset] = (event[\timingOffset] ? 0) + amount;
			};
			phase = (phase + event[\dur]) mod: (2 * quant);
			inval = event.yield;
		};
		^inval
	}
}
