-- ==============================================================================
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

installModule("AuraConfig", [===[-- AuraConfig.lua
-- Central configuration for all Auras, Rarities, Colors, Visual Styles, and Crafting Recipes in Sol's RNG game.

local AuraConfig = {}

-- Visual Cutscene Tiers
AuraConfig.CutsceneTier = {
	Normal = "Normal",
	Rare = "Rare",
	Legendary = "Legendary",
	Mythic = "Mythic",
	Godly = "Godly",
}

-- Game Settings & Balance
AuraConfig.Settings = {
	BaseRollCooldown = 2.0,      -- Seconds between manual rolls
	FastRollCooldown = 0.5,      -- Fast roll mode cooldown
	AutoRollInterval = 2.2,      -- Auto roll interval
	DefaultStorage = 20,         -- Base inventory slots
	ExtraStorageBonus = 30,      -- Bonus slots from gamepass or upgrade
	MaxStorageLimit = 100,       -- Max inventory limit
	
	-- Base coins awarded per roll based on tier
	CoinsPerRoll = {
		Common = 5,
		Good = 10,
		Rare = 25,
		Epic = 50,
		Legendary = 150,
		Mythic = 500,
		Godly = 2000,
		Crafted = 1000,
	},

	-- Global broadcast threshold (1 in X)
	GlobalBroadcastThreshold = 10000,

	-- Gamepass IDs (Replace with your actual Roblox Gamepass IDs when published)
	GamepassIds = {
		X2Luck = 0,         -- e.g. 12345678
		AutoRoll = 0,       -- e.g. 12345679
		ExtraStorage = 0,   -- e.g. 12345680
		VIP = 0,            -- e.g. 12345681
	},

	-- DevProduct IDs for instant boosts (Optional)
	DevProductIds = {
		LuckPotion10Min = 0,
		Instant1000Coins = 0,
	}
}

-- Catalog of all Rollable and Special Auras
AuraConfig.Auras = {
	-- COMMON TIER (1 in 2 to 1 in 4)
	Common = {
		Id = "Common",
		Name = "Common",
		Rarity = 2,
		Tier = "Common",
		Color = Color3.fromRGB(220, 220, 225),
		Description = "A faint, gentle aura of pure simple energy.",
		Cutscene = AuraConfig.CutsceneTier.Normal,
		ParticleColor = Color3.fromRGB(230, 230, 240),
		ParticleShape = "Dust",
	},
	Uncommon = {
		Id = "Uncommon",
		Name = "Uncommon",
		Rarity = 4,
		Tier = "Common",
		Color = Color3.fromRGB(160, 230, 160),
		Description = "Subtle green sparks glowing with mild vitality.",
		Cutscene = AuraConfig.CutsceneTier.Normal,
		ParticleColor = Color3.fromRGB(140, 240, 140),
		ParticleShape = "Sparks",
	},

	-- GOOD TIER (1 in 8 to 1 in 16)
	Natural = {
		Id = "Natural",
		Name = "Natural",
		Rarity = 8,
		Tier = "Good",
		Color = Color3.fromRGB(72, 199, 116),
		Description = "Leaves and emerald orbs dancing with forest vitality.",
		Cutscene = AuraConfig.CutsceneTier.Normal,
		ParticleColor = Color3.fromRGB(60, 220, 100),
		ParticleShape = "Leaves",
	},
	Rare = {
		Id = "Rare",
		Name = "Rare",
		Rarity = 16,
		Tier = "Good",
		Color = Color3.fromRGB(56, 189, 248),
		Description = "A vivid sky-blue aura shimmering with rising azure flames.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(70, 200, 255),
		ParticleShape = "Flame",
	},

	-- RARE TIER (1 in 32 to 1 in 64)
	Divinus = {
		Id = "Divinus",
		Name = "Divinus",
		Rarity = 32,
		Tier = "Rare",
		Color = Color3.fromRGB(250, 204, 21),
		Description = "Holy golden sparkles blessing the bearer with light.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(255, 220, 50),
		ParticleShape = "Sparkles",
	},
	Crystallized = {
		Id = "Crystallized",
		Name = "Crystallized",
		Rarity = 64,
		Tier = "Rare",
		Color = Color3.fromRGB(6, 182, 212),
		Description = "Sharp diamond shards and icy cyan glow.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(50, 230, 255),
		ParticleShape = "Shards",
	},

	-- EPIC TIER (1 in 150 to 1 in 400)
	Topaz = {
		Id = "Topaz",
		Name = "Topaz",
		Rarity = 150,
		Tier = "Epic",
		Color = Color3.fromRGB(245, 158, 11),
		Description = "Deep amber embers floating in orbital harmony.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(250, 170, 20),
		ParticleShape = "Embers",
	},
	Glacier = {
		Id = "Glacier",
		Name = "Glacier",
		Rarity = 300,
		Tier = "Epic",
		Color = Color3.fromRGB(147, 197, 253),
		Description = "An arctic chill radiating sub-zero frost and blizzard mists.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(180, 220, 255),
		ParticleShape = "Frost",
	},
	Wind = {
		Id = "Wind",
		Name = "Wind",
		Rarity = 400,
		Tier = "Epic",
		Color = Color3.fromRGB(167, 243, 208),
		Description = "A raging cyclone spiral enveloping the character in swift breezes.",
		Cutscene = AuraConfig.CutsceneTier.Rare,
		ParticleColor = Color3.fromRGB(180, 255, 220),
		ParticleShape = "Vortex",
	},

	-- LEGENDARY TIER (1 in 1,000 to 1 in 5,000)
	Ruby = {
		Id = "Ruby",
		Name = "Ruby",
		Rarity = 1000,
		Tier = "Legendary",
		Color = Color3.fromRGB(239, 68, 68),
		Description = "Blazing crimson volcanic flame pillar ascending to the heavens.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(255, 50, 50),
		ParticleShape = "FireColumn",
	},
	Undead = {
		Id = "Undead",
		Name = "Undead",
		Rarity = 2000,
		Tier = "Legendary",
		Color = Color3.fromRGB(16, 185, 129),
		Description = "Ominous necrotic souls and radioactive green mist rising from below.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(20, 230, 140),
		ParticleShape = "Souls",
	},
	Solar = {
		Id = "Solar",
		Name = "Solar",
		Rarity = 5000,
		Tier = "Legendary",
		Color = Color3.fromRGB(249, 115, 22),
		Description = "A blinding solar corona flaring with pure thermonuclear radiance.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(255, 140, 30),
		ParticleShape = "Sunburst",
	},

	-- MYTHIC TIER (1 in 10,000 to 1 in 100,000)
	Lunar = {
		Id = "Lunar",
		Name = "Lunar",
		Rarity = 10000,
		Tier = "Mythic",
		Color = Color3.fromRGB(139, 92, 246),
		Description = "A mystical crescent night sky with floating celestial starlight.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(170, 120, 255),
		ParticleShape = "MoonStars",
	},
	Poseidon = {
		Id = "Poseidon",
		Name = "Poseidon",
		Rarity = 25000,
		Tier = "Mythic",
		Color = Color3.fromRGB(2, 132, 199),
		Description = "Lord of the deep seas summoning aquatic geysers and roaring tidal crests.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(20, 170, 255),
		ParticleShape = "Tsunami",
	},
	Hades = {
		Id = "Hades",
		Name = "Hades",
		Rarity = 50000,
		Tier = "Mythic",
		Color = Color3.fromRGB(220, 38, 38),
		Description = "Underworld hellfire and demonic dark red lightning crashing around.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(240, 20, 20),
		ParticleShape = "Hellfire",
	},
	Galaxy = {
		Id = "Galaxy",
		Name = "Galaxy",
		Rarity = 100000,
		Tier = "Mythic",
		Color = Color3.fromRGB(99, 102, 241),
		Description = "A deep cosmic spiral galaxy with swirling nebulae and newborn stars.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(130, 140, 255),
		ParticleShape = "NebulaSpiral",
	},

	-- GODLY & CELESTIAL TIER (1 in 250,000 to 1 in 1,000,000)
	Archangel = {
		Id = "Archangel",
		Name = "Archangel",
		Rarity = 250000,
		Tier = "Godly",
		Color = Color3.fromRGB(252, 211, 77),
		Description = "Six wings of divine light, holy choir resonance and celestial halos.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 235, 120),
		ParticleShape = "DivineHalo",
	},
	ExoticApex = {
		Id = "ExoticApex",
		Name = "Exotic: Apex",
		Rarity = 500000,
		Tier = "Godly",
		Color = Color3.fromRGB(236, 72, 153),
		Description = "Reality-bending prismatic chromatic spectrum shifting through all hues.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 90, 190),
		ParticleShape = "PrismaticGlitch",
	},
	AbyssalHunter = {
		Id = "AbyssalHunter",
		Name = "Abyssal Hunter",
		Rarity = 1000000,
		Tier = "Godly",
		Color = Color3.fromRGB(124, 58, 237),
		Description = "A singularity black hole radiating neon violet cosmic lightning bolts.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(160, 80, 255),
		ParticleShape = "Singularity",
	},

	-- CRAFTED / SPECIAL AURAS
	Eclipse = {
		Id = "Eclipse",
		Name = "Eclipse",
		Rarity = 0, -- Crafted only
		Tier = "Crafted",
		Color = Color3.fromRGB(245, 158, 11),
		Description = "The convergence of Solar and Lunar energies. Sun and Moon orbital harmony.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 180, 40),
		ParticleShape = "EclipseCorona",
		IsCrafted = true,
	},
	Chronos = {
		Id = "Chronos",
		Name = "Chronos",
		Rarity = 0,
		Tier = "Crafted",
		Color = Color3.fromRGB(6, 182, 212),
		Description = "Time bends to your command. Spinning clock dials and golden time gears.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(80, 230, 255),
		ParticleShape = "TimeClock",
		IsCrafted = true,
	},
	HellforgedLeviathan = {
		Id = "HellforgedLeviathan",
		Name = "Hellforged Leviathan",
		Rarity = 0,
		Tier = "Crafted",
		Color = Color3.fromRGB(185, 28, 28),
		Description = "Boiling magma geysers and abyss waters clashing in an unstoppable storm.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(240, 60, 30),
		ParticleShape = "LavaTide",
		IsCrafted = true,
	},
	VIPCrown = {
		Id = "VIPCrown",
		Name = "VIP Crown",
		Rarity = 0,
		Tier = "VIP",
		Color = Color3.fromRGB(251, 191, 36),
		Description = "Exclusive regal golden crown aura gifted only to prestigious VIP supporters.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(255, 215, 0),
		ParticleShape = "CrownGlow",
		IsSpecial = true,
	}
}

-- CRAFTING RECIPES CATALOG
AuraConfig.Recipes = {
	{
		Id = "Recipe_Eclipse",
		ResultType = "Aura",
		ResultId = "Eclipse",
		Name = "Eclipse Aura",
		Tier = "Crafted",
		Color = Color3.fromRGB(245, 158, 11),
		Description = "Synthesize the cosmic dance of Sun and Moon into a legendary dual aura.",
		Ingredients = {
			{ AuraId = "Solar", Count = 1 },
			{ AuraId = "Lunar", Count = 1 },
			{ AuraId = "Rare", Count = 3 },
		},
	},
	{
		Id = "Recipe_LuckGauntlet",
		ResultType = "Gear",
		ResultId = "LuckGauntlet",
		Name = "Luck Gauntlet (Gear)",
		Tier = "Gear",
		Color = Color3.fromRGB(234, 179, 8),
		Description = "Permanent equippable gear granting a passive +50% Luck Multiplier (x1.5).",
		LuckBonus = 1.5,
		Ingredients = {
			{ AuraId = "Topaz", Count = 1 },
			{ AuraId = "Divinus", Count = 2 },
			{ AuraId = "Ruby", Count = 1 },
		},
	},
	{
		Id = "Recipe_FortuneElixir",
		ResultType = "Potion",
		ResultId = "FortuneElixir",
		Name = "Fortune Elixir (10m)",
		Tier = "Potion",
		Color = Color3.fromRGB(34, 197, 94),
		Description = "A shimmering brew granting 2x Luck for 10 minutes upon creation.",
		Duration = 600,
		LuckBonus = 2.0,
		Ingredients = {
			{ AuraId = "Crystallized", Count = 2 },
			{ AuraId = "Uncommon", Count = 4 },
			{ AuraId = "Natural", Count = 2 },
		},
	},
	{
		Id = "Recipe_Chronos",
		ResultType = "Aura",
		ResultId = "Chronos",
		Name = "Chronos Aura",
		Tier = "Godly",
		Color = Color3.fromRGB(6, 182, 212),
		Description = "Weave the fabric of spacetime using celestial remnants.",
		Ingredients = {
			{ AuraId = "Galaxy", Count = 1 },
			{ AuraId = "Archangel", Count = 1 },
			{ AuraId = "Glacier", Count = 2 },
		},
	},
	{
		Id = "Recipe_HellforgedLeviathan",
		ResultType = "Aura",
		ResultId = "HellforgedLeviathan",
		Name = "Hellforged Leviathan",
		Tier = "Godly",
		Color = Color3.fromRGB(185, 28, 28),
		Description = "Combine underworld hellfire with deep sea titans.",
		Ingredients = {
			{ AuraId = "Hades", Count = 1 },
			{ AuraId = "Poseidon", Count = 1 },
			{ AuraId = "Ruby", Count = 2 },
		},
	},
}

-- Pre-sorted list of rollable auras ordered by rarity descending (hardest first)
AuraConfig.RollableAuras = {}
for id, aura in pairs(AuraConfig.Auras) do
	if aura.Rarity and aura.Rarity > 0 then
		table.insert(AuraConfig.RollableAuras, aura)
	end
end
table.sort(AuraConfig.RollableAuras, function(a, b)
	return a.Rarity > b.Rarity
end)

-- Helper to format numbers like 1,000,000
function AuraConfig.FormatNumber(n)
	local formatted = tostring(n)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

-- Helper to format Rarity string
function AuraConfig.FormatRarity(rarity)
	if not rarity or rarity <= 0 then
		return "Special"
	end
	return "1 in " .. AuraConfig.FormatNumber(rarity)
end

-- Helper to get tier color
function AuraConfig.GetTierColor(tier)
	if tier == "Common" then
		return Color3.fromRGB(220, 220, 225)
	elseif tier == "Good" then
		return Color3.fromRGB(72, 199, 116)
	elseif tier == "Rare" then
		return Color3.fromRGB(56, 189, 248)
	elseif tier == "Epic" then
		return Color3.fromRGB(168, 85, 247)
	elseif tier == "Legendary" then
		return Color3.fromRGB(239, 68, 68)
	elseif tier == "Mythic" then
		return Color3.fromRGB(217, 70, 239)
	elseif tier == "Godly" then
		return Color3.fromRGB(250, 204, 21)
	elseif tier == "Crafted" then
		return Color3.fromRGB(245, 158, 11)
	elseif tier == "Gear" then
		return Color3.fromRGB(234, 179, 8)
	elseif tier == "Potion" then
		return Color3.fromRGB(34, 197, 94)
	elseif tier == "VIP" then
		return Color3.fromRGB(251, 191, 36)
	end
	return Color3.fromRGB(255, 255, 255)
end

return AuraConfig
]===])
installModule("AuraVisuals", [===[-- AuraVisuals.lua
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
]===])
installModule("SoundEffects", [===[-- SoundEffects.lua
-- Audio manager for Sol's RNG game.

local SoundEffects = {}

local SOUND_IDS = {
	Click = "rbxasset://sounds/electronicpingshort.wav",
	Spin = "rbxasset://sounds/action_footstep_plastic.mp3",
	RevealCommon = "rbxasset://sounds/snap.mp3",
	RevealRare = "rbxassetid://9114221192",      -- Magical high bell chime
	RevealLegendary = "rbxassetid://9114220524", -- Dramatic fanfare
	RevealMythic = "rbxassetid://9114222384",    -- Celestial blast / angelic chord
	RevealGodly = "rbxassetid://9114223175",     -- Deep cosmic thunder resonance
	Craft = "rbxassetid://9114221580",           -- Anvil clang & magical burst
	Equip = "rbxasset://sounds/uianimation.mp3",
}

local soundFolder = nil

local function getSoundFolder()
	if soundFolder and soundFolder.Parent then
		return soundFolder
	end
	local workspace = game:GetService("Workspace")
	local existing = workspace:FindFirstChild("RNG_SoundFolder")
	if existing and existing:IsA("Folder") then
		soundFolder = existing
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = "RNG_SoundFolder"
	folder.Parent = workspace
	soundFolder = folder
	return folder
end

function SoundEffects.Play(soundKey, volume, playbackSpeed)
	local assetId = SOUND_IDS[soundKey] or SOUND_IDS.Click
	local folder = getSoundFolder()

	local sound = Instance.new("Sound")
	sound.SoundId = assetId
	sound.Volume = volume or 0.8
	sound.PlaybackSpeed = playbackSpeed or 1.0
	sound.PlayOnRemove = false
	sound.Parent = folder

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	sound:Play()

	-- Safety cleanup
	task.delay(5, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

return SoundEffects
]===])
local craftSetupModule = installModule("CraftingStationSetup", [===[--!strict
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
]===])

-- 2. Build Map Environment & Lighting
pcall(function()
	local craftSetup = require(craftSetupModule)
	craftSetup.BuildMap()
end)

-- 3. Install Server Script in ServerScriptService
local existingServerScript = ServerScriptService:FindFirstChild("RNGServer")
if existingServerScript and existingServerScript:IsA("Script") then
	existingServerScript.Source = [===[-- RNGServer.server.lua
-- Core game server manager for Sol's RNG game.
-- Handles Roll mechanics, Inventories, Crafting, Gamepasses, Leaderstats, and Data Saving.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")

-- Ensure ReplicatedStorage modules are accessible
local AuraRNGFolder = ReplicatedStorage:FindFirstChild("AuraRNG")
if not AuraRNGFolder then
	AuraRNGFolder = Instance.new("Folder")
	AuraRNGFolder.Name = "AuraRNG"
	AuraRNGFolder.Parent = ReplicatedStorage
end

local EventsFolder = AuraRNGFolder:FindFirstChild("Events")
if not EventsFolder then
	EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = AuraRNGFolder
end

-- Helper to find or create RemoteEvent/RemoteFunction
local function getRemoteEvent(name)
	local existing = EventsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = EventsFolder
	return event
end

local function getRemoteFunction(name)
	local existing = EventsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end
	local func = Instance.new("RemoteFunction")
	func.Name = name
	func.Parent = EventsFolder
	return func
end

local RollRequestFunc = getRemoteFunction("RollRequest")
local CraftAuraFunc = getRemoteFunction("CraftAura")
local EquipAuraEvent = getRemoteEvent("EquipAura")
local DeleteAuraEvent = getRemoteEvent("DeleteAura")
local SetAutoDeleteEvent = getRemoteEvent("SetAutoDelete")
local ToggleTestPerkEvent = getRemoteEvent("ToggleTestPerk")
local DataSyncEvent = getRemoteEvent("DataSync")
local GlobalAnnouncementEvent = getRemoteEvent("GlobalAnnouncement")

-- Require shared modules
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")
local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local AuraVisuals = require(ModulesFolder:WaitForChild("AuraVisuals"))

-- Auto-build base platform, spawn location, and crafting altar if not already present
task.spawn(function()
	pcall(function()
		local setupModule = ModulesFolder:FindFirstChild("CraftingStationSetup")
		if setupModule and not game:GetService("Workspace"):FindFirstChild("RNG_Platform") then
			local CraftingStationSetup = require(setupModule)
			CraftingStationSetup.BuildMap()
		end
	end)
end)

-- Optional DataStore setup with safe fallback for local Studio testing
local DATA_STORE_KEY = "SolsRNG_PlayerData_v1"
local playerDataStore = nil
pcall(function()
	playerDataStore = DataStoreService:GetDataStore(DATA_STORE_KEY)
end)

-- In-memory session store: Player -> Data table
local sessionData = {}
local lastRollTime = {}

-- Calculate active luck for a player
local function calculateLuck(player, data)
	local luck = 1.0

	-- x2 Luck Gamepass or Test Perk
	if data.Gamepasses.X2Luck or data.TestPerks.X2Luck then
		luck = luck * 2.0
	end

	-- VIP Gamepass or Test Perk (x1.5 Luck)
	if data.Gamepasses.VIP or data.TestPerks.VIP then
		luck = luck * 1.5
	end

	-- Crafted Luck Gauntlet Gear (+50% Luck)
	if data.EquippedGear == "LuckGauntlet" then
		luck = luck * 1.5
	end

	-- Active Fortune Elixir Potion (x2 Luck)
	if data.PotionExpiry and os.time() < data.PotionExpiry then
		luck = luck * 2.0
	end

	return luck
end

-- Calculate current inventory item count
local function getInventoryCount(data)
	local count = 0
	for _, qty in pairs(data.Inventory) do
		count = count + qty
	end
	return count
end

-- Sync full data to client
local function syncClient(player)
	local data = sessionData[player]
	if not data then return end

	local currentLuck = calculateLuck(player, data)

	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rollsVal = leaderstats:FindFirstChild("Rolls")
		if rollsVal and rollsVal:IsA("IntValue") then
			rollsVal.Value = data.Rolls or 0
		end

		local bestVal = leaderstats:FindFirstChild("Best Aura")
		if bestVal and bestVal:IsA("StringValue") then
			bestVal.Value = data.BestAura or "None"
		end

		local coinsVal = leaderstats:FindFirstChild("Coins")
		if coinsVal and coinsVal:IsA("IntValue") then
			coinsVal.Value = data.Coins or 0
		end

		local luckVal = leaderstats:FindFirstChild("Luck")
		if luckVal and luckVal:IsA("NumberValue") then
			luckVal.Value = currentLuck
		end
	end

	-- Calculate max storage
	local maxStorage = AuraConfig.Settings.DefaultStorage
	if data.Gamepasses.ExtraStorage or data.TestPerks.ExtraStorage then
		maxStorage = maxStorage + AuraConfig.Settings.ExtraStorageBonus
	end
	data.MaxStorage = maxStorage

	DataSyncEvent:FireClient(player, {
		Rolls = data.Rolls,
		Coins = data.Coins,
		BestAura = data.BestAura,
		BestRarity = data.BestRarity,
		EquippedAura = data.EquippedAura,
		EquippedGear = data.EquippedGear,
		Inventory = data.Inventory,
		MaxStorage = data.MaxStorage,
		AutoDeleteThreshold = data.AutoDeleteThreshold,
		PotionExpiry = data.PotionExpiry,
		Gamepasses = data.Gamepasses,
		TestPerks = data.TestPerks,
		CurrentLuck = currentLuck,
	})
end

-- Save player data safely
local function savePlayerData(player)
	local data = sessionData[player]
	if not data or not playerDataStore then return end

	local success, err = pcall(function()
		local toSave = {
			Rolls = data.Rolls,
			Coins = data.Coins,
			BestAura = data.BestAura,
			BestRarity = data.BestRarity,
			EquippedAura = data.EquippedAura,
			EquippedGear = data.EquippedGear,
			Inventory = data.Inventory,
			AutoDeleteThreshold = data.AutoDeleteThreshold,
			PotionExpiry = data.PotionExpiry,
			Gamepasses = data.Gamepasses,
		}
		playerDataStore:SetAsync(tostring(player.UserId), toSave)
	end)

	if not success then
		warn(string.format("[RNG Server] Failed to save data for %s: %s", player.Name, tostring(err)))
	end
end

-- Load player data
local function loadPlayerData(player)
	local defaultData = {
		Rolls = 0,
		Coins = 100,
		BestAura = "None",
		BestRarity = 1,
		EquippedAura = "None",
		EquippedGear = "None",
		Inventory = {
			Common = 1,
		},
		MaxStorage = AuraConfig.Settings.DefaultStorage,
		AutoDeleteThreshold = 0,
		PotionExpiry = 0,
		Gamepasses = {
			X2Luck = false,
			AutoRoll = false,
			ExtraStorage = false,
			VIP = false,
		},
		TestPerks = {
			X2Luck = false,
			AutoRoll = false,
			ExtraStorage = false,
			VIP = false,
		},
	}

	if playerDataStore then
		local success, saved = pcall(function()
			return playerDataStore:GetAsync(tostring(player.UserId))
		end)
		if success and type(saved) == "table" then
			for k, v in pairs(saved) do
				defaultData[k] = v
			end
		end
	end

	-- Check real Gamepass ownership from Roblox API
	pcall(function()
		local gp = AuraConfig.Settings.GamepassIds
		if gp.X2Luck and gp.X2Luck > 0 then
			defaultData.Gamepasses.X2Luck = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.X2Luck)
		end
		if gp.AutoRoll and gp.AutoRoll > 0 then
			defaultData.Gamepasses.AutoRoll = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.AutoRoll)
		end
		if gp.ExtraStorage and gp.ExtraStorage > 0 then
			defaultData.Gamepasses.ExtraStorage = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.ExtraStorage)
		end
		if gp.VIP and gp.VIP > 0 then
			defaultData.Gamepasses.VIP = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.VIP)
		end
	end)

	sessionData[player] = defaultData
	syncClient(player)
