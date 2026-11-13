-- AuraVisuals.lua
-- Professional multi-layered procedural Visual Effects (VFX) engine for Sol's RNG.
-- Creates ground magic rings, ascending body energy, orbiting celestial stars,
-- divine wings, head halos, character highlights, light beams, and modern overhead badges.

local AuraConfig = require(script.Parent.AuraConfig)

local AuraVisuals = {}

-- Standard high-definition particle textures built into Roblox engine
local TEXTURES = {
	Sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	Smoke = "rbxasset://textures/particles/smoke_main.dds",
	Point = "rbxassetid://241594419",   -- Glowing star orb
	Flame = "rbxassetid://258128463",   -- Rising energy flame
	Ring = "rbxassetid://243664672",    -- Energy ring / magic disc
	Cross = "rbxassetid://258127006",   -- Divine star glint
	Shard = "rbxassetid://241594432",   -- Diamond ice crystal
}

-- Safely clear all aura effects from character
function AuraVisuals.ClearAura(character)
	if not character then return end

	local existing = character:FindFirstChild("ActiveAura")
	if existing then
		existing:Destroy()
	end

	local head = character:FindFirstChild("Head")
	if head then
		local oldBb = head:FindFirstChild("AuraBillboardGui")
		if oldBb then
			oldBb:Destroy()
		end
	end

	-- Clean up any stray highlight or attachments
	for _, child in ipairs(character:GetDescendants()) do
		if child.Name == "AuraHighlight" or child.Name == "AuraVFXAttachment" then
			child:Destroy()
		end
	end
end

-- Safely get or create character's ActiveAura folder
local function getActiveFolder(character)
	local existing = character:FindFirstChild("ActiveAura")
	if existing and existing:IsA("Folder") then
		existing:ClearAllChildren()
		return existing
	end
	if existing then existing:Destroy() end

	local folder = Instance.new("Folder")
	folder.Name = "ActiveAura"
	folder.Parent = character
	return folder
end

-- Helper: Create configured ParticleEmitter
local function createEmitter(parent, props)
	local pe = Instance.new("ParticleEmitter")
	pe.Color = props.Color
	pe.Size = props.Size
	pe.Transparency = props.Transparency
	pe.Lifetime = props.Lifetime
	pe.Rate = props.Rate
	pe.Speed = props.Speed
	pe.SpreadAngle = props.SpreadAngle or Vector2.new(15, 15)
	pe.Acceleration = props.Acceleration or Vector3.new(0, 2, 0)
	pe.Drag = props.Drag or 0.5
	pe.LightEmission = props.LightEmission or 1.0
	pe.LightInfluence = props.LightInfluence or 0.0
	pe.Texture = props.Texture or TEXTURES.Sparkle
	pe.RotSpeed = props.RotSpeed or NumberRange.new(-60, 60)
	pe.Orientation = props.Orientation or Enum.ParticleOrientation.FacingCamera
	pe.EmissionDirection = props.EmissionDirection or Enum.NormalId.Top
	pe.Parent = parent
	return pe
end

-- LAYER 1: Ground Magic Circle / Rune Disc
local function addGroundMagicCircle(parentAtt, color, scaleMultiplier)
	local scale = scaleMultiplier or 1.0

	-- Expanding ground energy pulse
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.2 * scale),
			NumberSequenceKeypoint.new(0.6, 3.8 * scale),
			NumberSequenceKeypoint.new(1, 4.8 * scale),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.15, 0.2),
			NumberSequenceKeypoint.new(0.7, 0.4),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.8, 2.5),
		Rate = 6,
		Speed = NumberRange.new(0.1, 0.3),
		SpreadAngle = Vector2.new(0, 0),
		Acceleration = Vector3.new(0, 0.2, 0),
		Drag = 1.0,
		Texture = TEXTURES.Ring,
		RotSpeed = NumberRange.new(20, 40),
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
	})

	-- Ground ambient spark motes
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.6 * scale),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.2, 0.1),
			NumberSequenceKeypoint.new(0.8, 0.3),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.5, 2.2),
		Rate = 18 * scale,
		Speed = NumberRange.new(1.0, 3.0),
		SpreadAngle = Vector2.new(45, 45),
		Acceleration = Vector3.new(0, 3.5, 0),
		Texture = TEXTURES.Cross,
	})
end

