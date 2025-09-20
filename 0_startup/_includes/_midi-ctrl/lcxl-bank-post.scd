(
// --- lcxl-bank-post.scd (SC 3.14 safe) ---
// Prints current bank every time ~setBank is called.
// Requires: ~setBank already defined by the router.

var postBank, origSetBank;

if(~setBank.notNil) {
    postBank = { |b| ("[ bank  b" ++ b ++ " ]").postln };
    origSetBank = ~setBank;

    // wrap ~setBank to add a post after switching
    ~setBank = { |b|
        var r = origSetBank.value(b);
        postBank.(b);
        r
    };

    "[lcxl] bank-post installed".postln;
} {
    "[lcxl] ~setBank not found; skipping bank post hook".postln;
};
)

