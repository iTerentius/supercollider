// Harmony
(
Pdefn(\root_deg_0, Pstep(Pseq([0, -2], 1),  16));

Pdefn(\root_degs, Pseq([
    Pn(Pdefn(\root_deg_0), inf),
], 1));
)