-- LAYER 2: Body Ascending Energy Wisps (The Core Flame)
local function addBodyEnergyWisps(parentAtt, color, secondaryColor, rate, speedRange, sizeRange)
	local secColor = secondaryColor or color
	createEmitter(parentAtt, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.5, secColor),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, sizeRange[1] or 0.4),
			NumberSequenceKeypoint.new(0.5, sizeRange[2] or 1.6),
			NumberSequenceKeypoint.new(1, sizeRange[3] or 0.2),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(0.7, 0.3),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.2, 2.0),
		Rate = rate or 35,
		Speed = speedRange or NumberRange.new(3.0, 6.0),
		SpreadAngle = Vector2.new(20, 20),
		Acceleration = Vector3.new(0, 5, 0),
		Texture = TEXTURES.Flame,
	})
end

-- LAYER 3: Orbiting Celestial Star Particles
local function addOrbitingSparks(parentAtt, color, rate)
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.8),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.2, 0.0),
			NumberSequenceKeypoint.new(0.8, 0.2),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.6, 2.6),
		Rate = rate or 25,
		Speed = NumberRange.new(2.5, 5.0),
		SpreadAngle = Vector2.new(60, 60),
		Acceleration = Vector3.new(0, 2, 0),
		RotSpeed = NumberRange.new(-120, 120),
		Texture = TEXTURES.Sparkle,
	})
end

-- LAYER 4: Divine Angelic Wings (For Archangel, Solar, Godly)
local function addAngelicWings(character, folder, color)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end

	-- Left Wing Attachment
	local attWingL = Instance.new("Attachment")
	attWingL.Name = "AuraVFXAttachment"
	attWingL.Position = Vector3.new(-1.2, 0.8, 0.8)
	attWingL.Orientation = Vector3.new(0, 35, 15)
	attWingL.Parent = torso

	-- Right Wing Attachment
	local attWingR = Instance.new("Attachment")
	attWingR.Name = "AuraVFXAttachment"
	attWingR.Position = Vector3.new(1.2, 0.8, 0.8)
	attWingR.Orientation = Vector3.new(0, -35, -15)
	attWingR.Parent = torso

	local function makeWingEmitter(parentAtt)
		createEmitter(parentAtt, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.6, color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 180)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.4, 2.2),
				NumberSequenceKeypoint.new(1, 0.3),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.2, 0.05),
				NumberSequenceKeypoint.new(0.8, 0.2),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(0.8, 1.4),
			Rate = 40,
			Speed = NumberRange.new(3.0, 6.0),
			SpreadAngle = Vector2.new(20, 20),
			Acceleration = Vector3.new(0, 3, 0),
			Texture = TEXTURES.Flame,
		})
	end

	makeWingEmitter(attWingL)
	makeWingEmitter(attWingR)
end

-- LAYER 5: Floating Head Halo / Celestial Crown
local function addHeadCrown(character, folder, color, isVIP)
	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	local attCrown = Instance.new("Attachment")
	attCrown.Name = "AuraVFXAttachment"
	attCrown.Position = Vector3.new(0, 1.6, 0)
	attCrown.Parent = head

	-- Rotating Halo Ring
	createEmitter(attCrown, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(0.5, 2.2),
			NumberSequenceKeypoint.new(1, 1.5),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.6),
		}),
		Lifetime = NumberRange.new(1.0, 1.6),
		Rate = 4,
		Speed = NumberRange.new(0, 0.1),
		SpreadAngle = Vector2.new(0, 0),
		Acceleration = Vector3.new(0, 0, 0),
		RotSpeed = NumberRange.new(45, 90),
		Texture = TEXTURES.Ring,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
	})

	-- Halo Star Sparkles
	createEmitter(attCrown, {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Size = NumberSequence.new(0.4, 0.1),
		Transparency = NumberSequence.new(0.1, 1.0),
		Lifetime = NumberRange.new(0.8, 1.4),
		Rate = 12,
		Speed = NumberRange.new(0.5, 1.5),
		SpreadAngle = Vector2.new(180, 180),
		Texture = TEXTURES.Cross,
	})
end

-- LAYER 6: Vertical Pillar of Divine Light (For Legendary+)
local function addLightPillar(rootPart, activeFolder, color)
	local attBottom = Instance.new("Attachment")
	attBottom.Name = "AuraVFXAttachment"
	attBottom.Position = Vector3.new(0, -2.8, 0)
	attBottom.Parent = rootPart

	local attTop = Instance.new("Attachment")
	attTop.Name = "AuraVFXAttachment"
	attTop.Position = Vector3.new(0, 12, 0)
	attTop.Parent = rootPart

	local beam = Instance.new("Beam")
	beam.Name = "AuraPillarBeam"
	beam.Attachment0 = attBottom
	beam.Attachment1 = attTop
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, color),
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 0.95),
	})
	beam.Width0 = 3.8
	beam.Width1 = 6.2
	beam.LightEmission = 1.0
	beam.TextureSpeed = 1.8
	beam.Texture = TEXTURES.Flame
	beam.Parent = activeFolder
