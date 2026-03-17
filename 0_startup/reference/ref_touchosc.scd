// =============================================================================
// TOUCHOSC  (tosc-router.scd + tosc-pad-router.scd)
// =============================================================================
// Two files load at startup:
//   tosc-router.scd     — core OSC dispatcher, mixer bindings, state persistence
//   tosc-pad-router.scd — LP Mini-style pad launcher grid
//
// Requires tosc-router.scd loaded first (provides ~oscParam, ~toscAddr).

// =============================================================================
// CONNECTION CONFIG
// =============================================================================
// In tosc-router.scd, set ~toscAddr to your tablet's IP:
//   ~toscAddr = NetAddr("192.168.0.62", 9000);   // tablet
//   ~toscAddr = NetAddr("127.0.0.1",   9000);    // desktop testing
//
// In TouchOSC app:
//   Connection → Send to:    [this machine's IP] : 57120
//   Connection → Receive on: [tablet IP]         : 9000

// =============================================================================
// SC GLOBALS — ROUTER
// =============================================================================
~oscParam    // IdentityDictionary: Symbol(path) → Function { |val| }  (0.0–1.0)
~oscState    // IdentityDictionary: Symbol(path) → Float  (last known value)
~toscAddr    // NetAddr to tablet

~toscSend.('tosc/b1/s1/f', 0.8);       // send val, fire callback, store in ~oscState
~toscSync.();                            // push all ~oscState to TOSC (after reconnect)
~toscStateSave.("myProject".asSymbol);  // save fader/filter positions to Archive
~toscStateLoad.("myProject".asSymbol);  // restore and sync to TOSC

// Register any OSC control manually:
~oscParam['tosc/b1/s1/f'] = { |val| ~t1.set(\amp, val) };

// =============================================================================
// SC GLOBALS — PAD ROUTER
// =============================================================================
~toscPads       // IdentityDictionary: Symbol(addr) → binding dict
~toscPadColors  // named RGBA color dict (orange, amber, green, cyan, blue, etc.)

// Bind a pad:
// bank, row, col : Integer
// key            : Symbol (Pdef/Tdef/Ndef) or Function
// color          : Symbol from ~toscPadColors — stopped color  (default \white)
// playColor      : Symbol — playing color (defaults to color)
// onStop         : Function called instead of obj.stop on toggle-off (optional)
// label          : String on pad (defaults to key.asString)
~toscPadBind.(1, 1, 1, \bd1, \orange, \green);
~toscPadBind.(1, 2, 1, \sd1, \yellow, \green);
~toscPadBind.(2, 1, 1, \bd1_fx_1, \blue, \green, ~fxSendStop[\bd1_fx_1]);

// Group launchers — any playing → stop all; none playing → start all:
~toscColBind.(1, 1);         // all pads in bank 1, col 1
~toscRowBind.(2, 1);         // all pads in bank 2, row 1 (spans cols)

// Repaint / sync:
~toscPadPaintAll.();         // repaint state only (call after reconnect)
~toscPadSyncAll.();          // repaint state + resend labels + nums (call after reconnect)
~toscPadStopAll.();          // stop all running pads across all banks

// =============================================================================
// OSC ADDRESS CONVENTIONS
// =============================================================================
// Mixer (TOSC page = bank, column = strip):
//   tosc/b{bank}/s{strip}/f    — fader (level)
//   tosc/b{bank}/s{strip}/r1   — knob row 1 (HPF)
//   tosc/b{bank}/s{strip}/r2   — knob row 2 (LPF)
//   tosc/b{bank}/s{strip}/r3   — knob row 3 (pan)
//   tosc/master/f              — master fader
//
// Pad grid (SC → TOSC feedback):
//   /tosc/p{bank}/{row}/col{col}/state   — 0.0=stopped, 1.0=playing  (updates pad color)
//   /tosc/p{bank}/{row}/col{col}/label   — pad label string
//   /tosc/p{bank}/{row}/col{col}/nums    — position string e.g. "1|2"
//
// Pad grid (TOSC → SC):
//   tosc/p{bank}/{row}/{col}   — pad press (val > 0.5 = toggle)
//   tosc/p{bank}/r/{row}       — row launcher
//   tosc/p{bank}/c/{col}       — col launcher
//   tosc/p/all                 — stop all pads
//
// Dispatcher normalises leading slash — both /tosc/... and tosc/... work.
// XY controls split into key/x and key/y sub-keys automatically.

// =============================================================================
// STATE PERSISTENCE
// =============================================================================
// Save and restore fader/filter positions per project:
~toscStateSave.("2026_03_06".asSymbol);
~toscStateLoad.("2026_03_06".asSymbol);  // put in lib/config.scd

