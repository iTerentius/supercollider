TempoClock.default.tempo = 90/60;
"start.scd".loadRelative;
// Instruments
Pdef(\bash).play;
Pdef(\bash).stop;

~setR1.set(\room, 1.0,  \damp,  0.5,  \mix, 1.5);
~setR2.set(\maxdt,  0.7,  \dt, 1.1,  \dec, 1.1);
~bash_rev = ~ensurePostSend.(~pbd1, ~r1, 0.7);
~bash_rev.tryPerform(\free);
~bash_rev.level_(1);
~bash_del = ~ensurePostSend.(~pbd1, ~r2,  1);
~bash_del.tryPerform(\free);

~bash_b = ~ensurePostSend.(~pbd1, ~r3,  1);
~bash_b.tryPerform(\free);
~bash_b.level_(1);
Pdef(\bCtl).play;
~bash_b.level_(1);
~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1);
~bash_t.tryPerform(\free);

~bash_t.tryPerform(\free);
~bash_t.level_(0.7);

Pdef(\bashat).play;
Pdef(\bashat).stop;

~bhat_rev = ~ensurePostSend.(~phh1,  ~r1,  1);
~bhat_rev.tryPerform(\free);
~bhat_del = ~ensurePostSend.(~phh1,  ~r2,  1);
~bhat_del.tryPerform(\free);
~bhat_b = ~ensurePostSend.(~phh1,  ~r3,  1);
~bhat_b.tryPerform(\free);
~bhat_t = ~ensurePostSend.(~phh1,  ~r4,  1);
~bhat_t.tryPerform(\free);

~lumi_t = ~ensurePostSend.(~t3,  ~r4,  1);
~lumiStop.();

Pdef(\roll).play;
Pdef(\roll).stop;

~roll_fx1.free;
~roll_fx1 = ~psd1.playfx(~exp1);

Pdef(\roll_fx_ctl).play;
~roll_rev = ~ensurePostSend.(~psd1, ~r1,  0.8);
~roll_rev.tryPerform(\free);
~roll_del = ~ensurePostSend.(~psd1, ~r2,  0.8);
~roll_del.tryPerform(\free);
~roll_b = ~ensurePostSend.(~psd1,  ~r3,  1);
~roll_b.tryPerform(\free);
~roll_glitch = ~ensurePostSend.(~psd1,  ~r4,  1);
~roll_glitch.tryPerform(\free);

// FX
~r3_fx_rev = ~r3.newPostSend(~r1,  0.5);
~r3_fx_rev.tryPerform(\free);
~r3.level_(1);
~r1_fx_r3 = ~r1.newPostSend(~r3,  0.2);


~r4_fx.free;
~r4_fx_rev = ~r4.newPostSend(~r1,  1);
~r4_fx_rev.tryPerform(\free);

Pdef(\neutron).play;
Pdef(\neutron).stop;

Pdef(\modelD).play;
Pdef(\modelD).stop;
~mD_rev = ~ensurePostSend.(~t3,  ~r1,  1);
~mD_rev.tryPerform(\free);
~mD_del = ~ensurePostSend.(~t3,  ~r2,  1);
~mD_del.tryPerform(\free);
~mD_t = ~ensurePostSend.(~t3, ~r3,  1);
~mD_t.tryPerform(\free);

Pdef(\ms20).play;
Pdef(\ms20).stop;

~ms20_rev = ~ensurePostSend.(~t2,  ~r1,  1);
~ms20_rev.tryPerform(\free);
~ms20_del = ~ensurePostSend.(~t2,  ~r2,  1);
~ms20_del.tryPerform(\free);
~ms20_t = ~ensurePostSend.(~t2, ~r4,  1);
~ms20_t.tryPerform(\free);