end

-- Initialize player leaderstats and character setup
local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local rolls = Instance.new("IntValue")
	rolls.Name = "Rolls"
	rolls.Value = 0
	rolls.Parent = leaderstats

	local bestAura = Instance.new("StringValue")
	bestAura.Name = "Best Aura"
	bestAura.Value = "None"
	bestAura.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 100
	coins.Parent = leaderstats

	local luck = Instance.new("NumberValue")
	luck.Name = "Luck"
	luck.Value = 1.0
	luck.Parent = leaderstats

	loadPlayerData(player)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		local data = sessionData[player]
		if data and data.EquippedAura and data.EquippedAura ~= "None" then
			local isVIP = (data.Gamepasses.VIP or data.TestPerks.VIP)
			AuraVisuals.ApplyAura(character, data.EquippedAura, isVIP)
		end
	end)
end

local function onPlayerRemoving(player)
	savePlayerData(player)
	sessionData[player] = nil
	lastRollTime[player] = nil
end

-- CORE ROLL LOGIC
local function executeRoll(player, isFastRoll)
	local data = sessionData[player]
	if not data then
		return { Success = false, Message = "Player data not loaded" }
	end

	-- Rate limiting check
	local now = os.clock()
	local minCooldown = isFastRoll and AuraConfig.Settings.FastRollCooldown or (AuraConfig.Settings.BaseRollCooldown * 0.7)
	local lastTime = lastRollTime[player] or 0
	if (now - lastTime) < minCooldown then
		return { Success = false, Message = "Roll on cooldown" }
	end
	lastRollTime[player] = now

	local totalLuck = calculateLuck(player, data)
	local rolledAura = nil

	-- Loop through rollable auras sorted by Rarity descending (rarest first)
	for _, aura in ipairs(AuraConfig.RollableAuras) do
		local effectiveRarity = math.max(1, math.floor(aura.Rarity / totalLuck))
		if math.random(1, effectiveRarity) == 1 then
			rolledAura = aura
			break
		end
	end

	-- Fallback if no rare hits
	if not rolledAura then
		if math.random(1, 2) == 1 then
			rolledAura = AuraConfig.Auras.Uncommon
		else
			rolledAura = AuraConfig.Auras.Common
		end
	end

	data.Rolls = (data.Rolls or 0) + 1

	-- Determine coins earned
	local coinsEarned = AuraConfig.Settings.CoinsPerRoll[rolledAura.Tier] or 5
	data.Coins = (data.Coins or 0) + coinsEarned

	-- Check if auto-delete applies
	local wasAutoDeleted = false
	if data.AutoDeleteThreshold and data.AutoDeleteThreshold > 0 and rolledAura.Rarity <= data.AutoDeleteThreshold then
		wasAutoDeleted = true
		-- Give bonus scrap coins for auto-deleted auras
		data.Coins = data.Coins + math.max(1, math.floor(rolledAura.Rarity * 0.5))
	else
		-- Storage capacity check
		local currentCount = getInventoryCount(data)
		if currentCount >= data.MaxStorage then
			-- Inventory full fallback: give extra coin compensation
			wasAutoDeleted = true
			data.Coins = data.Coins + math.max(5, rolledAura.Rarity)
		else
			data.Inventory[rolledAura.Id] = (data.Inventory[rolledAura.Id] or 0) + 1
		end
	end

	-- Check for new best aura
	local isNewBest = false
	if rolledAura.Rarity > (data.BestRarity or 1) then
		data.BestRarity = rolledAura.Rarity
		data.BestAura = rolledAura.Name
		isNewBest = true
	end

	-- Global announcement for high tier auras (1 in 10,000+)
	if rolledAura.Rarity >= AuraConfig.Settings.GlobalBroadcastThreshold then
		GlobalAnnouncementEvent:FireAllClients({
			PlayerName = player.DisplayName or player.Name,
			AuraName = rolledAura.Name,
			Rarity = rolledAura.Rarity,
			Tier = rolledAura.Tier,
		})
	end

	syncClient(player)

	return {
		Success = true,
		Aura = rolledAura,
		WasAutoDeleted = wasAutoDeleted,
		CoinsEarned = coinsEarned,
		IsNewBest = isNewBest,
		TotalRolls = data.Rolls,
	}
end

-- REMOTE EVENT & FUNCTION HANDLERS

RollRequestFunc.OnServerInvoke = function(player, isFastRoll)
	return executeRoll(player, isFastRoll)
end

EquipAuraEvent.OnServerEvent:Connect(function(player, auraId)
	local data = sessionData[player]
	if not data then return end

	if not auraId or auraId == "None" or auraId == "" then
		data.EquippedAura = "None"
		if player.Character then
			AuraVisuals.ClearAura(player.Character)
		end
		syncClient(player)
		return
	end

	-- Verify player owns at least 1 of this aura
	if not data.Inventory[auraId] or data.Inventory[auraId] <= 0 then
		-- Check if it's the VIP special aura and player is VIP
		if auraId == "VIPCrown" and (data.Gamepasses.VIP or data.TestPerks.VIP) then
			-- Allowed
		else
			return
		end
	end

	data.EquippedAura = auraId
	if player.Character then
		local isVIP = (data.Gamepasses.VIP or data.TestPerks.VIP)
		AuraVisuals.ApplyAura(player.Character, auraId, isVIP)
	end
	syncClient(player)
end)

DeleteAuraEvent.OnServerEvent:Connect(function(player, auraId)
	local data = sessionData[player]
	if not data then return end

	local currentCount = data.Inventory[auraId] or 0
	if currentCount <= 0 then return end

	data.Inventory[auraId] = currentCount - 1
	if data.Inventory[auraId] <= 0 then
		data.Inventory[auraId] = nil
	end

	-- If this was equipped, unequip it
	if data.EquippedAura == auraId and (data.Inventory[auraId] == nil) then
		data.EquippedAura = "None"
		if player.Character then
			AuraVisuals.ClearAura(player.Character)
		end
	end

	local auraData = AuraConfig.Auras[auraId]
	local scrapValue = auraData and math.max(2, math.floor(auraData.Rarity * 0.4)) or 2
	data.Coins = (data.Coins or 0) + scrapValue

	syncClient(player)
end)

SetAutoDeleteEvent.OnServerEvent:Connect(function(player, threshold)
	local data = sessionData[player]
	if not data then return end

	data.AutoDeleteThreshold = math.max(0, math.floor(threshold or 0))
	syncClient(player)
end)

-- CRAFTING HANDLER
CraftAuraFunc.OnServerInvoke = function(player, recipeId)
	local data = sessionData[player]
	if not data then
		return { Success = false, Message = "Data not loaded" }
	end

	-- Find recipe
	local targetRecipe = nil
	for _, recipe in ipairs(AuraConfig.Recipes) do
		if recipe.Id == recipeId then
			targetRecipe = recipe
			break
		end
	end

	if not targetRecipe then
		return { Success = false, Message = "Recipe not found" }
	end

	-- Validate all ingredients exist in player inventory
	for _, ing in ipairs(targetRecipe.Ingredients) do
		local owned = data.Inventory[ing.AuraId] or 0
		if owned < ing.Count then
			local auraName = AuraConfig.Auras[ing.AuraId] and AuraConfig.Auras[ing.AuraId].Name or ing.AuraId
			return {
				Success = false,
				Message = string.format("Need %d of %s (You have %d)", ing.Count, auraName, owned),
			}
		end
	end

	-- Deduct ingredients
	for _, ing in ipairs(targetRecipe.Ingredients) do
		data.Inventory[ing.AuraId] = data.Inventory[ing.AuraId] - ing.Count
		if data.Inventory[ing.AuraId] <= 0 then
			data.Inventory[ing.AuraId] = nil
		end
		-- Unequip if deducted aura was equipped and no more exist
		if data.EquippedAura == ing.AuraId and not data.Inventory[ing.AuraId] then
			data.EquippedAura = "None"
			if player.Character then
				AuraVisuals.ClearAura(player.Character)
			end
		end
	end

	-- Award result based on type
	if targetRecipe.ResultType == "Aura" then
		data.Inventory[targetRecipe.ResultId] = (data.Inventory[targetRecipe.ResultId] or 0) + 1
	elseif targetRecipe.ResultType == "Gear" then
		data.EquippedGear = targetRecipe.ResultId
	elseif targetRecipe.ResultType == "Potion" then
		local duration = targetRecipe.Duration or 600
		data.PotionExpiry = os.time() + duration
	end

	-- Award crafting bonus coins
	data.Coins = (data.Coins or 0) + 100

	syncClient(player)

	return {
		Success = true,
		Recipe = targetRecipe,
		Message = "Crafting Successful!",
	}
end

