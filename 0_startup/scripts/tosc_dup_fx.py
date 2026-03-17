#!/usr/bin/env python3
"""
Duplicate fx1 → fx2-fx5 in a TouchOSC XML file.

Usage:
    python3 tosc_dup_fx.py input.xml output.xml

Strategy:
  - Find the fx1 GROUP node by its known ID (or by searching for name=fx1)
  - Extract its raw XML text by tracking <node> depth
  - For each copy (fx2..fx5):
      • Replace all node IDs with fresh UUIDs
      • Change name from fx1 → fx{n}
      • Change the outer frame x position
      • Replace ALL tag values in the block with n  (replaces the Lua tag setter)
  - Insert all copies immediately after fx1 in the output
"""

import re
import sys
import uuid

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
FX1_NAME = "fx1"
FX1_ID   = "0a7f7786-2187-11f1-ab91-822d22c57702"   # outer GROUP node ID
PAGE2_ID = "d7256f44-2181-11f1-8180-822d22c57702"    # fx pager page-2 GROUP node ID

FX_WIDTH        = 400
FX_GAP          = 10    # pixels between slots on same page
FX1_X           = 43    # x of fx1 on page 1
FX1_Y           = 20    # y (same for all slots)
FX_SLOTS_PAGE1  = 5     # fx1-fx5  on page 1  (tag=1)
FX_SLOTS_PAGE2  = 5     # fx6-fx10 on page 2  (tag=2)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def find_node_boundaries(text, node_id):
    """Return (start, end) byte offsets of the <node ID='node_id' ...>…</node> block."""
    pattern = f"<node ID='{node_id}'"
    start = text.find(pattern)
    if start == -1:
        raise ValueError(f"Node ID '{node_id}' not found in XML")

    # Walk forward tracking <node depth
    depth = 0
    pos = start
    while pos < len(text):
        next_open  = text.find('<node', pos)
        next_close = text.find('</node>', pos)
        if next_close == -1:
            raise ValueError("Unmatched <node> — XML may be malformed")
        if next_open != -1 and next_open < next_close:
            depth += 1
            pos = next_open + len('<node')
        else:
            depth -= 1
            pos = next_close + len('</node>')
            if depth == 0:
                return start, pos
    raise ValueError("Could not find closing </node> for fx1")


def new_uuid():
    return str(uuid.uuid4())


def replace_all_ids(block):
    """Replace every node ID='...' with a fresh UUID."""
    def _repl(m):
        return f"<node ID='{new_uuid()}'"
    return re.sub(r"<node ID='[^']*'", _repl, block)


def replace_name(block, old_name, new_name):
    """Change the first occurrence of name CDATA value."""
    # Matches:  <key><![CDATA[name]]></key>\n<value><![CDATA[fx1]]></value>
    # We only want the first match (the outer group name, not inner children).
    pattern = (
        r'(<key><!\[CDATA\[name\]\]></key>\s*<value><!\[CDATA\[)'
        + re.escape(old_name)
        + r'(\]\]></value>)'
    )
    new_block, count = re.subn(pattern, r'\g<1>' + new_name + r'\2', block, count=1)
    if count == 0:
        raise ValueError(f"Could not find name '{old_name}' in block")
    return new_block


def replace_all_tags(block, new_tag_value):
    """Replace ALL tag property values in the block (mirrors the Lua tag setter)."""
    tag = str(new_tag_value)
    pattern = (
        r'(<key><!\[CDATA\[tag\]\]></key>\s*<value><!\[CDATA\[)'
        + r'[^]]*'
        + r'(\]\]></value>)'
    )
    new_block, count = re.subn(pattern, r'\g<1>' + tag + r'\2', block)
    if count == 0:
        # tag might use plain text (no CDATA) — try alternative
        pattern2 = r'(<key><!\[CDATA\[tag\]\]></key>\s*<value>)[^<]*?(</value>)'
        new_block, count = re.subn(pattern2, r'\g<1>' + tag + r'\2', block)
    if count == 0:
        print(f"  WARNING: could not update any tags to {new_tag_value} — check manually", file=sys.stderr)
    else:
        print(f"    Tagged {count} controls with {new_tag_value}")
    return new_block


def replace_outer_frame_x(block, new_x):
    """Replace the x value in the outer node's frame property (first <x>…</x>)."""
    new_block, count = re.subn(r'<x>[0-9]+</x>', f'<x>{new_x}</x>', block, count=1)
    if count == 0:
        print(f"  WARNING: could not update frame x to {new_x}", file=sys.stderr)
    return new_block


