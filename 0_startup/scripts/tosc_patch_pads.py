#!/usr/bin/env python3
"""
Patch pad page in a .tosc XML file:
  1. Remove banks 2 and 3 from pad PAGER 'p' (keep only bank 1)
  2. Each pad row GROUP gets a BOX 'color' node inserted AFTER the button (on top):
       - Passive display only: cornerRadius=10, outline=0, interactive=0, no Lua, no messages
       - Starts amber; BUTTON Lua drives its color via findByName("color")
  3. BUTTON 'pad': background=0, outline=0; keeps x receive (state from SC);
     x Lua sets BOX color + sibling label/nums textColor (amber/green, white/black)
  4. LABEL 'label': textColor=white, textSize=14, default text cleared
  5. LABEL 'nums':  textColor=white, textSize=20, h=18, default text cleared, divider '-'

Usage:
    python3 tosc_patch_pads.py input.xml output.xml
"""

import sys
import uuid
import xml.etree.ElementTree as ET


# ── Lua scripts ───────────────────────────────────────────────────────────────

BUTTON_LUA = (
    "function onValueChanged(key)\n"
    "    if key == \"touch\" then\n"
    "        local row  = self.parent.name\n"
    "        local col  = string.match(self.parent.parent.name, \"%d+\")\n"
    "        local bank = self.parent.parent.parent.name\n"
    "        sendOSC(\"/tosc/p\" .. bank .. \"/\" .. row .. \"/\" .. col, self.values.touch)\n"
    "    end\n"
    "    if key == \"x\" then\n"
    "        local x = self.values.x\n"
    "        local bx = self.parent:findByName(\"color\")\n"
    "        local isPlaying = x > 0.9\n"
    "        if bx then\n"
    "            if isPlaying then\n"
    "                bx.color = Color(0.2, 1.0, 0.3, 1.0)\n"
    "            else\n"
    "                local idx = math.floor(x * 20 + 0.1)\n"
    "                local cols = {\n"
    "                    [0]  = Color(1.0, 0.6, 0.0, 1.0),\n"
    "                    [1]  = Color(1.0, 0.5, 0.1, 1.0),\n"
    "                    [2]  = Color(1.0, 0.9, 0.1, 1.0),\n"
    "                    [3]  = Color(0.1, 0.9, 1.0, 1.0),\n"
    "                    [4]  = Color(0.2, 0.4, 1.0, 1.0),\n"
    "                    [5]  = Color(0.4, 0.2, 1.0, 1.0),\n"
    "                    [6]  = Color(0.7, 0.2, 1.0, 1.0),\n"
    "                    [7]  = Color(1.0, 0.3, 0.7, 1.0),\n"
    "                    [8]  = Color(1.0, 0.1, 0.9, 1.0),\n"
    "                    [9]  = Color(1.0, 0.2, 0.2, 1.0),\n"
    "                    [10] = Color(1.0, 1.0, 1.0, 1.0),\n"
    "                    [11] = Color(0.3, 0.6, 1.0, 1.0),\n"
    "                    [12] = Color(0.2, 1.0, 0.3, 1.0),\n"
    "                    [13] = Color(0.15, 0.15, 0.15, 1.0)\n"
    "                }\n"
    "                bx.color = cols[idx] or Color(1.0, 0.6, 0.0, 1.0)\n"
    "            end\n"
    "        end\n"
    "        local tc = isPlaying and Color(0, 0, 0, 1) or Color(1, 1, 1, 1)\n"
    "        local lbl = self.parent:findByName(\"label\")\n"
    "        local nms = self.parent:findByName(\"nums\")\n"
    "        if lbl then lbl.textColor = tc end\n"
    "        if nms then nms.textColor = tc end\n"
    "    end\n"
    "end"
)

BOX_NODE_XML = """\
<node ID="{node_id}" type="BOX">
  <properties>
    <property type="b"><key>background</key><value>1</value></property>
    <property type="c"><key>color</key><value><r>0.078</r><g>0.078</g><b>0.157</b><a>1.0</a></value></property>
    <property type="f"><key>cornerRadius</key><value>10</value></property>
    <property type="r"><key>frame</key><value><x>0</x><y>0</y><w>100</w><h>100</h></value></property>
    <property type="b"><key>grabFocus</key><value>0</value></property>
    <property type="b"><key>interactive</key><value>0</value></property>
    <property type="b"><key>locked</key><value>0</value></property>
    <property type="s"><key>name</key><value>color</value></property>
    <property type="i"><key>orientation</key><value>0</value></property>
    <property type="b"><key>outline</key><value>0</value></property>
    <property type="i"><key>outlineStyle</key><value>1</value></property>
    <property type="i"><key>pointerPriority</key><value>0</value></property>
    <property type="i"><key>shape</key><value>1</value></property>
    <property type="b"><key>visible</key><value>1</value></property>
  </properties>
  <values>
    <value>
      <key>touch</key>
      <locked>0</locked>
      <lockedDefaultCurrent>0</lockedDefaultCurrent>
      <default>false</default>
      <defaultPull>0</defaultPull>
    </value>
  </values>
</node>"""


# ── XML helpers ───────────────────────────────────────────────────────────────