-- TEST PERK TOGGLE (Allows free testing of all monetization features without Robux!)
ToggleTestPerkEvent.OnServerEvent:Connect(function(player, perkName)
	local data = sessionData[player]
	if not data then return end

	if data.TestPerks[perkName] ~= nil then
		data.TestPerks[perkName] = not data.TestPerks[perkName]

		-- If VIP was toggled on, give VIP Crown
		if perkName == "VIP" and data.TestPerks.VIP then
			data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		end

		syncClient(player)
	end
end)

-- Connect PlayerAdded / PlayerRemoving
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, p)
end

-- Periodic auto-save every 120 seconds
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerData(player)
		end
	end
end)

print("[Sols RNG] Server initialized successfully! All systems running.")
]===]
else
	if existingServerScript then existingServerScript:Destroy() end
	local serverScript = Instance.new("Script")
	serverScript.Name = "RNGServer"
	serverScript.Source = [===[-- RNGServer.server.lua
-- Core game server manager for Sol's RNG game.
-- Handles Roll mechanics, Inventories, Crafting, Gamepasses, Leaderstats, and Data Saving.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")

-- Ensure ReplicatedStorage modules are accessible
local AuraRNGFolder = ReplicatedStorage:FindFirstChild("AuraRNG")
if not AuraRNGFolder then
	AuraRNGFolder = Instance.new("Folder")
	AuraRNGFolder.Name = "AuraRNG"
	AuraRNGFolder.Parent = ReplicatedStorage
end

local EventsFolder = AuraRNGFolder:FindFirstChild("Events")
if not EventsFolder then
	EventsFolder = Instance.new("Folder")
	EventsFolder.Name = "Events"
	EventsFolder.Parent = AuraRNGFolder
end

-- Helper to find or create RemoteEvent/RemoteFunction
local function getRemoteEvent(name)
	local existing = EventsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = EventsFolder
	return event
end

local function getRemoteFunction(name)
	local existing = EventsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end
	local func = Instance.new("RemoteFunction")
	func.Name = name
	func.Parent = EventsFolder
	return func
end

local RollRequestFunc = getRemoteFunction("RollRequest")
local CraftAuraFunc = getRemoteFunction("CraftAura")
local EquipAuraEvent = getRemoteEvent("EquipAura")
local DeleteAuraEvent = getRemoteEvent("DeleteAura")
local SetAutoDeleteEvent = getRemoteEvent("SetAutoDelete")
local ToggleTestPerkEvent = getRemoteEvent("ToggleTestPerk")
local DataSyncEvent = getRemoteEvent("DataSync")
local GlobalAnnouncementEvent = getRemoteEvent("GlobalAnnouncement")

-- Require shared modules
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")
local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local AuraVisuals = require(ModulesFolder:WaitForChild("AuraVisuals"))

-- Auto-build base platform, spawn location, and crafting altar if not already present
task.spawn(function()
	pcall(function()
		local setupModule = ModulesFolder:FindFirstChild("CraftingStationSetup")
		if setupModule and not game:GetService("Workspace"):FindFirstChild("RNG_Platform") then
			local CraftingStationSetup = require(setupModule)
			CraftingStationSetup.BuildMap()
		end
	end)
end)

-- Optional DataStore setup with safe fallback for local Studio testing
local DATA_STORE_KEY = "SolsRNG_PlayerData_v1"
local playerDataStore = nil
pcall(function()
	playerDataStore = DataStoreService:GetDataStore(DATA_STORE_KEY)
end)

-- In-memory session store: Player -> Data table
local sessionData = {}
local lastRollTime = {}

-- Calculate active luck for a player
local function calculateLuck(player, data)
	local luck = 1.0

	-- x2 Luck Gamepass or Test Perk
	if data.Gamepasses.X2Luck or data.TestPerks.X2Luck then
		luck = luck * 2.0
	end

	-- VIP Gamepass or Test Perk (x1.5 Luck)
	if data.Gamepasses.VIP or data.TestPerks.VIP then
		luck = luck * 1.5
	end

	-- Crafted Luck Gauntlet Gear (+50% Luck)
	if data.EquippedGear == "LuckGauntlet" then
		luck = luck * 1.5
	end

	-- Active Fortune Elixir Potion (x2 Luck)
	if data.PotionExpiry and os.time() < data.PotionExpiry then
		luck = luck * 2.0
	end

	return luck
end

-- Calculate current inventory item count
local function getInventoryCount(data)
	local count = 0
	for _, qty in pairs(data.Inventory) do
		count = count + qty
	end
	return count
end

-- Sync full data to client
local function syncClient(player)
	local data = sessionData[player]
	if not data then return end

	local currentLuck = calculateLuck(player, data)

	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rollsVal = leaderstats:FindFirstChild("Rolls")
		if rollsVal and rollsVal:IsA("IntValue") then
			rollsVal.Value = data.Rolls or 0
		end

		local bestVal = leaderstats:FindFirstChild("Best Aura")
		if bestVal and bestVal:IsA("StringValue") then
			bestVal.Value = data.BestAura or "None"
		end

		local coinsVal = leaderstats:FindFirstChild("Coins")
		if coinsVal and coinsVal:IsA("IntValue") then
			coinsVal.Value = data.Coins or 0
		end

		local luckVal = leaderstats:FindFirstChild("Luck")
		if luckVal and luckVal:IsA("NumberValue") then
			luckVal.Value = currentLuck
		end
	end

	-- Calculate max storage
	local maxStorage = AuraConfig.Settings.DefaultStorage
	if data.Gamepasses.ExtraStorage or data.TestPerks.ExtraStorage then
		maxStorage = maxStorage + AuraConfig.Settings.ExtraStorageBonus
	end
	data.MaxStorage = maxStorage

	DataSyncEvent:FireClient(player, {
		Rolls = data.Rolls,
		Coins = data.Coins,
		BestAura = data.BestAura,
		BestRarity = data.BestRarity,
		EquippedAura = data.EquippedAura,
		EquippedGear = data.EquippedGear,
		Inventory = data.Inventory,
		MaxStorage = data.MaxStorage,
		AutoDeleteThreshold = data.AutoDeleteThreshold,
		PotionExpiry = data.PotionExpiry,
		Gamepasses = data.Gamepasses,
		TestPerks = data.TestPerks,
		CurrentLuck = currentLuck,
	})
end

-- Save player data safely
local function savePlayerData(player)
	local data = sessionData[player]
	if not data or not playerDataStore then return end

	local success, err = pcall(function()
		local toSave = {
			Rolls = data.Rolls,
			Coins = data.Coins,
			BestAura = data.BestAura,
			BestRarity = data.BestRarity,
			EquippedAura = data.EquippedAura,
			EquippedGear = data.EquippedGear,
			Inventory = data.Inventory,
			AutoDeleteThreshold = data.AutoDeleteThreshold,
			PotionExpiry = data.PotionExpiry,
			Gamepasses = data.Gamepasses,
		}
		playerDataStore:SetAsync(tostring(player.UserId), toSave)
	end)

	if not success then
		warn(string.format("[RNG Server] Failed to save data for %s: %s", player.Name, tostring(err)))
	end
end

-- Load player data
local function loadPlayerData(player)
	local defaultData = {
		Rolls = 0,
		Coins = 100,
		BestAura = "None",
		BestRarity = 1,
		EquippedAura = "None",
		EquippedGear = "None",
		Inventory = {
			Common = 1,
		},
		MaxStorage = AuraConfig.Settings.DefaultStorage,
		AutoDeleteThreshold = 0,
		PotionExpiry = 0,
		Gamepasses = {
			X2Luck = false,
			AutoRoll = false,
			ExtraStorage = false,
			VIP = false,
		},
		TestPerks = {
			X2Luck = false,
			AutoRoll = false,
			ExtraStorage = false,
			VIP = false,
		},
	}

	if playerDataStore then
		local success, saved = pcall(function()
			return playerDataStore:GetAsync(tostring(player.UserId))
		end)
		if success and type(saved) == "table" then
			for k, v in pairs(saved) do
				defaultData[k] = v
			end
		end
	end

	-- Check real Gamepass ownership from Roblox API
	pcall(function()
		local gp = AuraConfig.Settings.GamepassIds
		if gp.X2Luck and gp.X2Luck > 0 then
			defaultData.Gamepasses.X2Luck = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.X2Luck)
		end
		if gp.AutoRoll and gp.AutoRoll > 0 then
			defaultData.Gamepasses.AutoRoll = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.AutoRoll)
		end
		if gp.ExtraStorage and gp.ExtraStorage > 0 then
			defaultData.Gamepasses.ExtraStorage = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.ExtraStorage)
		end
		if gp.VIP and gp.VIP > 0 then
			defaultData.Gamepasses.VIP = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.VIP)
		end
	end)

	sessionData[player] = defaultData
	syncClient(player)
end

-- Initialize player leaderstats and character setup
local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local rolls = Instance.new("IntValue")
	rolls.Name = "Rolls"
	rolls.Value = 0
	rolls.Parent = leaderstats

	local bestAura = Instance.new("StringValue")
	bestAura.Name = "Best Aura"
	bestAura.Value = "None"
	bestAura.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 100
	coins.Parent = leaderstats

	local luck = Instance.new("NumberValue")
	luck.Name = "Luck"
	luck.Value = 1.0
	luck.Parent = leaderstats

	loadPlayerData(player)

	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		local data = sessionData[player]
		if data and data.EquippedAura and data.EquippedAura ~= "None" then
			local isVIP = (data.Gamepasses.VIP or data.TestPerks.VIP)
			AuraVisuals.ApplyAura(character, data.EquippedAura, isVIP)
		end
	end)
end

local function onPlayerRemoving(player)
	savePlayerData(player)
	sessionData[player] = nil
	lastRollTime[player] = nil
end

-- CORE ROLL LOGIC
local function executeRoll(player, isFastRoll)
	local data = sessionData[player]
	if not data then
		return { Success = false, Message = "Player data not loaded" }
	end

	-- Rate limiting check
	local now = os.clock()
	local minCooldown = isFastRoll and AuraConfig.Settings.FastRollCooldown or (AuraConfig.Settings.BaseRollCooldown * 0.7)
	local lastTime = lastRollTime[player] or 0
	if (now - lastTime) < minCooldown then
		return { Success = false, Message = "Roll on cooldown" }
	end
	lastRollTime[player] = now

	local totalLuck = calculateLuck(player, data)
	local rolledAura = nil

	-- Loop through rollable auras sorted by Rarity descending (rarest first)
	for _, aura in ipairs(AuraConfig.RollableAuras) do
		local effectiveRarity = math.max(1, math.floor(aura.Rarity / totalLuck))
		if math.random(1, effectiveRarity) == 1 then
			rolledAura = aura
			break
		end
	end

	-- Fallback if no rare hits
	if not rolledAura then
		if math.random(1, 2) == 1 then
			rolledAura = AuraConfig.Auras.Uncommon
		else
			rolledAura = AuraConfig.Auras.Common
		end
	end

	data.Rolls = (data.Rolls or 0) + 1

	-- Determine coins earned
	local coinsEarned = AuraConfig.Settings.CoinsPerRoll[rolledAura.Tier] or 5
	data.Coins = (data.Coins or 0) + coinsEarned

	-- Check if auto-delete applies
	local wasAutoDeleted = false
	if data.AutoDeleteThreshold and data.AutoDeleteThreshold > 0 and rolledAura.Rarity <= data.AutoDeleteThreshold then
		wasAutoDeleted = true
		-- Give bonus scrap coins for auto-deleted auras
		data.Coins = data.Coins + math.max(1, math.floor(rolledAura.Rarity * 0.5))
	else
		-- Storage capacity check
		local currentCount = getInventoryCount(data)
		if currentCount >= data.MaxStorage then
			-- Inventory full fallback: give extra coin compensation
			wasAutoDeleted = true
			data.Coins = data.Coins + math.max(5, rolledAura.Rarity)
		else
			data.Inventory[rolledAura.Id] = (data.Inventory[rolledAura.Id] or 0) + 1
		end
	end

	-- Check for new best aura
	local isNewBest = false
	if rolledAura.Rarity > (data.BestRarity or 1) then
		data.BestRarity = rolledAura.Rarity
		data.BestAura = rolledAura.Name
		isNewBest = true
	end

	-- Global announcement for high tier auras (1 in 10,000+)
	if rolledAura.Rarity >= AuraConfig.Settings.GlobalBroadcastThreshold then
		GlobalAnnouncementEvent:FireAllClients({
			PlayerName = player.DisplayName or player.Name,
			AuraName = rolledAura.Name,
			Rarity = rolledAura.Rarity,
			Tier = rolledAura.Tier,
		})
	end

	syncClient(player)

	return {
		Success = true,
		Aura = rolledAura,
		WasAutoDeleted = wasAutoDeleted,
		CoinsEarned = coinsEarned,
		IsNewBest = isNewBest,
		TotalRolls = data.Rolls,
	}
end

-- REMOTE EVENT & FUNCTION HANDLERS

RollRequestFunc.OnServerInvoke = function(player, isFastRoll)
	return executeRoll(player, isFastRoll)
end

EquipAuraEvent.OnServerEvent:Connect(function(player, auraId)
	local data = sessionData[player]
	if not data then return end

	if not auraId or auraId == "None" or auraId == "" then
		data.EquippedAura = "None"
		if player.Character then
			AuraVisuals.ClearAura(player.Character)
		end
		syncClient(player)
		return
	end

	-- Verify player owns at least 1 of this aura
	if not data.Inventory[auraId] or data.Inventory[auraId] <= 0 then
		-- Check if it's the VIP special aura and player is VIP
		if auraId == "VIPCrown" and (data.Gamepasses.VIP or data.TestPerks.VIP) then
			-- Allowed
		else
			return
		end
	end

	data.EquippedAura = auraId
	if player.Character then
		local isVIP = (data.Gamepasses.VIP or data.TestPerks.VIP)
		AuraVisuals.ApplyAura(player.Character, auraId, isVIP)
	end
	syncClient(player)
end)

DeleteAuraEvent.OnServerEvent:Connect(function(player, auraId)
	local data = sessionData[player]
	if not data then return end

	local currentCount = data.Inventory[auraId] or 0
	if currentCount <= 0 then return end

	data.Inventory[auraId] = currentCount - 1
	if data.Inventory[auraId] <= 0 then
		data.Inventory[auraId] = nil
	end

	-- If this was equipped, unequip it
	if data.EquippedAura == auraId and (data.Inventory[auraId] == nil) then
		data.EquippedAura = "None"
		if player.Character then
			AuraVisuals.ClearAura(player.Character)
		end
	end

	local auraData = AuraConfig.Auras[auraId]
	local scrapValue = auraData and math.max(2, math.floor(auraData.Rarity * 0.4)) or 2
	data.Coins = (data.Coins or 0) + scrapValue

	syncClient(player)
end)

SetAutoDeleteEvent.OnServerEvent:Connect(function(player, threshold)
	local data = sessionData[player]
	if not data then return end

	data.AutoDeleteThreshold = math.max(0, math.floor(threshold or 0))
	syncClient(player)
end)

-- CRAFTING HANDLER
CraftAuraFunc.OnServerInvoke = function(player, recipeId)
	local data = sessionData[player]
	if not data then
		return { Success = false, Message = "Data not loaded" }
	end

	-- Find recipe
	local targetRecipe = nil
	for _, recipe in ipairs(AuraConfig.Recipes) do
		if recipe.Id == recipeId then
			targetRecipe = recipe
			break
		end
	end

	if not targetRecipe then
		return { Success = false, Message = "Recipe not found" }
	end

	-- Validate all ingredients exist in player inventory
	for _, ing in ipairs(targetRecipe.Ingredients) do
		local owned = data.Inventory[ing.AuraId] or 0
		if owned < ing.Count then
			local auraName = AuraConfig.Auras[ing.AuraId] and AuraConfig.Auras[ing.AuraId].Name or ing.AuraId
			return {
				Success = false,
				Message = string.format("Need %d of %s (You have %d)", ing.Count, auraName, owned),
			}
		end
	end

	-- Deduct ingredients
	for _, ing in ipairs(targetRecipe.Ingredients) do
		data.Inventory[ing.AuraId] = data.Inventory[ing.AuraId] - ing.Count
		if data.Inventory[ing.AuraId] <= 0 then
			data.Inventory[ing.AuraId] = nil
		end
		-- Unequip if deducted aura was equipped and no more exist
		if data.EquippedAura == ing.AuraId and not data.Inventory[ing.AuraId] then
			data.EquippedAura = "None"
			if player.Character then
				AuraVisuals.ClearAura(player.Character)
			end
		end
	end

	-- Award result based on type
	if targetRecipe.ResultType == "Aura" then
		data.Inventory[targetRecipe.ResultId] = (data.Inventory[targetRecipe.ResultId] or 0) + 1
	elseif targetRecipe.ResultType == "Gear" then
		data.EquippedGear = targetRecipe.ResultId
	elseif targetRecipe.ResultType == "Potion" then
		local duration = targetRecipe.Duration or 600
		data.PotionExpiry = os.time() + duration
	end

	-- Award crafting bonus coins
	data.Coins = (data.Coins or 0) + 100

	syncClient(player)

	return {
		Success = true,
		Recipe = targetRecipe,
		Message = "Crafting Successful!",
	}
