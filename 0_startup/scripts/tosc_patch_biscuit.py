#!/usr/bin/env python3
"""
Patch a biscuit FX layout in a TouchOSC XML file:
  1. Delete radio12 duplicates from ws_shape_g and p_shape_g
  2. Rename radio13 → radio in filterType group
  3. Add onValueChanged Lua to all unscripted RADIOs:
       bit1-bit8  (sends /biscuit/b{n}, value -1/0/1)
       bits       (sends /biscuit/bits, value 1-8)
       shape      (sends /biscuit/shape, value 0-7)
       pitchShift (sends /biscuit/pitchShift, value 0-7)
       radio      (filterType, sends /biscuit/filterType, value 0-2)
  4. Add onValueChanged Lua to xy1 and xy2 (drive paired radials; OSC
     sent by the radial's own script to avoid double-send)
  5. Rewrite all RADIAL 'r' scripts: add XY_SYNC cross-sync table so
     moving a knob also repositions the paired XY pad, and vice-versa.

Usage:
    python3 tosc_patch_biscuit.py input.xml output.xml
"""

import sys
import xml.etree.ElementTree as ET


# ── Lua ───────────────────────────────────────────────────────────────────────

# bit1-bit8: 3-step radio → -1 / 0 / 1
BIT_LUA = (
    'function onValueChanged(key)\n'
    '  if key == "x" then\n'
    '    local v = math.floor(self.values.x * 2 + 0.5) - 1\n'
    '    local n = self.name:match("%d+")\n'
    '    sendOSC("/tosc/fx/" .. self.tag .. "/biscuit/b" .. n, v)\n'
    '  end\n'
    'end'
)

# bits: 8-step radio → 1..8 integer
BITS_LUA = (
    'function onValueChanged(key)\n'
    '  if key == "x" then\n'
    '    local v = math.floor(self.values.x * 7 + 0.5) + 1\n'
    '    sendOSC("/tosc/fx/" .. self.tag .. "/biscuit/bits", v)\n'
    '  end\n'
    'end'
)

# shape / pitchShift: 8-step → 0..7 integer, self.name is the SC param name
DISCRETE8_LUA = (
    'function onValueChanged(key)\n'
    '  if key == "x" then\n'
    '    local v = math.floor(self.values.x * 7 + 0.5)\n'
    '    sendOSC("/tosc/fx/" .. self.tag .. "/biscuit/" .. self.name, v)\n'
    '  end\n'
    'end'
)

# filterType radio: 3-step → 0/1/2, parent group name is the SC param name
FILTERTYPE_LUA = (
    'function onValueChanged(key)\n'
    '  if key == "x" then\n'
    '    local v = math.floor(self.values.x * 2 + 0.5)\n'
    '    sendOSC("/tosc/fx/" .. self.tag .. "/biscuit/" .. self.parent.name, v)\n'
    '  end\n'
    'end'
)

# xy1 (analogOutputFilter): X drives filterFreq radial, Y drives filterQ radial.
# OSC is NOT sent here — each radial's own onValueChanged sends it, preventing double-send.
# Tolerance guard (0.001) breaks the update loop when the radial sets back the XY value.
XY1_LUA = (
    'function onValueChanged(key)\n'
    '  if key ~= "x" and key ~= "y" then return end\n'
    '  local par = self.parent\n'
    '  if key == "x" then\n'
    '    local grp = par.children["filterFreq"]\n'
    '    if grp then\n'
    '      local r = grp.children["r"]\n'
    '      if r and math.abs(r.values.x - self.values.x) > 0.001 then\n'
    '        r.values.x = self.values.x\n'
    '      end\n'
    '    end\n'
    '  end\n'
    '  if key == "y" then\n'
    '    local grp = par.children["filterQ"]\n'
    '    if grp then\n'
    '      local r = grp.children["r"]\n'
    '      if r and math.abs(r.values.x - self.values.y) > 0.001 then\n'
    '        r.values.x = self.values.y\n'
    '      end\n'
    '    end\n'
    '  end\n'
    'end'
)

# xy2 (wetDry): X drives naked radial, Y drives dressed radial.
XY2_LUA = (
    'function onValueChanged(key)\n'
    '  if key ~= "x" and key ~= "y" then return end\n'
    '  local par = self.parent\n'
    '  if key == "x" then\n'
    '    local grp = par.children["naked"]\n'
    '    if grp then\n'
    '      local r = grp.children["r"]\n'
    '      if r and math.abs(r.values.x - self.values.x) > 0.001 then\n'
    '        r.values.x = self.values.x\n'
    '      end\n'
    '    end\n'
    '  end\n'
    '  if key == "y" then\n'
    '    local grp = par.children["dressed"]\n'
    '    if grp then\n'
    '      local r = grp.children["r"]\n'
    '      if r and math.abs(r.values.x - self.values.y) > 0.001 then\n'
    '        r.values.x = self.values.y\n'
    '      end\n'
    '    end\n'
    '  end\n'
    'end'
)

