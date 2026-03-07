// =============================================================================
// QUANTIZED RECORDING  (_includes/quant-recording.scd)
// =============================================================================
// NOT loaded by default. Load manually:
//   "_includes/quant-recording.scd".loadRelative;
// Globals: ~quantRecord

// --- Record server output, starting on next bar ---
~quantRecord.(
    clock: ~link,                      // clock for quantization
    numChannels: 2,                    // channels to record
    path: "~/Music/recordings",        // output dir
    fileName: "take"                   // prefix (timestamp appended)
);
// Stop: s.stopRecording;