end

-- TEST PERK TOGGLE (Allows free testing of all monetization features without Robux!)
ToggleTestPerkEvent.OnServerEvent:Connect(function(player, perkName)
	local data = sessionData[player]
	if not data then return end

	if data.TestPerks[perkName] ~= nil then
		data.TestPerks[perkName] = not data.TestPerks[perkName]

		-- If VIP was toggled on, give VIP Crown
		if perkName == "VIP" and data.TestPerks.VIP then
			data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		end

		syncClient(player)
	end
end)

-- Connect PlayerAdded / PlayerRemoving
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, p)
end

-- Periodic auto-save every 120 seconds
task.spawn(function()
	while true do
		task.wait(120)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerData(player)
		end
	end
end)

print("[Sols RNG] Server initialized successfully! All systems running.")
]===]
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
	existingClientScript.Source = [===[-- RNGClient.client.lua
-- Client controller and complete GUI manager for Sol's RNG game.
-- Manages HUD, Rolling Animations, Cutscenes, Inventory, Crafting, Shop & Passes, and Settings.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ReplicatedStorage references
local AuraRNGFolder = ReplicatedStorage:WaitForChild("AuraRNG")
local EventsFolder = AuraRNGFolder:WaitForChild("Events")
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")

local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local SoundEffects = require(ModulesFolder:WaitForChild("SoundEffects"))

-- Remotes
local RollRequestFunc = EventsFolder:WaitForChild("RollRequest")
local CraftAuraFunc = EventsFolder:WaitForChild("CraftAura")
local EquipAuraEvent = EventsFolder:WaitForChild("EquipAura")
local DeleteAuraEvent = EventsFolder:WaitForChild("DeleteAura")
local SetAutoDeleteEvent = EventsFolder:WaitForChild("SetAutoDelete")
local ToggleTestPerkEvent = EventsFolder:WaitForChild("ToggleTestPerk")
local DataSyncEvent = EventsFolder:WaitForChild("DataSync")
local GlobalAnnouncementEvent = EventsFolder:WaitForChild("GlobalAnnouncement")

-- Local Player Cache State
local localData = {
	Rolls = 0,
	Coins = 100,
	BestAura = "None",
	BestRarity = 1,
	EquippedAura = "None",
	EquippedGear = "None",
	Inventory = {},
	MaxStorage = 20,
	AutoDeleteThreshold = 0,
	PotionExpiry = 0,
	Gamepasses = {},
	TestPerks = {},
	CurrentLuck = 1.0,
}

local isAutoRollOn = false
local isFastRollOn = false
local isRolling = false
local selectedInventoryAura = nil
local selectedCraftRecipe = nil

--------------------------------------------------------------------------------
-- UI CONSTRUCTION & INSTANCES
--------------------------------------------------------------------------------

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RNG_ScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui
end

-- Helper: Rounded corner
local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = parent
	return corner
end

-- Helper: Stroke outline
local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(60, 65, 80)
	stroke.Thickness = thickness or 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- Top HUD Container
local topHud = Instance.new("Frame")
topHud.Name = "TopHUD"
topHud.Size = UDim2.new(0, 720, 0, 48)
topHud.Position = UDim2.new(0.5, -360, 0, 14)
topHud.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
topHud.BackgroundTransparency = 0.15
addCorner(topHud, 12)
addStroke(topHud, Color3.fromRGB(45, 52, 70), 1.5)
topHud.Parent = screenGui

local topListLayout = Instance.new("UIListLayout")
topListLayout.FillDirection = Enum.FillDirection.Horizontal
topListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topListLayout.Padding = UDim.new(0, 20)
topListLayout.Parent = topHud

-- Top Stat Labels
local function createTopStat(icon, defaultText, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 140, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 15
	label.TextColor3 = color
	label.Text = icon .. " " .. defaultText
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = topHud
	return label
end

local rollsLabel = createTopStat("🎲", "Rolls: 0", Color3.fromRGB(220, 225, 240))
local luckLabel = createTopStat("🍀", "Luck: x1.0", Color3.fromRGB(74, 222, 128))
local coinsLabel = createTopStat("🪙", "Coins: 100", Color3.fromRGB(250, 204, 21))
local potionLabel = createTopStat("⏳", "Potion: None", Color3.fromRGB(56, 189, 248))

-- Bottom Center Controls Container
local bottomControls = Instance.new("Frame")
bottomControls.Name = "BottomControls"
bottomControls.Size = UDim2.new(0, 400, 0, 100)
bottomControls.Position = UDim2.new(0.5, -200, 1, -115)
bottomControls.BackgroundTransparency = 1
bottomControls.Parent = screenGui

-- Big ROLL Button
local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.Size = UDim2.new(0, 210, 0, 62)
rollButton.Position = UDim2.new(0.5, -105, 0, 0)
rollButton.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
rollButton.Font = Enum.Font.GothamBlack
rollButton.TextSize = 24
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.Text = "🎲 ROLL"
addCorner(rollButton, 14)
addStroke(rollButton, Color3.fromRGB(96, 165, 250), 2)
rollButton.Parent = bottomControls

-- Roll Button Gradient
local rollGradient = Instance.new("UIGradient")
rollGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 78, 216)),
})
rollGradient.Rotation = 45
rollGradient.Parent = rollButton

-- Auto Roll Button
local autoRollBtn = Instance.new("TextButton")
autoRollBtn.Name = "AutoRollButton"
autoRollBtn.Size = UDim2.new(0, 130, 0, 32)
autoRollBtn.Position = UDim2.new(0.5, -140, 1, -34)
autoRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
autoRollBtn.Font = Enum.Font.GothamBold
autoRollBtn.TextSize = 13
autoRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
autoRollBtn.Text = "⚡ AUTO: OFF"
addCorner(autoRollBtn, 8)
addStroke(autoRollBtn, Color3.fromRGB(55, 62, 80), 1)
autoRollBtn.Parent = bottomControls

-- Fast Roll Button
local fastRollBtn = Instance.new("TextButton")
fastRollBtn.Name = "FastRollButton"
fastRollBtn.Size = UDim2.new(0, 130, 0, 32)
fastRollBtn.Position = UDim2.new(0.5, 10, 1, -34)
fastRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
fastRollBtn.Font = Enum.Font.GothamBold
fastRollBtn.TextSize = 13
fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
fastRollBtn.Text = "⏩ FAST: OFF"
addCorner(fastRollBtn, 8)
addStroke(fastRollBtn, Color3.fromRGB(55, 62, 80), 1)
fastRollBtn.Parent = bottomControls

-- Left Navigation Bar
local leftNav = Instance.new("Frame")
leftNav.Name = "LeftNav"
leftNav.Size = UDim2.new(0, 68, 0, 280)
leftNav.Position = UDim2.new(0, 16, 0.5, -140)
leftNav.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
leftNav.BackgroundTransparency = 0.2
addCorner(leftNav, 14)
addStroke(leftNav, Color3.fromRGB(45, 52, 70), 1.5)
leftNav.Parent = screenGui

local navListLayout = Instance.new("UIListLayout")
navListLayout.FillDirection = Enum.FillDirection.Vertical
navListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navListLayout.Padding = UDim.new(0, 12)
navListLayout.Parent = leftNav

local function createNavButton(name, icon, tooltip)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Btn"
	btn.Size = UDim2.new(0, 52, 0, 52)
	btn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 22
	btn.Text = icon
	addCorner(btn, 10)
	addStroke(btn, Color3.fromRGB(50, 58, 78), 1.2)
	btn.Parent = leftNav
	return btn
end

local navInventoryBtn = createNavButton("Inventory", "🎒", "Inventory")
local navCraftingBtn = createNavButton("Crafting", "⚗️", "Crafting")
local navShopBtn = createNavButton("Shop", "🛒", "Shop & Passes")
local navSettingsBtn = createNavButton("Settings", "⚙️", "Settings")

-- Bottom Left: Equipped Aura Card
local equippedCard = Instance.new("Frame")
equippedCard.Name = "EquippedCard"
equippedCard.Size = UDim2.new(0, 210, 0, 62)
equippedCard.Position = UDim2.new(0, 16, 1, -78)
equippedCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
equippedCard.BackgroundTransparency = 0.2
addCorner(equippedCard, 10)
addStroke(equippedCard, Color3.fromRGB(45, 52, 70), 1.5)
equippedCard.Parent = screenGui

local equippedTitle = Instance.new("TextLabel")
equippedTitle.Size = UDim2.new(1, -65, 0, 20)
equippedTitle.Position = UDim2.new(0, 12, 0, 10)
equippedTitle.BackgroundTransparency = 1
equippedTitle.Font = Enum.Font.GothamBold
equippedTitle.TextSize = 14
equippedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
equippedTitle.TextXAlignment = Enum.TextXAlignment.Left
equippedTitle.Text = "Aura: None"
equippedTitle.Parent = equippedCard

local equippedSubtitle = Instance.new("TextLabel")
equippedSubtitle.Size = UDim2.new(1, -65, 0, 16)
equippedSubtitle.Position = UDim2.new(0, 12, 0, 32)
equippedSubtitle.BackgroundTransparency = 1
equippedSubtitle.Font = Enum.Font.GothamMedium
equippedSubtitle.TextSize = 12
equippedSubtitle.TextColor3 = Color3.fromRGB(156, 163, 175)
equippedSubtitle.TextXAlignment = Enum.TextXAlignment.Left
equippedSubtitle.Text = "Not Equipped"
equippedSubtitle.Parent = equippedCard

local unequipBtn = Instance.new("TextButton")
unequipBtn.Name = "UnequipBtn"
unequipBtn.Size = UDim2.new(0, 42, 0, 42)
unequipBtn.Position = UDim2.new(1, -52, 0.5, -21)
unequipBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
unequipBtn.Font = Enum.Font.GothamBold
unequipBtn.TextSize = 12
unequipBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
unequipBtn.Text = "✕"
addCorner(unequipBtn, 8)
unequipBtn.Parent = equippedCard

--------------------------------------------------------------------------------
-- MODAL WINDOW HELPER
--------------------------------------------------------------------------------

local activeModal = nil

local function createModalWindow(titleText, width, height)
	local window = Instance.new("Frame")
	window.Size = UDim2.new(0, width, 0, height)
	window.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
	window.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	window.BackgroundTransparency = 0.05
	window.Visible = false
	addCorner(window, 14)
	addStroke(window, Color3.fromRGB(55, 65, 88), 2)
	window.Parent = screenGui

	-- Header Bar
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	header.BackgroundTransparency = 0.3
	addCorner(header, 14)
	header.Parent = window

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 18, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = titleText
	titleLabel.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
	closeBtn.Text = "✕"
	addCorner(closeBtn, 8)
	closeBtn.Parent = header

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -32, 1, -64)
	content.Position = UDim2.new(0, 16, 0, 54)
	content.BackgroundTransparency = 1
	content.Parent = window

	closeBtn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		window.Visible = false
		if activeModal == window then
			activeModal = nil
		end
	end)

	return window, content, closeBtn
end

local function toggleModal(modal)
	SoundEffects.Play("Click")
	if activeModal == modal then
		modal.Visible = false
		activeModal = nil
	else
		if activeModal then
			activeModal.Visible = false
		end
		modal.Visible = true
		activeModal = modal
	end
end

--------------------------------------------------------------------------------
-- 1. INVENTORY WINDOW
--------------------------------------------------------------------------------

local inventoryWindow, invContent = createModalWindow("🎒 AURA INVENTORY", 680, 480)

-- Top Storage Bar
local storageInfo = Instance.new("TextLabel")
storageInfo.Size = UDim2.new(0, 200, 0, 24)
storageInfo.Position = UDim2.new(0, 0, 0, 0)
storageInfo.BackgroundTransparency = 1
storageInfo.Font = Enum.Font.GothamBold
storageInfo.TextSize = 14
storageInfo.TextColor3 = Color3.fromRGB(156, 163, 175)
storageInfo.TextXAlignment = Enum.TextXAlignment.Left
storageInfo.Text = "Storage: 0 / 20"
storageInfo.Parent = invContent

-- Auto Delete Threshold Dropdown/Button
local autoDeleteBtn = Instance.new("TextButton")
autoDeleteBtn.Size = UDim2.new(0, 180, 0, 26)
autoDeleteBtn.Position = UDim2.new(1, -180, 0, 0)
autoDeleteBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
autoDeleteBtn.Font = Enum.Font.GothamMedium
autoDeleteBtn.TextSize = 12
autoDeleteBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
autoDeleteBtn.Text = "Auto-Delete: None"
addCorner(autoDeleteBtn, 6)
addStroke(autoDeleteBtn, Color3.fromRGB(50, 58, 78), 1)
autoDeleteBtn.Parent = invContent

-- Left Grid Container
local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -210, 1, -36)
invScroll.Position = UDim2.new(0, 0, 0, 32)
invScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
invScroll.BackgroundTransparency = 0.5
invScroll.ScrollBarThickness = 6
invScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 95)
addCorner(invScroll, 8)
invScroll.Parent = invContent

local invGrid = Instance.new("UIGridLayout")
invGrid.CellSize = UDim2.new(0, 100, 0, 100)
invGrid.CellPadding = UDim2.new(0, 8, 0, 8)
invGrid.Parent = invScroll

-- Right Detail Panel
local detailPanel = Instance.new("Frame")
detailPanel.Size = UDim2.new(0, 195, 1, -36)
detailPanel.Position = UDim2.new(1, -195, 0, 32)
detailPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
addCorner(detailPanel, 8)
addStroke(detailPanel, Color3.fromRGB(40, 48, 65), 1)
detailPanel.Parent = invContent

local detailName = Instance.new("TextLabel")
detailName.Size = UDim2.new(1, -16, 0, 28)
detailName.Position = UDim2.new(0, 8, 0, 10)
detailName.BackgroundTransparency = 1
detailName.Font = Enum.Font.GothamBlack
detailName.TextSize = 16
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.Text = "Select an Aura"
detailName.Parent = detailPanel

local detailRarity = Instance.new("TextLabel")
detailRarity.Size = UDim2.new(1, -16, 0, 20)
detailRarity.Position = UDim2.new(0, 8, 0, 38)
detailRarity.BackgroundTransparency = 1
detailRarity.Font = Enum.Font.GothamBold
detailRarity.TextSize = 13
detailRarity.TextColor3 = Color3.fromRGB(156, 163, 175)
detailRarity.Text = ""
detailRarity.Parent = detailPanel

local detailDesc = Instance.new("TextLabel")
detailDesc.Size = UDim2.new(1, -16, 0, 80)
detailDesc.Position = UDim2.new(0, 8, 0, 64)
detailDesc.BackgroundTransparency = 1
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 12
detailDesc.TextColor3 = Color3.fromRGB(200, 205, 220)
detailDesc.TextWrapped = true
detailDesc.TextYAlignment = Enum.TextYAlignment.Top
detailDesc.Text = "Click any aura card on the left to equip or manage."
detailDesc.Parent = detailPanel

local equipActionBtn = Instance.new("TextButton")
equipActionBtn.Size = UDim2.new(1, -20, 0, 38)
equipActionBtn.Position = UDim2.new(0, 10, 1, -94)
equipActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
equipActionBtn.Font = Enum.Font.GothamBold
equipActionBtn.TextSize = 14
equipActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipActionBtn.Text = "Equip"
equipActionBtn.Visible = false
addCorner(equipActionBtn, 8)
equipActionBtn.Parent = detailPanel

local deleteActionBtn = Instance.new("TextButton")
deleteActionBtn.Size = UDim2.new(1, -20, 0, 36)
deleteActionBtn.Position = UDim2.new(0, 10, 1, -48)
deleteActionBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 28)
deleteActionBtn.Font = Enum.Font.GothamMedium
deleteActionBtn.TextSize = 12
deleteActionBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
deleteActionBtn.Text = "Scrap (+Coins)"
deleteActionBtn.Visible = false
addCorner(deleteActionBtn, 8)
deleteActionBtn.Parent = detailPanel

