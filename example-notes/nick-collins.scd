s.reboot;

p = ProxySpace.push(s);

a = {(SinOsc.ar(SinOsc.kr(55, mul: 0.2), amp:0.02) + Gendy1.kr(LFPulse.kr(2, mul:0.1),0.5, mul:0.1))!2 * 0.00001}.play;
a.free;

//plot it out

{ Stepper.ar(Impulse.ar(100), 0,1,10,1) }.plot(0.3,minval:0,maxval:10);

{ SinOsc.ar(Stepper.ar(Impulse.ar(10), 0,1,10,1)*100,0,0.1) }.play

//impulse frequency of 4 is 4 events per second

//kr used since slow rates and Select works with array data second input if kr but not ar

b = { LFPar.ar(Select.kr(Stepper.kr(Impulse.kr(4,0.1),0,0,7,1),[72,63,67,72,55,62,63,60].midicps),0.1)!2 * 0.1}.play

//speed control

{ Saw.ar(Select.kr(Stepper.kr(Impulse.kr(MouseX.kr(1,40),0.1),0,0,7,1),[75,63,67,72,55,62,63,60].midicps),0.1) }.play

//trigger on any change

(

{var source, trigger;


source= LFNoise0.ar(100);

trigger= Trig1.ar(abs(source- Delay1.ar(source)), 0.001); //0.001 is duration of trigger signal output


[source, trigger]

}.plot(0.2)

)

//grab the sine's current value 100 times a second

{Latch.ar(SinOsc.ar(133), Impulse.ar(100))}.plot(0.5)

{Latch.ar(LFNoise2.ar(100), Impulse.ar(100))}.plot(0.1) //removes smoothing!

//could be used to create sequencing patterns!

{LFPulse.ar(50+(200*Latch.ar(SinOsc.ar(13.3), Impulse.ar(1))))!2 *0.2}.play




{EnvGen.ar(Env([0,1,0],[0.01,0.01]),Impulse.kr(50))}.plot(0.1)



//If you set the envelope up carefully, this could be used like a more flexible Stepper

{EnvGen.ar(Env([0,1,0,0.5,-0.4],0.01!4),Impulse.kr(25))}.plot(0.1)



//slowed down by factor of 10 to be heard as held pitches

{VarSaw.ar(900 *(EnvGen.ar(Env([0,1,0,0.5,-0.4],0.25!4,curve:\step),Impulse.kr(0.125,0,10))))!2 * 0.1}.play



//use midicps on output to get scales

s.prepareForRecord;
s.record;
s.stopRecording;
(
~rec[0] = { | freq = 48, relTime = 2 |
	var sig = 0, temp, env;
	env = EnvGen.kr(Env.perc(releaseTime:relTime), doneAction: 2);
	8.do{ | i |
		temp = LFPulse.ar(freq + i, LFPulse.kr(Rand(0, i).round(rrand(0.125, i))).midicps)!2 / 8;
		sig = sig + temp * env;
		Out.ar(0, sig * 1/8);
	};
};
)

(
~rec[1] = \xset -> Pbind(
	\dur, Pseq([0.5, 0.5, 1, 2, 0.25, 0.125, 0.125, 0.5, Rest(2)].scramble, inf),
	\degree, Pseq(Scale.minor.degrees.mirror.scramble, inf),
	\octave, 2,
	\relTime, Pseq([1, 2, 3, 0.5], inf),
)
)
~rec.play;
~rec.stop;
~rec.free;

//the Impulse's rate acts like a beats per second here, and the envelope timings are in beats (0.125 per transition)