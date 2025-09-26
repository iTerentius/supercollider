
    // For Regular Params.
    // "_includes/_midi-ctrl/lcxl_lite_router.scd".loadRelative;    // LCXL direct mapping plus LEDs
    "cc_bind_hub.scd".loadRelative;         // hub first so ~ccEmit exists
    // "_includes/_midi-ctrl/lcxl_param_router_full.scd".loadRelative;    // LCXL direct mapping plus LEDs
    // "_includes/_midi-ctrl/lcn_param_router.scd".loadRelative;    // optional if you still use LCN/ LCXL taper override
    "midi_router_cleanup.scd".loadRelative;         // hub first so ~ccEmit exists
    "lcn_param_router.locked.uid.v4.scd".loadRelative;         // hub first so ~ccEmit exists
    "lcxl_param_router.locked.uid.v9.scd".loadRelative;         // hub first so ~ccEmit exists
    "rearm_both_locked_uid.v2.scd".loadRelative;         // hub first so ~ccEmit exists
    "lcxl_force_rearm.v1.scd".loadRelative;         // hub first so ~ccEmit exists