// =============================================================================
// TOSC TREE STRUCTURE  (pad grid pages)
// =============================================================================
// p  (PAGER)
//  └─ 1  (GROUP, bank 1)
//      └─ col1  (GROUP)
//          └─ 1  (GROUP, row)
//              ├─ pad    BUTTON  — interactive, Toggle Press
//              ├─ label  LABEL   — pad name from SC
//              └─ nums   LABEL   — position string e.g. "1|1"
//      └─ r1..r9   BUTTON  — row launchers  (inside bank group)
//      └─ c1..c2   BUTTON  — col launchers  (inside bank group or col group)
//  └─ 2  (GROUP, bank 2)  ...
//  └─ 3  (GROUP, bank 3)  ...
//
// Duplication tip: group all pads on a page → copy → paste to new page → ungroup.
// Names are retained so no renaming required.

// =============================================================================
// TOSC CONTROL SETUP — PAD BUTTON
// =============================================================================
// Control type : BUTTON
// Button type  : Toggle Press
// Tag          : bank number ("1", "2", "3")  ← required for address tokens
//
// OSC Message:
//   Send:    checked   Receive: checked
//   Address tokens: /tosc/p | tag | / | parent.name | / | parent.parent.name | /state
//   Argument: x (FLOAT)
//   → resolves to e.g. /tosc/p1/1/col1/state
//   Trigger: x / ANY
//
// Lua script (onValueChanged fires from received OSC on tablet — NOT on desktop):
/*
function onValueChanged(key)
  if key == "touch" then
    local row  = self.parent.name
    local col  = string.match(self.parent.parent.name, "%d+")
    local bank = self.parent.parent.parent.name  -- or self.tag if tree depth differs
    sendOSC("/tosc/p" .. bank .. "/" .. row .. "/" .. col, self.values.touch)
  end
  if key == "x" then
    if self.values.x > 0.5 then
      self.color = Color(0.2, 1.0, 0.3, 1.0)   -- green: playing
    else
      self.color = Color(1.0, 0.6, 0.0, 1.0)   -- amber: stopped (match editor color)
    end
  end
end
*/
// Note: module-level local vars (e.g. local stoppedColor) do NOT persist between
// onValueChanged calls — TOSC re-evaluates the script each time. Hardcode colors.

// =============================================================================
// TOSC CONTROL SETUP — LABEL
// =============================================================================
// Control type : LABEL
// Tag          : bank number (set by tag script or manually)
//
// OSC Message:
//   Send: unchecked   Receive: checked
//   Address tokens: /tosc/p | tag | / | parent.name | / | parent.parent.name | /label
//   Argument: text (STRING)
//   Trigger: text / ANY

// =============================================================================
// TOSC CONTROL SETUP — NUMS LABEL
// =============================================================================
// Control type : LABEL
// Tag          : bank number
//
// OSC Message:
//   Send: unchecked   Receive: checked
//   Address: /tosc/p | tag | / | parent.name | / | parent.parent.name | /nums
//   Argument: text (STRING)
//
// Lua script — self-populates on load, no SC trigger needed:
/*
function init()
  local row = self.parent.name
  local col = string.match(self.parent.parent.name, "%d+")
  self.values.text = col .. "|" .. row
end
*/

// =============================================================================
// TOSC CONTROL SETUP — ROW LAUNCHER
// =============================================================================
// Control type : BUTTON, Momentary or Toggle Press
// Tag          : bank number
//
// Lua script:
/*
function onValueChanged(key)
  if key == "touch" then
    local row  = string.match(self.name, "%d+")
    local bank = self.parent.name
    sendOSC("/tosc/p" .. bank .. "/r/" .. row, self.values.touch)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — COL LAUNCHER
// =============================================================================
// Lua script:
/*
function onValueChanged(key)
  if key == "touch" then
    local col  = string.match(self.name, "%d+")
    local bank = self.parent.name  -- or self.parent.parent.name depending on position
    sendOSC("/tosc/p" .. bank .. "/c/" .. col, self.values.touch)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — ALL-STOP BUTTON
// =============================================================================
// Lua script:
/*
function onValueChanged(key)
  if key == "touch" then
    sendOSC("/tosc/p/all", self.values.touch)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — MIXER FADER / KNOB
// =============================================================================
// Control type : FADER (vertical) or RADIAL (knob)
// No OSC message needed — driven entirely by Lua:
/*
function onValueChanged(key)
  if key == "x" then
    local addr = "/tosc/b" .. self.parent.parent.name .. "/" .. self.parent.name .. "/" .. self.name
    sendOSC(addr, self.values[1])
  end
end
*/

