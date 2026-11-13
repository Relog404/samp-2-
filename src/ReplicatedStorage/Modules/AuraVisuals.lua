-- AuraVisuals.lua
-- Ultra-high density, multi-layered visual effects (VFX) engine for Sol's RNG.
-- Features dense ground shockwaves, concentric rotating magic rings, high-rate ascending body auras,
-- orbital celestial particles, radiant divine wings, animated head halos, and sharp character highlights.

local AuraConfig = require(script.Parent.AuraConfig)

local AuraVisuals = {}

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
	if existing then existing:Destroy() end

	local head = character:FindFirstChild("Head")
	if head then
		local oldBb = head:FindFirstChild("AuraBillboardGui")
		if oldBb then oldBb:Destroy() end
	end

	for _, child in ipairs(character:GetDescendants()) do
		if child.Name == "AuraHighlight" or child.Name == "AuraVFXAttachment" then
			child:Destroy()
		end
	end
end

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

local function createEmitter(parent, props)
	local pe = Instance.new("ParticleEmitter")
	pe.Color = props.Color
	pe.Size = props.Size
	pe.Transparency = props.Transparency
	pe.Lifetime = props.Lifetime
	pe.Rate = props.Rate
	pe.Speed = props.Speed
	pe.SpreadAngle = props.SpreadAngle or Vector2.new(15, 15)
	pe.Acceleration = props.Acceleration or Vector3.new(0, 3, 0)
	pe.Drag = props.Drag or 0.5
	pe.LightEmission = props.LightEmission or 0.45
	pe.LightInfluence = props.LightInfluence or 0.0
	pe.Texture = props.Texture or TEXTURES.Sparkle
	pe.RotSpeed = props.RotSpeed or NumberRange.new(-90, 90)
	pe.Orientation = props.Orientation or Enum.ParticleOrientation.FacingCamera
	pe.EmissionDirection = props.EmissionDirection or Enum.NormalId.Top
	pe.Parent = parent
	return pe
end

-- LAYER 1: Dual Concentric Ground Magic Circles & Expanding Shockwaves
local function addDenseGroundEffects(parentAtt, color, scaleMultiplier)
	local scale = scaleMultiplier or 1.0

	-- Expanding Ground Shockwave Disc
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5 * scale),
			NumberSequenceKeypoint.new(0.5, 4.5 * scale),
			NumberSequenceKeypoint.new(1, 6.0 * scale),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(0.7, 0.35),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.6, 2.2),
		Rate = 12,
		Speed = NumberRange.new(0.2, 0.5),
		SpreadAngle = Vector2.new(0, 0),
		Acceleration = Vector3.new(0, 0.1, 0),
		Drag = 1.0,
		Texture = TEXTURES.Ring,
		RotSpeed = NumberRange.new(35, 70),
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
	})

	-- Rapid Inner Magic Circle
	createEmitter(parentAtt, {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2.0 * scale),
			NumberSequenceKeypoint.new(1, 3.2 * scale),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 0.2),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.0, 1.5),
		Rate = 8,
		Speed = NumberRange.new(0.1, 0.2),
		Texture = TEXTURES.Ring,
		RotSpeed = NumberRange.new(-90, -45),
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
	})

	-- Ground Spark Eruption
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(0.5, 0.8 * scale),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.15, 0.0),
			NumberSequenceKeypoint.new(0.8, 0.2),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.4, 2.2),
		Rate = 35 * scale,
		Speed = NumberRange.new(2.5, 5.5),
		SpreadAngle = Vector2.new(45, 45),
		Acceleration = Vector3.new(0, 5, 0),
		Texture = TEXTURES.Cross,
	})
end

