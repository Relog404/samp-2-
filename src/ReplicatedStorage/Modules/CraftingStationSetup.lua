-- CraftingStationSetup.lua
-- Creates the vibrant morning cyber-mystic floating platform, interactive Crafting Altar with ProximityPrompt,
-- and crisp sunny morning lighting for Sol's RNG game.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local CraftingStationSetup = {}

function CraftingStationSetup.BuildMap()
	-- 1. Setup Crisp Sunny Morning Lighting
	Lighting.TimeOfDay = "08:00:00"
	Lighting.ClockTime = 8.0
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(110, 120, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 145, 170)
	Lighting.GlobalShadows = true
	Lighting.GeographicLatitude = 45

	-- Morning Sun Rays
	local sunRays = Lighting:FindFirstChild("RNGSunRays")
	if not sunRays then
		sunRays = Instance.new("SunRaysEffect")
		sunRays.Name = "RNGSunRays"
		sunRays.Intensity = 0.28
		sunRays.Spread = 0.85
		sunRays.Parent = Lighting
	end

	-- Vibrant Bloom
	local bloom = Lighting:FindFirstChild("RNGBloom")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Name = "RNGBloom"
		bloom.Parent = Lighting
	end
	bloom.Intensity = 1.1
	bloom.Size = 22
	bloom.Threshold = 0.82

	-- Saturated Color Correction
	local cc = Lighting:FindFirstChild("RNGColorCorrection")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Name = "RNGColorCorrection"
		cc.Parent = Lighting
	end
	cc.Brightness = 0.04
	cc.Contrast = 0.12
	cc.Saturation = 0.22

	-- Atmosphere for clear blue sky
	local atmo = Lighting:FindFirstChild("RNGAtmosphere")
	if not atmo then
		atmo = Instance.new("Atmosphere")
		atmo.Name = "RNGAtmosphere"
		atmo.Parent = Lighting
	end
	atmo.Density = 0.22
	atmo.Offset = 0.1
	atmo.Color = Color3.fromRGB(180, 205, 235)
	atmo.Decay = Color3.fromRGB(120, 140, 180)
	atmo.Glare = 0.25
	atmo.Haze = 0.4

	-- 2. Build Base Platform
	local existingPlatform = Workspace:FindFirstChild("RNG_Platform")
	if existingPlatform then
		existingPlatform:Destroy()
	end

	local platformFolder = Instance.new("Folder")
	platformFolder.Name = "RNG_Platform"
	platformFolder.Parent = Workspace

	-- Main Deck (Sleek Marble/Quartz Finish)
	local mainFloor = Instance.new("Part")
	mainFloor.Name = "MainFloor"
	mainFloor.Size = Vector3.new(120, 4, 120)
	mainFloor.Position = Vector3.new(0, 0, 0)
	mainFloor.Anchored = true
	mainFloor.Material = Enum.Material.SmoothPlastic
	mainFloor.Color = Color3.fromRGB(28, 32, 44)
	mainFloor.TopSurface = Enum.SurfaceType.Smooth
	mainFloor.BottomSurface = Enum.SurfaceType.Smooth
	mainFloor.Parent = platformFolder

	-- Glowing Cyan Neon Border
	local border = Instance.new("Part")
	border.Name = "BorderGlow"
	border.Size = Vector3.new(122, 1, 122)
	border.Position = Vector3.new(0, 2.1, 0)
	border.Anchored = true
	border.CanCollide = false
	border.Material = Enum.Material.Neon
	border.Color = Color3.fromRGB(56, 189, 248)
	border.Transparency = 0.3
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
	spawnLight.Brightness = 2.5
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
	altarBase.Color = Color3.fromRGB(35, 40, 56)
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

	-- Anvil Light & Sparkle Emitter
	local anvilLight = Instance.new("PointLight")
	anvilLight.Color = Color3.fromRGB(250, 204, 21)
	anvilLight.Brightness = 3.5
	anvilLight.Range = 22
	anvilLight.Parent = anvil

	local anvilEmitter = Instance.new("ParticleEmitter")
	anvilEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	anvilEmitter.Size = NumberSequence.new(0.5, 0.1)
	anvilEmitter.Transparency = NumberSequence.new(0.1, 1.0)
	anvilEmitter.Lifetime = NumberRange.new(1.2, 2.0)
	anvilEmitter.Rate = 35
	anvilEmitter.Speed = NumberRange.new(2.0, 5.0)
	anvilEmitter.SpreadAngle = Vector2.new(180, 180)
	anvilEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	anvilEmitter.Parent = anvil

	-- Proximity Prompt on Altar
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CraftingPrompt"
	prompt.ObjectText = "Кузница Алхимика"
	prompt.ActionText = "Открыть Крафт"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.Parent = anvil

	-- Overhead Billboard
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 60
	bb.Parent = anvil

	local bbLabel = Instance.new("TextLabel")
	bbLabel.Size = UDim2.new(1, 0, 1, 0)
	bbLabel.BackgroundTransparency = 1
	bbLabel.Font = Enum.Font.GothamBlack
	bbLabel.TextSize = 16
	bbLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
	bbLabel.Text = "⚗️ КУЗНИЦА КРАФТА"
	bbLabel.TextStrokeColor3 = Color3.fromRGB(20, 20, 30)
	bbLabel.TextStrokeTransparency = 0.2
	bbLabel.Parent = bb

	print("[Sols RNG] Morning Platform, Crafting Altar, and Sunny Lighting successfully built!")
end

return CraftingStationSetup
