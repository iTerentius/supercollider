#!/usr/bin/env python3
"""
Add OSC receive path+argument to all mixer controls in a TouchOSC XML file.

Mixer controls have a Lua script that sends to /tosc/b{bank}/{strip}/{ctrl}
using:  self.parent.parent.name / self.parent.name / self.name

This script fills in the matching receive <path> and <argument> so that
SC can push values back to the control (soft-takeover / visual sync).

The script is safe to re-run — it only touches empty <path>…</path> blocks.

Usage:
    python3 tosc_add_mixer_recv.py input.xml output.xml
"""

import re
import sys

# ---------------------------------------------------------------------------
# The receive <path> block (mirrors Lua: /tosc/b + ppp.name + / + pp.name + / + name)
# ---------------------------------------------------------------------------
RECV_PATH = """\
<path>
<partial>
<type>CONSTANT</type>
<conversion>STRING</conversion>
<value><![CDATA[/tosc/b]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
<partial>
<type>PROPERTY</type>
<conversion>STRING</conversion>
<value><![CDATA[parent.parent.name]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
<partial>
<type>CONSTANT</type>
<conversion>STRING</conversion>
<value><![CDATA[/]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
<partial>
<type>PROPERTY</type>
<conversion>STRING</conversion>
<value><![CDATA[parent.name]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
<partial>
<type>CONSTANT</type>
<conversion>STRING</conversion>
<value><![CDATA[/]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
<partial>
<type>PROPERTY</type>
<conversion>STRING</conversion>
<value><![CDATA[name]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
</path>"""

RECV_ARGS = """\
<arguments>
<partial>
<type>VALUE</type>
<conversion>FLOAT</conversion>
<value><![CDATA[x]]></value>
<scaleMin>0</scaleMin>
<scaleMax>1</scaleMax>
</partial>
</arguments>"""

# What we're looking for (empty path/args produced by TOSC when you enable receive
# but don't fill in the address)
EMPTY_PATH = "<path>\n</path>"
EMPTY_ARGS = "<arguments>\n</arguments>"

# Lua signature unique to mixer controls
MIXER_LUA_MARKER = 'local addr = "/tosc/b" .. self.parent.parent.name'

# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 tosc_add_mixer_recv.py input.xml output.xml")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    print(f"Reading {in_path} …")
    text = open(in_path, encoding="utf-8").read()

    # Find all positions of EMPTY_PATH in the file.
    # For each, look back up to 3000 chars for the mixer Lua marker.
    # If found, replace both <path>…</path> and <arguments>…</arguments>.

    EMPTY_PATH_LEN = len(EMPTY_PATH)
    EMPTY_ARGS_LEN = len(EMPTY_ARGS)
    LOOKBACK = 4000  # chars — enough to reach back from <path> to <script>

    result = list(text)  # mutable char list would be slow; use segments instead
    segments = []
    pos = 0
    updated = 0

    while pos < len(text):
        idx = text.find(EMPTY_PATH, pos)
        if idx == -1:
            segments.append(text[pos:])
            break

        # Check if the mixer Lua marker is within LOOKBACK chars before this point
        lookback_start = max(0, idx - LOOKBACK)
        context = text[lookback_start:idx]

        if MIXER_LUA_MARKER in context:
            # Also verify the <arguments>\n</arguments> follows the </path>
            after_path = idx + EMPTY_PATH_LEN
            # There may be a newline between </path> and <arguments>
            remainder = text[after_path:after_path + EMPTY_ARGS_LEN + 2]
            args_rel = remainder.find(EMPTY_ARGS)
            if args_rel != -1:
                # Splice in replacement
                segments.append(text[pos:idx])
                segments.append(RECV_PATH)
                args_abs_start = after_path + args_rel
                segments.append(text[after_path:args_abs_start])  # gap (newline)
                segments.append(RECV_ARGS)
                pos = args_abs_start + EMPTY_ARGS_LEN
                updated += 1
            else:
                # No empty args found right after — leave unchanged
                segments.append(text[pos:idx + EMPTY_PATH_LEN])
                pos = idx + EMPTY_PATH_LEN
        else:
            # Not a mixer control — copy verbatim
            segments.append(text[pos:idx + EMPTY_PATH_LEN])
            pos = idx + EMPTY_PATH_LEN

    out = "".join(segments)

    print(f"  Updated {updated} controls.")
    print(f"Writing {out_path} …")
    open(out_path, "w", encoding="utf-8").write(out)
    print("Done.")
    print()
    print("After importing into TouchOSC:")
    print("  • Call ~toscSync.() from SC to push current mixer state to tablet.")
    print("  • Faders/knobs will now visually match SC state on load / after ~toscStateLoad.")


if __name__ == "__main__":
    main()
