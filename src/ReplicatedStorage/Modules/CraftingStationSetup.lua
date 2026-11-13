--!strict
-- CraftingStationSetup.lua
-- Creates the sleek cyber-mystic floating platform, interactive Crafting Altar with ProximityPrompt,
-- and atmospheric lighting for Sol's RNG game.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local CraftingStationSetup = {}

function CraftingStationSetup.BuildMap()
	-- 1. Setup Atmospheric Lighting
	Lighting.TimeOfDay = "21:30:00"
	Lighting.Brightness = 1.8
	Lighting.ClockTime = 21.5
	Lighting.Ambient = Color3.fromRGB(40, 45, 60)
	Lighting.OutdoorAmbient = Color3.fromRGB(30, 35, 50)
	Lighting.GlobalShadows = true

	if not Lighting:FindFirstChild("RNGBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "RNGBloom"
		bloom.Intensity = 1.2
		bloom.Size = 24
		bloom.Threshold = 0.85
		bloom.Parent = Lighting
	end

	if not Lighting:FindFirstChild("RNGColorCorrection") then
		local cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "RNGColorCorrection"
		cc.Brightness = 0.04
		cc.Contrast = 0.15
		cc.Saturation = 0.2
		cc.Parent = Lighting
	end

	-- 2. Build Base Platform
	local existingPlatform = Workspace:FindFirstChild("RNG_Platform")
	if existingPlatform then
		existingPlatform:Destroy()
	end

	local platformFolder = Instance.new("Folder")
	platformFolder.Name = "RNG_Platform"
	platformFolder.Parent = Workspace

	-- Main Deck
	local mainFloor = Instance.new("Part")
	mainFloor.Name = "MainFloor"
	mainFloor.Size = Vector3.new(120, 4, 120)
	mainFloor.Position = Vector3.new(0, 0, 0)
	mainFloor.Anchored = true
	mainFloor.Material = Enum.Material.Slate
	mainFloor.Color = Color3.fromRGB(22, 25, 34)
	mainFloor.TopSurface = Enum.SurfaceType.Smooth
	mainFloor.BottomSurface = Enum.SurfaceType.Smooth
	mainFloor.Parent = platformFolder

	-- Glowing Neon Border Ring
	local border = Instance.new("Part")
	border.Name = "BorderGlow"
	border.Size = Vector3.new(122, 1, 122)
	border.Position = Vector3.new(0, 2.1, 0)
	border.Anchored = true
	border.CanCollide = false
	border.Material = Enum.Material.Neon
	border.Color = Color3.fromRGB(56, 189, 248)
	border.Transparency = 0.4
	border.Parent = platformFolder

	-- Center Spawn Location
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "RNG_Spawn"
	spawn.Size = Vector3.new(16, 1, 16)
	spawn.Position = Vector3.new(0, 2.1, 0)
	spawn.Anchored = true
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(37, 99, 235)
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = platformFolder

	-- Center Ambient Light
	local spawnLight = Instance.new("PointLight")
	spawnLight.Color = Color3.fromRGB(96, 165, 250)
	spawnLight.Brightness = 2.0
	spawnLight.Range = 25
	spawnLight.Parent = spawn

	-- 3. Interactive Crafting Altar
	local altarModel = Instance.new("Model")
	altarModel.Name = "CraftingAltar"
	altarModel.Parent = platformFolder

	-- Pedestal Base
	local altarBase = Instance.new("Part")
	altarBase.Name = "AltarBase"
	altarBase.Size = Vector3.new(10, 2, 10)
	altarBase.Position = Vector3.new(35, 2.5, 0)
	altarBase.Anchored = true
	altarBase.Material = Enum.Material.SmoothPlastic
	altarBase.Color = Color3.fromRGB(30, 35, 48)
	altarBase.Parent = altarModel

	-- Glowing Rune Disc
	local runeDisc = Instance.new("Part")
	runeDisc.Name = "RuneDisc"
	runeDisc.Size = Vector3.new(8, 0.4, 8)
	runeDisc.Position = Vector3.new(35, 3.6, 0)
	runeDisc.Anchored = true
	runeDisc.Material = Enum.Material.Neon
	runeDisc.Color = Color3.fromRGB(168, 85, 247)
	runeDisc.Parent = altarModel

	-- Floating Mystical Crystal Anvil
	local anvil = Instance.new("Part")
	anvil.Name = "FloatingCrystal"
	anvil.Size = Vector3.new(3.5, 4, 3.5)
	anvil.Position = Vector3.new(35, 6.5, 0)
	anvil.Anchored = true
	anvil.CanCollide = false
	anvil.Material = Enum.Material.Neon
	anvil.Color = Color3.fromRGB(245, 158, 11)
	anvil.Orientation = Vector3.new(45, 45, 0)
	anvil.Parent = altarModel

	-- Anvil Light & Particle Emitter
	local anvilLight = Instance.new("PointLight")
	anvilLight.Color = Color3.fromRGB(250, 204, 21)
	anvilLight.Brightness = 3.5
	anvilLight.Range = 22
	anvilLight.Parent = anvil

	local anvilEmitter = Instance.new("ParticleEmitter")
	anvilEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	anvilEmitter.Size = NumberSequence.new(0.4, 0.1)
	anvilEmitter.Transparency = NumberSequence.new(0.1, 1.0)
	anvilEmitter.Lifetime = NumberRange.new(1.2, 2.0)
	anvilEmitter.Rate = 25
	anvilEmitter.Speed = NumberRange.new(2.0, 4.0)
	anvilEmitter.SpreadAngle = Vector2.new(180, 180)
	anvilEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	anvilEmitter.Parent = anvil

	-- Proximity Prompt on Altar
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CraftingPrompt"
	prompt.ObjectText = "Alchemist Altar"
	prompt.ActionText = "Open Crafting Forge"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.Parent = anvil

	-- Overhead Billboard
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 50
	bb.Parent = anvil

	local bbLabel = Instance.new("TextLabel")
	bbLabel.Size = UDim2.new(1, 0, 1, 0)
	bbLabel.BackgroundTransparency = 1
	bbLabel.Font = Enum.Font.GothamBlack
	bbLabel.TextSize = 16
	bbLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
	bbLabel.Text = "⚗️ CRAFTING FORGE"
	bbLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 30)
	bbLabel.TextStrokeTransparency = 0.2
	bbLabel.Parent = bb

	print("[Sols RNG] Platform, Crafting Altar, and Atmospheric Lighting successfully built!")
end

return CraftingStationSetup
