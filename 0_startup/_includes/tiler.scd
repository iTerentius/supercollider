(
// ---- tiler.scd ----
// Order (top→bottom): s.meter → FreqScope → Stethoscope → Node Tree
// Uses top-left stacking: small y near top → larger y further down.

s.waitForBoot {
    // Declare ALL vars up here:
    var pad = 12, meterH = 180, scopeH = 250, stethoH = 220, colW = 620, minTreeH = 240;
    var sb, left, topY, nodeTreeWindowFn, placeFn;
    var retries = 10, retryInterval = 0.25, attempt;

    // Screen geometry
    sb   = Window.screenBounds;
    left = sb.left + pad;   // column x (left margin)
    topY = pad;             // start just below top edge

    // Ensure the four windows exist (don’t recreate if already present)
    q = q ?? { s.meter };                                      // Server meter
    w = w ?? { FreqScope.new(colW, scopeH, 0, nil, nil, s) };  // FreqScope (server last)
    v = v ?? { Stethoscope(s, 2) };                            // Stethoscope
    // x = x ?? { s.plotTree(0.5) };                              // Node tree object

    // Helper: get the node-tree window across SC versions
    nodeTreeWindowFn = {
        (x.respondsTo(\window) and: { x.window.notNil }).if({ x.window }, { s.plotTreeWindow })
    };

    // Placement from the top-left downward
    placeFn = {
        var y = topY, tWin, remain;

        // 1) Server meter (position only; size fixed)
        if (q.notNil) {
            q.position = left @ y;
            y = y + meterH + pad;
        };

        // 2) FreqScope
        if (w.notNil and: { w.window.notNil }) {
            w.window.bounds = Rect(left, y, colW, scopeH);
            y = y + scopeH + pad;
        };

        // 3) Stethoscope
        if (v.notNil and: { v.window.notNil }) {
            v.window.bounds = Rect(left, y, colW, stethoH);
            y = y + stethoH + pad;
        };

        // 4) Node tree (fill remaining height, min size)
        // tWin = nodeTreeWindowFn.();
        // if (tWin.notNil) {
        //     remain = (sb.height - y - pad).max(minTreeH).asInteger;
        //     tWin.bounds = Rect(left, y, colW, remain);
        // };

        nil
    };

    // Retry placement a few times to catch slow-opening windows
    Routine({
        attempt = 0;
        while { attempt < retries } {
            retryInterval.wait;
            attempt = attempt + 1;
            { placeFn.() }.defer;
        }
    }).play(AppClock);
};
)