# RADIAL r: full param mapping, label update, OSC send, XY cross-sync.
# XY_SYNC: when this knob moves, also nudge the sibling XY pad on the matching axis.
# if p == nil (param not in table), bail silently — handles any stray radials.
RADIAL_LUA = (
    'local PARAMS = {\n'
    '  drive      = { min=1.0,   max=5.6,   unit="x",   scale="lin" },\n'
    '  clock      = { min=250,   max=30000, unit="Hz",  scale="exp" },\n'
    '  bits       = { min=1,     max=8,     unit="bit", scale="lin" },\n'
    '  filterFreq = { min=20,    max=20000, unit="Hz",  scale="exp" },\n'
    '  filterQ    = { min=0,     max=1,     unit="",    scale="lin" },\n'
    '  stepRate   = { min=0.1,   max=40,    unit="Hz",  scale="exp" },\n'
    '  sf0        = { min=20,    max=20000, unit="Hz",  scale="exp" },\n'
    '  sf1        = { min=20,    max=20000, unit="Hz",  scale="exp" },\n'
    '  sf2        = { min=20,    max=20000, unit="Hz",  scale="exp" },\n'
    '  sf3        = { min=20,    max=20000, unit="Hz",  scale="exp" },\n'
    '  delTime    = { min=0.001, max=2.0,   unit="s",   scale="exp" },\n'
    '  delFB      = { min=0,     max=1,     unit="",    scale="lin" },\n'
    '  naked      = { min=0,     max=1,     unit="",    scale="lin" },\n'
    '  dressed    = { min=0,     max=1,     unit="",    scale="lin" },\n'
    '}\n'
    'local XY_SYNC = {\n'
    '  filterFreq = { sibling="xy1", axis="x" },\n'
    '  filterQ    = { sibling="xy1", axis="y" },\n'
    '  naked      = { sibling="xy2", axis="x" },\n'
    '  dressed    = { sibling="xy2", axis="y" },\n'
    '}\n'
    'local function mapParam(p, n)\n'
    '  if p.scale == "exp" then\n'
    '    local lMin = math.log(p.min)\n'
    '    return math.exp(lMin + n * (math.log(p.max) - lMin))\n'
    '  else\n'
    '    return p.min + n * (p.max - p.min)\n'
    '  end\n'
    'end\n'
    'local function fmtParam(p, v)\n'
    '  if p.unit == "Hz" then\n'
    '    return v >= 1000 and string.format("%.1f kHz", v/1000) or string.format("%.0f Hz", v)\n'
    '  elseif p.unit == "bit" then\n'
    '    return string.format("%d bit", math.floor(v + 0.5))\n'
    '  elseif p.unit == "s" then\n'
    '    return string.format("%.3f s", v)\n'
    '  elseif p.unit == "x" then\n'
    '    return string.format("%.2f x", v)\n'
    '  else\n'
    '    return string.format("%.2f", v)\n'
    '  end\n'
    'end\n'
    'function onValueChanged(key)\n'
    '  if key == "x" then\n'
    '    local p = PARAMS[self.parent.name]\n'
    '    if p == nil then return end\n'
    '    local realVal = mapParam(p, self.values.x)\n'
    '    local lab = self.parent.children["lab_val"]\n'
    '    if lab then lab.values.text = fmtParam(p, realVal) end\n'
    '    sendOSC("/tosc/fx/" .. self.tag .. "/" .. self.parent.parent.name .. "/" .. self.parent.name, realVal)\n'
    '    local xs = XY_SYNC[self.parent.name]\n'
    '    if xs then\n'
    '      local xy = self.parent.parent.children[xs.sibling]\n'
    '      if xy then\n'
    '        local norm = self.values.x\n'
    '        if xs.axis == "x" and math.abs(xy.values.x - norm) > 0.001 then\n'
    '          xy.values.x = norm\n'
    '        elseif xs.axis == "y" and math.abs(xy.values.y - norm) > 0.001 then\n'
    '          xy.values.y = norm\n'
    '        end\n'
    '      end\n'
    '    end\n'
    '  end\n'
    'end'
)


# ── XML helpers ───────────────────────────────────────────────────────────────

def get_name(node):
    for p in node.findall('properties/property'):
        k = p.find('key')
        v = p.find('value')
        if k is not None and k.text == 'name' and v is not None:
            return (v.text or '').strip()
    return ''


def set_name(node, name):
    for p in node.findall('properties/property'):
        k = p.find('key')
        v = p.find('value')
        if k is not None and k.text == 'name' and v is not None:
            v.text = name
            return


def get_script(node):
    for p in node.findall('properties/property'):
        k = p.find('key')
        v = p.find('value')
        if k is not None and k.text == 'script' and v is not None:
            return (v.text or '').strip()
    return ''


def set_script(node, lua):
    props = node.find('properties')
    if props is None:
        props = ET.SubElement(node, 'properties')
    for p in props.findall('property'):
        k = p.find('key')
        if k is not None and k.text == 'script':
            v = p.find('value')
            if v is not None:
                v.text = lua
                return
    p = ET.SubElement(props, 'property')
    p.set('type', 's')
    ET.SubElement(p, 'key').text = 'script'
    ET.SubElement(p, 'value').text = lua