// =============================================================================
// ONE-TIME UTILITY — SET ALL TAGS BY BANK
// =============================================================================
// Place on the PAGER (p) element, run bare (no function wrapper) from script editor.
// Sets tag = bank number on every descendant of each bank group.
/*
local p = self
local count = 0

local function tagAll(ctrl, tag)
  ctrl.tag = tag
  count = count + 1
  for i = 1, #ctrl.children do
    tagAll(ctrl.children[i], tag)
  end
end

for i = 1, #p.children do
  local bank = p.children[i]
  if tonumber(bank.name) then
    tagAll(bank, bank.name)
  end
end

print("Tagged " .. count .. " controls")
*/

// =============================================================================
// KNOWN LIMITATIONS / GOTCHAS
// =============================================================================
// - onValueChanged does NOT fire from received OSC in TOSC desktop app.
//   It DOES fire on the actual tablet (iOS/Android). All color feedback
//   and Lua-driven receive requires the tablet.
//
// - onReceiveOSC never fires from real OSC in TOSC desktop (tested on
//   GROUP, BUTTON, and document level). Untested on tablet.
//
// - PROPERTY argument binding (color R/G/B/A via address builder) does not
//   work from received OSC in TOSC desktop.
//
// - module-level Lua variables reset on every onValueChanged call.
//   Do not rely on local stoppedColor = nil pattern — hardcode colors instead.
//
// - TOSC address builder supports max 2 parent levels:
//   parent.name, parent.parent.name. Use Tag for bank number.
//
// - sendOSC() in TOSC Lua uses configured connections, not IP/port args.
//   Correct: sendOSC("/addr", value)
//   Wrong:   sendOSC("192.168.x.x", 57120, "/addr", value)
//
// - TOSC sends BOOL type for button touch events. SC dispatcher normalises
//   via .binaryValue.asFloat so true → 1.0, false → 0.0.
//
// - ~toscPadPaintAll only repaints state. After reconnect use ~toscPadSyncAll
//   to also resend labels and nums.
//
// - init() Lua callback fires on file load — use for self-populating controls
//   (e.g. nums label computing its own position from tree).
//
// - update() Lua callback fires every frame — available for polling logic.

// =============================================================================
// TOSC TREE STRUCTURE — FX PAGE
// =============================================================================
// synth-fx (PAGER)
//  └─ 1  (GROUP, page 1, tag=1)  — fx1..fx5
//      └─ fx1  (GROUP)
//          ├─ f      FADER   — slot level/send fader
//          ├─ label  LABEL   — slot name  (receive-only OSC, no Lua)
//          ├─ r1     GROUP
//          │   ├─ r      RADIAL  — knob
//          │   └─ label  LABEL   — knob label (receive-only OSC)
//          ├─ r2     GROUP  (same structure as r1)
//          ├─ xy1    GROUP
//          │   ├─ xy     XY      — XY pad
//          │   └─ label  LABEL
//          └─ t1     GROUP
//              ├─ t      BUTTON  — toggle, Momentary Press
//              └─ label  LABEL
//      └─ fx2..fx5  (same structure, tag=1)
//  └─ 2  (GROUP, page 2, tag=2)  — fx6..fx10

// =============================================================================
// OSC ADDRESS SCHEME — FX CONTROLS
// =============================================================================
// r / t controls (RADIAL/BUTTON inside sub-group, depth=2):
//   /tosc/fx/{tag}/{fxN}/{groupN}
//   e.g.  /tosc/fx/1/fx1/r1   /tosc/fx/1/fx1/t1
//
// xy control (XY inside sub-group, depth=2):
//   /tosc/fx/{tag}/{fxN}/{groupN}  — sends two floats (x, y)
//   e.g.  /tosc/fx/1/fx1/xy1
//
// f fader (FADER direct child of fxN, depth=1):
//   /tosc/fx/{tag}/{fxN}/f
//   e.g.  /tosc/fx/1/fx1/f
//
// label — knob/XY/toggle label (LABEL inside sub-group, depth=2):
//   /tosc/fx/{tag}/{fxN}/{groupN}/label
//   e.g.  /tosc/fx/1/fx1/r1/label
//
// label — slot label (LABEL direct child of fxN, depth=1):
//   /tosc/fx/{tag}/{fxN}/label
//   e.g.  /tosc/fx/1/fx1/label
//
// tag=1 → page 1 (fx1..fx5),  tag=2 → page 2 (fx6..fx10)