-- Function to refresh inventory UI
local function refreshInventoryUI()
	-- Clear old item cards
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local totalCount = 0
	for auraId, count in pairs(localData.Inventory) do
		totalCount = totalCount + count
		local auraData = AuraConfig.Auras[auraId]
		if auraData then
			local card = Instance.new("TextButton")
			card.Name = "Card_" .. auraId
			card.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			card.Text = ""
			addCorner(card, 8)
			local stroke = addStroke(card, auraData.Color, 1.5)

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -8, 0, 28)
			name.Position = UDim2.new(0, 4, 0, 6)
			name.BackgroundTransparency = 1
			name.Font = Enum.Font.GothamBold
			name.TextSize = 12
			name.TextColor3 = auraData.Color
			name.Text = auraData.Name
			name.TextWrapped = true
			name.Parent = card

			local rarity = Instance.new("TextLabel")
			rarity.Size = UDim2.new(1, -8, 0, 16)
			rarity.Position = UDim2.new(0, 4, 0, 36)
			rarity.BackgroundTransparency = 1
			rarity.Font = Enum.Font.GothamMedium
			rarity.TextSize = 10
			rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
			rarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
			rarity.Parent = card

			local countTag = Instance.new("TextLabel")
			countTag.Size = UDim2.new(0, 30, 0, 16)
			countTag.Position = UDim2.new(1, -34, 1, -20)
			countTag.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
			countTag.Font = Enum.Font.GothamBold
			countTag.TextSize = 10
			countTag.TextColor3 = Color3.fromRGB(220, 225, 240)
			countTag.Text = "x" .. tostring(count)
			addCorner(countTag, 4)
			countTag.Parent = card

			-- Equipped Indicator
			if localData.EquippedAura == auraId then
				local eqTag = Instance.new("TextLabel")
				eqTag.Size = UDim2.new(0, 52, 0, 16)
				eqTag.Position = UDim2.new(0, 4, 1, -20)
				eqTag.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				eqTag.Font = Enum.Font.GothamBold
				eqTag.TextSize = 9
				eqTag.TextColor3 = Color3.fromRGB(255, 255, 255)
				eqTag.Text = "EQUIPPED"
				addCorner(eqTag, 4)
				eqTag.Parent = card
			end

			card.MouseButton1Click:Connect(function()
				SoundEffects.Play("Click")
				selectedInventoryAura = auraId
				detailName.Text = auraData.Name
				detailName.TextColor3 = auraData.Color
				detailRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
				detailDesc.Text = auraData.Description

				equipActionBtn.Visible = true
				if localData.EquippedAura == auraId then
					equipActionBtn.Text = "Unequip"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
				else
					equipActionBtn.Text = "Equip"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
				end
				deleteActionBtn.Visible = true
			end)

			card.Parent = invScroll
		end
	end

	storageInfo.Text = string.format("Storage: %d / %d", totalCount, localData.MaxStorage)
	invScroll.CanvasSize = UDim2.new(0, 0, 0, invGrid.AbsoluteContentSize.Y + 20)
end

equipActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Equip")
	if localData.EquippedAura == selectedInventoryAura then
		EquipAuraEvent:FireServer("None")
	else
		EquipAuraEvent:FireServer(selectedInventoryAura)
	end
end)

deleteActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Click")
	DeleteAuraEvent:FireServer(selectedInventoryAura)
	selectedInventoryAura = nil
	equipActionBtn.Visible = false
	deleteActionBtn.Visible = false
	detailName.Text = "Select an Aura"
	detailRarity.Text = ""
	detailDesc.Text = "Aura scrapped for coins."
end)

-- Cycle auto-delete threshold
local thresholds = { 0, 2, 4, 16, 64 }
local thresholdNames = { [0] = "None", [2] = "Common (1/2)", [4] = "Uncommon (1/4)", [16] = "Rare (1/16)", [64] = "Crystallized (1/64)" }
autoDeleteBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	local cur = localData.AutoDeleteThreshold or 0
	local nextIdx = 1
	for i, v in ipairs(thresholds) do
		if v == cur then
			nextIdx = (i % #thresholds) + 1
			break
		end
	end
	local nextVal = thresholds[nextIdx]
	SetAutoDeleteEvent:FireServer(nextVal)
end)

--------------------------------------------------------------------------------
-- 2. CRAFTING ALCHEMIST WINDOW
--------------------------------------------------------------------------------

local craftWindow, craftContent = createModalWindow("⚗️ ALCHEMIST CRAFTING FORGE", 720, 500)

local recipeListScroll = Instance.new("ScrollingFrame")
recipeListScroll.Size = UDim2.new(0, 240, 1, 0)
recipeListScroll.Position = UDim2.new(0, 0, 0, 0)
recipeListScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
recipeListScroll.BackgroundTransparency = 0.5
recipeListScroll.ScrollBarThickness = 4
addCorner(recipeListScroll, 8)
recipeListScroll.Parent = craftContent

local recipeListLayout = Instance.new("UIListLayout")
recipeListLayout.Padding = UDim.new(0, 8)
recipeListLayout.Parent = recipeListScroll

-- Recipe Details & Ingredients Panel
local craftDetail = Instance.new("Frame")
craftDetail.Size = UDim2.new(1, -255, 1, 0)
craftDetail.Position = UDim2.new(0, 255, 0, 0)
craftDetail.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
addCorner(craftDetail, 8)
addStroke(craftDetail, Color3.fromRGB(40, 48, 65), 1)
craftDetail.Parent = craftContent

local craftResultName = Instance.new("TextLabel")
craftResultName.Size = UDim2.new(1, -20, 0, 28)
craftResultName.Position = UDim2.new(0, 10, 0, 12)
craftResultName.BackgroundTransparency = 1
craftResultName.Font = Enum.Font.GothamBlack
craftResultName.TextSize = 18
craftResultName.TextColor3 = Color3.fromRGB(255, 255, 255)
craftResultName.Text = "Select a Recipe"
craftResultName.Parent = craftDetail

local craftResultDesc = Instance.new("TextLabel")
craftResultDesc.Size = UDim2.new(1, -20, 0, 40)
craftResultDesc.Position = UDim2.new(0, 10, 0, 42)
craftResultDesc.BackgroundTransparency = 1
craftResultDesc.Font = Enum.Font.Gotham
craftResultDesc.TextSize = 12
craftResultDesc.TextColor3 = Color3.fromRGB(200, 205, 220)
craftResultDesc.TextWrapped = true
craftResultDesc.Text = "Combine rare auras to forge exclusive godly auras, luck gauntlets, and elixirs!"
craftResultDesc.Parent = craftDetail

local ingredientsHeader = Instance.new("TextLabel")
ingredientsHeader.Size = UDim2.new(1, -20, 0, 20)
ingredientsHeader.Position = UDim2.new(0, 10, 0, 92)
ingredientsHeader.BackgroundTransparency = 1
ingredientsHeader.Font = Enum.Font.GothamBold
ingredientsHeader.TextSize = 13
ingredientsHeader.TextColor3 = Color3.fromRGB(156, 163, 175)
ingredientsHeader.Text = "REQUIRED INGREDIENTS:"
ingredientsHeader.TextXAlignment = Enum.TextXAlignment.Left
ingredientsHeader.Parent = craftDetail

local ingredientsFrame = Instance.new("Frame")
ingredientsFrame.Size = UDim2.new(1, -20, 0, 180)
ingredientsFrame.Position = UDim2.new(0, 10, 0, 118)
ingredientsFrame.BackgroundTransparency = 1
ingredientsFrame.Parent = craftDetail

local ingListLayout = Instance.new("UIListLayout")
ingListLayout.Padding = UDim.new(0, 6)
ingListLayout.Parent = ingredientsFrame

local craftActionBtn = Instance.new("TextButton")
craftActionBtn.Size = UDim2.new(1, -20, 0, 44)
craftActionBtn.Position = UDim2.new(0, 10, 1, -54)
craftActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
craftActionBtn.Font = Enum.Font.GothamBlack
craftActionBtn.TextSize = 16
craftActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
craftActionBtn.Text = "⚗️ FORGE RECIPE"
craftActionBtn.Visible = false
addCorner(craftActionBtn, 10)
craftActionBtn.Parent = craftDetail

local function refreshCraftingUI()
	for _, child in ipairs(recipeListScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, recipe in ipairs(AuraConfig.Recipes) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 52)
		btn.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
		btn.Text = ""
		addCorner(btn, 8)
		addStroke(btn, recipe.Color, 1.2)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -12, 0, 22)
		title.Position = UDim2.new(0, 8, 0, 6)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextColor3 = recipe.Color
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = recipe.Name
		title.Parent = btn

		local typeLabel = Instance.new("TextLabel")
		typeLabel.Size = UDim2.new(1, -12, 0, 16)
		typeLabel.Position = UDim2.new(0, 8, 0, 28)
		typeLabel.BackgroundTransparency = 1
		typeLabel.Font = Enum.Font.Gotham
		typeLabel.TextSize = 11
		typeLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.Text = string.format("Type: %s", recipe.ResultType)
		typeLabel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedCraftRecipe = recipe
			craftResultName.Text = recipe.Name
			craftResultName.TextColor3 = recipe.Color
			craftResultDesc.Text = recipe.Description

			-- Clear ingredients frame
			for _, child in ipairs(ingredientsFrame:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			local canCraftAll = true
			for _, ing in ipairs(recipe.Ingredients) do
				local owned = localData.Inventory[ing.AuraId] or 0
				local auraData = AuraConfig.Auras[ing.AuraId]
				local auraName = auraData and auraData.Name or ing.AuraId
				local auraColor = auraData and auraData.Color or Color3.fromRGB(220, 225, 240)

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 32)
				row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
				addCorner(row, 6)
				row.Parent = ingredientsFrame

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 8, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Font = Enum.Font.GothamBold
				nameLbl.TextSize = 12
				nameLbl.TextColor3 = auraColor
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.Text = auraName
				nameLbl.Parent = row

				local countLbl = Instance.new("TextLabel")
				countLbl.Size = UDim2.new(0.3, 0, 1, 0)
				countLbl.Position = UDim2.new(0.68, 0, 0, 0)
				countLbl.BackgroundTransparency = 1
				countLbl.Font = Enum.Font.GothamBold
				countLbl.TextSize = 12
				if owned >= ing.Count then
					countLbl.TextColor3 = Color3.fromRGB(74, 222, 128)
					countLbl.Text = string.format("✓ %d / %d", owned, ing.Count)
				else
					countLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
					countLbl.Text = string.format("✕ %d / %d", owned, ing.Count)
					canCraftAll = false
				end
				countLbl.Parent = row
			end

			craftActionBtn.Visible = true
			if canCraftAll then
				craftActionBtn.Text = "⚗️ FORGE NOW"
				craftActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			else
				craftActionBtn.Text = "Missing Auras"
				craftActionBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
			end
		end)

		btn.Parent = recipeListScroll
	end

	recipeListScroll.CanvasSize = UDim2.new(0, 0, 0, recipeListLayout.AbsoluteContentSize.Y + 20)
end

craftActionBtn.MouseButton1Click:Connect(function()
	if not selectedCraftRecipe then return end
	SoundEffects.Play("Click")
	local result = CraftAuraFunc:InvokeServer(selectedCraftRecipe.Id)
	if result and result.Success then
		SoundEffects.Play("Craft")
		refreshCraftingUI()
		refreshInventoryUI()
	end
end)

--------------------------------------------------------------------------------
-- 3. SHOP & GAMEPASSES WINDOW
--------------------------------------------------------------------------------

local shopWindow, shopContent = createModalWindow("🛒 SHOP & PASSES (TEST MODE INCLUDED)", 700, 480)

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, 0)
shopScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
shopScroll.BackgroundTransparency = 0.5
shopScroll.ScrollBarThickness = 6
addCorner(shopScroll, 8)
shopScroll.Parent = shopContent

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.Parent = shopScroll

local passItems = {
	{
		Id = "X2Luck",
		Name = "🎲 x2 Luck Pass",
		Color = Color3.fromRGB(74, 222, 128),
		Desc = "Permanently doubles your chance for all rare, mythic, and godly auras!",
		PerkKey = "X2Luck",
	},
	{
		Id = "AutoRoll",
		Name = "⚡ Auto Roll Pass",
		Color = Color3.fromRGB(250, 204, 21),
		Desc = "Automatically rolls in the background while you chat, explore, or AFK!",
		PerkKey = "AutoRoll",
	},
	{
		Id = "ExtraStorage",
		Name = "🎨 Aura Storage (+30)",
		Color = Color3.fromRGB(56, 189, 248),
		Desc = "Expands your aura inventory capacity by +30 slots to keep all your treasures!",
		PerkKey = "ExtraStorage",
	},
	{
		Id = "VIP",
		Name = "⭐ VIP Supporter Pass",
		Color = Color3.fromRGB(245, 158, 11),
		Desc = "Exclusive VIP Crown Aura + x1.5 Permanent Luck + Golden VIP Chat & Overhead Tag!",
		PerkKey = "VIP",
	},
}

local function refreshShopUI()
	for _, child in ipairs(shopScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, item in ipairs(passItems) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -12, 0, 84)
		row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		addCorner(row, 8)
		addStroke(row, item.Color, 1.2)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.65, 0, 0, 24)
		nameLbl.Position = UDim2.new(0, 12, 0, 10)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = Enum.Font.GothamBlack
		nameLbl.TextSize = 16
		nameLbl.TextColor3 = item.Color
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Text = item.Name
		nameLbl.Parent = row

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(0.65, 0, 0, 38)
		descLbl.Position = UDim2.new(0, 12, 0, 36)
		descLbl.BackgroundTransparency = 1
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 12
		descLbl.TextColor3 = Color3.fromRGB(180, 185, 200)
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextWrapped = true
		descLbl.Text = item.Desc
		descLbl.Parent = row

		-- Test Toggle Button
		local testBtn = Instance.new("TextButton")
		testBtn.Size = UDim2.new(0, 170, 0, 42)
		testBtn.Position = UDim2.new(1, -182, 0.5, -21)
		testBtn.Font = Enum.Font.GothamBold
		testBtn.TextSize = 12
		addCorner(testBtn, 8)

		local isOwned = (localData.Gamepasses and localData.Gamepasses[item.PerkKey])
			or (localData.TestPerks and localData.TestPerks[item.PerkKey])

		if isOwned then
			testBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			testBtn.Text = "ACTIVE (TEST ON)"
		else
			testBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
			testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			testBtn.Text = "TEST FOR FREE"
		end

		testBtn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			ToggleTestPerkEvent:FireServer(item.PerkKey)
		end)

		testBtn.Parent = row
		row.Parent = shopScroll
	end

	shopScroll.CanvasSize = UDim2.new(0, 0, 0, shopLayout.AbsoluteContentSize.Y + 20)
end

--------------------------------------------------------------------------------
-- 4. SETTINGS WINDOW
--------------------------------------------------------------------------------

local settingsWindow, setContent = createModalWindow("⚙️ SETTINGS", 450, 260)

local setFastRollBtn = Instance.new("TextButton")
setFastRollBtn.Size = UDim2.new(1, 0, 0, 44)
setFastRollBtn.Position = UDim2.new(0, 0, 0, 10)
setFastRollBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setFastRollBtn.Font = Enum.Font.GothamBold
setFastRollBtn.TextSize = 14
setFastRollBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
addCorner(setFastRollBtn, 8)
addStroke(setFastRollBtn, Color3.fromRGB(45, 52, 70), 1)
setFastRollBtn.Parent = setContent

local setAutoDeleteInfo = Instance.new("TextLabel")
setAutoDeleteInfo.Size = UDim2.new(1, 0, 0, 44)
setAutoDeleteInfo.Position = UDim2.new(0, 0, 0, 68)
setAutoDeleteInfo.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setAutoDeleteInfo.Font = Enum.Font.GothamMedium
setAutoDeleteInfo.TextSize = 13
setAutoDeleteInfo.TextColor3 = Color3.fromRGB(200, 205, 220)
setAutoDeleteInfo.Text = "Auto-Delete: Configure inside Inventory"
addCorner(setAutoDeleteInfo, 8)
setAutoDeleteInfo.Parent = setContent

setFastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: ON"
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
	end
end)

--------------------------------------------------------------------------------
-- 5. ROLL REVEAL CUTSCENE OVERLAY
--------------------------------------------------------------------------------

local cutsceneOverlay = Instance.new("Frame")
cutsceneOverlay.Name = "CutsceneOverlay"
cutsceneOverlay.Size = UDim2.new(1, 0, 1, 0)
cutsceneOverlay.BackgroundColor3 = Color3.fromRGB(5, 6, 10)
cutsceneOverlay.BackgroundTransparency = 0.35
cutsceneOverlay.Visible = false
cutsceneOverlay.Parent = screenGui

local revealCard = Instance.new("Frame")
revealCard.Name = "RevealCard"
revealCard.Size = UDim2.new(0, 360, 0, 420)
revealCard.Position = UDim2.new(0.5, -180, 0.5, -210)
revealCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
addCorner(revealCard, 16)
local cardStroke = addStroke(revealCard, Color3.fromRGB(255, 255, 255), 2.5)
revealCard.Parent = cutsceneOverlay

local cardTierTag = Instance.new("TextLabel")
cardTierTag.Size = UDim2.new(1, 0, 0, 28)
cardTierTag.Position = UDim2.new(0, 0, 0, 24)
cardTierTag.BackgroundTransparency = 1
cardTierTag.Font = Enum.Font.GothamBlack
cardTierTag.TextSize = 14
cardTierTag.TextColor3 = Color3.fromRGB(156, 163, 175)
cardTierTag.Text = "[ TIER ]"
cardTierTag.Parent = revealCard

