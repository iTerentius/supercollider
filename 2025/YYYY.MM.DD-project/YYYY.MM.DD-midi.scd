
// pick default device for 2-arg ~ccb
~ccdev.(\lcx);  // or \lc

// bind using default
~ccb.(\b0_s1_r1, { |x| Ndef(\t1).set(\mod, x.linexp(0,1, 1,64)) });

// bind explicitly to Launch Control (non-XL)
~ccb.(\lc,  \b0_s1_r1, { |x| Ndef(\t1).set(\mod, x.linexp(0,1, 1,64)) });

// unbind
~ccu.(\b0_s1_r1);        // default device
~ccu.(\lc, \b0_s1_r1);   // explicit device