-- LAYER 2: Dense Ascending Body Energy Wisps (Volumetric Flame Wrap)
local function addDenseBodyEnergy(parentAtt, color, secondaryColor, rate, speedRange, sizeRange)
	local secColor = secondaryColor or color
	-- Dense Core Flames
	createEmitter(parentAtt, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(0.4, secColor),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, sizeRange[1] or 0.6),
			NumberSequenceKeypoint.new(0.5, sizeRange[2] or 2.2),
			NumberSequenceKeypoint.new(1, sizeRange[3] or 0.3),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.1, 0.05),
			NumberSequenceKeypoint.new(0.7, 0.25),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.2, 1.8),
		Rate = rate or 65,
		Speed = speedRange or NumberRange.new(4.0, 8.0),
		SpreadAngle = Vector2.new(25, 25),
		Acceleration = Vector3.new(0, 7, 0),
		Texture = TEXTURES.Flame,
	})

	-- Secondary Inner Core Glow
	createEmitter(parentAtt, {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.5, 1.4),
			NumberSequenceKeypoint.new(1, 0.2),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(0.8, 1.4),
		Rate = (rate or 65) * 0.5,
		Speed = NumberRange.new(3.0, 6.0),
		SpreadAngle = Vector2.new(15, 15),
		Acceleration = Vector3.new(0, 5, 0),
		Texture = TEXTURES.Flame,
	})
end

-- LAYER 3: Swirling Orbiting Celestial Star Clusters
local function addDenseOrbitingSparks(parentAtt, color, rate)
	createEmitter(parentAtt, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.5, 1.2),
			NumberSequenceKeypoint.new(1, 0.2),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.0),
			NumberSequenceKeypoint.new(0.15, 0.0),
			NumberSequenceKeypoint.new(0.8, 0.2),
			NumberSequenceKeypoint.new(1, 1.0),
		}),
		Lifetime = NumberRange.new(1.8, 2.8),
		Rate = rate or 45,
		Speed = NumberRange.new(3.5, 7.0),
		SpreadAngle = Vector2.new(80, 80),
		Acceleration = Vector3.new(0, 3, 0),
		RotSpeed = NumberRange.new(-180, 180),
		Texture = TEXTURES.Sparkle,
	})
end

-- LAYER 4: Radiant Divine Angelic Wings (Large, Multi-Layered)
local function addAngelicWings(character, folder, color)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end

	local attWingL = Instance.new("Attachment")
	attWingL.Name = "AuraVFXAttachment"
	attWingL.Position = Vector3.new(-1.4, 0.9, 0.8)
	attWingL.Orientation = Vector3.new(0, 35, 20)
	attWingL.Parent = torso

	local attWingR = Instance.new("Attachment")
	attWingR.Name = "AuraVFXAttachment"
	attWingR.Position = Vector3.new(1.4, 0.9, 0.8)
	attWingR.Orientation = Vector3.new(0, -35, -20)
	attWingR.Parent = torso

	local function makeWingEmitter(parentAtt)
		createEmitter(parentAtt, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 150)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(0.4, 2.8),
				NumberSequenceKeypoint.new(1, 0.4),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(0.15, 0.0),
				NumberSequenceKeypoint.new(0.7, 0.15),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(0.9, 1.6),
			Rate = 60,
			Speed = NumberRange.new(4.0, 8.0),
			SpreadAngle = Vector2.new(20, 20),
			Acceleration = Vector3.new(0, 4, 0),
			Texture = TEXTURES.Flame,
		})
	end

	makeWingEmitter(attWingL)
	makeWingEmitter(attWingR)
end

-- LAYER 4B: Mythic Dragon Serpent & Draconic Flame Wings
local function addDragonWings(character, folder, color)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end

	local attWingL = Instance.new("Attachment")
	attWingL.Name = "AuraVFXAttachment"
	attWingL.Position = Vector3.new(-1.8, 1.2, 0.9)
	attWingL.Orientation = Vector3.new(0, 45, 25)
	attWingL.Parent = torso

	local attWingR = Instance.new("Attachment")
	attWingR.Name = "AuraVFXAttachment"
	attWingR.Position = Vector3.new(1.8, 1.2, 0.9)
	attWingR.Orientation = Vector3.new(0, -45, -25)
	attWingR.Parent = torso

	local function makeDragonWing(att)
		createEmitter(att, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 150)),
				ColorSequenceKeypoint.new(0.4, color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 20, 10)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.5, 3.2),
				NumberSequenceKeypoint.new(1, 0.4),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.5, 0.05),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Lifetime = NumberRange.new(1.0, 1.8),
			Rate = 50,
			Speed = NumberRange.new(3.5, 7.5),
			SpreadAngle = Vector2.new(15, 15),
			Acceleration = Vector3.new(0, 3, 0),
			Texture = TEXTURES.Flame,
		})
	end

	makeDragonWing(attWingL)
	makeDragonWing(attWingR)
