(
// ---- tiler.scd ----
// Order (top→bottom): s.meter → FreqScope → Stethoscope → Node Tree
// Places windows RELATIVE TO the meter's current position to avoid coord-system mismatches.

s.waitForBoot {
    // Sizes you can tweak
    var pad = 12, meterH = 200, scopeH = 250, stethoH = 220, minTreeH = 240, wantW = 620;

    // Bounds helpers
    var ab = Window.availableBounds;                 // safe visible area
    var minW = 264;                                  // FreqScope minimum width
    var clampW = { |x| x.clip(minW, ab.width - pad) };
    var clampH = { |x| x.clip(120, ab.height - pad) };

    // Open (or reuse) windows
    q = q ?? { s.meter };                                      // Server meter (fixed size UI)
    w = w ?? { FreqScope.new(wantW, scopeH, 0, nil, nil, s) }; // FreqScope (server last)
    v = v ?? { Stethoscope(s, 2) };                            // Stethoscope
    x = x ?? { s.plotTree(0.5) };                              // Node tree holder

    // Get the node tree window across versions
    var nodeTreeWindow = {
        (x.respondsTo(\window) and: { x.window.notNil }).if({ x.window }, { s.plotTreeWindow })
    };

    // Placement function: read meter pos and stack downward from it
    var place = {
        var base = q.notNil.if({ q.position }, { Point(ab.left + pad, ab.top + pad) });
        var colX = base.x;                     // align left edges with the meter
        var y    = base.y + meterH + pad;      // start just below the meter
        var colW = clampW.(wantW);
        var treeH;

        // FreqScope
        if (w.notNil and: { w.window.notNil }) {
            w.window.bounds = Rect(colX, y, colW, clampH.(scopeH));
            y = y + clampH.(scopeH) + pad;
        };

        // Stethoscope
        if (v.notNil and: { v.window.notNil }) {
            v.window.bounds = Rect(colX, y, colW, clampH.(stethoH));
            y = y + clampH.(stethoH) + pad;
        };

        // Node Tree (fill remaining vertical space; clamp to minTreeH)
        var tWin = nodeTreeWindow.();
        if (tWin.notNil) {
            // compute remaining height inside availableBounds in a coord-agnostic way:
            // use the bottom edge as the max height source
            var bottomEdge = ab.top + ab.height - pad;   // lower edge in the same orientation as 'y'
            treeH = (bottomEdge - y).max(minTreeH).asInteger;
            tWin.bounds = Rect(colX, y, colW, clampH.(treeH));
        };

        nil
    };

    // Retry a few times so late-opening child windows get placed
    Routine({
        12.do {
            0.25.wait;
            { place.() }.defer;
        };
    }).play(AppClock);
};
)

