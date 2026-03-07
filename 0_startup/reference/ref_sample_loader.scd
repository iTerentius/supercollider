// =============================================================================
// SAMPLE LOADER  (_includes/sample_loader.scd)
// =============================================================================
// Globals:  ~sTree, ~fbufs, ~bufMeta, ~auditionOut

// --- Load a sample directory recursively (wav/aif/aiff/flac) ---
~loadSamps.("/path/to/samples");
// Populates ~sTree as nested IdentityDictionaries:
//   ~sTree[\folder_name][\file_name] -> Buffer
// Also populates ~fbufs[\folder_name] -> array of bufnums

// --- Inspect the tree ---
~printTree.();                         // print all folder/file keys
~listTopKeys.();                       // print just top-level folder keys

// --- Retrieve a buffer by keys ---
~getSample.(\kicks, \kick_01);         // -> Buffer (or nil)
~asBuf.(\kicks, \kick_01);            // same, but with tolerant key matching
~asBuf.(aBuf);                        // pass-through if already a Buffer

// --- Play a buffer (audition) ---
~playBuf.(~getSample.(\kicks, \kick_01));
~playBuf.(\kicks, \kick_01);          // resolves keys automatically
~playBuf.(\kicks, \kick_01,
    out: 0,
    amp: 0.6,
    rate: 1,
    startPos: 0,    // 0.0-1.0 normalized
    pan: 0           // -1 to 1
);

// --- Set default audition output ---
~setDefaultOut.(0);                   // bus pair index

// --- Chop helper (needs \chop_pb_m / \chop_pb_s synthdefs) ---
~chopSample.(\breaks, \amen_break, out: 0, amp: 0.5, rate: 1);
~chopInstrForBuf.(buf);               // -> \chop_pb_m or \chop_pb_s
