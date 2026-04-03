// slots.scd — THE file you edit to configure a new project.
// Every other lib file derives from ~slots. Never edit bindings.scd.
//
// To add a voice:
//   1. Add a row here
//   2. Copy parts/_voice.scd, rename it, change pfx + trk at the top
//   3. Add safeLoad.("parts/myvoice.scd") to score.scd
//   4. Done — bindings are generated automatically
(
// Returns in send order — index 0 = top row on LP Bank 2 / top APC pad column
~slotRets = [~r1, ~r2, ~r3, ~r4, ~r5];

// LP Mini: pad colors per return row (5 rows, one per return)
~slotFxLpCols  = [41, 81, 5, 35, 10];   // blue, cyan, pink, purple, orange

// APC40: pad colors per return row
~slotFxApcCols = [\blue, \cyan, \pink, \purple, \orange];

// Voice slots
// Each is an Event:
//   \n   : Symbol — Pdef key + Pdefn prefix (must match var pfx in your part file)
//   \t   : MixerChannel — the track this voice routes to
//   \lp  : (b=bank, r=row, c=col, col=color) — LP Mini launcher pad
//   \apc : (b=bank, p=padNote, col=color)    — APC40 launcher pad
//
// APC40 pad layout reference:
//   Row 0 (top): 32 33 34 35 36 37 38 39
//   Row 1:       24 25 26 27 28 29 30 31
//   Row 2:       16 17 18 19 20 21 22 23
//   Row 3:        8  9 10 11 12 13 14 15
//   Row 4 (bot):  0  1  2  3  4  5  6  7
//
// FX send pads (Bank 2): same pad column as Bank 1, rows = returns top→bottom
// So voice at APC pad 32 → FX sends at 32, 24, 16, 8, 0 in Bank 2.
// Voices past column 8: use the next LP bank; APC wraps to next row.

~slots = [
    (n:\v1, t:~t1,  lp:(b:1, r:1, c:1, col:10),  apc:(b:1, p:32, col:\orange)),
    (n:\v2_bass, t:~t2,  lp:(b:1, r:1, c:2, col:20),  apc:(b:1, p:33, col:\yellow)),
    (n:\v3, t:~t3,  lp:(b:1, r:1, c:3, col:30),  apc:(b:1, p:34, col:\cyan)),
    (n:\v4, t:~t4,  lp:(b:1, r:1, c:4, col:40),  apc:(b:1, p:35, col:\blue)),
    // add more below — up to 8 voices per LP bank / APC row before overflow
    // (n:\v5, t:~t5, lp:(b:1, r:1, c:5, col:50), apc:(b:1, p:36, col:\purple)),
];
)
