// An example of using the sampler, looks for samples in a folder called mmd.
(
Pdef(0,
	Pseed(Pn(999,1),
		Psync(
			Pbind(*[
				type: \cln,
				snd: \Field,
				num: Pbrown(0, 12),
				dur: Pseq([0.25, 0.5, 1, 2], inf),
				rel: 2,
				// amp: Pexprand(1.0, 8.0),
				pan: Pdup(Pwhite(0, 28), Pwrand([Pwhite(0.0, 0.333), Pwhite(0.666, 1.0)], [1, 1.5].normalizeSum, inf)),
				lpf: Pwrand([625, 1250, 2500, 5000, 10000, 20000], (1 .. 6).normalizeSum, inf),
				spd: Pwhite(1/2, 1, inf),
				shp: Pwhite(0.0, 1.0),
				dla: 0.05,
				dlf: 0.94,
				dlt: 1/2 / Pdup(Pwrand([1, 2, 3], [256, 16, 1].normalizeSum,inf), Pbrown(1, 199, Prand((1 .. 19), inf))),
				rin: Pwrand([0,0.05], [9, 1].normalizeSum, inf),
				rev: 0.97,
				dry: Pdup(Pwhite(1, 9), Pwrand([0.25, 1], [3, 1].normalizeSum, inf)),
				// hpf: 40,
			]), 1, inf,
		)
	)
).play
)