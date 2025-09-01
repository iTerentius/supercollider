(
// ---- tiler.scd ----
// Stack (top → down): s.meter → FreqScope → Stethoscope
// Top-left stacking, fixed column width. All vars at top. No ternary. No Routine.

s.waitForBoot {
    // ===== vars (top of block) =====
    var pad = 12, meterH = 200, scopeH = 250, stethoH = 220;
    var wantW = 620, minW = 264;          // fixed column width (clamped)
    var ab, left, startY, colW;
    var ensureFreq, ensureStetho, place;
    var retries = 10, retryInterval = 0.25;
    var i; // loop index for scheduling

    // -------- screen geometry (visible area of the primary screen) --------
    ab     = Window.availableBounds;            // Rect(left, top, width, height)
    left   = (ab.left + pad).asInteger;         // fixed left edge
    startY = (ab.top  + pad).asInteger;         // start near top-left
    colW   = wantW.min(ab.width - (pad * 2)).max(minW).asInteger;

    // -------- ensure windows exist --------
    q = q ?? { s.meter };  // Server meter (only supports .position)

    ensureFreq = {
        if (w.isNil or: { w.window.isNil }) {
            w = FreqScope.new(colW, scopeH, 0, nil, nil, s);
        };
    };

    ensureStetho = {
        if (v.isNil or: { v.window.isNil }) {
            v = Stethoscope(s, 2);
        };
    };

    // -------- placement (top-left downwards) --------
    place = {
        var y, wW, sW; // declare at top of function
        y = startY;

        // 1) Server meter (estimate height just for spacing)
        if (q.notNil) {
            q.position = left @ y;
            y = y + meterH + pad;
        };

        // 2) FreqScope
        ensureFreq.value;
        if (w.notNil and: { w.window.notNil }) {
            wW = colW;
            w.window.bounds = Rect(left, y, wW, scopeH);
            y = y + scopeH + pad;
        };

        // 3) Stethoscope
        ensureStetho.value;
        if (v.notNil and: { v.window.notNil }) {
            sW = colW;
            v.window.bounds = Rect(left, y, sW, stethoH);
            y = y + stethoH + pad;
        };

        nil
    };

    // -------- schedule a few one-shot placements (no Routine) --------
    i = 0;
    while { i <= retries } {
        AppClock.sched(i * retryInterval, { place.value; nil });
        i = i + 1;
    };
};
)

