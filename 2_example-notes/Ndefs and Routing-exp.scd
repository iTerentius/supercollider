// From: https://sc-users.bham.ac.narkive.com/PAapaSaM/many-to-one-audio-routing-in-jitlib

a = NodeProxy.audio(s, 2); // summing bus
f = NodeProxy.audio(s, 2); // fx unit, or whatever
f.source = { GVerb.ar(\in.ar([0,0])) }
a <>> f // a goes into input of f
f.play

b = NodeProxy.audio(s, 2);
c = NodeProxy.audio(s, 2);
b.source = {Impulse.ar([2.3,2.4], mul:0.5)};
c.source = {Saw.ar([224,223], mul: 0.2)};

a.add(b);
a.add(c);
a.sources.size

a.removeAt(a.sources.find([c]))
a.add(c)
a.removeAll
