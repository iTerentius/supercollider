#!/usr/bin/env python3
"""
Patch mixer strip controls in a TouchOSC XML file (PAGER 'b' layout):

  1. Master fader (FADER 'fader1' sibling of PAGER 'b'):
       Replaces generic-template Lua with hardcoded /tosc/master/f path.

  2. XY controls (XY 'xy1' in each strip):
       Current Lua only fires for key=="x", ignoring y-axis.
       Replaced with Lua that sends x to {base}/x and y to {base}/y separately.

  3. Mute buttons (BUTTON 't' inside GROUP 'mute' in each strip):
       Current Lua uses FX convention and only goes 2 parent levels up, missing bank.
       Replaced with Lua that produces /tosc/b{bank}/{strip}/mute.

  4. Strip labels (LABEL 'label' at bottom of each strip):
       Current receive path uses /tosc/fx/1/{strip}/label (bank-blind).
       Replaced with /tosc/b{bank}/{strip}/label.

Usage:
    python3 tosc_patch_mixer.py input.xml output.xml
"""

import sys
import xml.etree.ElementTree as ET


# ── Lua scripts ────────────────────────────────────────────────────────────────

MASTER_FADER_LUA = """\
function onValueChanged(key)
  if key == "x" then
    sendOSC("/tosc/master/f", self.values.x)
  end
end"""

XY_LUA = """\
function onValueChanged(key)
  local base = "/tosc/b" .. self.parent.parent.name .. "/" .. self.parent.name .. "/" .. self.name
  if key == "x" then
    sendOSC(base .. "/x", self.values.x)
  end
  if key == "y" then
    sendOSC(base .. "/y", self.values.y)
  end
end"""

MUTE_LUA = """\
function onValueChanged(key)
  if key == "x" then
    local bank  = self.parent.parent.parent.name
    local strip = self.parent.parent.name
    sendOSC("/tosc/b" .. bank .. "/" .. strip .. "/mute", self.values.x)
  end
end"""

PAGER_DEV_LUA = """\
function onValueChanged(key)
  if key == "page" then
    if self.values.page == 1 then
      sendOSC("/tosc/pads/visible", 1.0)
    end
  end
end"""


# ── XML helpers ────────────────────────────────────────────────────────────────

def get_prop_el(node, key):
    for p in node.findall('properties/property'):
        k = p.find('key')
        if k is not None and k.text == key:
            return p.find('value')
    return None


def set_prop_value(node, key, new_text):
    for p in node.findall('properties/property'):
        k = p.find('key')
        if k is not None and k.text == key:
            v = p.find('value')
            if v is not None:
                v.text = new_text
                return
    # add if missing
    props = node.find('properties')
    if props is None:
        props = ET.SubElement(node, 'properties')
    p = ET.SubElement(props, 'property')
    ET.SubElement(p, 'key').text = key
    ET.SubElement(p, 'value').text = new_text


def _partial_el(ptype, value):
    """Build a <partial> element."""
    el = ET.Element('partial')
    ET.SubElement(el, 'type').text = ptype
    ET.SubElement(el, 'conversion').text = 'STRING'
    v = ET.SubElement(el, 'value')
    v.text = value
    ET.SubElement(el, 'scaleMin').text = '0'
    ET.SubElement(el, 'scaleMax').text = '1'
    return el


def replace_label_receive_path(label_node):
    """
    Replace the OSC receive <path> in a strip LABEL's messages block
    to use bank-aware /tosc/b{bank}/{strip}/label addressing.

    Label parent chain: LABEL → GROUP(strip) → GROUP(bank).
    Partials: CONSTANT '/tosc/b', PROPERTY 'parent.parent.name',
              CONSTANT '/', PROPERTY 'parent.name', CONSTANT '/label'.
    """
    msgs = label_node.find('messages')
    if msgs is None:
        return False
    osc = msgs.find('osc')
    if osc is None:
        return False
    path_el = osc.find('path')
    if path_el is None:
        return False

    # Clear existing partials and rebuild
    for p in list(path_el):
        path_el.remove(p)

    path_el.append(_partial_el('CONSTANT', '/tosc/b'))
    path_el.append(_partial_el('PROPERTY', 'parent.parent.name'))
    path_el.append(_partial_el('CONSTANT', '/'))
    path_el.append(_partial_el('PROPERTY', 'parent.name'))
    path_el.append(_partial_el('CONSTANT', '/label'))
    return True