end

-- LAYER 7: Modern Glassmorphic Overhead Billboard Title
local function createOverheadGui(character, auraData, isVIP)
	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	local oldBb = head:FindFirstChild("AuraBillboardGui")
	if oldBb then oldBb:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AuraBillboardGui"
	billboard.Size = UDim2.new(0, 240, 0, 68)
	billboard.StudsOffset = Vector3.new(0, 3.4, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 120
	billboard.Parent = head

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(1, 0, 1, 0)
	pill.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
	pill.BackgroundTransparency = 0.25
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = pill

	local stroke = Instance.new("UIStroke")
	stroke.Color = auraData.Color
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = pill
	pill.Parent = billboard

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = pill

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 1)
	list.Parent = pill

	-- VIP Tag (if VIP)
	if isVIP then
		local vipLabel = Instance.new("TextLabel")
		vipLabel.Size = UDim2.new(1, 0, 0, 14)
		vipLabel.BackgroundTransparency = 1
		vipLabel.Font = Enum.Font.GothamBlack
		vipLabel.TextSize = 11
		vipLabel.TextColor3 = Color3.fromRGB(251, 191, 36)
		vipLabel.Text = "★ VIP SUPPORTER ★"
		vipLabel.Parent = pill
	end

	-- Aura Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 18
	nameLabel.TextColor3 = auraData.Color
	nameLabel.Text = auraData.Name
	nameLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
	nameLabel.TextStrokeTransparency = 0.1
	nameLabel.Parent = pill

	-- Tier & Rarity Subtitle
	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0, 15)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = Enum.Font.GothamBold
	subLabel.TextSize = 11
	subLabel.TextColor3 = Color3.fromRGB(200, 205, 220)

	local rText = AuraConfig.FormatRarity(auraData.Rarity or 0)
	if auraData.Tier == "Crafted" then
		rText = "Crafted Masterpiece"
	end
	subLabel.Text = string.format("[ %s • %s ]", auraData.Tier:upper(), rText)
	subLabel.Parent = pill
end

-- =============================================================================
-- MAIN ENTRY POINT: APPLY AURA TO CHARACTER
-- =============================================================================

