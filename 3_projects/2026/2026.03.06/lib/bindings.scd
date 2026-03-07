// Bindings — LaunchPad Mini + APC40 Mk2
(
// --- row 1: voice launchers ---
~lpBind.([1, 1], \bd1,     10);
~lpBind.([1, 2], \sd1,     15);
~lpBind.([1, 3], \hh1,     20);
~lpBind.([1, 4], \roll,    30);
~lpBind.([1, 5], \ms20,    40);
~lpBind.([1, 6], \thingA,  50);
~lpBind.([1, 7], \neutron, 22);
~lpBind.([1, 8], \modelD,  12);

~lpBind.([5, 1], \bd1_fx_1, 41, nil, nil, ~makeFxSendTdef.(\bd1_fx_1, ~pbd1, ~r1));
~lpBind.([6, 1], \bd1_fx_2, 81, nil, nil, ~makeFxSendTdef.(\bd1_fx_2, ~pbd1, ~r2));
~lpBind.([7, 1], \bd1_fx_3,  5, nil, nil, ~makeFxSendTdef.(\bd1_fx_3, ~pbd1, ~r3));
~lpBind.([8, 1], \bd1_fx_4, 35, nil, nil, ~makeFxSendTdef.(\bd1_fx_4, ~pbd1, ~r4));


// --- APC40 Mk2 pads ---
~apcAssignPad.(32, \bd1);
~apcAssignPad.(33, \sd1);
)
