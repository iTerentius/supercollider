var ctrl, q, v, w, x, moveWatch, layout;
    var outbus = 0;   // change if your main LR isn’t 0/1
    var gutter = 10;

    // Controller window
    ctrl = Window("Monitor Desk (controller)", Rect(120, 100, 620, ))
        .front
        .alwaysOnTop_(true);

    // Open your preferred stock tools
    q = s.meter;                         // server meter
    v = Stethoscope(s, 2);               // oscilloscope
    w = FreqScope.new(580, 220, outbus, nil, nil, s);  // <<< server last (colors = nil)

    // Node tree button (opens/positions beside controller)
    Button(ctrl, Rect(10, ctrl.view.bounds.height-38, 160, 28))
      .states_([["Node Tree ▶︎"]])
      .action_({
        var b = ctrl.bounds;
        x = s.plotTree(0.5);  // get the NodeTreeView
        if (x.respondsTo(\window)) {
            x.window.bounds = Rect(b.left + b.width + gutter, b.bottom + b.height - 420, 520, 400);
        };
      });

    // Layout function (stacked + narrow)
    layout = { |b|
        var left = b.left + gutter;
        var innerW = b.width - (gutter * 2);
        var y = b.bottom + gutter;

        // FreqScope (has its own window)
        if (w.notNil) {
            w.window.bounds = Rect(left, y, innerW, 220);
            y = y + 220 + gutter;
        };

        // Stethoscope
        if (v.notNil) {
            v.bounds = Rect(left, y, innerW, 200);
            y = y + 200 + gutter;
        };

        // Server meter (position only; size is fixed)
        if (q.notNil) {
            q.position = left @ y;
            y = y + 130 + gutter;  // approximate height for spacing
        };

        // Park node-tree (if open) to the right
        if (x.notNil and: { x.respondsTo(\window) and: { x.window.notNil } }) {
            x.window.bounds = Rect(b.left + b.width + gutter, b.bottom + b.height - 420, 520, 400);
        };
    };

    // Initial layout
    { layout.(ctrl.bounds) }.defer;

    // Resize handler -> TopView
    ctrl.view.onResize_({ layout.(ctrl.bounds) });

    // Follow moves (poll bounds while dragging)
    moveWatch = Routine({
        var last = ctrl.bounds;
        loop {
            0.15.wait;
            if (ctrl.bounds != last) {
                last = ctrl.bounds;
                { layout.(last) }.defer;
            };
        }
    }).play(AppClock);

    // Cleanup
    ctrl.onClose_({
        moveWatch.stop;
        if (w.notNil) { w.kill };           // FreqScope cleanup
        if (v.notNil) { v.close };
        if (q.notNil) { q.close };
        if (x.notNil and: { x.respondsTo(\window) }) { x.window.close };
    });
