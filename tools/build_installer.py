#!/usr/bin/env python3
"""
build_installer.py
Bundles all scripts and modules into a single OneClick_Installer.lua
that can be pasted directly into Roblox Studio's Command Bar or into a ServerScript.
"""

def read_file(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def generate_installer():
    aura_config_src = read_file("src/ReplicatedStorage/Modules/AuraConfig.lua")
    aura_visuals_src = read_file("src/ReplicatedStorage/Modules/AuraVisuals.lua")
    sound_effects_src = read_file("src/ReplicatedStorage/Modules/SoundEffects.lua")
    crafting_setup_src = read_file("src/ReplicatedStorage/Modules/CraftingStationSetup.lua")
    server_src = read_file("src/ServerScriptService/RNGServer.server.lua")
    client_src = read_file("src/StarterGui/RNG_ScreenGui/RNGClient.client.lua")

    installer_lua = f"""-- ==============================================================================
-- 🎲 SOL'S RNG - ONE-CLICK INSTALLER FOR ROBLOX STUDIO 🎲
-- ==============================================================================
-- КАК ЗАПУСТИТЬ ЗА 5 СЕКУНД:
-- Способ 1: Откройте Roblox Studio -> Вид (View) -> Командная строка (Command Bar)
--           Вставьте этот скрипт целиком в командную строку и нажмите Enter!
-- Способ 2: Создайте обычный Script в ServerScriptService, вставьте этот код и нажмите PLAY (F5)!
-- ==============================================================================

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")

print("==============================================================================")
print("🎲 [AURA RNG] Starting One-Click Game Installation...")
print("==============================================================================")

-- 1. Setup ReplicatedStorage Structure
local auraRngFolder = ReplicatedStorage:FindFirstChild("AuraRNG")
if not auraRngFolder then
	auraRngFolder = Instance.new("Folder")
	auraRngFolder.Name = "AuraRNG"
	auraRngFolder.Parent = ReplicatedStorage
end

local eventsFolder = auraRngFolder:FindFirstChild("Events")
if not eventsFolder then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = auraRngFolder
end

local modulesFolder = auraRngFolder:FindFirstChild("Modules")
if not modulesFolder then
	modulesFolder = Instance.new("Folder")
	modulesFolder.Name = "Modules"
	modulesFolder.Parent = auraRngFolder
end

-- Create Remote Events and Functions
local function getOrCreateRemote(className, name)
	local existing = eventsFolder:FindFirstChild(name)
	if existing then return existing end
	local item = Instance.new(className)
	item.Name = name
	item.Parent = eventsFolder
	return item
end

getOrCreateRemote("RemoteFunction", "RollRequest")
getOrCreateRemote("RemoteFunction", "CraftAura")
getOrCreateRemote("RemoteEvent", "EquipAura")
getOrCreateRemote("RemoteEvent", "DeleteAura")
getOrCreateRemote("RemoteEvent", "SetAutoDelete")
getOrCreateRemote("RemoteEvent", "ToggleTestPerk")
getOrCreateRemote("RemoteEvent", "DataSync")
getOrCreateRemote("RemoteEvent", "GlobalAnnouncement")

-- Create / Update ModuleScripts
local function installModule(name, sourceCode)
	local existing = modulesFolder:FindFirstChild(name)
	if existing and existing:IsA("ModuleScript") then
		existing.Source = sourceCode
		return existing
	end
	if existing then existing:Destroy() end
	local mod = Instance.new("ModuleScript")
	mod.Name = name
	mod.Source = sourceCode
	mod.Parent = modulesFolder
	return mod
end

installModule("AuraConfig", [===[{aura_config_src}]===])
installModule("AuraVisuals", [===[{aura_visuals_src}]===])
installModule("SoundEffects", [===[{sound_effects_src}]===])
local craftSetupModule = installModule("CraftingStationSetup", [===[{crafting_setup_src}]===])

-- 2. Build Map Environment & Lighting
pcall(function()
	local craftSetup = require(craftSetupModule)
	craftSetup.BuildMap()
end)

-- 3. Install Server Script in ServerScriptService
local existingServerScript = ServerScriptService:FindFirstChild("RNGServer")
if existingServerScript and existingServerScript:IsA("Script") then
	existingServerScript.Source = [===[{server_src}]===]
else
	if existingServerScript then existingServerScript:Destroy() end
	local serverScript = Instance.new("Script")
	serverScript.Name = "RNGServer"
	serverScript.Source = [===[{server_src}]===]
	serverScript.Parent = ServerScriptService
end

-- 4. Install StarterGui ScreenGui & Client Script
local existingScreenGui = StarterGui:FindFirstChild("RNG_ScreenGui")
if not existingScreenGui then
	existingScreenGui = Instance.new("ScreenGui")
	existingScreenGui.Name = "RNG_ScreenGui"
	existingScreenGui.ResetOnSpawn = false
	existingScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	existingScreenGui.Parent = StarterGui
end

local existingClientScript = existingScreenGui:FindFirstChild("RNGClient")
if existingClientScript and existingClientScript:IsA("LocalScript") then
	existingClientScript.Source = [===[{client_src}]===]
else
	if existingClientScript then existingClientScript:Destroy() end
	local clientScript = Instance.new("LocalScript")
	clientScript.Name = "RNGClient"
	clientScript.Source = [===[{client_src}]===]
	clientScript.Parent = existingScreenGui
end

print("==============================================================================")
print("✅ [AURA RNG] УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА!")
print("==============================================================================")
print("🎉 Все системы готовы к работе:")
print("   • Модули аур и эффектов созданы в ReplicatedStorage.AuraRNG")
print("   • Серверный обработчик установлен в ServerScriptService.RNGServer")
print("   • Интерфейс GUI установлен в StarterGui.RNG_ScreenGui")
print("   • Неоновая платформа, спавн и алтарь крафта построены в Workspace")
print("")
print("🚀 НАЖМИТЕ ЗЕЛЕНУЮ КНОПКУ 'PLAY' (F5), ЧТОБЫ НАЧАТЬ ИГРАТЬ!")
print("==============================================================================")
"""

    with open("OneClick_Installer.lua", "w", encoding="utf-8") as f:
        f.write(installer_lua)

    print(f"Generated OneClick_Installer.lua ({len(installer_lua)} bytes)")

if __name__ == "__main__":
    generate_installer()
