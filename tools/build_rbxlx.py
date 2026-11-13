#!/usr/bin/env python3
"""
build_rbxlx.py
Generates the complete SolsRNG_Game.rbxlx place file for Roblox Studio.
"""

import os
import xml.etree.ElementTree as ET
from xml.dom import minidom

ref_counter = 0

def get_ref(prefix="RBX"):
    global ref_counter
    ref_counter += 1
    return f"{prefix}{ref_counter}"

def create_item(parent, class_name, name, referent=None):
    if referent is None:
        referent = get_ref()
    item = ET.SubElement(parent, "Item", {"class": class_name, "referent": referent})
    props = ET.SubElement(item, "Properties")
    name_el = ET.SubElement(props, "string", {"name": "Name"})
    name_el.text = name
    return item, props

def add_script(parent, script_type, name, file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        source_code = f.read()
    item, props = create_item(parent, script_type, name)
    source_el = ET.SubElement(props, "ProtectedString", {"name": "Source"})
    source_el.text = source_code
    return item

def add_folder(parent, name):
    item, _ = create_item(parent, "Folder", name)
    return item

def add_remote_event(parent, name):
    item, _ = create_item(parent, "RemoteEvent", name)
    return item

def add_remote_function(parent, name):
    item, _ = create_item(parent, "RemoteFunction", name)
    return item

def build_place():
    root = ET.Element("roblox", {
        "xmlns:xmime": "http://www.w3.org/2005/05/xmlmime",
        "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:noNamespaceSchemaLocation": "http://www.roblox.com/roblox.xsd",
        "version": "4"
    })
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"

    # 1. Workspace
    ws_item, ws_props = create_item(root, "Workspace", "Workspace", referent="RBX0")
    fe = ET.SubElement(ws_props, "bool", {"name": "FilteringEnabled"})
    fe.text = "true"

    # Add a Terrain item in Workspace (required by Roblox Studio)
    create_item(ws_item, "Terrain", "Terrain", referent="RBX_Terrain")

    # Add SpawnLocation
    spawn_item, spawn_props = create_item(ws_item, "SpawnLocation", "RNG_Spawn")
    ET.SubElement(spawn_props, "bool", {"name": "Anchored"}).text = "true"
    ET.SubElement(spawn_props, "bool", {"name": "Neutral"}).text = "true"
    ET.SubElement(spawn_props, "int", {"name": "Duration"}).text = "0"
    v3 = ET.SubElement(spawn_props, "Vector3", {"name": "size"})
    ET.SubElement(v3, "X").text = "16"
    ET.SubElement(v3, "Y").text = "1"
    ET.SubElement(v3, "Z").text = "16"
    cf = ET.SubElement(spawn_props, "CoordinateFrame", {"name": "CFrame"})
    ET.SubElement(cf, "X").text = "0"
    ET.SubElement(cf, "Y").text = "2"
    ET.SubElement(cf, "Z").text = "0"
    ET.SubElement(cf, "R00").text = "1"
    ET.SubElement(cf, "R01").text = "0"
    ET.SubElement(cf, "R02").text = "0"
    ET.SubElement(cf, "R10").text = "0"
    ET.SubElement(cf, "R11").text = "1"
    ET.SubElement(cf, "R12").text = "0"
    ET.SubElement(cf, "R20").text = "0"
    ET.SubElement(cf, "R21").text = "0"
    ET.SubElement(cf, "R22").text = "1"

    # Add Main Platform Part
    floor_item, floor_props = create_item(ws_item, "Part", "MainFloor")
    ET.SubElement(floor_props, "bool", {"name": "Anchored"}).text = "true"
    floor_v3 = ET.SubElement(floor_props, "Vector3", {"name": "size"})
    ET.SubElement(floor_v3, "X").text = "120"
    ET.SubElement(floor_v3, "Y").text = "4"
    ET.SubElement(floor_v3, "Z").text = "120"
    floor_cf = ET.SubElement(floor_props, "CoordinateFrame", {"name": "CFrame"})
    ET.SubElement(floor_cf, "X").text = "0"
    ET.SubElement(floor_cf, "Y").text = "0"
    ET.SubElement(floor_cf, "Z").text = "0"
    ET.SubElement(floor_cf, "R00").text = "1"
    ET.SubElement(floor_cf, "R01").text = "0"
    ET.SubElement(floor_cf, "R02").text = "0"
    ET.SubElement(floor_cf, "R10").text = "0"
    ET.SubElement(floor_cf, "R11").text = "1"
    ET.SubElement(floor_cf, "R12").text = "0"
    ET.SubElement(floor_cf, "R20").text = "0"
    ET.SubElement(floor_cf, "R21").text = "0"
    ET.SubElement(floor_cf, "R22").text = "1"

    # 2. Lighting
    light_item, light_props = create_item(root, "Lighting", "Lighting", referent="RBX_Lighting")
    ET.SubElement(light_props, "string", {"name": "TimeOfDay"}).text = "21:30:00"
    ET.SubElement(light_props, "float", {"name": "Brightness"}).text = "1.8"
    ET.SubElement(light_props, "float", {"name": "ClockTime"}).text = "21.5"

    bloom_item, bloom_props = create_item(light_item, "BloomEffect", "RNGBloom")
    ET.SubElement(bloom_props, "float", {"name": "Intensity"}).text = "1.2"
    ET.SubElement(bloom_props, "float", {"name": "Size"}).text = "24"
    ET.SubElement(bloom_props, "float", {"name": "Threshold"}).text = "0.85"

    cc_item, cc_props = create_item(light_item, "ColorCorrectionEffect", "RNGColorCorrection")
    ET.SubElement(cc_props, "float", {"name": "Brightness"}).text = "0.04"
    ET.SubElement(cc_props, "float", {"name": "Contrast"}).text = "0.15"
    ET.SubElement(cc_props, "float", {"name": "Saturation"}).text = "0.2"

    # 3. ReplicatedStorage
    rep_item, _ = create_item(root, "ReplicatedStorage", "ReplicatedStorage", referent="RBX_ReplicatedStorage")
    aura_rng_folder = add_folder(rep_item, "AuraRNG")
    events_folder = add_folder(aura_rng_folder, "Events")
    modules_folder = add_folder(aura_rng_folder, "Modules")

    # Add Remotes
    add_remote_function(events_folder, "RollRequest")
    add_remote_function(events_folder, "CraftAura")
    add_remote_event(events_folder, "EquipAura")
    add_remote_event(events_folder, "DeleteAura")
    add_remote_event(events_folder, "SetAutoDelete")
    add_remote_event(events_folder, "ToggleTestPerk")
    add_remote_event(events_folder, "DataSync")
    add_remote_event(events_folder, "GlobalAnnouncement")

    # Add Modules
    add_script(modules_folder, "ModuleScript", "AuraConfig", "src/ReplicatedStorage/Modules/AuraConfig.lua")
    add_script(modules_folder, "ModuleScript", "AuraVisuals", "src/ReplicatedStorage/Modules/AuraVisuals.lua")
    add_script(modules_folder, "ModuleScript", "SoundEffects", "src/ReplicatedStorage/Modules/SoundEffects.lua")
    add_script(modules_folder, "ModuleScript", "CraftingStationSetup", "src/ReplicatedStorage/Modules/CraftingStationSetup.lua")

    # 4. ServerScriptService
    sss_item, _ = create_item(root, "ServerScriptService", "ServerScriptService", referent="RBX_ServerScriptService")
    add_script(sss_item, "Script", "RNGServer", "src/ServerScriptService/RNGServer.server.lua")

    # 5. ServerStorage
    create_item(root, "ServerStorage", "ServerStorage", referent="RBX_ServerStorage")

    # 6. StarterGui
    gui_item, _ = create_item(root, "StarterGui", "StarterGui", referent="RBX_StarterGui")
    screen_gui_item, sg_props = create_item(gui_item, "ScreenGui", "RNG_ScreenGui")
    ET.SubElement(sg_props, "bool", {"name": "ResetOnSpawn"}).text = "false"
    ET.SubElement(sg_props, "token", {"name": "ZIndexBehavior"}).text = "1"
    add_script(screen_gui_item, "LocalScript", "RNGClient", "src/StarterGui/RNG_ScreenGui/RNGClient.client.lua")

    # 7. StarterPack & StarterPlayer
    create_item(root, "StarterPack", "StarterPack", referent="RBX_StarterPack")
    sp_item, _ = create_item(root, "StarterPlayer", "StarterPlayer", referent="RBX_StarterPlayer")
    create_item(sp_item, "StarterPlayerScripts", "StarterPlayerScripts", referent="RBX_StarterPlayerScripts")
    create_item(sp_item, "StarterCharacterScripts", "StarterCharacterScripts", referent="RBX_StarterCharacterScripts")

    # 8. SoundService
    create_item(root, "SoundService", "SoundService", referent="RBX_SoundService")

    # Format and save
    xml_str = ET.tostring(root, encoding="utf-8")
    parsed = minidom.parseString(xml_str)
    pretty_xml = parsed.toprettyxml(indent="\t")

    output_path = "SolsRNG_Game.rbxlx"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(pretty_xml)

    print(f"Generated {output_path} ({os.path.getsize(output_path)} bytes)")

if __name__ == "__main__":
    build_place()
