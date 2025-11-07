
// Instrument Sends
~perc_rev = ~perc.newPostSend(~r1, 0.2);
~perc_rev.tryPerform(\free);

~perc_del = ~perc.newPostSend(~r2, 0.4);
~perc_del.tryPerform(\free);

// Inline sends
(
~t1_fx = ~t1.playfx{ | outbus, bot=30, wet=0.5, amp=0.5 |
  var sig = In.ar(outbus, 2);
  sig = sig * SinOsc.ar(bot) * wet;
  // sig = sig / 0.2;
};
)
~t1_fx.free;
~t1_fx.set(\bot)
(
~t5_fx = ~t5.playfx{ | outbus, bot=30, wet=0.5, amp=0.5 |
  var sig = In.ar(outbus, 2);
  sig = sig * SinOsc.ar(bot) * wet;
  // sig = sig / 0.2;
};
)
~t5_fx.free;
~t5_fx.set(\bot)

Ndef(\mod_bot).fadeTime = 3;
Ndef(\mod_bot, {LFPulse.ar(0.5).range(120, 1000)});
~t5_fx.set(\bot, Ndef(\mod_bot));
~t5_fx.set(\wet, 0.7);



