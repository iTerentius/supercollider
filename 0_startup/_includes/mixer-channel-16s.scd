// Main Out
(
~m1 = MixerChannel.new(\m1, s, 2, 2, outbus: 0);
~lcxlBindParam.(\b0_s1_f, {|x| ~m1.level_(x)});
~lcxlBindParam.(\b0_s1_r3, {|x| ~m1.pan_(x.linlin(0, 1, -1, 1))});

// Instrument Tracks
~t1 = MixerChannel.new(\t1, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s2_f, {|x| ~t1.level_(x)});
~lcxlBindParam.(\b0_s2_r3, {|x| ~t1.pan_(x.linlin(0, 1, -1, 1))});

~t2 = MixerChannel.new(\t2, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s3_f, {|x| ~t2.level_(x)});
~lcxlBindParam.(\b0_s3_r3, {|x| ~t2.pan_(x.linlin(0, 1, -1, 1))});

~t3 = MixerChannel.new(\t3, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s4_f, {|x| ~t3.level_(x)});
~lcxlBindParam.(\b0_s4_r3, {|x| ~t3.pan_(x.linlin(0, 1, -1, 1))});

~t4 = MixerChannel.new(\t4, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s5_f, {|x| ~t4.level_(x)});
~lcxlBindParam.(\b0_s5_r3, {|x| ~t4.pan_(x.linlin(0, 1, -1, 1))});

~t5 = MixerChannel.new(\t5, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s6_f, {|x| ~t5.level_(x)});
~lcxlBindParam.(\b0_s6_r3, {|x| ~t5.pan_(x.linlin(0, 1, -1, 1))});

~t6 = MixerChannel.new(\t6, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s7_f, {|x| ~t6.level_(x)});
~lcxlBindParam.(\b0_s7_r3, {|x| ~t6.pan_(x.linlin(0, 1, -1, 1))});

~t7 = MixerChannel.new(\t7, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b0_s8_f, {|x| ~t7.level_(x)});
~lcxlBindParam.(\b0_s8_r3, {|x| ~t7.pan_(x.linlin(0, 1, -1, 1))});

~t8 = MixerChannel.new(\t8, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b1_s1_f, {|x| ~t8.level_(x)});
~lcxlBindParam.(\b1_s1_r3, {|x| ~t8.pan_(x.linlin(0, 1, -1, 1))});

~t9 = MixerChannel.new(\t9, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b1_s2_f, {|x| ~t9.level_(x)});
~lcxlBindParam.(\b1_s2_r3, {|x| ~t9.pan_(x.linlin(0, 1, -1, 1))});

~t10 = MixerChannel.new(\t10, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b1_s3_f, {|x| ~t10.level_(x)});
~lcxlbindparam.(\b1_s3_r3, {|x| ~t10.pan_(x.linlin(0, 1, -1, 1))});

~t11 = MixerChannel.new(\t11, s, 2, 2, outbus: ~m1);
~lcxlBindParam.(\b1_s4_f, {|x| ~t11.level_(x)});
~lcxlbindparam.(\b1_s4_r3, {|x| ~t11.pan_(x.linlin(0, 1, -1, 1))});

// Returns
~r1 = MixerChannel.new(\r1, s, 2, 2, \outbus, ~m1);
~lcxlBindParam.(\b1_s5_f, {|x| ~r1.level_(x)});
~lcxlbindparam.(\b1_s4_r3, {|x| ~r1.pan_(x.linlin(0, 1, -1, 1))});

~r2 = MixerChannel.new(\r2, s, 2, 2, \outbus, ~m1);
~lcxlBindParam.(\b1_s6_f, {|x| ~r2.level_(x)});
~lcxlbindparam.(\b1_s6_r3, {|x| ~r2.pan_(x.linlin(0, 1, -1, 1))});

~r3 = MixerChannel.new(\r3, s, 2, 2, \outbus, ~m1);
~lcxlBindParam.(\b1_s7_f, {|x| ~r3.level_(x)});
~lcxlbindparam.(\b1_s7_r3, {|x| ~r3.pan_(x.linlin(0, 1, -1, 1))});

~r4 = MixerChannel.new(\r4, s, 2, 2, \outbus, ~m1);
~lcxlBindParam.(\b1_s8_f, {|x| ~r4.level_(x)});
~lcxlbindparam.(\b1_s8_r3, {|x| ~r4.pan_(x.linlin(0, 1, -1, 1))});

~perc = MixerChannel.new(\perc, s, 2, 2, outbus: ~t1);

~pbd1 = MixerChannel.new(\pbd1, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s1_f, {|x| ~pbd1.level_(x)});
~lcxlBindParam.(\b4_s1_r3, {|x| ~pbd1.pan_(x.linlin(0, 1, -1, 1))});

~pbd2 = MixerChannel.new(\pbd2, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s2_f, {|x| ~pbd2.level_(x)});
~lcxlBindParam.(\b4_s2_r3, {|x| ~pbd2.pan_(x.linlin(0, 1, -1, 1))});

~phh1 = MixerChannel.new(\phh1, s, 2, 2, outbus: ~perc);
~lcxlBindParam.(\b4_s3_f, {|x| ~phh1.level_(x)});
~lcxlBindParam.(\b4_s3_r3, {|x| ~phh1.pan_(x.linlin(0, 1, -1, 1))});

// Default FX
// -- Reverb
~r1.playfx( { |outbus, room=0.8, damp=0.2|
			var sig = In.ar(outbus, 2);
			FreeVerb2.ar(sig[0], sig[1], mix: 1, room: room, damp: damp);
		}
);

// -- Delay
~r2.playfx( { |outbus|
			var sig = In.ar(outbus, 2);
			CombL.ar(sig, maxdelaytime: 0.2, delaytime: 0.2, decaytime: 1.0);
		}
);


)


// (
// ~r1.playfx({ |out| 
//    var numChan, maxDelay, preDelay, decay, numRefl, random;
//    var sig, new, dlys;
//    #numChan, maxDelay, preDelay, decay, numRefl, random = #[2, 0.181, 0.08, 4, 8, 0.1];
//    sig = In.ar(out, numChan);
//    new = sig;
//    dlys = Array.fill(numRefl, {
//       new = AllpassN.ar(new, maxDelay,
//          Array.fill(numChan, { random.rand }) + preDelay, decay);
//    });
//    Mix.ar(dlys * Array.series(numRefl, 1, (numRefl+1).reciprocal.neg))
// });
//
// )
//     \inbus, ~r1.inbus, // The reverb reads its input from the channel's bus
//     \mix, 1, // 100% wet
//     \room, 0.8,
//     \damp, 0.5,
// ]);
