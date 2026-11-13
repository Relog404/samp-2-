-- AuraVisuals.lua
-- Procedurally creates and attaches high-quality particle emitters, highlights,
-- light beams, and overhead billboards for all Auras in the game.

local AuraConfig = require(script.Parent.AuraConfig)

local AuraVisuals = {}

-- Standard particle texture asset IDs built into Roblox or reliable default library assets
local TEXTURES = {
	Sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	Smoke = "rbxasset://textures/particles/smoke_main.dds",
	Point = "rbxassetid://241594419",   -- Glowing soft dot / star
	Flame = "rbxassetid://258128463",   -- Rising flame wisps
	Ring = "rbxassetid://243664672",    -- Circular energy ring
	Cross = "rbxassetid://258127006",   -- Divine sparkle / star
	Shard = "rbxassetid://241594432",   -- Crystal diamond shard
}

-- Helper to safely get or create character's ActiveAura folder
local function getActiveFolder(character)
	local existing = character:FindFirstChild("ActiveAura")
	if existing and existing:IsA("Folder") then
		existing:ClearAllChildren()
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "ActiveAura"
	folder.Parent = character
	return folder
end

-- Clear aura effects
function AuraVisuals.ClearAura(character)
	local existing = character:FindFirstChild("ActiveAura")
	if existing then
		existing:Destroy()
	end
	
	local head = character:FindFirstChild("Head")
	if head then
		local oldBillboard = head:FindFirstChild("AuraBillboardGui")
		if oldBillboard then
			oldBillboard:Destroy()
		end
	end
end

-- Build standard particle emitter
local function createEmitter(parent, config)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = config.Color
	emitter.Size = config.Size
	emitter.Transparency = config.Transparency
	emitter.Lifetime = config.Lifetime
	emitter.Rate = config.Rate
	emitter.Speed = config.Speed
	emitter.SpreadAngle = config.SpreadAngle or Vector2.new(15, 15)
	emitter.Acceleration = config.Acceleration or Vector3.new(0, 2, 0)
	emitter.Drag = config.Drag or 0.5
	emitter.LightEmission = config.LightEmission or 0.9
	emitter.Texture = config.Texture or TEXTURES.Point
	emitter.RotSpeed = config.RotSpeed or NumberRange.new(-45, 45)
	emitter.EmissionDirection = config.EmissionDirection or Enum.NormalId.Top
	emitter.Parent = parent
	return emitter
end

-- Create overhead Billboard GUI above character head
local function createOverheadGui(character, auraData, isVIP)
	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	local oldGui = head:FindFirstChild("AuraBillboardGui")
	if oldGui then oldGui:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AuraBillboardGui"
	billboard.Size = UDim2.new(0, 260, 0, 65)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 120
	billboard.Parent = head

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = container

	-- VIP Tag (if VIP)
	if isVIP then
		local vipLabel = Instance.new("TextLabel")
		vipLabel.Size = UDim2.new(1, 0, 0, 16)
		vipLabel.BackgroundTransparency = 1
		vipLabel.Font = Enum.Font.GothamBlack
		vipLabel.TextSize = 13
		vipLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		vipLabel.Text = "[ ⭐ VIP ⭐ ]"
		vipLabel.TextStrokeColor3 = Color3.fromRGB(50, 40, 0)
		vipLabel.TextStrokeTransparency = 0.2
		vipLabel.Parent = container
	end

	-- Aura Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 18
	nameLabel.TextColor3 = auraData.Color
	nameLabel.Text = auraData.Name
	nameLabel.TextStrokeColor3 = Color3.fromRGB(15, 15, 20)
	nameLabel.TextStrokeTransparency = 0.1
	nameLabel.Parent = container

	-- Rarity / Tier Tag
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0, 16)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Font = Enum.Font.GothamMedium
	rarityLabel.TextSize = 13
	rarityLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
	
	local rarityText = AuraConfig.FormatRarity(auraData.Rarity or 0)
	if auraData.Tier == "Crafted" then
		rarityText = "Crafted Masterpiece"
	end
	rarityLabel.Text = string.format("%s • %s", auraData.Tier:upper(), rarityText)
	rarityLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
	rarityLabel.TextStrokeTransparency = 0.3
	rarityLabel.Parent = container
end