def replace_outer_frame_y(block, new_y):
    """Replace the y value in the outer node's frame property (first <y>…</y>)."""
    new_block, count = re.subn(r'<y>[0-9]+</y>', f'<y>{new_y}</y>', block, count=1)
    if count == 0:
        print(f"  WARNING: could not update frame y to {new_y}", file=sys.stderr)
    return new_block


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 tosc_dup_fx.py input.xml output.xml")
        sys.exit(1)

    in_path, out_path = sys.argv[1], sys.argv[2]

    print(f"Reading {in_path} …")
    with open(in_path, 'r', encoding='utf-8') as f:
        text = f.read()

    print(f"Locating fx1 node (ID={FX1_ID}) …")
    start, end = find_node_boundaries(text, FX1_ID)
    fx1_block = text[start:end]
    print(f"  Found: chars {start}–{end}  ({end - start:,} chars, "
          f"~{(end-start)//1000}k)")

    # Fix slot label path bug in fx1: last path partial has 'label' not '/label'
    BROKEN_LABEL = "<![CDATA[label]]></value>\n<scaleMin>0</scaleMin>\n<scaleMax>1</scaleMax>\n</partial>\n</path>"
    FIXED_LABEL  = "<![CDATA[/label]]></value>\n<scaleMin>0</scaleMin>\n<scaleMax>1</scaleMax>\n</partial>\n</path>"
    n_fixed   = fx1_block.count(BROKEN_LABEL)
    fx1_block = fx1_block.replace(BROKEN_LABEL, FIXED_LABEL)
    print(f"  Patched {n_fixed} slot label path(s) in fx1 (label → /label)")

    # Build page-1 copies: fx2, fx3, fx4  (tag=1, same x-progression as fx1)
    page1_copies = []
    for i in range(1, FX_SLOTS_PAGE1):          # i = 1, 2, 3  →  fx2, fx3, fx4
        slot_n  = i + 1
        new_x   = FX1_X + i * (FX_WIDTH + FX_GAP)
        new_name = f"fx{slot_n}"
        print(f"  Creating {new_name} at x={new_x} (page 1, tag=1) …")

        blk = fx1_block
        blk = replace_all_ids(blk)
        blk = replace_name(blk, FX1_NAME, new_name)
        blk = replace_all_tags(blk, 1)          # tag=1 for all page-1 slots
        blk = replace_outer_frame_x(blk, new_x)
        page1_copies.append(blk)

    # Build page-2 copies: fx6..fx10  (tag=2)
    page2_copies = []
    for j in range(FX_SLOTS_PAGE2):             # j = 0..4  →  fx6..fx10
        slot_n  = FX_SLOTS_PAGE1 + 1 + j
        new_x   = FX1_X + j * (FX_WIDTH + FX_GAP)
        new_name = f"fx{slot_n}"
        print(f"  Creating {new_name} at x={new_x} (page 2, tag=2) …")
        blk = fx1_block
        blk = replace_all_ids(blk)
        blk = replace_name(blk, FX1_NAME, new_name)
        blk = replace_all_tags(blk, 2)
        blk = replace_outer_frame_x(blk, new_x)
        blk = replace_outer_frame_y(blk, FX1_Y)
        page2_copies.append(blk)

    # Stitch page-1 copies right after fx1
    print("Stitching page-1 copies …")
    separator = "\n"
    inserted  = text[:start] + fx1_block + separator + separator.join(page1_copies) + text[end:]

    # Inject all page-2 slots into the page-2 GROUP node
    print(f"Injecting {len(page2_copies)} slot(s) into page-2 GROUP (ID={PAGE2_ID}) …")
    p2_start, p2_end = find_node_boundaries(inserted, PAGE2_ID)
    p2_block = inserted[p2_start:p2_end]

    children_xml = "\n".join(page2_copies)
    INJECT_MARKER = "</values>\n</node>"
    marker_pos = p2_block.rfind(INJECT_MARKER)
    if marker_pos == -1:
        # Already has a <children> block — append before </children>
        CHILD_CLOSE = "</children>\n</node>"
        marker_pos2 = p2_block.rfind(CHILD_CLOSE)
        if marker_pos2 == -1:
            raise ValueError("Cannot find injection point in page-2 GROUP node")
        new_p2_block = (
            p2_block[:marker_pos2]
            + children_xml + "\n"
            + CHILD_CLOSE
        )
    else:
        new_p2_block = (
            p2_block[:marker_pos + len("</values>\n")]
            + "<children>\n"
            + children_xml + "\n"
            + "</children>\n"
            + "</node>"
        )

    inserted = inserted[:p2_start] + new_p2_block + inserted[p2_end:]

    print(f"Writing {out_path} …")
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(inserted)

    print("Done.")
    print()
    print("Next steps after importing into TouchOSC:")
    print("  1. Verify fx2-fx5 appear side-by-side on the synth-fx page.")
    print("  2. Confirm knob/toggle/XY Lua scripts are present in fx2-fx5.")
    print("  3. Test OSC round-trip from SC.")
    print("  (No manual Lua tag setter needed — tags propagated by this script.)")


if __name__ == "__main__":
    main()