local cardName = Instance.new("TextLabel")
cardName.Size = UDim2.new(1, -20, 0, 42)
cardName.Position = UDim2.new(0, 10, 0, 52)
cardName.BackgroundTransparency = 1
cardName.Font = Enum.Font.GothamBlack
cardName.TextSize = 28
cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
cardName.Text = "Aura Name"
cardName.Parent = revealCard

local cardRarity = Instance.new("TextLabel")
cardRarity.Size = UDim2.new(1, 0, 0, 28)
cardRarity.Position = UDim2.new(0, 0, 0, 100)
cardRarity.BackgroundTransparency = 1
cardRarity.Font = Enum.Font.GothamBold
cardRarity.TextSize = 18
cardRarity.TextColor3 = Color3.fromRGB(240, 243, 250)
cardRarity.Text = "1 in 100,000"
cardRarity.Parent = revealCard

local cardDesc = Instance.new("TextLabel")
cardDesc.Size = UDim2.new(1, -40, 0, 100)
cardDesc.Position = UDim2.new(0, 20, 0, 140)
cardDesc.BackgroundTransparency = 1
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextSize = 13
cardDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
cardDesc.TextWrapped = true
cardDesc.Text = "Aura description..."
cardDesc.Parent = revealCard

local cardEquipBtn = Instance.new("TextButton")
cardEquipBtn.Size = UDim2.new(0, 150, 0, 44)
cardEquipBtn.Position = UDim2.new(0.5, -160, 1, -64)
cardEquipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
cardEquipBtn.Font = Enum.Font.GothamBold
cardEquipBtn.TextSize = 15
cardEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardEquipBtn.Text = "EQUIP"
addCorner(cardEquipBtn, 10)
cardEquipBtn.Parent = revealCard

local cardCloseBtn = Instance.new("TextButton")
cardCloseBtn.Size = UDim2.new(0, 150, 0, 44)
cardCloseBtn.Position = UDim2.new(0.5, 10, 1, -64)
cardCloseBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
cardCloseBtn.Font = Enum.Font.GothamBold
cardCloseBtn.TextSize = 15
cardCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardCloseBtn.Text = "COLLECT"
addCorner(cardCloseBtn, 10)
cardCloseBtn.Parent = revealCard

local currentRolledAura = nil

local function showCutscene(auraData)
	currentRolledAura = auraData
	cardTierTag.Text = string.format("[ %s ]", auraData.Tier:upper())
	cardName.Text = auraData.Name
	cardName.TextColor3 = auraData.Color
	cardRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
	cardDesc.Text = auraData.Description
	cardStroke.Color = auraData.Color

	-- Play sound matching rarity tier
	if auraData.Rarity >= 250000 then
		SoundEffects.Play("RevealGodly")
	elseif auraData.Rarity >= 10000 then
		SoundEffects.Play("RevealMythic")
	elseif auraData.Rarity >= 1000 then
		SoundEffects.Play("RevealLegendary")
	elseif auraData.Rarity >= 16 then
		SoundEffects.Play("RevealRare")
	else
		SoundEffects.Play("RevealCommon")
	end

	cutsceneOverlay.Visible = true

	-- Entrance animation
	revealCard.Size = UDim2.new(0, 100, 0, 100)
	TweenService:Create(revealCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 360, 0, 420),
	}):Play()
end

cardEquipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		EquipAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardCloseBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	cutsceneOverlay.Visible = false
end)

--------------------------------------------------------------------------------
-- 6. GLOBAL ANNOUNCEMENT BANNER
--------------------------------------------------------------------------------

local banner = Instance.new("Frame")
banner.Name = "GlobalBanner"
banner.Size = UDim2.new(0, 520, 0, 44)
banner.Position = UDim2.new(0.5, -260, 0, -60) -- Start off-screen
banner.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
banner.BackgroundTransparency = 0.1
addCorner(banner, 10)
local bannerStroke = addStroke(banner, Color3.fromRGB(250, 204, 21), 2)
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.new(1, -20, 1, 0)
bannerText.Position = UDim2.new(0, 10, 0, 0)
bannerText.BackgroundTransparency = 1
bannerText.Font = Enum.Font.GothamBold
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.fromRGB(255, 235, 120)
bannerText.Text = "🎉 Player rolled MYTHIC!"
bannerText.Parent = banner

GlobalAnnouncementEvent.OnClientEvent:Connect(function(info)
	local tierColor = AuraConfig.GetTierColor(info.Tier)
	bannerStroke.Color = tierColor
	bannerText.Text = string.format("🎉 %s rolled %s (%s)!", info.PlayerName, info.AuraName:upper(), AuraConfig.FormatRarity(info.Rarity))
	bannerText.TextColor3 = tierColor

	-- Slide down
	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -260, 0, 68),
	}):Play()

	task.delay(4.5, function()
		TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -260, 0, -60),
		}):Play()
	end)
end)

--------------------------------------------------------------------------------
-- 7. ROLL TRIGGER & BUTTON EVENTS
--------------------------------------------------------------------------------

local function doRoll()
	if isRolling then return end
	isRolling = true

	-- Button bounce
	TweenService:Create(rollButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 195, 0, 56),
	}):Play()

	SoundEffects.Play("Spin")

	local result = RollRequestFunc:InvokeServer(isFastRollOn)

	task.wait(0.12)
	TweenService:Create(rollButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 210, 0, 62),
	}):Play()

	if result and result.Success and result.Aura then
		if not isFastRollOn then
			showCutscene(result.Aura)
		else
			-- Fast roll: play sound only
			SoundEffects.Play("RevealCommon")
		end
	end

	isRolling = false
end

rollButton.MouseButton1Click:Connect(function()
	doRoll()
end)

-- Auto Roll Loop
autoRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isAutoRollOn = not isAutoRollOn
	if isAutoRollOn then
		autoRollBtn.Text = "⚡ AUTO: ON"
		autoRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 55, 35)
	else
		autoRollBtn.Text = "⚡ AUTO: OFF"
		autoRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
	end
end)

task.spawn(function()
	while true do
		task.wait(AuraConfig.Settings.AutoRollInterval)
		if isAutoRollOn and not isRolling and not cutsceneOverlay.Visible then
			doRoll()
		end
	end
end)

fastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: ON"
	else
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
	end
end)

unequipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	EquipAuraEvent:FireServer("None")
end)

-- Navigation button clicks
navInventoryBtn.MouseButton1Click:Connect(function()
	toggleModal(inventoryWindow)
	refreshInventoryUI()
end)

navCraftingBtn.MouseButton1Click:Connect(function()
	toggleModal(craftWindow)
	refreshCraftingUI()
end)

navShopBtn.MouseButton1Click:Connect(function()
	toggleModal(shopWindow)
	refreshShopUI()
end)

navSettingsBtn.MouseButton1Click:Connect(function()
	toggleModal(settingsWindow)
end)

-- 3D World ProximityPrompt Trigger for Crafting Altar
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	if prompt.Name == "CraftingPrompt" and player == LocalPlayer then
		if not craftWindow.Visible then
			toggleModal(craftWindow)
		end
		refreshCraftingUI()
	end
end)

--------------------------------------------------------------------------------
-- 8. DATA SYNC RECEIVER
--------------------------------------------------------------------------------

DataSyncEvent.OnClientEvent:Connect(function(data)
	for k, v in pairs(data) do
		localData[k] = v
	end

	-- Update Top Stats
	rollsLabel.Text = string.format("🎲 Rolls: %s", AuraConfig.FormatNumber(localData.Rolls or 0))
	luckLabel.Text = string.format("🍀 Luck: x%.1f", localData.CurrentLuck or 1.0)
	coinsLabel.Text = string.format("🪙 %s", AuraConfig.FormatNumber(localData.Coins or 0))

	-- Update Potion label
	if localData.PotionExpiry and localData.PotionExpiry > os.time() then
		local remaining = localData.PotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format("⏳ 2x Pot: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		potionLabel.Text = "⏳ Pot: None"
		potionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
	end

	-- Update Equipped Card
	local eqAura = AuraConfig.Auras[localData.EquippedAura]
	if eqAura then
		equippedTitle.Text = eqAura.Name
		equippedTitle.TextColor3 = eqAura.Color
		equippedSubtitle.Text = AuraConfig.FormatRarity(eqAura.Rarity or 0)
	else
		equippedTitle.Text = "Aura: None"
		equippedTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
		equippedSubtitle.Text = "Not Equipped"
	end

	-- Update Auto Delete Threshold Text
	local autoDelText = thresholdNames[localData.AutoDeleteThreshold or 0] or "None"
	autoDeleteBtn.Text = "Auto-Delete: " .. autoDelText

	-- Refresh open modal if visible
	if inventoryWindow.Visible then refreshInventoryUI() end
	if craftWindow.Visible then refreshCraftingUI() end
	if shopWindow.Visible then refreshShopUI() end
end)

print("[Sols RNG] Client GUI initialized!")
]===]
else
	if existingClientScript then existingClientScript:Destroy() end
	local clientScript = Instance.new("LocalScript")
	clientScript.Name = "RNGClient"
	clientScript.Source = [===[-- RNGClient.client.lua
-- Client controller and complete GUI manager for Sol's RNG game.
-- Manages HUD, Rolling Animations, Cutscenes, Inventory, Crafting, Shop & Passes, and Settings.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ReplicatedStorage references
local AuraRNGFolder = ReplicatedStorage:WaitForChild("AuraRNG")
local EventsFolder = AuraRNGFolder:WaitForChild("Events")
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")

local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local SoundEffects = require(ModulesFolder:WaitForChild("SoundEffects"))

-- Remotes
local RollRequestFunc = EventsFolder:WaitForChild("RollRequest")
local CraftAuraFunc = EventsFolder:WaitForChild("CraftAura")
local EquipAuraEvent = EventsFolder:WaitForChild("EquipAura")
local DeleteAuraEvent = EventsFolder:WaitForChild("DeleteAura")
local SetAutoDeleteEvent = EventsFolder:WaitForChild("SetAutoDelete")
local ToggleTestPerkEvent = EventsFolder:WaitForChild("ToggleTestPerk")
local DataSyncEvent = EventsFolder:WaitForChild("DataSync")
local GlobalAnnouncementEvent = EventsFolder:WaitForChild("GlobalAnnouncement")

-- Local Player Cache State
local localData = {
	Rolls = 0,
	Coins = 100,
	BestAura = "None",
	BestRarity = 1,
	EquippedAura = "None",
	EquippedGear = "None",
	Inventory = {},
	MaxStorage = 20,
	AutoDeleteThreshold = 0,
	PotionExpiry = 0,
	Gamepasses = {},
	TestPerks = {},
	CurrentLuck = 1.0,
}

local isAutoRollOn = false
local isFastRollOn = false
local isRolling = false
local selectedInventoryAura = nil
local selectedCraftRecipe = nil

--------------------------------------------------------------------------------
-- UI CONSTRUCTION & INSTANCES
--------------------------------------------------------------------------------

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RNG_ScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui
end

-- Helper: Rounded corner
local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = parent
	return corner
end

-- Helper: Stroke outline
local function addStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(60, 65, 80)
	stroke.Thickness = thickness or 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- Top HUD Container
local topHud = Instance.new("Frame")
topHud.Name = "TopHUD"
topHud.Size = UDim2.new(0, 720, 0, 48)
topHud.Position = UDim2.new(0.5, -360, 0, 14)
topHud.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
topHud.BackgroundTransparency = 0.15
addCorner(topHud, 12)
addStroke(topHud, Color3.fromRGB(45, 52, 70), 1.5)
topHud.Parent = screenGui

local topListLayout = Instance.new("UIListLayout")
topListLayout.FillDirection = Enum.FillDirection.Horizontal
topListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topListLayout.Padding = UDim.new(0, 20)
topListLayout.Parent = topHud

-- Top Stat Labels
local function createTopStat(icon, defaultText, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 140, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 15
	label.TextColor3 = color
	label.Text = icon .. " " .. defaultText
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = topHud
	return label
end

local rollsLabel = createTopStat("🎲", "Rolls: 0", Color3.fromRGB(220, 225, 240))
local luckLabel = createTopStat("🍀", "Luck: x1.0", Color3.fromRGB(74, 222, 128))
local coinsLabel = createTopStat("🪙", "Coins: 100", Color3.fromRGB(250, 204, 21))
local potionLabel = createTopStat("⏳", "Potion: None", Color3.fromRGB(56, 189, 248))

-- Bottom Center Controls Container
local bottomControls = Instance.new("Frame")
bottomControls.Name = "BottomControls"
bottomControls.Size = UDim2.new(0, 400, 0, 100)
bottomControls.Position = UDim2.new(0.5, -200, 1, -115)
bottomControls.BackgroundTransparency = 1
bottomControls.Parent = screenGui

-- Big ROLL Button
local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.Size = UDim2.new(0, 210, 0, 62)
rollButton.Position = UDim2.new(0.5, -105, 0, 0)
rollButton.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
rollButton.Font = Enum.Font.GothamBlack
rollButton.TextSize = 24
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.Text = "🎲 ROLL"
addCorner(rollButton, 14)
addStroke(rollButton, Color3.fromRGB(96, 165, 250), 2)
rollButton.Parent = bottomControls

-- Roll Button Gradient
local rollGradient = Instance.new("UIGradient")
rollGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 78, 216)),
})
rollGradient.Rotation = 45
rollGradient.Parent = rollButton

-- Auto Roll Button
local autoRollBtn = Instance.new("TextButton")
autoRollBtn.Name = "AutoRollButton"
autoRollBtn.Size = UDim2.new(0, 130, 0, 32)
autoRollBtn.Position = UDim2.new(0.5, -140, 1, -34)
autoRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
autoRollBtn.Font = Enum.Font.GothamBold
autoRollBtn.TextSize = 13
autoRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
autoRollBtn.Text = "⚡ AUTO: OFF"
addCorner(autoRollBtn, 8)
addStroke(autoRollBtn, Color3.fromRGB(55, 62, 80), 1)
autoRollBtn.Parent = bottomControls

-- Fast Roll Button
local fastRollBtn = Instance.new("TextButton")
fastRollBtn.Name = "FastRollButton"
fastRollBtn.Size = UDim2.new(0, 130, 0, 32)
fastRollBtn.Position = UDim2.new(0.5, 10, 1, -34)
fastRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
fastRollBtn.Font = Enum.Font.GothamBold
fastRollBtn.TextSize = 13
fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
fastRollBtn.Text = "⏩ FAST: OFF"
addCorner(fastRollBtn, 8)
addStroke(fastRollBtn, Color3.fromRGB(55, 62, 80), 1)
fastRollBtn.Parent = bottomControls

-- Left Navigation Bar
local leftNav = Instance.new("Frame")
leftNav.Name = "LeftNav"
leftNav.Size = UDim2.new(0, 68, 0, 280)
leftNav.Position = UDim2.new(0, 16, 0.5, -140)
leftNav.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
leftNav.BackgroundTransparency = 0.2
addCorner(leftNav, 14)
addStroke(leftNav, Color3.fromRGB(45, 52, 70), 1.5)
leftNav.Parent = screenGui

local navListLayout = Instance.new("UIListLayout")
navListLayout.FillDirection = Enum.FillDirection.Vertical
navListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navListLayout.Padding = UDim.new(0, 12)
navListLayout.Parent = leftNav

local function createNavButton(name, icon, tooltip)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Btn"
	btn.Size = UDim2.new(0, 52, 0, 52)
	btn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 22
	btn.Text = icon
	addCorner(btn, 10)
	addStroke(btn, Color3.fromRGB(50, 58, 78), 1.2)
	btn.Parent = leftNav
	return btn
end

local navInventoryBtn = createNavButton("Inventory", "🎒", "Inventory")
local navCraftingBtn = createNavButton("Crafting", "⚗️", "Crafting")
local navShopBtn = createNavButton("Shop", "🛒", "Shop & Passes")
local navSettingsBtn = createNavButton("Settings", "⚙️", "Settings")

-- Bottom Left: Equipped Aura Card
local equippedCard = Instance.new("Frame")
equippedCard.Name = "EquippedCard"
equippedCard.Size = UDim2.new(0, 210, 0, 62)
equippedCard.Position = UDim2.new(0, 16, 1, -78)
equippedCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
equippedCard.BackgroundTransparency = 0.2
addCorner(equippedCard, 10)
addStroke(equippedCard, Color3.fromRGB(45, 52, 70), 1.5)
equippedCard.Parent = screenGui

local equippedTitle = Instance.new("TextLabel")
equippedTitle.Size = UDim2.new(1, -65, 0, 20)
equippedTitle.Position = UDim2.new(0, 12, 0, 10)
equippedTitle.BackgroundTransparency = 1
equippedTitle.Font = Enum.Font.GothamBold
equippedTitle.TextSize = 14
equippedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
equippedTitle.TextXAlignment = Enum.TextXAlignment.Left
equippedTitle.Text = "Aura: None"
equippedTitle.Parent = equippedCard

