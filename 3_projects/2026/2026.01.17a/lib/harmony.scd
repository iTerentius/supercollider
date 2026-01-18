// Harmony
(
Pdefn(\root_deg_0, Pseq([0, 1,  2,  4], 1).stutter(2));

Pdefn(\root_degs, Pseq([
    Pn(Pdefn(\root_deg_0), inf),
], 1));
)
