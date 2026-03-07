// Control — live FX routing, play/stop, sends
// Eval individual blocks as needed; not loaded by score.scd

(
~link.tempo = 110/60;
"score.scd".loadRelative;
~setR1.set(\room, 1.0,  \damp, 0.5,  \mix, 1.5);
~setR2.set(\maxdt, 0.7, \dt,   1.1,  \dec, 1.1);
)

//--------------------------------------------------
// bd1

Pdef(\bd1).play;
Pdef(\bd1).stop;

~bd1_rev = ~ensurePostSend.(~pbd1, ~r1, 0.7);
~bd1_rev.tryPerform(\free);
~bd1_rev.level_(1);

~bd1_del = ~ensurePostSend.(~pbd1, ~r2, 1);
~bd1_del.tryPerform(\free);

~bd1_b = ~ensurePostSend.(~pbd1, ~r3, 1);
~bd1_b.tryPerform(\free);
~bd1_b.level_(1);

~bd1_t = ~ensurePostSend.(~pbd1, ~r4, 1);
~bd1_t.tryPerform(\free);
~bd1_t.level_(0.7);

//--------------------------------------------------
// sd1

Pdef(\sd1).play;
Pdef(\sd1).stop;

~sd1_rev = ~ensurePostSend.(~psd1, ~r1, 0.7);
~sd1_rev.tryPerform(\free);
~sd1_rev.level_(1);

~sd1_del = ~ensurePostSend.(~psd1, ~r2, 1);
~sd1_del.tryPerform(\free);

~sd1_b = ~ensurePostSend.(~psd1, ~r3, 1);
~sd1_b.tryPerform(\free);
~sd1_b.level_(1);

~sd1_t = ~ensurePostSend.(~psd1, ~r4, 1);
~sd1_t.tryPerform(\free);
~sd1_t.level_(0.7);

//--------------------------------------------------
// hh1

Pdef(\hh1).play;
Pdef(\hh1).stop;

~hh1_rev = ~ensurePostSend.(~phh1, ~r1, 1);
~hh1_rev.tryPerform(\free);
~hh1_del = ~ensurePostSend.(~phh1, ~r2, 1);
~hh1_del.tryPerform(\free);
~hh1_b = ~ensurePostSend.(~phh1, ~r3, 1);
~hh1_b.tryPerform(\free);
~hh1_t = ~ensurePostSend.(~phh1, ~r4, 1);
~hh1_t.tryPerform(\free);

//--------------------------------------------------
// roll

Pdef(\roll).play;
Pdef(\roll).stop;

~roll_fx1.free;
~roll_fx1 = ~t2.playfx(~exp1);

Pdef(\roll_fx_ctl).play;

~roll_rev = ~ensurePostSend.(~t2, ~r1, 0.8);
~roll_rev.tryPerform(\free);
~roll_del = ~ensurePostSend.(~t2, ~r2, 0.8);
~roll_del.tryPerform(\free);
~roll_b = ~ensurePostSend.(~t2, ~r3, 1);
~roll_b.tryPerform(\free);
~roll_glitch = ~ensurePostSend.(~t2, ~r4, 1);
~roll_glitch.tryPerform(\free);

//--------------------------------------------------
// ms20

Pdef(\ms20).play;
Pdef(\ms20).stop;

~ms20_rev = ~ensurePostSend.(~t3, ~r1, 1);
~ms20_rev.tryPerform(\free);
~ms20_del = ~ensurePostSend.(~t3, ~r2, 1);
~ms20_del.tryPerform(\free);
~ms20_t = ~ensurePostSend.(~t3, ~r4, 1);
~ms20_t.tryPerform(\free);

//--------------------------------------------------
// thingA / lumi

Pdef(\thingA).play;
Pdef(\thingA).stop;

~lumi_t = ~ensurePostSend.(~t3, ~r4, 1);
~lumiStop.();

//--------------------------------------------------
// neutron

Pdef(\neutron).play;
Pdef(\neutron).stop;

//--------------------------------------------------
// model D

Pdef(\modelD).play;
Pdef(\modelD).stop;

~mD_rev = ~ensurePostSend.(~t5, ~r1, 1);
~mD_rev.tryPerform(\free);
~mD_del = ~ensurePostSend.(~t5, ~r2, 1);
~mD_del.tryPerform(\free);
~mD_t = ~ensurePostSend.(~t5, ~r3, 1);
~mD_t.tryPerform(\free);

//--------------------------------------------------
// biscuit FX

Pdef(\bCtl).play;

~r3_fx_rev = ~r3.newPostSend(~r1, 0.5);
~r3_fx_rev.tryPerform(\free);
~r3_fx_del = ~r3.newPostSend(~r2, 0.5);
~r3_fx_del.tryPerform(\free);
~r3.level_(1);

~r4_fx_rev = ~r4.newPostSend(~r1, 1);
~r4_fx_rev.tryPerform(\free);

~setR1.set(\room, 0.8,  \damp, 0.5,  \mix, 1.0);
~setR2.set(\maxdt, 1.0, \dt,   0.8,  \dec, 2.0);