function AuraVisuals.ApplyAura(character, auraId, isVIP)
	AuraVisuals.ClearAura(character)

	if not character or not auraId or auraId == "None" or auraId == "" then
		return
	end

	local auraData = AuraConfig.Auras[auraId]
	if not auraData then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("UpperTorso")
	
	if not rootPart or not rootPart:IsA("BasePart") then return end

	local activeFolder = getActiveFolder(character)
	local auraColor = auraData.Color or Color3.fromRGB(255, 255, 255)
	local pColor = auraData.ParticleColor or auraColor
	local rarity = auraData.Rarity or 0

	-- 1. Create Core Attachments
	local attFoot = Instance.new("Attachment")
	attFoot.Name = "AuraVFXAttachment"
	attFoot.Position = Vector3.new(0, -2.7, 0)
	attFoot.Parent = rootPart

	local attRoot = Instance.new("Attachment")
	attRoot.Name = "AuraVFXAttachment"
	attRoot.Position = Vector3.new(0, 0, 0)
	attRoot.Parent = rootPart

	-- 2. Character Highlight (Clean, avatar-preserving outline glow)
	local highlight = Instance.new("Highlight")
	highlight.Name = "AuraHighlight"
	highlight.Adornee = character
	highlight.OutlineColor = auraColor
	highlight.OutlineTransparency = 0.05
	highlight.FillColor = auraColor
	highlight.FillTransparency = 0.92 -- Translucent so avatar face/clothing stays crisp!
	highlight.Parent = activeFolder

	-- 3. PointLight with breathing illumination
	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light.Color = auraColor
	light.Range = (rarity >= 10000 or auraData.IsCrafted) and 20 or 14
	light.Brightness = (rarity >= 10000 or auraData.IsCrafted) and 3.8 or 2.2
	light.Shadows = false
	light.Parent = attRoot

	-- 4. Overhead Modern Billboard GUI
	createOverheadGui(character, auraData, isVIP or false)

	-- 5. Always apply Ground Magic Circle & Orbiting Sparks for all auras
	local groundScale = (rarity >= 10000) and 1.4 or 1.0
	addGroundMagicCircle(attFoot, pColor, groundScale)
	addOrbitingSparks(attRoot, pColor, (rarity >= 1000) and 35 or 18)

	-- 6. Tailor Specialized VFX based on Aura Shape & Tier
	local shape = auraData.ParticleShape or "Sparks"

	if shape == "Dust" or shape == "Sparks" then
		-- Common / Uncommon
		addBodyEnergyWisps(attRoot, pColor, auraColor, 20, NumberRange.new(1.5, 3.5), {0.2, 0.8, 0.1})

	elseif shape == "Leaves" then
		-- Natural
		addBodyEnergyWisps(attRoot, pColor, Color3.fromRGB(160, 240, 100), 28, NumberRange.new(2.0, 4.5), {0.3, 1.2, 0.2})

	elseif shape == "Flame" or shape == "Embers" then
		-- Rare / Topaz
		addBodyEnergyWisps(attRoot, pColor, Color3.fromRGB(255, 230, 150), 40, NumberRange.new(3.5, 7.0), {0.4, 1.6, 0.2})

	elseif shape == "Sparkles" then
		-- Divinus: Holy sparkles + Head Halo
		addBodyEnergyWisps(attRoot, pColor, Color3.fromRGB(255, 255, 200), 35, NumberRange.new(3.0, 6.0), {0.3, 1.4, 0.2})
		addHeadCrown(character, activeFolder, pColor, false)

	elseif shape == "Shards" or shape == "Frost" then
		-- Crystallized / Glacier: Crystalline shards & blizzard mist
		createEmitter(attRoot, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 1.1),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.0),
				NumberSequenceKeypoint.new(0.2, 0.0),
				NumberSequenceKeypoint.new(0.8, 0.3),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.6, 2.4),
			Rate = 30,
			Speed = NumberRange.new(2.5, 5.5),
			SpreadAngle = Vector2.new(45, 45),
			Acceleration = Vector3.new(0, 3, 0),
			RotSpeed = NumberRange.new(-140, 140),
			Texture = TEXTURES.Shard,
		})

	elseif shape == "FireColumn" or shape == "Hellfire" or shape == "LavaTide" then
		-- Ruby / Hades / Hellforged: Violent blazing fire column + Vertical Pillar
		addBodyEnergyWisps(attRoot, Color3.fromRGB(255, 40, 20), pColor, 55, NumberRange.new(5.0, 10.0), {0.6, 2.4, 0.3})
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "Sunburst" or shape == "EclipseCorona" then
		-- Solar / Eclipse: Radiant solar corona + Head Halo + Light Pillar
		addBodyEnergyWisps(attRoot, Color3.fromRGB(255, 180, 40), Color3.fromRGB(255, 255, 255), 60, NumberRange.new(4.5, 9.0), {0.6, 2.5, 0.3})
		addHeadCrown(character, activeFolder, pColor, false)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "MoonStars" or shape == "NebulaSpiral" or shape == "Singularity" then
		-- Lunar / Galaxy / Abyssal Hunter: Deep cosmic nebula + starlight beam
		createEmitter(attRoot, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, pColor),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 180, 255)),
				ColorSequenceKeypoint.new(1, pColor),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.5, 2.2),
				NumberSequenceKeypoint.new(1, 0.4),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.0),
				NumberSequenceKeypoint.new(0.2, 0.1),
				NumberSequenceKeypoint.new(0.7, 0.25),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.8, 2.8),
			Rate = 45,
			Speed = NumberRange.new(2.5, 5.5),
			SpreadAngle = Vector2.new(60, 60),
			Acceleration = Vector3.new(0, 2.5, 0),
			Texture = TEXTURES.Cross,
		})
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "DivineHalo" or shape == "TimeClock" or shape == "PrismaticGlitch" then
		-- Archangel / Chronos / Exotic Apex: Divine wings + Halo + Pillar
		addBodyEnergyWisps(attRoot, pColor, Color3.fromRGB(255, 255, 255), 55, NumberRange.new(4.0, 8.5), {0.5, 2.2, 0.3})
		addAngelicWings(character, activeFolder, pColor)
		addHeadCrown(character, activeFolder, pColor, false)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "CrownGlow" then
		-- VIP Crown: Regal floating crown above head + Golden sparkles
		addHeadCrown(character, activeFolder, Color3.fromRGB(255, 215, 0), true)
		addBodyEnergyWisps(attRoot, Color3.fromRGB(251, 191, 36), Color3.fromRGB(255, 255, 255), 30, NumberRange.new(2.5, 5.0), {0.3, 1.2, 0.2})

	else
		addBodyEnergyWisps(attRoot, pColor, auraColor, 35, NumberRange.new(3.0, 6.0), {0.4, 1.5, 0.2})
		if rarity >= 1000 then
			addLightPillar(rootPart, activeFolder, pColor)
		end
	end
end

return AuraVisuals
