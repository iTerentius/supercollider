// midi_router_cleanup.scd  2025-09-26 18:46
(
// free any stray MIDIdefs that might collide
[
\apc_bank_note, \apc_cc, \apc_grid_on, \apc_grid_off,
\lcxl_bank_note, \lcxl_cc_full,
\lcn_bank_note_locked, \lcn_cc_locked,
\peek_lcxl_locked, \peek_lcn_locked,
\peek_lcxl_locked_uid, \peek_lcn_locked_uid
].do { |k| MIDIdef.free(k) };

"[router cleanup] freed known defs".postln;
)