// =============================================================================
// TOSC CONTROL SETUP — FX RADIAL KNOB (r)
// =============================================================================
// Control type: RADIAL
// Tag:          inherited from fxN group (set by Python build pipeline)
// Receive path: /tosc/fx/ | tag | / | parent.parent.name | / | parent.name
// Argument:     x (VALUE FLOAT)
//
// Lua script (onValueChanged):
/*
function onValueChanged(key)
  if key == "x" then
    sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.parent.name .. "/" ..
  self.parent.name, self.values.x)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — FX XY PAD (xy)
// =============================================================================
// Control type: XY
// Receive path: /tosc/fx/ | tag | / | parent.parent.name | / | parent.name
// Arguments:    x, y (two VALUE FLOATs)
//
// Lua script:
/*
function onValueChanged(key)
  if key == "x" or key == "y" then
    sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.parent.name .. "/" ..
  self.parent.name, self.values.x, self.values.y)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — FX TOGGLE BUTTON (t)
// =============================================================================
// Control type: BUTTON, Momentary Press
// Receive path: /tosc/fx/ | tag | / | parent.parent.name | / | parent.name
// Argument:     touch (VALUE FLOAT)
//
// Lua script:
/*
function onValueChanged(key)
  if key == "touch" then
    sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.parent.name .. "/" ..
  self.parent.name, self.values.touch)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — FX FADER (f)
// =============================================================================
// Control type: FADER (horizontal or vertical)
// Receive path: /tosc/fx/ | tag | / | parent.name | /f
// Argument:     x (VALUE FLOAT)
//
// Lua script:
/*
function onValueChanged(key)
  if key == "x" then
    sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.name .. "/f", self.values.x)
  end
end
*/

// =============================================================================
// TOSC CONTROL SETUP — FX LABELS
// =============================================================================
// Receive-only (no Lua). OSC message blocks set by Python build pipeline.
//
// Knob/XY/toggle label (inside sub-group, depth=2):
//   Receive path: /tosc/fx/ | tag | / | parent.parent.name | / | parent.name | /label
//   Trigger: text / ANY    Argument: text (VALUE STRING)
//
// Slot label (direct child of fxN, depth=1):
//   Receive path: /tosc/fx/ | tag | / | parent.name | /label
//   Trigger: text / ANY    Argument: text (VALUE STRING)

// =============================================================================
// SC FX BIND HELPERS  (tosc-fx.scd)
// =============================================================================
// ~toscFXLabel.(slot, text)           — push slot label text
//   addr: /tosc/fx/{page}/fx{slot}/label
//
// ~toscFXBind.(slot, group, func)     — bind r/t control; calls func(val 0-1)
//   addr: /tosc/fx/{page}/fx{slot}/{group}
//
// ~toscFXBindXY.(slot, group, func)   — bind xy control; calls func(x, y)
//   addr: /tosc/fx/{page}/fx{slot}/{group}
//
// ~toscFXSync.(slot, group, val)      — push value back to TOSC control
// ~toscFXSyncXY.(slot, group, x, y)  — push XY values back
//
// page = ceil(slot / 5).asInteger  — slot 1-5 → page 1, slot 6-10 → page 2

// =============================================================================
// PYTHON BUILD PIPELINE  (0_startup/scripts/)
// =============================================================================
// Source: sc-devices-016.xml  (decompressed base; do NOT modify directly)
// Output: sc-devices-NNN.tosc
//
// Run from the TouchOSC/SC/ directory (or adjust paths):
/*
REF=~/Music/supercollider/0_startup/scripts
python3 $REF/tosc_dup_fx.py      input.xml    step1.xml   # dup fx1 → fx2..fx10 across 2 pages
python3 $REF/tosc_add_mixer_recv.py step1.xml step2.xml   # fill 320 mixer receive paths
python3 $REF/tosc_add_fx_recv.py    step2.xml step3.xml   # fix FX control receive paths
python3 $REF/tosc_add_label_recv.py step3.xml step4.xml   # add label receive messages
python3 $REF/tosc_convert.py compress step4.xml output.tosc
*/
//
// tosc_dup_fx.py config (top of file):
//   FX1_ID          — UUID of the fx1 GROUP node in the base XML
//   PAGE2_ID        — UUID of the page-2 GROUP in the synth-fx PAGER
//   FX_WIDTH/GAP    — slot width (400) and gap (10) in px
//   FX1_X / FX1_Y  — top-left position of fx1 (43, 20)
//   FX_SLOTS_PAGE1  — number of slots on page 1 (currently 5)
//   FX_SLOTS_PAGE2  — number of slots on page 2 (currently 5)
//
// The script also patches a pre-existing bug in the base XML:
//   slot label path had CDATA[label] instead of CDATA[/label] (missing leading /)
//   Fixed by string-replacing in the fx1 block before duplication.
//
// tosc_convert.py — decompress/recompress .tosc ↔ .xml
//   .tosc is raw zlib-compressed XML (magic bytes 78 9C), NOT a zip file.
//   python3 tosc_convert.py decompress file.tosc file.xml
//   python3 tosc_convert.py compress   file.xml  file.tosc