end

local function addDragonSerpent(character, folder, color)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not rootPart or not rootPart:IsA("BasePart") then return end

	local angles = { 0, 60, 120, 180, 240, 300 }
	for idx, deg in ipairs(angles) do
		local rad = math.rad(deg)
		local radius = 3.2
		local height = -1.2 + (idx * 0.5)

		local att = Instance.new("Attachment")
		att.Name = "AuraVFXAttachment"
		att.Position = Vector3.new(math.cos(rad) * radius, height, math.sin(rad) * radius)
		att.Parent = rootPart

		createEmitter(att, {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 100)),
				ColorSequenceKeypoint.new(0.5, color),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 20, 10)),
			}),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(0.5, 1.8),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			Transparency = NumberSequence.new(0.1, 1.0),
			Lifetime = NumberRange.new(0.8, 1.4),
			Rate = 22,
			Speed = NumberRange.new(1.0, 2.5),
			SpreadAngle = Vector2.new(20, 20),
			Texture = TEXTURES.Flame,
		})

		createEmitter(att, {
			Color = ColorSequence.new(Color3.fromRGB(255, 180, 40)),
			Size = NumberSequence.new(0.3, 0.05),
			Transparency = NumberSequence.new(0.0, 1.0),
			Lifetime = NumberRange.new(1.0, 1.8),
			Rate = 12,
			Speed = NumberRange.new(1.5, 3.5),
			SpreadAngle = Vector2.new(180, 180),
			Texture = TEXTURES.Sparkle,
		})
	end
end

-- LAYER 4C: Ancient Celestial Turtle Shell & Orbiting Runic Jade Shields
local function addAncientTurtleShell(character, folder, color)
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end

	local attBack = Instance.new("Attachment")
	attBack.Name = "AuraVFXAttachment"
	attBack.Position = Vector3.new(0, 0.2, 1.1)
	attBack.Parent = torso

	createEmitter(attBack, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 255, 230)),
			ColorSequenceKeypoint.new(0.5, color),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 100, 60)),
		}),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2.2),
			NumberSequenceKeypoint.new(0.5, 3.8),
			NumberSequenceKeypoint.new(1, 2.4),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.1),
			NumberSequenceKeypoint.new(1, 0.8),
		}),
		Lifetime = NumberRange.new(1.2, 1.8),
		Rate = 8,
		Speed = NumberRange.new(0.1, 0.3),
		SpreadAngle = Vector2.new(5, 5),
		Texture = TEXTURES.Ring,
		RotSpeed = NumberRange.new(15, 30),
	})
end

local function addOrbitingTurtleShields(character, folder, color)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not rootPart or not rootPart:IsA("BasePart") then return end

	local angles = { 0, 90, 180, 270 }
	for _, deg in ipairs(angles) do
		local rad = math.rad(deg)
		local radius = 3.6

		local att = Instance.new("Attachment")
		att.Name = "AuraVFXAttachment"
		att.Position = Vector3.new(math.cos(rad) * radius, -0.2, math.sin(rad) * radius)
		att.Parent = rootPart

		createEmitter(att, {
			Color = ColorSequence.new(color),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.0),
				NumberSequenceKeypoint.new(0.5, 1.6),
				NumberSequenceKeypoint.new(1, 1.0),
			}),
			Transparency = NumberSequence.new(0.2, 0.8),
			Lifetime = NumberRange.new(1.0, 1.5),
			Rate = 6,
			Speed = NumberRange.new(0.1, 0.2),
			Texture = TEXTURES.Ring,
			RotSpeed = NumberRange.new(45, 90),
		})

		createEmitter(att, {
			Color = ColorSequence.new(Color3.fromRGB(160, 255, 210)),
			Size = NumberSequence.new(0.4, 0.1),
			Transparency = NumberSequence.new(0.1, 1.0),
			Lifetime = NumberRange.new(1.2, 1.8),
			Rate = 14,
			Speed = NumberRange.new(1.2, 2.8),
			SpreadAngle = Vector2.new(15, 15),
			Acceleration = Vector3.new(0, 2.5, 0),
			Texture = TEXTURES.Cross,
		})
	end
