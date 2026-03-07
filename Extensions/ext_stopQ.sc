// sc_system/Extensions/ext_stopQ.sc
+ TaskProxy {
    stopQ { |quant|
        var dt = this.clock ? TempoClock.default;
        if(quant.isNil) {
            this.stop;
        } {
            dt.schedAbs(dt.nextTimeOnGrid(quant), { this.stop; nil });
        };
    }
}
