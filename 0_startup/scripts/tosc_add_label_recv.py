#!/usr/bin/env python3
"""
Add OSC receive messages to FX label controls in a TouchOSC XML file.

FX labels currently have NO messages block, so SC can't push label text to them.
This adds a receive-only OSC messages block to every LABEL inside the fx groups.

Two address patterns depending on label depth:

  Knob/XY/toggle label  (label inside r1/r2/xy1/t1 group inside fxN):
    /tosc/fx/ + tag + / + parent.parent.name + / + parent.name + /label

  Slot label  (label directly inside fxN, after the fader):
    /tosc/fx/ + tag + / + parent.name + /label

Discrimination: if self.parent.parent.name appears in Lua within 2000 chars
before the label → knob/XY/toggle label. Otherwise → slot label.

Usage:
    python3 tosc_add_label_recv.py input.xml output.xml
"""

import re
import sys

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _partial(ptype, val):
    return (
        "<partial>\n"
        f"<type>{ptype}</type>\n"
        "<conversion>STRING</conversion>\n"
        f"<value><![CDATA[{val}]]></value>\n"
        "<scaleMin>0</scaleMin>\n"
        "<scaleMax>1</scaleMax>\n"
        "</partial>"
    )


def _osc_messages(path_partials):
    """Build a receive-only OSC messages block for a label control."""
    path_body = "\n".join(path_partials)
    return (
        "<messages>\n"
        "<osc>\n"
        "<enabled>1</enabled>\n"
        "<send>0</send>\n"
        "<receive>1</receive>\n"
        "<feedback>0</feedback>\n"
        "<noDuplicates>0</noDuplicates>\n"
        "<connections>1111111111</connections>\n"
        "<triggers>\n"
        "<trigger>\n"
        "<var><![CDATA[text]]></var>\n"
        "<condition>ANY</condition>\n"
        "</trigger>\n"
        "</triggers>\n"
        "<path>\n"
        + path_body + "\n"
        "</path>\n"
        "<arguments>\n"
        "<partial>\n"
        "<type>VALUE</type>\n"
        "<conversion>STRING</conversion>\n"
        "<value><![CDATA[text]]></value>\n"
        "<scaleMin>0</scaleMin>\n"
        "<scaleMax>1</scaleMax>\n"
        "</partial>\n"
        "</arguments>\n"
        "</osc>\n"
        "</messages>"
    )


# Path for knob/XY/toggle label  (parent = r1/xy1/t1,  grandparent = fxN)
#   /tosc/fx/ + tag + / + parent.parent.name + / + parent.name + /label
MESSAGES_DEEP = _osc_messages([
    _partial("CONSTANT", "/tosc/fx/"),
    _partial("PROPERTY", "tag"),
    _partial("CONSTANT", "/"),
    _partial("PROPERTY", "parent.parent.name"),
    _partial("CONSTANT", "/"),
    _partial("PROPERTY", "parent.name"),
    _partial("CONSTANT", "/label"),
])

# Path for slot label  (parent = fxN directly)
#   /tosc/fx/ + tag + / + parent.name + /label
MESSAGES_SLOT = _osc_messages([
    _partial("CONSTANT", "/tosc/fx/"),
    _partial("PROPERTY", "tag"),
    _partial("CONSTANT", "/"),
    _partial("PROPERTY", "parent.name"),
    _partial("CONSTANT", "/label"),
])

# Lua marker that distinguishes knob/XY/toggle controls from fader/slot context
DEEP_LUA_MARKER = "self.parent.parent.name"

# Pattern to find label nodes that have NO messages block yet.
# Tempered greedy: (?:(?!<node ID=).)*? prevents crossing into a sibling node,
# which would happen when a preceding label already has <messages> (its </values>
# is not immediately followed by </node>, so .*? would otherwise extend further).
LABEL_NO_MSG = re.compile(
    r"(<node ID='[^']+' type='LABEL'>(?:(?!<node ID=).)*?</values>\n)(</node>)",
    re.DOTALL
)

LOOKBACK      = 4500   # chars back for is_deep discriminator
LOOKBACK_FX   = 9000   # chars back to detect fx context (some groups are large)

# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 tosc_add_label_recv.py input.xml output.xml")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    print(f"Reading {in_path} …")
    text = open(in_path, encoding="utf-8").read()

    segments = []
    pos = 0
    added_deep = 0
    added_slot = 0
    skipped    = 0

    for m in LABEL_NO_MSG.finditer(text):
        # Already has a messages block?
        if '<messages>' in m.group(1):
            continue

        node_start = m.start()

        # Only process labels inside fx groups — check wider window
        fx_ctx = text[max(0, node_start - LOOKBACK_FX): node_start]
        if 'sendOSC("/tosc/fx/"' not in fx_ctx:
            skipped += 1
            continue

        # Use child_depth to pick path: depth=1 means direct child of fxN (slot label)
        # depth=2 means inside a sub-group (r1/xy1/t1) → deep path
        prefix_text = text[:node_start]
        child_depth = prefix_text.count('<children>') - prefix_text.count('</children>')
        is_deep = child_depth >= 2

        messages_block = MESSAGES_DEEP if is_deep else MESSAGES_SLOT
        label_prefix   = m.group(1)   # <node…>…</values>\n
        close_node     = m.group(2)   # </node>

        # Copy text up to this label node
        segments.append(text[pos:node_start])
        segments.append(label_prefix)
        segments.append(messages_block)
        segments.append("\n")
        segments.append(close_node)
        pos = m.end()

        if is_deep:
            added_deep += 1
        else:
            added_slot += 1

    segments.append(text[pos:])
    out = "".join(segments)

    print(f"  Added knob/XY/toggle label receives: {added_deep}")
    print(f"  Added slot label receives:           {added_slot}")
    print(f"  Skipped (non-fx labels):             {skipped}")

    print(f"Writing {out_path} …")
    open(out_path, "w", encoding="utf-8").write(out)
    print("Done.")


if __name__ == "__main__":
    main()