end

-- LAYER 5: Animated Head Halos & Celestial Crowns
local function addHeadCrown(character, folder, color, isVIP)
	local head = character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	local attCrown = Instance.new("Attachment")
	attCrown.Name = "AuraVFXAttachment"
	attCrown.Position = Vector3.new(0, 1.8, 0)
	attCrown.Parent = head

	-- Rotating Halo Ring
	createEmitter(attCrown, {
		Color = ColorSequence.new(color),
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.8),
			NumberSequenceKeypoint.new(0.5, 2.6),
			NumberSequenceKeypoint.new(1, 1.8),
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.5),
		}),
		Lifetime = NumberRange.new(1.2, 1.8),
		Rate = 6,
		Speed = NumberRange.new(0, 0.1),
		SpreadAngle = Vector2.new(0, 0),
		Acceleration = Vector3.new(0, 0, 0),
		RotSpeed = NumberRange.new(60, 120),
		Texture = TEXTURES.Ring,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		EmissionDirection = Enum.NormalId.Top,
	})

	-- Halo Star Burst
	createEmitter(attCrown, {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Size = NumberSequence.new(0.5, 0.1),
		Transparency = NumberSequence.new(0.05, 1.0),
		Lifetime = NumberRange.new(0.8, 1.5),
		Rate = 20,
		Speed = NumberRange.new(0.8, 2.2),
		SpreadAngle = Vector2.new(180, 180),
		Texture = TEXTURES.Cross,
	})
end

-- LAYER 6: Towering Vertical Pillar of Divine Light (For Legendary+)
local function addLightPillar(rootPart, activeFolder, color)
	local attBottom = Instance.new("Attachment")
	attBottom.Name = "AuraVFXAttachment"
	attBottom.Position = Vector3.new(0, -2.8, 0)
	attBottom.Parent = rootPart

	local attTop = Instance.new("Attachment")
	attTop.Name = "AuraVFXAttachment"
	attTop.Position = Vector3.new(0, 15, 0)
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
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.05),
		NumberSequenceKeypoint.new(1, 0.95),
	})
	beam.Width0 = 4.2
	beam.Width1 = 7.0
	beam.LightEmission = 1.0
	beam.TextureSpeed = 2.2
	beam.Texture = TEXTURES.Flame
	beam.Parent = activeFolder
end