-- Create Vertical Light Pillar Beam (for Legendary+)
local function createVerticalBeam(parent, rootPart, color)
	local attBottom = Instance.new("Attachment")
	attBottom.Name = "BeamAttBottom"
	attBottom.Position = Vector3.new(0, -2.5, 0)
	attBottom.Parent = rootPart

	local attTop = Instance.new("Attachment")
	attTop.Name = "BeamAttTop"
	attTop.Position = Vector3.new(0, 10, 0)
	attTop.Parent = rootPart

	local beam = Instance.new("Beam")
	beam.Name = "AuraPillarBeam"
	beam.Attachment0 = attBottom
	beam.Attachment1 = attTop
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, color),
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 0.9),
	})
	beam.Width0 = 3.5
	beam.Width1 = 5.0
	beam.LightEmission = 1.0
	beam.TextureSpeed = 1.5
	beam.Texture = TEXTURES.Flame
	beam.Parent = parent
end

-- Main function to apply an aura to a character model
function AuraVisuals.ApplyAura(character, auraId, isVIP)
	AuraVisuals.ClearAura(character)

	if not auraId or auraId == "None" or auraId == "" then
		return
	end

	local auraData = AuraConfig.Auras[auraId]
	if not auraData then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("UpperTorso")
	
	if not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	local activeFolder = getActiveFolder(character)
	local auraColor = auraData.Color or Color3.fromRGB(255, 255, 255)
	local pColor = auraData.ParticleColor or auraColor

	-- 1. Attachment on RootPart
	local rootAttachment = Instance.new("Attachment")
	rootAttachment.Name = "AuraRootAttachment"
	rootAttachment.Position = Vector3.new(0, -0.5, 0)
	rootAttachment.Parent = rootPart

	-- 2. Character Highlight (Glow outline)
	local highlight = Instance.new("Highlight")
	highlight.Name = "AuraHighlight"
	highlight.Adornee = character
	highlight.OutlineColor = auraColor
	highlight.OutlineTransparency = 0.1
	highlight.FillColor = auraColor
	highlight.FillTransparency = 0.85
	highlight.Parent = activeFolder

	-- 3. Dynamic PointLight
	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light.Color = auraColor
	light.Range = (auraData.Rarity >= 10000 or auraData.IsCrafted) and 18 or 12
	light.Brightness = (auraData.Rarity >= 10000 or auraData.IsCrafted) and 3.5 or 2.0
	light.Shadows = false
	light.Parent = rootAttachment

	-- 4. Overhead Billboard GUI
	createOverheadGui(character, auraData, isVIP or false)

	-- 5. Build Tailored Particle Emitters based on ParticleShape / Tier
	local shape = auraData.ParticleShape or "Sparks"

	if shape == "Dust" then
		-- Common: subtle ambient dust
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.5, 0.6),
				NumberSequenceKeypoint.new(1, 0.1),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.5, 2.5),
			Rate = 12,
			Speed = NumberRange.new(1.0, 2.0),
			SpreadAngle = Vector2.new(45, 45),
			Acceleration = Vector3.new(0, 1.5, 0),
			Texture = TEXTURES.Point,
		})

	elseif shape == "Leaves" then
		-- Natural: swirling leaves & green vitality
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.8),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.8, 0.4),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(2.0, 3.2),
			Rate = 22,
			Speed = NumberRange.new(2.0, 4.0),
			SpreadAngle = Vector2.new(60, 60),
			Acceleration = Vector3.new(0, 3, 0),
			RotSpeed = NumberRange.new(-90, 90),
			Texture = TEXTURES.Sparkle,
		})

	elseif shape == "Flame" or shape == "Embers" then
		-- Rising flames or fiery embers
		createEmitter(rootAttachment, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, pColor),
				ColorSequenceKeypoint.new(0.6, auraColor),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 200)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.4, 1.2),
				NumberSequenceKeypoint.new(1, 0.1),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.7, 0.3),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.2, 2.0),
			Rate = 35,
			Speed = NumberRange.new(3.0, 6.0),
			SpreadAngle = Vector2.new(25, 25),
			Acceleration = Vector3.new(0, 5, 0),
			Texture = TEXTURES.Flame,
		})

	elseif shape == "Shards" or shape == "Frost" then
		-- Diamond crystal shards & sub-zero mist
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.5, 0.9),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.6, 0.2),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.8, 2.8),
			Rate = 30,
			Speed = NumberRange.new(2.0, 4.5),
			SpreadAngle = Vector2.new(40, 40),
			Acceleration = Vector3.new(0, 2.5, 0),
			RotSpeed = NumberRange.new(-120, 120),
			Texture = TEXTURES.Shard,
		})
		-- Frost ambient mist
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(Color3.fromRGB(200, 240, 255)),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.0),
				NumberSequenceKeypoint.new(1, 2.5),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.5, 2.2),
			Rate = 12,
			Speed = NumberRange.new(0.5, 1.5),
			Texture = TEXTURES.Smoke,
		})

	elseif shape == "FireColumn" or shape == "Hellfire" then
		-- High-tier Fire Column (Ruby, Hades)
		createEmitter(rootAttachment, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 20)),
				ColorSequenceKeypoint.new(0.5, pColor),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 100)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.4, 2.2),
				NumberSequenceKeypoint.new(1, 0.3),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.7, 0.25),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.0, 1.8),
			Rate = 50,
			Speed = NumberRange.new(6.0, 11.0),
			SpreadAngle = Vector2.new(20, 20),
			Acceleration = Vector3.new(0, 8, 0),
			Texture = TEXTURES.Flame,
		})
		-- Fiery sparks
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(Color3.fromRGB(255, 240, 150)),
			Size = NumberSequence.new(0.3, 0.1),
			Transparency = NumberSequence.new(0.1, 1.0),
			Lifetime = NumberRange.new(1.0, 2.0),
			Rate = 35,
			Speed = NumberRange.new(4.0, 9.0),
			SpreadAngle = Vector2.new(35, 35),
			Acceleration = Vector3.new(0, 6, 0),
			Texture = TEXTURES.Cross,
		})
		createVerticalBeam(activeFolder, rootPart, pColor)

	elseif shape == "Sunburst" or shape == "EclipseCorona" then
		-- Solar / Eclipse: Blinding solar rays & energy corona
		createEmitter(rootAttachment, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 40)),
				ColorSequenceKeypoint.new(0.5, pColor),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(0.5, 2.5),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.8, 0.4),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.4, 2.2),
			Rate = 60,
			Speed = NumberRange.new(4.0, 9.0),
			SpreadAngle = Vector2.new(45, 45),
			Acceleration = Vector3.new(0, 4, 0),
			Texture = TEXTURES.Cross,
		})
		createVerticalBeam(activeFolder, rootPart, pColor)

	elseif shape == "MoonStars" or shape == "NebulaSpiral" or shape == "Singularity" then
		-- Cosmic / Galaxy / Abyssal Hunter / Lunar: Deep space stars & swirling nebula
		createEmitter(rootAttachment, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, pColor),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 255)),
				ColorSequenceKeypoint.new(1, pColor),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(0.5, 1.6),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.1),
				NumberSequenceKeypoint.new(0.7, 0.2),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(2.0, 3.2),
			Rate = 45,
			Speed = NumberRange.new(3.0, 6.5),
			SpreadAngle = Vector2.new(50, 50),
			Acceleration = Vector3.new(0, 3, 0),
			RotSpeed = NumberRange.new(-60, 60),
			Texture = TEXTURES.Cross,
		})
		-- Swirling cosmic mist
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.5),
				NumberSequenceKeypoint.new(1, 3.8),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(2.0, 3.0),
			Rate = 20,
			Speed = NumberRange.new(1.0, 3.0),
			SpreadAngle = Vector2.new(70, 70),
			Texture = TEXTURES.Smoke,
		})
		createVerticalBeam(activeFolder, rootPart, pColor)

	elseif shape == "DivineHalo" or shape == "TimeClock" or shape == "PrismaticGlitch" then
		-- Archangel / Chronos / Exotic Apex: Celestial divine radiance
		createEmitter(rootAttachment, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 220)),
				ColorSequenceKeypoint.new(0.5, pColor),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.4),
				NumberSequenceKeypoint.new(0.5, 2.0),
				NumberSequenceKeypoint.new(1, 0.3),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.05),
				NumberSequenceKeypoint.new(0.8, 0.2),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.5, 2.5),
			Rate = 55,
			Speed = NumberRange.new(4.0, 8.0),
			SpreadAngle = Vector2.new(40, 40),
			Acceleration = Vector3.new(0, 5, 0),
			Texture = TEXTURES.Cross,
		})
		createVerticalBeam(activeFolder, rootPart, pColor)

	else
		-- General fallback emitter
		createEmitter(rootAttachment, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 1.0),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.7, 0.3),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.5, 2.5),
			Rate = 30,
			Speed = NumberRange.new(2.5, 5.0),
			SpreadAngle = Vector2.new(30, 30),
			Acceleration = Vector3.new(0, 3, 0),
			Texture = TEXTURES.Point,
		})
		if auraData.Rarity and auraData.Rarity >= 1000 then
			createVerticalBeam(activeFolder, rootPart, pColor)
		end
	end
end

return AuraVisuals