local equippedSubtitle = Instance.new("TextLabel")
equippedSubtitle.Size = UDim2.new(1, -65, 0, 16)
equippedSubtitle.Position = UDim2.new(0, 12, 0, 32)
equippedSubtitle.BackgroundTransparency = 1
equippedSubtitle.Font = Enum.Font.GothamMedium
equippedSubtitle.TextSize = 12
equippedSubtitle.TextColor3 = Color3.fromRGB(156, 163, 175)
equippedSubtitle.TextXAlignment = Enum.TextXAlignment.Left
equippedSubtitle.Text = "Not Equipped"
equippedSubtitle.Parent = equippedCard

local unequipBtn = Instance.new("TextButton")
unequipBtn.Name = "UnequipBtn"
unequipBtn.Size = UDim2.new(0, 42, 0, 42)
unequipBtn.Position = UDim2.new(1, -52, 0.5, -21)
unequipBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
unequipBtn.Font = Enum.Font.GothamBold
unequipBtn.TextSize = 12
unequipBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
unequipBtn.Text = "✕"
addCorner(unequipBtn, 8)
unequipBtn.Parent = equippedCard

--------------------------------------------------------------------------------
-- MODAL WINDOW HELPER
--------------------------------------------------------------------------------

local activeModal = nil

local function createModalWindow(titleText, width, height)
	local window = Instance.new("Frame")
	window.Size = UDim2.new(0, width, 0, height)
	window.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
	window.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	window.BackgroundTransparency = 0.05
	window.Visible = false
	addCorner(window, 14)
	addStroke(window, Color3.fromRGB(55, 65, 88), 2)
	window.Parent = screenGui

	-- Header Bar
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	header.BackgroundTransparency = 0.3
	addCorner(header, 14)
	header.Parent = window

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 18, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 18
	titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = titleText
	titleLabel.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
	closeBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
	closeBtn.Text = "✕"
	addCorner(closeBtn, 8)
	closeBtn.Parent = header

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -32, 1, -64)
	content.Position = UDim2.new(0, 16, 0, 54)
	content.BackgroundTransparency = 1
	content.Parent = window

	closeBtn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		window.Visible = false
		if activeModal == window then
			activeModal = nil
		end
	end)

	return window, content, closeBtn
end

local function toggleModal(modal)
	SoundEffects.Play("Click")
	if activeModal == modal then
		modal.Visible = false
		activeModal = nil
	else
		if activeModal then
			activeModal.Visible = false
		end
		modal.Visible = true
		activeModal = modal
	end
end

--------------------------------------------------------------------------------
-- 1. INVENTORY WINDOW
--------------------------------------------------------------------------------

local inventoryWindow, invContent = createModalWindow("🎒 AURA INVENTORY", 680, 480)

-- Top Storage Bar
local storageInfo = Instance.new("TextLabel")
storageInfo.Size = UDim2.new(0, 200, 0, 24)
storageInfo.Position = UDim2.new(0, 0, 0, 0)
storageInfo.BackgroundTransparency = 1
storageInfo.Font = Enum.Font.GothamBold
storageInfo.TextSize = 14
storageInfo.TextColor3 = Color3.fromRGB(156, 163, 175)
storageInfo.TextXAlignment = Enum.TextXAlignment.Left
storageInfo.Text = "Storage: 0 / 20"
storageInfo.Parent = invContent

-- Auto Delete Threshold Dropdown/Button
local autoDeleteBtn = Instance.new("TextButton")
autoDeleteBtn.Size = UDim2.new(0, 180, 0, 26)
autoDeleteBtn.Position = UDim2.new(1, -180, 0, 0)
autoDeleteBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
autoDeleteBtn.Font = Enum.Font.GothamMedium
autoDeleteBtn.TextSize = 12
autoDeleteBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
autoDeleteBtn.Text = "Auto-Delete: None"
addCorner(autoDeleteBtn, 6)
addStroke(autoDeleteBtn, Color3.fromRGB(50, 58, 78), 1)
autoDeleteBtn.Parent = invContent

-- Left Grid Container
local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -210, 1, -36)
invScroll.Position = UDim2.new(0, 0, 0, 32)
invScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
invScroll.BackgroundTransparency = 0.5
invScroll.ScrollBarThickness = 6
invScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 70, 95)
addCorner(invScroll, 8)
invScroll.Parent = invContent

local invGrid = Instance.new("UIGridLayout")
invGrid.CellSize = UDim2.new(0, 100, 0, 100)
invGrid.CellPadding = UDim2.new(0, 8, 0, 8)
invGrid.Parent = invScroll

-- Right Detail Panel
local detailPanel = Instance.new("Frame")
detailPanel.Size = UDim2.new(0, 195, 1, -36)
detailPanel.Position = UDim2.new(1, -195, 0, 32)
detailPanel.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
addCorner(detailPanel, 8)
addStroke(detailPanel, Color3.fromRGB(40, 48, 65), 1)
detailPanel.Parent = invContent

local detailName = Instance.new("TextLabel")
detailName.Size = UDim2.new(1, -16, 0, 28)
detailName.Position = UDim2.new(0, 8, 0, 10)
detailName.BackgroundTransparency = 1
detailName.Font = Enum.Font.GothamBlack
detailName.TextSize = 16
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.Text = "Select an Aura"
detailName.Parent = detailPanel

local detailRarity = Instance.new("TextLabel")
detailRarity.Size = UDim2.new(1, -16, 0, 20)
detailRarity.Position = UDim2.new(0, 8, 0, 38)
detailRarity.BackgroundTransparency = 1
detailRarity.Font = Enum.Font.GothamBold
detailRarity.TextSize = 13
detailRarity.TextColor3 = Color3.fromRGB(156, 163, 175)
detailRarity.Text = ""
detailRarity.Parent = detailPanel

local detailDesc = Instance.new("TextLabel")
detailDesc.Size = UDim2.new(1, -16, 0, 80)
detailDesc.Position = UDim2.new(0, 8, 0, 64)
detailDesc.BackgroundTransparency = 1
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 12
detailDesc.TextColor3 = Color3.fromRGB(200, 205, 220)
detailDesc.TextWrapped = true
detailDesc.TextYAlignment = Enum.TextYAlignment.Top
detailDesc.Text = "Click any aura card on the left to equip or manage."
detailDesc.Parent = detailPanel

local equipActionBtn = Instance.new("TextButton")
equipActionBtn.Size = UDim2.new(1, -20, 0, 38)
equipActionBtn.Position = UDim2.new(0, 10, 1, -94)
equipActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
equipActionBtn.Font = Enum.Font.GothamBold
equipActionBtn.TextSize = 14
equipActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipActionBtn.Text = "Equip"
equipActionBtn.Visible = false
addCorner(equipActionBtn, 8)
equipActionBtn.Parent = detailPanel

local deleteActionBtn = Instance.new("TextButton")
deleteActionBtn.Size = UDim2.new(1, -20, 0, 36)
deleteActionBtn.Position = UDim2.new(0, 10, 1, -48)
deleteActionBtn.BackgroundColor3 = Color3.fromRGB(45, 25, 28)
deleteActionBtn.Font = Enum.Font.GothamMedium
deleteActionBtn.TextSize = 12
deleteActionBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
deleteActionBtn.Text = "Scrap (+Coins)"
deleteActionBtn.Visible = false
addCorner(deleteActionBtn, 8)
deleteActionBtn.Parent = detailPanel

-- Function to refresh inventory UI
local function refreshInventoryUI()
	-- Clear old item cards
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local totalCount = 0
	for auraId, count in pairs(localData.Inventory) do
		totalCount = totalCount + count
		local auraData = AuraConfig.Auras[auraId]
		if auraData then
			local card = Instance.new("TextButton")
			card.Name = "Card_" .. auraId
			card.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			card.Text = ""
			addCorner(card, 8)
			local stroke = addStroke(card, auraData.Color, 1.5)

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -8, 0, 28)
			name.Position = UDim2.new(0, 4, 0, 6)
			name.BackgroundTransparency = 1
			name.Font = Enum.Font.GothamBold
			name.TextSize = 12
			name.TextColor3 = auraData.Color
			name.Text = auraData.Name
			name.TextWrapped = true
			name.Parent = card

			local rarity = Instance.new("TextLabel")
			rarity.Size = UDim2.new(1, -8, 0, 16)
			rarity.Position = UDim2.new(0, 4, 0, 36)
			rarity.BackgroundTransparency = 1
			rarity.Font = Enum.Font.GothamMedium
			rarity.TextSize = 10
			rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
			rarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
			rarity.Parent = card

			local countTag = Instance.new("TextLabel")
			countTag.Size = UDim2.new(0, 30, 0, 16)
			countTag.Position = UDim2.new(1, -34, 1, -20)
			countTag.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
			countTag.Font = Enum.Font.GothamBold
			countTag.TextSize = 10
			countTag.TextColor3 = Color3.fromRGB(220, 225, 240)
			countTag.Text = "x" .. tostring(count)
			addCorner(countTag, 4)
			countTag.Parent = card

			-- Equipped Indicator
			if localData.EquippedAura == auraId then
				local eqTag = Instance.new("TextLabel")
				eqTag.Size = UDim2.new(0, 52, 0, 16)
				eqTag.Position = UDim2.new(0, 4, 1, -20)
				eqTag.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				eqTag.Font = Enum.Font.GothamBold
				eqTag.TextSize = 9
				eqTag.TextColor3 = Color3.fromRGB(255, 255, 255)
				eqTag.Text = "EQUIPPED"
				addCorner(eqTag, 4)
				eqTag.Parent = card
			end

			card.MouseButton1Click:Connect(function()
				SoundEffects.Play("Click")
				selectedInventoryAura = auraId
				detailName.Text = auraData.Name
				detailName.TextColor3 = auraData.Color
				detailRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
				detailDesc.Text = auraData.Description

				equipActionBtn.Visible = true
				if localData.EquippedAura == auraId then
					equipActionBtn.Text = "Unequip"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
				else
					equipActionBtn.Text = "Equip"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
				end
				deleteActionBtn.Visible = true
			end)

			card.Parent = invScroll
		end
	end

	storageInfo.Text = string.format("Storage: %d / %d", totalCount, localData.MaxStorage)
	invScroll.CanvasSize = UDim2.new(0, 0, 0, invGrid.AbsoluteContentSize.Y + 20)
end

equipActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Equip")
	if localData.EquippedAura == selectedInventoryAura then
		EquipAuraEvent:FireServer("None")
	else
		EquipAuraEvent:FireServer(selectedInventoryAura)
	end
end)

deleteActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Click")
	DeleteAuraEvent:FireServer(selectedInventoryAura)
	selectedInventoryAura = nil
	equipActionBtn.Visible = false
	deleteActionBtn.Visible = false
	detailName.Text = "Select an Aura"
	detailRarity.Text = ""
	detailDesc.Text = "Aura scrapped for coins."
end)

-- Cycle auto-delete threshold
local thresholds = { 0, 2, 4, 16, 64 }
local thresholdNames = { [0] = "None", [2] = "Common (1/2)", [4] = "Uncommon (1/4)", [16] = "Rare (1/16)", [64] = "Crystallized (1/64)" }
autoDeleteBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	local cur = localData.AutoDeleteThreshold or 0
	local nextIdx = 1
	for i, v in ipairs(thresholds) do
		if v == cur then
			nextIdx = (i % #thresholds) + 1
			break
		end
	end
	local nextVal = thresholds[nextIdx]
	SetAutoDeleteEvent:FireServer(nextVal)
end)

--------------------------------------------------------------------------------
-- 2. CRAFTING ALCHEMIST WINDOW
--------------------------------------------------------------------------------

local craftWindow, craftContent = createModalWindow("⚗️ ALCHEMIST CRAFTING FORGE", 720, 500)

local recipeListScroll = Instance.new("ScrollingFrame")
recipeListScroll.Size = UDim2.new(0, 240, 1, 0)
recipeListScroll.Position = UDim2.new(0, 0, 0, 0)
recipeListScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
recipeListScroll.BackgroundTransparency = 0.5
recipeListScroll.ScrollBarThickness = 4
addCorner(recipeListScroll, 8)
recipeListScroll.Parent = craftContent

local recipeListLayout = Instance.new("UIListLayout")
recipeListLayout.Padding = UDim.new(0, 8)
recipeListLayout.Parent = recipeListScroll

-- Recipe Details & Ingredients Panel
local craftDetail = Instance.new("Frame")
craftDetail.Size = UDim2.new(1, -255, 1, 0)
craftDetail.Position = UDim2.new(0, 255, 0, 0)
craftDetail.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
addCorner(craftDetail, 8)
addStroke(craftDetail, Color3.fromRGB(40, 48, 65), 1)
craftDetail.Parent = craftContent

local craftResultName = Instance.new("TextLabel")
craftResultName.Size = UDim2.new(1, -20, 0, 28)
craftResultName.Position = UDim2.new(0, 10, 0, 12)
craftResultName.BackgroundTransparency = 1
craftResultName.Font = Enum.Font.GothamBlack
craftResultName.TextSize = 18
craftResultName.TextColor3 = Color3.fromRGB(255, 255, 255)
craftResultName.Text = "Select a Recipe"
craftResultName.Parent = craftDetail

local craftResultDesc = Instance.new("TextLabel")
craftResultDesc.Size = UDim2.new(1, -20, 0, 40)
craftResultDesc.Position = UDim2.new(0, 10, 0, 42)
craftResultDesc.BackgroundTransparency = 1
craftResultDesc.Font = Enum.Font.Gotham
craftResultDesc.TextSize = 12
craftResultDesc.TextColor3 = Color3.fromRGB(200, 205, 220)
craftResultDesc.TextWrapped = true
craftResultDesc.Text = "Combine rare auras to forge exclusive godly auras, luck gauntlets, and elixirs!"
craftResultDesc.Parent = craftDetail

local ingredientsHeader = Instance.new("TextLabel")
ingredientsHeader.Size = UDim2.new(1, -20, 0, 20)
ingredientsHeader.Position = UDim2.new(0, 10, 0, 92)
ingredientsHeader.BackgroundTransparency = 1
ingredientsHeader.Font = Enum.Font.GothamBold
ingredientsHeader.TextSize = 13
ingredientsHeader.TextColor3 = Color3.fromRGB(156, 163, 175)
ingredientsHeader.Text = "REQUIRED INGREDIENTS:"
ingredientsHeader.TextXAlignment = Enum.TextXAlignment.Left
ingredientsHeader.Parent = craftDetail

local ingredientsFrame = Instance.new("Frame")
ingredientsFrame.Size = UDim2.new(1, -20, 0, 180)
ingredientsFrame.Position = UDim2.new(0, 10, 0, 118)
ingredientsFrame.BackgroundTransparency = 1
ingredientsFrame.Parent = craftDetail

local ingListLayout = Instance.new("UIListLayout")
ingListLayout.Padding = UDim.new(0, 6)
ingListLayout.Parent = ingredientsFrame

local craftActionBtn = Instance.new("TextButton")
craftActionBtn.Size = UDim2.new(1, -20, 0, 44)
craftActionBtn.Position = UDim2.new(0, 10, 1, -54)
craftActionBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
craftActionBtn.Font = Enum.Font.GothamBlack
craftActionBtn.TextSize = 16
craftActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
craftActionBtn.Text = "⚗️ FORGE RECIPE"
craftActionBtn.Visible = false
addCorner(craftActionBtn, 10)
craftActionBtn.Parent = craftDetail

local function refreshCraftingUI()
	for _, child in ipairs(recipeListScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, recipe in ipairs(AuraConfig.Recipes) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 52)
		btn.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
		btn.Text = ""
		addCorner(btn, 8)
		addStroke(btn, recipe.Color, 1.2)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -12, 0, 22)
		title.Position = UDim2.new(0, 8, 0, 6)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextColor3 = recipe.Color
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = recipe.Name
		title.Parent = btn

		local typeLabel = Instance.new("TextLabel")
		typeLabel.Size = UDim2.new(1, -12, 0, 16)
		typeLabel.Position = UDim2.new(0, 8, 0, 28)
		typeLabel.BackgroundTransparency = 1
		typeLabel.Font = Enum.Font.Gotham
		typeLabel.TextSize = 11
		typeLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.Text = string.format("Type: %s", recipe.ResultType)
		typeLabel.Parent = btn

		btn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedCraftRecipe = recipe
			craftResultName.Text = recipe.Name
			craftResultName.TextColor3 = recipe.Color
			craftResultDesc.Text = recipe.Description

			-- Clear ingredients frame
			for _, child in ipairs(ingredientsFrame:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end

			local canCraftAll = true
			for _, ing in ipairs(recipe.Ingredients) do
				local owned = localData.Inventory[ing.AuraId] or 0
				local auraData = AuraConfig.Auras[ing.AuraId]
				local auraName = auraData and auraData.Name or ing.AuraId
				local auraColor = auraData and auraData.Color or Color3.fromRGB(220, 225, 240)

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 32)
				row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
				addCorner(row, 6)
				row.Parent = ingredientsFrame

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 8, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Font = Enum.Font.GothamBold
				nameLbl.TextSize = 12
				nameLbl.TextColor3 = auraColor
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.Text = auraName
				nameLbl.Parent = row

				local countLbl = Instance.new("TextLabel")
				countLbl.Size = UDim2.new(0.3, 0, 1, 0)
				countLbl.Position = UDim2.new(0.68, 0, 0, 0)
				countLbl.BackgroundTransparency = 1
				countLbl.Font = Enum.Font.GothamBold
				countLbl.TextSize = 12
				if owned >= ing.Count then
					countLbl.TextColor3 = Color3.fromRGB(74, 222, 128)
					countLbl.Text = string.format("✓ %d / %d", owned, ing.Count)
				else
					countLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
					countLbl.Text = string.format("✕ %d / %d", owned, ing.Count)
					canCraftAll = false
				end
				countLbl.Parent = row
			end

			craftActionBtn.Visible = true
			if canCraftAll then
				craftActionBtn.Text = "⚗️ FORGE NOW"
				craftActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			else
				craftActionBtn.Text = "Missing Auras"
				craftActionBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
			end
		end)

		btn.Parent = recipeListScroll
	end

	recipeListScroll.CanvasSize = UDim2.new(0, 0, 0, recipeListLayout.AbsoluteContentSize.Y + 20)
