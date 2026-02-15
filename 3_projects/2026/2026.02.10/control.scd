"start.scd".loadRelative;
// Instruments
Pdef(\bash).play;
Pdef(\bash).stop;

~bash_rev = ~ensurePostSend.(~pbd1, ~r1, 0.7);
~bash_rev.tryPerform(\free);
~bash_rev.level_(1);
~bash_del = ~ensurePostSend.(~pbd1, ~r2,  1);
~bash_del.tryPerform(\free);

~bash_gin = ~ensurePostSend.(~pbd1, ~r3,  0.5);
~bash_gin.tryPerform(\free);
~bash_gin.level_(0.1);
~bash_t = ~ensurePostSend.(~pbd1, ~r4,  1);
~bash_t.tryPerform(\free);

~bash_t.tryPerform(\free);
~bash_t.level_(0.7);

Pdef(\bashat).play;
Pdef(\bashat).stop;

~bhat_del = ~ensurePostSend.(~phh1,  ~r2,  1);
~bhat_gin = ~ensurePostSend.(~phh1,  ~r4,  1);
~bhat_gin.tryPerform(\free);

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
~roll_glitch = ~ensurePostSend.(~psd1,  ~r4,  1);
~roll_glitch.tryPerform(\free);

// FX
~r3_fx.free;
~r3.level_(1);

(
~r4_fx.free;
~r4_fx = ~r4.playfx(~glitch);
)
~r4_fx_rev = ~r4.newPostSend(~r1,  1);