def get_prop_el(node, key):
    for p in node.findall('properties/property'):
        k = p.find('key')
        if k is not None and k.text == key:
            return p.find('value')
    return None


def set_prop_value(node, key, value_xml_str):
    props = node.find('properties')
    if props is None:
        props = ET.SubElement(node, 'properties')
    for p in props.findall('property'):
        k = p.find('key')
        if k is not None and k.text == key:
            v = p.find('value')
            if v is not None:
                p.remove(v)
            p.append(ET.fromstring(value_xml_str))
            return
    p = ET.SubElement(props, 'property')
    ET.SubElement(p, 'key').text = key
    p.append(ET.fromstring(value_xml_str))


def clear_value_default(node, key):
    vals = node.find('values')
    if vals is not None:
        for v in vals.findall('value'):
            k = v.find('key')
            if k is not None and k.text == key:
                d = v.find('default')
                if d is not None:
                    d.text = ''


def find_pager_p(root):
    for node in root.iter('node'):
        if node.get('type') == 'PAGER':
            v = get_prop_el(node, 'name')
            if v is not None and v.text == 'p':
                return node
    return None


# ── Main patch ────────────────────────────────────────────────────────────────

def patch(input_path, output_path):
    tree = ET.parse(input_path)
    root = tree.getroot()

    pager_p = find_pager_p(root)
    if pager_p is None:
        print('ERROR: pad PAGER "p" not found')
        sys.exit(1)

    children_el = pager_p.find('children')
    banks = list(children_el) if children_el is not None else []
    print(f'Pad PAGER "p" has {len(banks)} banks')

    # 1. Remove banks 2 and 3
    removed = 0
    for bank in list(banks):
        name_v = get_prop_el(bank, 'name')
        if name_v is not None and name_v.text in ('2', '3'):
            children_el.remove(bank)
            print(f'  Removed bank {name_v.text}')
            removed += 1
    print(f'Removed {removed} banks')

    # 2 & 3. Process each row GROUP containing a BUTTON pad
    boxes_added = buttons_patched = 0
    for row_group in pager_p.iter('node'):
        if row_group.get('type') != 'GROUP':
            continue
        row_children = row_group.find('children')
        if row_children is None:
            continue

        pad = None
        for child in row_children:
            name_v = get_prop_el(child, 'name')
            if child.get('type') == 'BUTTON' and name_v is not None and name_v.text == 'pad':
                pad = child
                break
        if pad is None:
            continue

        # Insert BOX after the BUTTON (renders on top)
        box_node = ET.fromstring(BOX_NODE_XML.format(node_id=str(uuid.uuid4())))
        pad_index = list(row_children).index(pad)
        row_children.insert(pad_index + 1, box_node)
        boxes_added += 1

        # Update BUTTON: transparent, no outline, updated Lua
        set_prop_value(pad, 'background', '<value>0</value>')
        set_prop_value(pad, 'outline',    '<value>0</value>')
        set_prop_value(pad, 'script',     f'<value>{BUTTON_LUA}</value>')
        buttons_patched += 1

    print(f'Added {boxes_added} BOX color nodes (on top, non-interactive)')
    print(f'Simplified {buttons_patched} BUTTON pads (transparent, x Lua drives BOX color)')

    # 4. Update LABELs
    label_updated = nums_updated = 0
    for lbl in pager_p.iter('node'):
        if lbl.get('type') != 'LABEL':
            continue
        name_v = get_prop_el(lbl, 'name')
        if name_v is None:
            continue

        if name_v.text in ('label', 'nums'):
            set_prop_value(lbl, 'textColor',
                           '<value><r>1</r><g>1</g><b>1</b><a>1</a></value>')
            label_updated += 1

        if name_v.text == 'label':
            set_prop_value(lbl, 'textSize', '<value>14</value>')
            clear_value_default(lbl, 'text')

        if name_v.text == 'nums':
            frame = get_prop_el(lbl, 'frame')
            if frame is not None:
                h_el = frame.find('h')
                if h_el is not None:
                    h_el.text = '18'
            set_prop_value(lbl, 'textSize', '<value>20</value>')
            clear_value_default(lbl, 'text')
            for p in lbl.findall('properties/property'):
                k = p.find('key')
                if k is not None and k.text == 'script':
                    v = p.find('value')
                    if v is not None and v.text:
                        v.text = v.text.replace('.. "|" ..', '.. "-" ..')
            nums_updated += 1

    print(f'Updated {label_updated} LABELs (textColor=white)')
    print(f'  label: textSize=14  |  nums: textSize=20, h=18, divider "-": {nums_updated} nodes')

    # 5. Clear 'x' default text from ALL LABEL nodes (covers mixer labels outside pad PAGER)
    label_x_cleared = 0
    for lbl in root.iter('node'):
        if lbl.get('type') != 'LABEL':
            continue
        vals = lbl.find('values')
        if vals is None:
            continue
        for v in vals.findall('value'):
            k = v.find('key')
            d = v.find('default')
            if k is not None and k.text == 'text' and d is not None and d.text == 'x':
                d.text = ''
                label_x_cleared += 1
    print(f'Cleared "x" default text from {label_x_cleared} LABEL nodes (mixer + any remaining)')

    tree.write(output_path, encoding='unicode', xml_declaration=True)
    print(f'Written: {output_path}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2])