# ── Main patch ─────────────────────────────────────────────────────────────────

def patch(input_path, output_path):
    tree = ET.parse(input_path)
    root = tree.getroot()

    master_patched = xy_patched = mute_patched = label_patched = pager_dev_patched = 0

    # 0. PAGER 'dev': add page-switch Lua to trigger pad repaint
    for node in root.iter('node'):
        if node.get('type') == 'PAGER' and get_prop_el(node, 'name') is not None:
            if get_prop_el(node, 'name').text == 'dev':
                set_prop_value(node, 'script', PAGER_DEV_LUA)
                pager_dev_patched += 1
                print(f'  PAGER "dev" Lua patched (ID={node.get("ID")})')

    # 1. Master fader: find FADER 'fader1' that is NOT inside PAGER 'b'
    pager_b = None
    for node in root.iter('node'):
        if node.get('type') == 'PAGER' and get_prop_el(node, 'name') is not None:
            if get_prop_el(node, 'name').text == 'b':
                pager_b = node
                break

    pager_b_ids = set()
    if pager_b is not None:
        for n in pager_b.iter('node'):
            pager_b_ids.add(n.get('ID'))

    for node in root.iter('node'):
        if node.get('type') == 'FADER':
            name_v = get_prop_el(node, 'name')
            if name_v is not None and name_v.text == 'fader1':
                if node.get('ID') not in pager_b_ids:
                    set_prop_value(node, 'script', MASTER_FADER_LUA)
                    master_patched += 1
                    print(f'  Master fader patched (ID={node.get("ID")})')

    # 2 & 3 & 4. Walk PAGER 'b' strips
    if pager_b is None:
        print('ERROR: PAGER "b" not found')
        sys.exit(1)

    for bank in list(pager_b.find('children') or []):
        bank_name = get_prop_el(bank, 'name')
        for strip in list(bank.find('children') or []):
            strip_children = strip.find('children')
            if strip_children is None:
                continue
            for ctrl in list(strip_children):
                ctype = ctrl.get('type')
                cname_v = get_prop_el(ctrl, 'name')
                cname = cname_v.text if cname_v is not None else ''

                # XY control
                if ctype == 'XY' and cname == 'xy1':
                    set_prop_value(ctrl, 'script', XY_LUA)
                    xy_patched += 1

                # Mute group → button
                if ctype == 'GROUP' and cname == 'mute':
                    mute_children = ctrl.find('children')
                    if mute_children is not None:
                        for btn in list(mute_children):
                            if btn.get('type') == 'BUTTON' and get_prop_el(btn, 'name') is not None:
                                if get_prop_el(btn, 'name').text == 't':
                                    set_prop_value(btn, 'script', MUTE_LUA)
                                    mute_patched += 1

                # Strip label
                if ctype == 'LABEL' and cname == 'label':
                    if replace_label_receive_path(ctrl):
                        label_patched += 1

    print(f'PAGER "dev" Lua patched:      {pager_dev_patched}')
    print(f'Master fader Lua patched:    {master_patched}')
    print(f'XY Lua patched (x+y split):  {xy_patched}')
    print(f'Mute button Lua patched:      {mute_patched}')
    print(f'Strip label recv paths fixed: {label_patched}')

    tree.write(output_path, encoding='unicode', xml_declaration=True)
    print(f'Written: {output_path}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2])