-- LAYER 7: Modern Overhead Billboard Title
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
	stroke.Transparency = 0.2
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
-- MAIN ENTRY POINT
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

	local attFoot = Instance.new("Attachment")
	attFoot.Name = "AuraVFXAttachment"
	attFoot.Position = Vector3.new(0, -2.7, 0)
	attFoot.Parent = rootPart

	local attRoot = Instance.new("Attachment")
	attRoot.Name = "AuraVFXAttachment"
	attRoot.Position = Vector3.new(0, 0, 0)
	attRoot.Parent = rootPart

	-- Character Highlight (vivid neon glow)
	local highlight = Instance.new("Highlight")
	highlight.Name = "AuraHighlight"
	highlight.Adornee = character
	highlight.OutlineColor = auraColor
	highlight.OutlineTransparency = 0.08
	highlight.FillColor = auraColor
	highlight.FillTransparency = 0.88
	highlight.Parent = activeFolder

	-- Dynamic Light
	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light.Color = auraColor
	light.Range = (rarity >= 10000 or auraData.IsCrafted) and 18 or 14
	light.Brightness = (rarity >= 10000 or auraData.IsCrafted) and 1.4 or 1.0
	light.Shadows = false
	light.Parent = attRoot

	createOverheadGui(character, auraData, isVIP or false)

	-- Always add dense ground runes & orbital sparkles
	local groundScale = (rarity >= 10000) and 1.5 or 1.1
	addDenseGroundEffects(attFoot, pColor, groundScale)
	addDenseOrbitingSparks(attRoot, pColor, (rarity >= 1000) and 55 or 25)

	local shape = auraData.ParticleShape or "Sparks"

	if shape == "Dust" or shape == "Sparks" then
		addDenseBodyEnergy(attRoot, pColor, auraColor, 40, NumberRange.new(2.0, 4.5), {0.3, 1.2, 0.2})

	elseif shape == "Leaves" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(160, 240, 100), 50, NumberRange.new(2.5, 5.5), {0.4, 1.6, 0.2})

	elseif shape == "Flame" or shape == "Embers" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(255, 220, 120), 75, NumberRange.new(4.5, 9.0), {0.5, 2.2, 0.3})

	elseif shape == "Sparkles" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(255, 255, 200), 65, NumberRange.new(4.0, 8.0), {0.5, 2.0, 0.3})
		addHeadCrown(character, activeFolder, pColor, false)

	elseif shape == "Shards" or shape == "Frost" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(180, 230, 255), 60, NumberRange.new(3.5, 7.5), {0.4, 1.8, 0.3})
		createEmitter(attRoot, {
			Color = ColorSequence.new(pColor),
			Size = NumberSequence.new(0.4, 1.2),
			Transparency = NumberSequence.new(0.1, 1.0),
			Lifetime = NumberRange.new(1.5, 2.5),
			Rate = 45,
			Speed = NumberRange.new(3.0, 6.5),
			SpreadAngle = Vector2.new(50, 50),
			RotSpeed = NumberRange.new(-180, 180),
			Texture = TEXTURES.Shard,
		})

	elseif shape == "FireColumn" or shape == "Hellfire" or shape == "LavaTide" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(255, 40, 20), pColor, 100, NumberRange.new(6.0, 12.0), {0.8, 3.0, 0.4})
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "Sunburst" or shape == "EclipseCorona" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(255, 180, 40), Color3.fromRGB(255, 255, 255), 110, NumberRange.new(5.5, 11.0), {0.8, 3.2, 0.4})
		addHeadCrown(character, activeFolder, pColor, false)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "MoonStars" or shape == "NebulaSpiral" or shape == "Singularity" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(240, 180, 255), 90, NumberRange.new(4.0, 8.5), {0.7, 2.8, 0.4})
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "DivineHalo" or shape == "TimeClock" or shape == "PrismaticGlitch" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(255, 255, 255), 110, NumberRange.new(5.0, 10.0), {0.8, 3.0, 0.4})
		addAngelicWings(character, activeFolder, pColor)
		addHeadCrown(character, activeFolder, pColor, false)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "CrownGlow" then
		addHeadCrown(character, activeFolder, Color3.fromRGB(255, 215, 0), true)
		addDenseBodyEnergy(attRoot, Color3.fromRGB(251, 191, 36), Color3.fromRGB(255, 255, 255), 60, NumberRange.new(3.5, 7.0), {0.4, 1.8, 0.3})

	elseif shape == "Dragon" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(244, 63, 94), Color3.fromRGB(251, 191, 36), 75, NumberRange.new(5.0, 9.0), {0.6, 2.2, 0.3})
		addDragonSerpent(character, activeFolder, pColor)
		addDragonWings(character, activeFolder, pColor)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "Turtle" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(16, 185, 129), Color3.fromRGB(52, 211, 153), 60, NumberRange.new(4.0, 8.0), {0.5, 2.0, 0.3})
		addAncientTurtleShell(character, activeFolder, pColor)
		addOrbitingTurtleShields(character, activeFolder, pColor)
		addLightPillar(rootPart, activeFolder, pColor)

	else
		addDenseBodyEnergy(attRoot, pColor, auraColor, 55, NumberRange.new(4.0, 8.0), {0.5, 2.0, 0.3})
		if rarity >= 1000 then
			addLightPillar(rootPart, activeFolder, pColor)
		end
	end
end

-- =============================================================================
-- PVP COMBAT SKILL VISUAL EFFECTS & FLOATING DAMAGE NUMBERS
-- =============================================================================