def find_child(node, name):
    c = node.find('children')
    if c is None:
        return None
    for child in c:
        if get_name(child) == name:
            return child
    return None


def remove_child(parent_node, child_node):
    c = parent_node.find('children')
    if c is not None:
        kids = list(c)
        if child_node in kids:
            c.remove(child_node)
            return True
    return False


def find_biscuit(root):
    for node in root.iter('node'):
        if node.get('type') == 'GROUP' and get_name(node) == 'biscuit':
            return node
    return None


# ── Patch ─────────────────────────────────────────────────────────────────────

def patch(input_path, output_path):
    tree = ET.parse(input_path)
    root = tree.getroot()

    biscuit = find_biscuit(root)
    if biscuit is None:
        print('ERROR: GROUP "biscuit" not found'); sys.exit(1)

    bits_grp    = find_child(biscuit, 'bits')
    fxMode_grp  = find_child(biscuit, 'fxMode')
    ws_shape_g  = find_child(fxMode_grp, 'ws_shape_g')
    p_shape_g   = find_child(fxMode_grp, 'p_shape_g')
    aof_grp     = find_child(biscuit, 'analogOutputFilter')
    filterT_grp = find_child(aof_grp, 'filterType')
    wetDry_grp  = find_child(biscuit, 'wetDry')

    # 1. Delete radio12 duplicates
    for grp, label in [(ws_shape_g, 'ws_shape_g'), (p_shape_g, 'p_shape_g')]:
        node = find_child(grp, 'radio12')
        if node is not None:
            remove_child(grp, node)
            print(f'  Deleted radio12 from {label}')
        else:
            print(f'  radio12 not found in {label} (already removed?)')

    # 2. Rename radio13 → radio in filterType
    r13 = find_child(filterT_grp, 'radio13')
    if r13 is not None:
        set_name(r13, 'radio')
        print('  Renamed radio13 → radio in filterType')
    else:
        print('  radio13 not found in filterType (already renamed?)')

    # 3. bit1-bit8 scripts
    c = bits_grp.find('children') if bits_grp is not None else None
    bit_count = 0
    if c is not None:
        for child in c:
            name = get_name(child)
            if child.get('type') == 'RADIO' and name.startswith('bit') and name[3:].isdigit():
                set_script(child, BIT_LUA)
                bit_count += 1
    print(f'  Set bit1-bit8 scripts: {bit_count}')

    # 4. bits RADIO
    bits_radio = find_child(bits_grp, 'bits') if bits_grp is not None else None
    if bits_radio is not None:
        set_script(bits_radio, BITS_LUA)
        print('  Set bits RADIO script')
    else:
        print('  WARNING: bits RADIO not found')

    # 5. shape in ws_shape_g
    shape_node = find_child(ws_shape_g, 'shape') if ws_shape_g is not None else None
    if shape_node is not None:
        set_script(shape_node, DISCRETE8_LUA)
        print('  Set ws_shape_g/shape script')
    else:
        print('  WARNING: ws_shape_g/shape not found')

    # 6. pitchShift in p_shape_g
    pitch_node = find_child(p_shape_g, 'pitchShift') if p_shape_g is not None else None
    if pitch_node is not None:
        set_script(pitch_node, DISCRETE8_LUA)
        print('  Set p_shape_g/pitchShift script')
    else:
        print('  WARNING: p_shape_g/pitchShift not found')

    # 7. radio (filterType) — may already be renamed in step 2
    ft_radio = find_child(filterT_grp, 'radio')
    if ft_radio is None:
        ft_radio = find_child(filterT_grp, 'radio13')
    if ft_radio is not None:
        set_script(ft_radio, FILTERTYPE_LUA)
        print('  Set filterType/radio script')
    else:
        print('  WARNING: filterType radio not found')

    # 8. xy1 (analogOutputFilter)
    xy1 = find_child(aof_grp, 'xy1') if aof_grp is not None else None
    if xy1 is not None:
        set_script(xy1, XY1_LUA)
        print('  Set xy1 script')
    else:
        print('  WARNING: xy1 not found in analogOutputFilter')

    # 9. xy2 (wetDry)
    xy2 = find_child(wetDry_grp, 'xy2') if wetDry_grp is not None else None
    if xy2 is not None:
        set_script(xy2, XY2_LUA)
        print('  Set xy2 script')
    else:
        print('  WARNING: xy2 not found in wetDry')

    # 10. Update all RADIAL 'r' scripts (replaces both versions incl. debug print)
    radial_count = 0
    for node in root.iter('node'):
        if node.get('type') == 'RADIAL' and get_name(node) == 'r':
            set_script(node, RADIAL_LUA)
            radial_count += 1
    print(f'  Updated {radial_count} RADIAL r scripts (added XY_SYNC)')

    tree.write(output_path, encoding='unicode', xml_declaration=True)
    print(f'Written: {output_path}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    patch(sys.argv[1], sys.argv[2])
