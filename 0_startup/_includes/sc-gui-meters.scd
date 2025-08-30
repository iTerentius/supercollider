(
// ---- tiler.scd ----
// Stacks (top → down): s.meter → FreqScope → Stethoscope
// No Routine, no scheduling. All vars declared at top. Fixed column width.

s.waitForBoot {
    // ====== vars (top) ======
    var pad = 12, meterH = 200, scopeH = 250, stethoH = 220;
    var wantW = 620, minW = 264;
    var ab, useTopOrigin = true;   // set to false if your system needs bottom-origin Y
    var left, startY, colW, y;
    var ensureFreq, ensureStetho;

    // Visible area on primary screen
    ab     = Window.availableBounds;                  // Rect(left, top, width, height)
    left   = (ab.left + pad).asInteger;
    colW   = wantW.min(ab.width - (pad * 2)).max(minW).asInteger;

    // Choose Y origin style
    startY = if (useTopOrigin) {
        (ab.top + pad).asInteger                // top-left stacking (y increases downward)
    }{
        (ab.bottom + ab.height - pad).asInteger // bottom-origin numeric "top"
    };

    // Ensure the three windows exist
    q = q ?? { s.meter };  // ServerMeter (pos only)
    if (w.isNil or: { w.window.isNil }) { w = FreqScope.new(colW, scopeH, 0, nil, nil, s) };
    if (v.isNil or: { v.window.isNil }) { v = Stethoscope(s, 2) };

    // ---- placement (no scheduling) ----
    y = startY;

    // 1) Server meter (spacing uses meterH estimate)
    if (useTopOrigin) {
        q.position = left @ y;         // top-left style
        y = y + meterH + pad;
    }{
        q.position = left @ (y - meterH);  // bottom-origin style
        y = y - (meterH + pad);
    };

    // 2) FreqScope
    if (w.window.notNil) {
        if (useTopOrigin) {
            w.window.bounds = Rect(left, y, colW, scopeH);
            y = y + scopeH + pad;
        }{
            w.window.bounds = Rect(left, (y - scopeH), colW, scopeH);
            y = y - (scopeH + pad);
        };
    };

    // 3) Stethoscope
    if (v.window.notNil) {
        if (useTopOrigin) {
            v.window.bounds = Rect(left, y, colW, stethoH);
            y = y + stethoH + pad;
        }{
            v.window.bounds = Rect(left, (y - stethoH), colW, stethoH);
            y = y - (stethoH + pad);
        };
    };

    // done — no AppClock, no Routine
};
)

