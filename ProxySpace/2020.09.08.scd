s.options.memSize_(2 pow: 20);
p = ProxySpace.push(s.reboot);
(
~iter = { | freq = 40, amp=0.5 |
	var temp;
	var env = 1;
	var sum = 0;
	// env = EnvGen.kr(Env([0, 1, 0, 1, 0], [0.1, 0.25, 0.5, 0.75, 1], loopNode: 10, releaseNode: 10));
	10.do{
		temp = VarSaw.ar(
			freq * MouseY.kr(1, 2.0) * {Rand(0.99, 1.02)  * 1}!2,
			~iterlfok1.kr * Impulse.kr(30)!2,
			Pulse.kr(Dust2.kr(~iterlfok1.kr))!2
			);
			sum = sum + temp * 0.5 * env;
	};
	Pan2.ar([sum * amp * ~itergate * 0.4, sum * amp * 1- ~itergate * 0.1]);
};
)
~iter.play;
~iter.stop;
~iter.release;

~iterlfok1.play;
~iterlfok1 = {LFNoise2.kr(MouseY.kr(30, 400 ))};
~iterlfok1.stop;

~itergate = {LFPulse.kr(MouseX.kr(1, 10))};