function AuraVisuals.ShowDamageNumber(targetChar, amount, isCrit, color)
	local head = targetChar and targetChar:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	local bb = Instance.new("BillboardGui")
	bb.Name = "DamageNumberGui"
	bb.Size = UDim2.new(0, 140, 0, 40)
	bb.StudsOffset = Vector3.new(math.random(-1, 1), 2.5, math.random(-1, 1))
	bb.AlwaysOnTop = true
	bb.MaxDistance = 100
	bb.Parent = head

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = isCrit and 22 or 17
	lbl.TextColor3 = isCrit and Color3.fromRGB(250, 204, 21) or (color or Color3.fromRGB(239, 68, 68))
	lbl.Text = isCrit and string.format("CRIT! -%d", amount) or string.format("-%d", amount)
	lbl.TextStrokeColor3 = Color3.fromRGB(15, 15, 20)
	lbl.TextStrokeTransparency = 0.1
	lbl.Parent = bb

	local tweenService = game:GetService("TweenService")
	tweenService:Create(bb, TweenInfo.new(0.9, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		StudsOffset = bb.StudsOffset + Vector3.new(0, 2.2, 0)
	}):Play()

	task.delay(0.9, function()
		if bb and bb.Parent then bb:Destroy() end
	end)
end

-- Skill 1: Aura Strike (Laser Projectile Slash)
function AuraVisuals.PlaySkill1VFX(casterChar, targetChar, color)
	local casterRoot = casterChar and casterChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if not casterRoot or not targetRoot then return end

	local beamPart = Instance.new("Part")
	beamPart.Size = Vector3.new(0.8, 0.8, (casterRoot.Position - targetRoot.Position).Magnitude)
	beamPart.CFrame = CFrame.new(casterRoot.Position:Lerp(targetRoot.Position, 0.5), targetRoot.Position)
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Material = Enum.Material.Neon
	beamPart.Color = color or Color3.fromRGB(56, 189, 248)
	beamPart.Transparency = 0.1
	beamPart.Parent = game:GetService("Workspace")

	local tweenService = game:GetService("TweenService")
	tweenService:Create(beamPart, TweenInfo.new(0.25), { Transparency = 1.0, Size = Vector3.new(0.1, 0.1, beamPart.Size.Z) }):Play()
	task.delay(0.25, function()
		if beamPart and beamPart.Parent then beamPart:Destroy() end
	end)
end

-- Skill 2: Elemental Burst (Ground Shockwave Eruption)
function AuraVisuals.PlaySkill2VFX(targetChar, color)
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.4, 4, 4)
	ring.Orientation = Vector3.new(0, 0, 90)
	ring.Position = targetRoot.Position - Vector3.new(0, 2.5, 0)
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = color or Color3.fromRGB(245, 158, 11)
	ring.Transparency = 0.2
	ring.Parent = game:GetService("Workspace")

	local tweenService = game:GetService("TweenService")
	tweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.4, 18, 18),
		Transparency = 1.0,
	}):Play()

	task.delay(0.4, function()
		if ring and ring.Parent then ring:Destroy() end
	end)
end

-- Skill 3: Celestial Ultimate (Massive Orbital Sky Beam)
function AuraVisuals.PlaySkill3VFX(targetChar, color)
	local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local pillar = Instance.new("Part")
	pillar.Shape = Enum.PartType.Cylinder
	pillar.Size = Vector3.new(120, 8, 8)
	pillar.Orientation = Vector3.new(0, 0, 90)
	pillar.Position = targetRoot.Position + Vector3.new(0, 45, 0)
	pillar.Anchored = true
	pillar.CanCollide = false
	pillar.Material = Enum.Material.Neon
	pillar.Color = color or Color3.fromRGB(250, 204, 21)
	pillar.Transparency = 0.05
	pillar.Parent = game:GetService("Workspace")

	local tweenService = game:GetService("TweenService")
	tweenService:Create(pillar, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = Vector3.new(120, 24, 24),
		Transparency = 1.0,
	}):Play()

	task.delay(0.6, function()
		if pillar and pillar.Parent then pillar:Destroy() end
	end)
end

return AuraVisuals
