#!/usr/bin/env python3
"""
Fix OSC receive paths on all FX controls (r, xy, t, f) in a TouchOSC XML file.

Controls in the FX groups currently have the wrong default receive path
  / parent.name / name  →  e.g. /r2/r
which doesn't match what SC sends.

This script replaces it with the correct FX address for each control type:

  r / xy / t  (inside r{n} or xy{n} group inside fx{n}):
    /tosc/fx/ + tag + / + parent.parent.name + / + parent.name
    e.g.  /tosc/fx/1/fx1/r2

  f  (fader, directly inside fx{n}):
    /tosc/fx/ + tag + / + parent.name + /f
    e.g.  /tosc/fx/1/fx1/f

Already-correct paths (those with /tosc/fx/ in the first partial) are skipped.

Usage:
    python3 tosc_add_fx_recv.py input.xml output.xml
"""

import re
import sys

# ---------------------------------------------------------------------------
# Wrong path that needs replacing (same pattern for all fx control types)
# ---------------------------------------------------------------------------
WRONG_PATH = (
    "<path>\n"
    "<partial>\n"
    "<type>CONSTANT</type>\n"
    "<conversion>STRING</conversion>\n"
    "<value><![CDATA[/]]></value>\n"
    "<scaleMin>0</scaleMin>\n"
    "<scaleMax>1</scaleMax>\n"
    "</partial>\n"
    "<partial>\n"
    "<type>PROPERTY</type>\n"
    "<conversion>STRING</conversion>\n"
    "<value><![CDATA[parent.name]]></value>\n"
    "<scaleMin>0</scaleMin>\n"
    "<scaleMax>1</scaleMax>\n"
    "</partial>\n"
    "<partial>\n"
    "<type>CONSTANT</type>\n"
    "<conversion>STRING</conversion>\n"
    "<value><![CDATA[/]]></value>\n"
    "<scaleMin>0</scaleMin>\n"
    "<scaleMax>1</scaleMax>\n"
    "</partial>\n"
    "<partial>\n"
    "<type>PROPERTY</type>\n"
    "<conversion>STRING</conversion>\n"
    "<value><![CDATA[name]]></value>\n"
    "<scaleMin>0</scaleMin>\n"
    "<scaleMax>1</scaleMax>\n"
    "</partial>\n"
    "</path>"
)

# ---------------------------------------------------------------------------
# Correct receive paths
# ---------------------------------------------------------------------------

def _path(*partials):
    """Build a <path> block from a list of (type, value) tuples."""
    lines = ["<path>"]
    for ptype, val in partials:
        lines += [
            "<partial>",
            f"<type>{ptype}</type>",
            "<conversion>STRING</conversion>",
            f"<value><![CDATA[{val}]]></value>",
            "<scaleMin>0</scaleMin>",
            "<scaleMax>1</scaleMax>",
            "</partial>",
        ]
    lines.append("</path>")
    return "\n".join(lines)


# /tosc/fx/ + tag + / + parent.parent.name + / + parent.name
#   → used by r, xy, t  (nested two levels inside fx slot)
CORRECT_PATH_DEEP = _path(
    ("CONSTANT", "/tosc/fx/"),
    ("PROPERTY", "tag"),
    ("CONSTANT", "/"),
    ("PROPERTY", "parent.parent.name"),
    ("CONSTANT", "/"),
    ("PROPERTY", "parent.name"),
)

# /tosc/fx/ + tag + / + parent.name + /f
#   → used by f fader  (directly inside fx slot, one level)
CORRECT_PATH_FADER = _path(
    ("CONSTANT", "/tosc/fx/"),
    ("PROPERTY", "tag"),
    ("CONSTANT", "/"),
    ("PROPERTY", "parent.name"),
    ("CONSTANT", "/f"),
)

# Lua markers that identify each control type
LUA_MARKER_DEEP  = 'sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.parent.name'
LUA_MARKER_FADER = 'sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.name .. "/f"'

LOOKBACK = 4000  # chars to look back from <path> to find the Lua script

# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 tosc_add_fx_recv.py input.xml output.xml")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    print(f"Reading {in_path} …")
    text = open(in_path, encoding="utf-8").read()

    WRONG_LEN = len(WRONG_PATH)
    LOOKBACK_SKIP = 20  # skip the already-correct ones: first partial has /tosc/fx/
    SKIP_MARKER   = "CDATA[/tosc/fx/]]>"

    segments = []
    pos = 0
    updated_deep  = 0
    updated_fader = 0
    skipped       = 0

    while pos < len(text):
        idx = text.find(WRONG_PATH, pos)
        if idx == -1:
            segments.append(text[pos:])
            break

        # Look back for fx Lua marker
        lookback_start = max(0, idx - LOOKBACK)
        context = text[lookback_start:idx]

        if LUA_MARKER_FADER in context:
            segments.append(text[pos:idx])
            segments.append(CORRECT_PATH_FADER)
            pos = idx + WRONG_LEN
            updated_fader += 1
        elif LUA_MARKER_DEEP in context:
            segments.append(text[pos:idx])
            segments.append(CORRECT_PATH_DEEP)
            pos = idx + WRONG_LEN
            updated_deep += 1
        else:
            # Not an fx control — copy verbatim
            segments.append(text[pos:idx + WRONG_LEN])
            pos = idx + WRONG_LEN
            skipped += 1

    out = "".join(segments)

    print(f"  Updated r/xy/t controls: {updated_deep}")
    print(f"  Updated f faders:        {updated_fader}")
    print(f"  Left unchanged:          {skipped}")

    print(f"Writing {out_path} …")
    open(out_path, "w", encoding="utf-8").write(out)
    print("Done.")


if __name__ == "__main__":
    main()
