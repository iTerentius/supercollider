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
~m1.level_(0.6);
~bd1_rev = ~ensurePostSend.(~t1, ~r1, 0.7);
~bd1_rev.tryPerform(\free);
~bd1_rev.level_(1);

~bd1_del = ~ensurePostSend.(~t1, ~r2, 1);
~bd1_del.tryPerform(\free);

~bd1_b = ~ensurePostSend.(~t1, ~r3, 1);
~bd1_b.tryPerform(\free);
~bd1_b.level_(0.7);

~bd1_t = ~ensurePostSend.(~t1, ~r4, 1);
~bd1_t.tryPerform(\free);
~bd1_t.level_(0.7);

~bd1_s = ~ensurePostSend.(~t1, ~r5, 1);
~bd1_s.tryPerform(\free);
~bd1_s.level_(1);

//--------------------------------------------------
// sd1

Pdef(\sd1).play;
Pdef(\sd1).stop;

~sd1_rev = ~ensurePostSend.(~t2, ~r1, 0.7);
~sd1_rev.tryPerform(\free);
~sd1_rev.level_(1);

~sd1_del = ~ensurePostSend.(~t2, ~r2, 1);
~sd1_del.tryPerform(\free);

~sd1_b = ~ensurePostSend.(~t2, ~r3, 1);
~sd1_b.tryPerform(\free);
~sd1_b.level_(1);

~sd1_t = ~ensurePostSend.(~t2, ~r4, 1);
~sd1_t.tryPerform(\free);
~sd1_t.level_(0.7);

~sd1_s = ~ensurePostSend.(~t2, ~r5, 1);
~sd1_s.tryPerform(\free);
~sd1_s.level_(0.7);

//--------------------------------------------------
// hh1

Pdef(\hh1).play;
Pdef(\hh1).stop;

~hh1_rev = ~ensurePostSend.(~t3, ~r1, 1);
~hh1_rev.tryPerform(\free);
~hh1_del = ~ensurePostSend.(~t3, ~r2, 1);
~hh1_del.tryPerform(\free);
~hh1_b = ~ensurePostSend.(~t3, ~r3, 1);
~hh1_b.tryPerform(\free);
~hh1_t = ~ensurePostSend.(~t3, ~r4, 1);
~hh1_t.tryPerform(\free);
~hh1_s = ~ensurePostSend.(~t3, ~r5, 1);
~hh1_s.tryPerform(\free);

//--------------------------------------------------
// roll

Pdef(\roll).play;
Pdef(\roll).stop;

~roll_fx1.free;
~roll_fx1 = ~t4.playfx(~exp1);

Pdef(\roll_fx_ctl).play;
Pdef(\roll_fx_ctl).stop;

~roll_rev = ~ensurePostSend.(~t4, ~r1, 0.8);
~roll_rev.tryPerform(\free);
~roll_del = ~ensurePostSend.(~t4, ~r2, 0.8);
~roll_del.tryPerform(\free);
~roll_b = ~ensurePostSend.(~t4, ~r3, 1);
~roll_b.tryPerform(\free);
~roll_s = ~ensurePostSend.(~t4, ~r5, 1);
~roll_s.tryPerform(\free);

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
Pdef(\spectral).play;
~r3_fx_rev = ~r3.newPostSend(~r1, 0.5);
~r3_fx_rev.tryPerform(\free);
~r3_fx_del = ~r3.newPostSend(~r2, 0.5);
~r3_fx_del.tryPerform(\free);

~r4_fx_rev = ~r4.newPostSend(~r1, 1);
~r4_fx_rev.tryPerform(\free);

~setR1.set(\room, 0.8,  \damp, 0.5,  \mix, 1.0);
~setR2.set(\maxdt, 1.0, \dt,   0.8,  \dec, 2.0);

~t1_2_r5.tryPerform(\free);
~t1_2_r5 = ~ensurePostSend.(~t1,  ~r5,  1);
~t2_2_r5.tryPerform(\free);
~t2_2_r5 = ~ensurePostSend.(~t2,  ~r5,  1);
~t3_2_r5.tryPerform(\free);
~t3_2_r5 = ~ensurePostSend.(~t3,  ~r5,  1);
~t4_2_r5 = ~ensurePostSend.(~t4,  ~r5,  1);
~t5_2_r5 = ~ensurePostSend.(~t5,  ~r5,  1);
~t6_2_r5 = ~ensurePostSend.(~t6,  ~r5,  1);
~t7_2_r5 = ~ensurePostSend.(~t7,  ~r5,  1);
~t8_2_r5 = ~ensurePostSend.(~t8,  ~r5,  1);
~r1_2_r5 = ~ensurePostSend.(~r1,  ~r5,  1);
~r2_2_r5 = ~ensurePostSend.(~r2,  ~r5,  1);
~r3_2_r5.tryPerform(\free);
~r3_2_r5 = ~ensurePostSend.(~r3,  ~r5,  1);
~r4_2_r5 = ~ensurePostSend.(~r4,  ~r5,  1);
~r5.level_(1.0);