end

craftActionBtn.MouseButton1Click:Connect(function()
	if not selectedCraftRecipe then return end
	SoundEffects.Play("Click")
	local result = CraftAuraFunc:InvokeServer(selectedCraftRecipe.Id)
	if result and result.Success then
		SoundEffects.Play("Craft")
		refreshCraftingUI()
		refreshInventoryUI()
	end
end)

--------------------------------------------------------------------------------
-- 3. SHOP & GAMEPASSES WINDOW
--------------------------------------------------------------------------------

local shopWindow, shopContent = createModalWindow("🛒 SHOP & PASSES (TEST MODE INCLUDED)", 700, 480)

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, 0)
shopScroll.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
shopScroll.BackgroundTransparency = 0.5
shopScroll.ScrollBarThickness = 6
addCorner(shopScroll, 8)
shopScroll.Parent = shopContent

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.Parent = shopScroll

local passItems = {
	{
		Id = "X2Luck",
		Name = "🎲 x2 Luck Pass",
		Color = Color3.fromRGB(74, 222, 128),
		Desc = "Permanently doubles your chance for all rare, mythic, and godly auras!",
		PerkKey = "X2Luck",
	},
	{
		Id = "AutoRoll",
		Name = "⚡ Auto Roll Pass",
		Color = Color3.fromRGB(250, 204, 21),
		Desc = "Automatically rolls in the background while you chat, explore, or AFK!",
		PerkKey = "AutoRoll",
	},
	{
		Id = "ExtraStorage",
		Name = "🎨 Aura Storage (+30)",
		Color = Color3.fromRGB(56, 189, 248),
		Desc = "Expands your aura inventory capacity by +30 slots to keep all your treasures!",
		PerkKey = "ExtraStorage",
	},
	{
		Id = "VIP",
		Name = "⭐ VIP Supporter Pass",
		Color = Color3.fromRGB(245, 158, 11),
		Desc = "Exclusive VIP Crown Aura + x1.5 Permanent Luck + Golden VIP Chat & Overhead Tag!",
		PerkKey = "VIP",
	},
}

local function refreshShopUI()
	for _, child in ipairs(shopScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, item in ipairs(passItems) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -12, 0, 84)
		row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		addCorner(row, 8)
		addStroke(row, item.Color, 1.2)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.65, 0, 0, 24)
		nameLbl.Position = UDim2.new(0, 12, 0, 10)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = Enum.Font.GothamBlack
		nameLbl.TextSize = 16
		nameLbl.TextColor3 = item.Color
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Text = item.Name
		nameLbl.Parent = row

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(0.65, 0, 0, 38)
		descLbl.Position = UDim2.new(0, 12, 0, 36)
		descLbl.BackgroundTransparency = 1
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 12
		descLbl.TextColor3 = Color3.fromRGB(180, 185, 200)
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextWrapped = true
		descLbl.Text = item.Desc
		descLbl.Parent = row

		-- Test Toggle Button
		local testBtn = Instance.new("TextButton")
		testBtn.Size = UDim2.new(0, 170, 0, 42)
		testBtn.Position = UDim2.new(1, -182, 0.5, -21)
		testBtn.Font = Enum.Font.GothamBold
		testBtn.TextSize = 12
		addCorner(testBtn, 8)

		local isOwned = (localData.Gamepasses and localData.Gamepasses[item.PerkKey])
			or (localData.TestPerks and localData.TestPerks[item.PerkKey])

		if isOwned then
			testBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			testBtn.Text = "ACTIVE (TEST ON)"
		else
			testBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
			testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			testBtn.Text = "TEST FOR FREE"
		end

		testBtn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			ToggleTestPerkEvent:FireServer(item.PerkKey)
		end)

		testBtn.Parent = row
		row.Parent = shopScroll
	end

	shopScroll.CanvasSize = UDim2.new(0, 0, 0, shopLayout.AbsoluteContentSize.Y + 20)
end

--------------------------------------------------------------------------------
-- 4. SETTINGS WINDOW
--------------------------------------------------------------------------------

local settingsWindow, setContent = createModalWindow("⚙️ SETTINGS", 450, 260)

local setFastRollBtn = Instance.new("TextButton")
setFastRollBtn.Size = UDim2.new(1, 0, 0, 44)
setFastRollBtn.Position = UDim2.new(0, 0, 0, 10)
setFastRollBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setFastRollBtn.Font = Enum.Font.GothamBold
setFastRollBtn.TextSize = 14
setFastRollBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
addCorner(setFastRollBtn, 8)
addStroke(setFastRollBtn, Color3.fromRGB(45, 52, 70), 1)
setFastRollBtn.Parent = setContent

local setAutoDeleteInfo = Instance.new("TextLabel")
setAutoDeleteInfo.Size = UDim2.new(1, 0, 0, 44)
setAutoDeleteInfo.Position = UDim2.new(0, 0, 0, 68)
setAutoDeleteInfo.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setAutoDeleteInfo.Font = Enum.Font.GothamMedium
setAutoDeleteInfo.TextSize = 13
setAutoDeleteInfo.TextColor3 = Color3.fromRGB(200, 205, 220)
setAutoDeleteInfo.Text = "Auto-Delete: Configure inside Inventory"
addCorner(setAutoDeleteInfo, 8)
setAutoDeleteInfo.Parent = setContent

setFastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: ON"
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
	end
end)

--------------------------------------------------------------------------------
-- 5. ROLL REVEAL CUTSCENE OVERLAY
--------------------------------------------------------------------------------

local cutsceneOverlay = Instance.new("Frame")
cutsceneOverlay.Name = "CutsceneOverlay"
cutsceneOverlay.Size = UDim2.new(1, 0, 1, 0)
cutsceneOverlay.BackgroundColor3 = Color3.fromRGB(5, 6, 10)
cutsceneOverlay.BackgroundTransparency = 0.35
cutsceneOverlay.Visible = false
cutsceneOverlay.Parent = screenGui

local revealCard = Instance.new("Frame")
revealCard.Name = "RevealCard"
revealCard.Size = UDim2.new(0, 360, 0, 420)
revealCard.Position = UDim2.new(0.5, -180, 0.5, -210)
revealCard.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
addCorner(revealCard, 16)
local cardStroke = addStroke(revealCard, Color3.fromRGB(255, 255, 255), 2.5)
revealCard.Parent = cutsceneOverlay

local cardTierTag = Instance.new("TextLabel")
cardTierTag.Size = UDim2.new(1, 0, 0, 28)
cardTierTag.Position = UDim2.new(0, 0, 0, 24)
cardTierTag.BackgroundTransparency = 1
cardTierTag.Font = Enum.Font.GothamBlack
cardTierTag.TextSize = 14
cardTierTag.TextColor3 = Color3.fromRGB(156, 163, 175)
cardTierTag.Text = "[ TIER ]"
cardTierTag.Parent = revealCard

local cardName = Instance.new("TextLabel")
cardName.Size = UDim2.new(1, -20, 0, 42)
cardName.Position = UDim2.new(0, 10, 0, 52)
cardName.BackgroundTransparency = 1
cardName.Font = Enum.Font.GothamBlack
cardName.TextSize = 28
cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
cardName.Text = "Aura Name"
cardName.Parent = revealCard

local cardRarity = Instance.new("TextLabel")
cardRarity.Size = UDim2.new(1, 0, 0, 28)
cardRarity.Position = UDim2.new(0, 0, 0, 100)
cardRarity.BackgroundTransparency = 1
cardRarity.Font = Enum.Font.GothamBold
cardRarity.TextSize = 18
cardRarity.TextColor3 = Color3.fromRGB(240, 243, 250)
cardRarity.Text = "1 in 100,000"
cardRarity.Parent = revealCard

local cardDesc = Instance.new("TextLabel")
cardDesc.Size = UDim2.new(1, -40, 0, 100)
cardDesc.Position = UDim2.new(0, 20, 0, 140)
cardDesc.BackgroundTransparency = 1
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextSize = 13
cardDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
cardDesc.TextWrapped = true
cardDesc.Text = "Aura description..."
cardDesc.Parent = revealCard

local cardEquipBtn = Instance.new("TextButton")
cardEquipBtn.Size = UDim2.new(0, 150, 0, 44)
cardEquipBtn.Position = UDim2.new(0.5, -160, 1, -64)
cardEquipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
cardEquipBtn.Font = Enum.Font.GothamBold
cardEquipBtn.TextSize = 15
cardEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardEquipBtn.Text = "EQUIP"
addCorner(cardEquipBtn, 10)
cardEquipBtn.Parent = revealCard

local cardCloseBtn = Instance.new("TextButton")
cardCloseBtn.Size = UDim2.new(0, 150, 0, 44)
cardCloseBtn.Position = UDim2.new(0.5, 10, 1, -64)
cardCloseBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
cardCloseBtn.Font = Enum.Font.GothamBold
cardCloseBtn.TextSize = 15
cardCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardCloseBtn.Text = "COLLECT"
addCorner(cardCloseBtn, 10)
cardCloseBtn.Parent = revealCard

local currentRolledAura = nil

local function showCutscene(auraData)
	currentRolledAura = auraData
	cardTierTag.Text = string.format("[ %s ]", auraData.Tier:upper())
	cardName.Text = auraData.Name
	cardName.TextColor3 = auraData.Color
	cardRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
	cardDesc.Text = auraData.Description
	cardStroke.Color = auraData.Color

	-- Play sound matching rarity tier
	if auraData.Rarity >= 250000 then
		SoundEffects.Play("RevealGodly")
	elseif auraData.Rarity >= 10000 then
		SoundEffects.Play("RevealMythic")
	elseif auraData.Rarity >= 1000 then
		SoundEffects.Play("RevealLegendary")
	elseif auraData.Rarity >= 16 then
		SoundEffects.Play("RevealRare")
	else
		SoundEffects.Play("RevealCommon")
	end

	cutsceneOverlay.Visible = true

	-- Entrance animation
	revealCard.Size = UDim2.new(0, 100, 0, 100)
	TweenService:Create(revealCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 360, 0, 420),
	}):Play()
end

cardEquipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		EquipAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardCloseBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	cutsceneOverlay.Visible = false
end)

--------------------------------------------------------------------------------
-- 6. GLOBAL ANNOUNCEMENT BANNER
--------------------------------------------------------------------------------

local banner = Instance.new("Frame")
banner.Name = "GlobalBanner"
banner.Size = UDim2.new(0, 520, 0, 44)
banner.Position = UDim2.new(0.5, -260, 0, -60) -- Start off-screen
banner.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
banner.BackgroundTransparency = 0.1
addCorner(banner, 10)
local bannerStroke = addStroke(banner, Color3.fromRGB(250, 204, 21), 2)
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.new(1, -20, 1, 0)
bannerText.Position = UDim2.new(0, 10, 0, 0)
bannerText.BackgroundTransparency = 1
bannerText.Font = Enum.Font.GothamBold
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.fromRGB(255, 235, 120)
bannerText.Text = "🎉 Player rolled MYTHIC!"
bannerText.Parent = banner

GlobalAnnouncementEvent.OnClientEvent:Connect(function(info)
	local tierColor = AuraConfig.GetTierColor(info.Tier)
	bannerStroke.Color = tierColor
	bannerText.Text = string.format("🎉 %s rolled %s (%s)!", info.PlayerName, info.AuraName:upper(), AuraConfig.FormatRarity(info.Rarity))
	bannerText.TextColor3 = tierColor

	-- Slide down
	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -260, 0, 68),
	}):Play()

	task.delay(4.5, function()
		TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -260, 0, -60),
		}):Play()
	end)
end)

--------------------------------------------------------------------------------
-- 7. ROLL TRIGGER & BUTTON EVENTS
--------------------------------------------------------------------------------

local function doRoll()
	if isRolling then return end
	isRolling = true

	-- Button bounce
	TweenService:Create(rollButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 195, 0, 56),
	}):Play()

	SoundEffects.Play("Spin")

	local result = RollRequestFunc:InvokeServer(isFastRollOn)

	task.wait(0.12)
	TweenService:Create(rollButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 210, 0, 62),
	}):Play()

	if result and result.Success and result.Aura then
		if not isFastRollOn then
			showCutscene(result.Aura)
		else
			-- Fast roll: play sound only
			SoundEffects.Play("RevealCommon")
		end
	end

	isRolling = false
end

rollButton.MouseButton1Click:Connect(function()
	doRoll()
end)

-- Auto Roll Loop
autoRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isAutoRollOn = not isAutoRollOn
	if isAutoRollOn then
		autoRollBtn.Text = "⚡ AUTO: ON"
		autoRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 55, 35)
	else
		autoRollBtn.Text = "⚡ AUTO: OFF"
		autoRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
	end
end)

task.spawn(function()
	while true do
		task.wait(AuraConfig.Settings.AutoRollInterval)
		if isAutoRollOn and not isRolling and not cutsceneOverlay.Visible then
			doRoll()
		end
	end
end)

fastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: ON"
	else
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
		setFastRollBtn.Text = "⏩ Fast Roll Cutscene: OFF"
	end
end)

unequipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	EquipAuraEvent:FireServer("None")
end)

-- Navigation button clicks
navInventoryBtn.MouseButton1Click:Connect(function()
	toggleModal(inventoryWindow)
	refreshInventoryUI()
end)

navCraftingBtn.MouseButton1Click:Connect(function()
	toggleModal(craftWindow)
	refreshCraftingUI()
end)

navShopBtn.MouseButton1Click:Connect(function()
	toggleModal(shopWindow)
	refreshShopUI()
end)

navSettingsBtn.MouseButton1Click:Connect(function()
	toggleModal(settingsWindow)
end)

-- 3D World ProximityPrompt Trigger for Crafting Altar
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	if prompt.Name == "CraftingPrompt" and player == LocalPlayer then
		if not craftWindow.Visible then
			toggleModal(craftWindow)
		end
		refreshCraftingUI()
	end
end)

--------------------------------------------------------------------------------
-- 8. DATA SYNC RECEIVER
--------------------------------------------------------------------------------

DataSyncEvent.OnClientEvent:Connect(function(data)
	for k, v in pairs(data) do
		localData[k] = v
	end

	-- Update Top Stats
	rollsLabel.Text = string.format("🎲 Rolls: %s", AuraConfig.FormatNumber(localData.Rolls or 0))
	luckLabel.Text = string.format("🍀 Luck: x%.1f", localData.CurrentLuck or 1.0)
	coinsLabel.Text = string.format("🪙 %s", AuraConfig.FormatNumber(localData.Coins or 0))

	-- Update Potion label
	if localData.PotionExpiry and localData.PotionExpiry > os.time() then
		local remaining = localData.PotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format("⏳ 2x Pot: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		potionLabel.Text = "⏳ Pot: None"
		potionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
	end

	-- Update Equipped Card
	local eqAura = AuraConfig.Auras[localData.EquippedAura]
	if eqAura then
		equippedTitle.Text = eqAura.Name
		equippedTitle.TextColor3 = eqAura.Color
		equippedSubtitle.Text = AuraConfig.FormatRarity(eqAura.Rarity or 0)
	else
		equippedTitle.Text = "Aura: None"
		equippedTitle.TextColor3 = Color3.fromRGB(220, 225, 235)
		equippedSubtitle.Text = "Not Equipped"
	end

	-- Update Auto Delete Threshold Text
	local autoDelText = thresholdNames[localData.AutoDeleteThreshold or 0] or "None"
	autoDeleteBtn.Text = "Auto-Delete: " .. autoDelText

	-- Refresh open modal if visible
	if inventoryWindow.Visible then refreshInventoryUI() end
	if craftWindow.Visible then refreshCraftingUI() end
	if shopWindow.Visible then refreshShopUI() end
end)

print("[Sols RNG] Client GUI initialized!")
]===]
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
