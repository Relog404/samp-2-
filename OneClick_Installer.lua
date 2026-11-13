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
-- Central configuration for all Auras, Rarities, Colors, Combat Power, Icons, and Upgrader rules.

local AuraConfig = {}

AuraConfig.CutsceneTier = {
	Normal = "Normal",
	Rare = "Rare",
	Legendary = "Legendary",
	Mythic = "Mythic",
	Godly = "Godly",
}

AuraConfig.Settings = {
	BaseRollCooldown = 2.0,
	FastRollCooldown = 0.5,
	AutoRollInterval = 2.2,
	DefaultStorage = 20,
	ExtraStorageBonus = 30,
	MaxStorageLimit = 150,

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

	GlobalBroadcastThreshold = 10000,

	GamepassIds = {
		X2Luck = 0,
		X3Luck = 0,
		AutoRoll = 0,
		ExtraStorage = 0,
		VIP = 0,
		FastRoll = 0,
	},

	DevProductIds = {
		CoinPack10k = 0,
		CoinPack50k = 0,
		CoinPack250k = 0,
		MegaPotion = 0,
		InstantLegendary = 0,
		InstantMythic = 0,
		StarterPack = 0,
	}
}

-- Catalog of all Auras with Icons and Combat Power
AuraConfig.Auras = {
	-- COMMON TIER (1 in 2 to 1 in 4)
	Common = {
		Id = "Common",
		Name = "Common",
		Rarity = 2,
		Tier = "Common",
		Power = 50,
		Icon = "rbxassetid://241594419",
		Symbol = "COM",
		Color = Color3.fromRGB(220, 220, 225),
		Description = "Faint gentle dust of pure simple energy.",
		Cutscene = AuraConfig.CutsceneTier.Normal,
		ParticleColor = Color3.fromRGB(230, 230, 240),
		ParticleShape = "Dust",
	},
	Uncommon = {
		Id = "Uncommon",
		Name = "Uncommon",
		Rarity = 4,
		Tier = "Common",
		Power = 100,
		Icon = "rbxassetid://241594419",
		Symbol = "UNC",
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
		Power = 250,
		Icon = "rbxasset://textures/particles/sparkles_main.dds",
		Symbol = "NAT",
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
		Power = 500,
		Icon = "rbxassetid://258128463",
		Symbol = "RAR",
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
		Power = 1000,
		Icon = "rbxassetid://258127006",
		Symbol = "DIV",
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
		Power = 2000,
		Icon = "rbxassetid://241594432",
		Symbol = "CRX",
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
		Power = 4500,
		Icon = "rbxassetid://241594419",
		Symbol = "TPZ",
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
		Power = 8000,
		Icon = "rbxassetid://241594432",
		Symbol = "GLC",
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
		Power = 11000,
		Icon = "rbxassetid://243664672",
		Symbol = "WND",
		Color = Color3.fromRGB(167, 243, 208),
		Description = "A raging cyclone spiral enveloping the character.",
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
		Power = 25000,
		Icon = "rbxassetid://258128463",
		Symbol = "RBY",
		Color = Color3.fromRGB(239, 68, 68),
		Description = "Blazing crimson volcanic flame pillar ascending to heaven.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(255, 50, 50),
		ParticleShape = "FireColumn",
	},
	Undead = {
		Id = "Undead",
		Name = "Undead",
		Rarity = 2000,
		Tier = "Legendary",
		Power = 45000,
		Icon = "rbxassetid://258128463",
		Symbol = "UND",
		Color = Color3.fromRGB(16, 185, 129),
		Description = "Ominous necrotic souls and radioactive green mist.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(20, 230, 140),
		ParticleShape = "Souls",
	},
	Solar = {
		Id = "Solar",
		Name = "Solar",
		Rarity = 5000,
		Tier = "Legendary",
		Power = 90000,
		Icon = "rbxassetid://258127006",
		Symbol = "SOL",
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
		Power = 180000,
		Icon = "rbxassetid://241594419",
		Symbol = "LUN",
		Color = Color3.fromRGB(139, 92, 246),
		Description = "A mystical crescent night sky with celestial starlight.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(170, 120, 255),
		ParticleShape = "MoonStars",
	},
	Poseidon = {
		Id = "Poseidon",
		Name = "Poseidon",
		Rarity = 25000,
		Tier = "Mythic",
		Power = 350000,
		Icon = "rbxassetid://243664672",
		Symbol = "POS",
		Color = Color3.fromRGB(2, 132, 199),
		Description = "Lord of the deep seas summoning aquatic geysers.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(20, 170, 255),
		ParticleShape = "Tsunami",
	},
	Hades = {
		Id = "Hades",
		Name = "Hades",
		Rarity = 50000,
		Tier = "Mythic",
		Power = 650000,
		Icon = "rbxassetid://258128463",
		Symbol = "HDS",
		Color = Color3.fromRGB(220, 38, 38),
		Description = "Underworld hellfire and demonic dark red lightning.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(240, 20, 20),
		ParticleShape = "Hellfire",
	},
	Galaxy = {
		Id = "Galaxy",
		Name = "Galaxy",
		Rarity = 100000,
		Tier = "Mythic",
		Power = 1200000,
		Icon = "rbxassetid://243664672",
		Symbol = "GLX",
		Color = Color3.fromRGB(99, 102, 241),
		Description = "A deep cosmic spiral galaxy with swirling nebulae.",
		Cutscene = AuraConfig.CutsceneTier.Mythic,
		ParticleColor = Color3.fromRGB(130, 140, 255),
		ParticleShape = "NebulaSpiral",
	},

	-- GODLY TIER (1 in 200,000 to 1 in 1,000,000)
	AncientTurtle = {
		Id = "AncientTurtle",
		Name = "Ancient Turtle",
		Rarity = 200000,
		Tier = "Godly",
		Power = 2500000,
		Icon = "rbxassetid://243664672",
		Symbol = "TRT",
		Symbol = "TRT",
		Color = Color3.fromRGB(16, 185, 129),
		Description = "Sacred celestial tortoise shell barrier and orbiting ancient jade runic plates.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(52, 211, 153),
		ParticleShape = "Turtle",
	},
	Archangel = {
		Id = "Archangel",
		Name = "Archangel",
		Rarity = 350000,
		Tier = "Godly",
		Power = 4000000,
		Icon = "rbxassetid://258127006",
		Symbol = "ANG",
		Symbol = "ANG",
		Color = Color3.fromRGB(252, 211, 77),
		Description = "Six wings of divine light, holy choir and celestial halos.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 235, 120),
		ParticleShape = "DivineHalo",
	},
	MythicDragon = {
		Id = "MythicDragon",
		Name = "Mythic Dragon",
		Rarity = 750000,
		Tier = "Godly",
		Power = 8500000,
		Icon = "rbxassetid://258128463",
		Symbol = "DRG",
		Symbol = "DRG",
		Color = Color3.fromRGB(244, 63, 94),
		Description = "Ancient mythical draconic serpent coiling around its master with magma embers.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 75, 40),
		ParticleShape = "Dragon",
	},
	ExoticApex = {
		Id = "ExoticApex",
		Name = "Exotic: Apex",
		Rarity = 500000,
		Tier = "Godly",
		Power = 6000000,
		Icon = "rbxassetid://241594432",
		Symbol = "APX",
		Symbol = "APX",
		Color = Color3.fromRGB(236, 72, 153),
		Description = "Reality-bending prismatic chromatic spectrum.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(255, 90, 190),
		ParticleShape = "PrismaticGlitch",
	},
	AbyssalHunter = {
		Id = "AbyssalHunter",
		Name = "Abyssal Hunter",
		Rarity = 1000000,
		Tier = "Godly",
		Power = 12000000,
		Icon = "rbxassetid://243664672",
		Symbol = "ABY",
		Color = Color3.fromRGB(124, 58, 237),
		Description = "A singularity black hole radiating neon violet lightning bolts.",
		Cutscene = AuraConfig.CutsceneTier.Godly,
		ParticleColor = Color3.fromRGB(160, 80, 255),
		ParticleShape = "Singularity",
	},

	-- CRAFTED / SPECIAL
	Eclipse = {
		Id = "Eclipse",
		Name = "Eclipse",
		Rarity = 0,
		Tier = "Crafted",
		Power = 800000,
		Icon = "rbxassetid://243664672",
		Symbol = "ECL",
		Color = Color3.fromRGB(245, 158, 11),
		Description = "The convergence of Solar and Lunar orbital harmony.",
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
		Power = 4000000,
		Icon = "rbxassetid://243664672",
		Symbol = "CHR",
		Color = Color3.fromRGB(6, 182, 212),
		Description = "Time bends to your command. Spinning clock dials and golden gears.",
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
		Power = 1500000,
		Icon = "rbxassetid://258128463",
		Symbol = "LVT",
		Color = Color3.fromRGB(185, 28, 28),
		Description = "Boiling magma geysers and abyss waters in an unstoppable storm.",
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
		Power = 200000,
		Icon = "rbxassetid://258127006",
		Symbol = "VIP",
		Color = Color3.fromRGB(251, 191, 36),
		Description = "Exclusive regal golden crown aura for VIP supporters.",
		Cutscene = AuraConfig.CutsceneTier.Legendary,
		ParticleColor = Color3.fromRGB(255, 215, 0),
		ParticleShape = "CrownGlow",
		IsSpecial = true,
	}
}

-- Ordered Tier Progression Ladder for the Upgrader
AuraConfig.UpgradeLadder = {
	"Common",
	"Uncommon",
	"Natural",
	"Rare",
	"Divinus",
	"Crystallized",
	"Topaz",
	"Glacier",
	"Wind",
	"Ruby",
	"Undead",
	"Solar",
	"Lunar",
	"Poseidon",
	"Hades",
	"Galaxy",
	"AncientTurtle",
	"Archangel",
	"MythicDragon",
	"ExoticApex",
	"AbyssalHunter",
}

-- Helper to find tier index on ladder
function AuraConfig.GetLadderIndex(auraId)
	for i, id in ipairs(AuraConfig.UpgradeLadder) do
		if id == auraId then return i end
	end
	return 1
end

-- Crafting Recipes
AuraConfig.Recipes = {
	{
		Id = "Recipe_Eclipse",
		ResultType = "Aura",
		ResultId = "Eclipse",
		Name = "Eclipse Aura",
		Tier = "Crafted",
		Icon = "rbxassetid://243664672",
		Color = Color3.fromRGB(245, 158, 11),
		Description = "Synthesize Sun and Moon into a legendary dual aura.",
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
		Icon = "rbxassetid://258127006",
		Color = Color3.fromRGB(234, 179, 8),
		Description = "Permanent equippable gear granting +50% Luck (x1.5).",
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
		Icon = "rbxassetid://241594419",
		Color = Color3.fromRGB(34, 197, 94),
		Description = "A brew granting 2x Luck for 10 minutes upon creation.",
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
		Icon = "rbxassetid://243664672",
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
		Icon = "rbxassetid://258128463",
		Color = Color3.fromRGB(185, 28, 28),
		Description = "Combine underworld hellfire with deep sea titans.",
		Ingredients = {
			{ AuraId = "Hades", Count = 1 },
			{ AuraId = "Poseidon", Count = 1 },
			{ AuraId = "Ruby", Count = 2 },
		},
	},
}

-- Pre-sorted rollable list
AuraConfig.RollableAuras = {}
for id, aura in pairs(AuraConfig.Auras) do
	if aura.Rarity and aura.Rarity > 0 then
		table.insert(AuraConfig.RollableAuras, aura)
	end
end
table.sort(AuraConfig.RollableAuras, function(a, b)
	return a.Rarity > b.Rarity
end)

function AuraConfig.FormatNumber(n)
	local formatted = tostring(n)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

function AuraConfig.FormatRarity(rarity)
	if not rarity or rarity <= 0 then
		return "Special"
	end
	return "1 in " .. AuraConfig.FormatNumber(rarity)
end

function AuraConfig.GetScrapValue(rarity)
	if not rarity or rarity <= 0 then
		return 500
	end
	if rarity <= 2 then return 5 end
	if rarity <= 4 then return 10 end
	if rarity <= 8 then return 20 end
	if rarity <= 16 then return 40 end
	if rarity <= 32 then return 80 end
	if rarity <= 64 then return 150 end
	if rarity <= 150 then return 300 end
	if rarity <= 300 then return 600 end
	if rarity <= 1000 then return 2000 end
	if rarity <= 5000 then return 8000 end
	if rarity <= 10000 then return 20000 end
	if rarity <= 50000 then return 50000 end
	return 100000
end

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

-- PROCEDURAL 3D ORBITING RIG SYSTEM
-- Dynamically orbits glowing Neon 3D parts with 60 FPS RenderStepped interpolation
local function addOrbiting3DRig(rootPart, activeFolder, config)
	if not rootPart or not activeFolder then return end

	local parts = {}
	for i = 1, config.Count do
		local p = Instance.new("Part")
		p.Name = "AuraOrbitPart_" .. tostring(i)
		p.Size = config.Size or Vector3.new(1, 1, 1)
		p.Shape = config.Shape or Enum.PartType.Block
		p.Color = (config.Colors and config.Colors[i]) or config.Color or Color3.fromRGB(255, 255, 255)
		p.Material = config.Material or Enum.Material.Neon
		p.CanCollide = false
		p.CastShadow = false
		p.Anchored = true
		p.Massless = true
		p.Parent = activeFolder

		if config.AttachEmitter then
			config.AttachEmitter(p, i)
		end

		table.insert(parts, p)
	end

	local RunService = game:GetService("RunService")
	local startTime = os.clock()
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not activeFolder or not activeFolder.Parent or not rootPart or not rootPart.Parent then
			if conn then conn:Disconnect() end
			return
		end

		local t = os.clock() - startTime
		for i, p in ipairs(parts) do
			local offsetAngle = ((i - 1) / #parts) * math.pi * 2
			local curAngle = t * (config.Speed or 2.0) + offsetAngle
			local r = config.Radius or 3.5
			local h = (config.BaseHeight or 0) + math.sin(t * 3.0 + offsetAngle) * (config.BobHeight or 0.4)
			local localPos = Vector3.new(math.cos(curAngle) * r, h, math.sin(curAngle) * r)
			p.CFrame = rootPart.CFrame * CFrame.new(localPos) * CFrame.Angles(t * 1.5, curAngle, 0)
		end
	end)

	activeFolder.Destroying:Connect(function()
		if conn then conn:Disconnect() end
	end)
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

	-- 3D Procedural Serpentine Dragon Orbiting Rig
	addOrbiting3DRig(rootPart, folder, {
		Count = 6,
		Size = Vector3.new(0.9, 0.9, 1.4),
		Shape = Enum.PartType.Ball,
		Colors = {
			Color3.fromRGB(255, 220, 50), -- Dragon Head
			Color3.fromRGB(244, 63, 94),
			Color3.fromRGB(239, 68, 68),
			Color3.fromRGB(220, 38, 38),
			Color3.fromRGB(185, 28, 28),
			Color3.fromRGB(150, 20, 10),  -- Dragon Tail
		},
		Radius = 3.6,
		Speed = 2.4,
		BaseHeight = 0.2,
		BobHeight = 0.7,
		AttachEmitter = function(part, idx)
			local att = Instance.new("Attachment")
			att.Parent = part
			createEmitter(att, {
				Color = ColorSequence.new(Color3.fromRGB(255, 100, 30)),
				Size = NumberSequence.new(0.6, 0.1),
				Transparency = NumberSequence.new(0.1, 1.0),
				Lifetime = NumberRange.new(0.6, 1.0),
				Rate = 20,
				Speed = NumberRange.new(1.0, 2.5),
				Texture = TEXTURES.Flame,
			})
		end,
	})
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

	-- 4 3D Floating Jade Runic Tablets
	addOrbiting3DRig(rootPart, folder, {
		Count = 4,
		Size = Vector3.new(1.1, 1.6, 0.22),
		Shape = Enum.PartType.Block,
		Color = Color3.fromRGB(16, 185, 129),
		Radius = 3.8,
		Speed = 1.6,
		BaseHeight = -0.2,
		BobHeight = 0.3,
		AttachEmitter = function(part, idx)
			local att = Instance.new("Attachment")
			att.Parent = part
			createEmitter(att, {
				Color = ColorSequence.new(Color3.fromRGB(52, 211, 153)),
				Size = NumberSequence.new(0.5, 0.1),
				Transparency = NumberSequence.new(0.1, 1.0),
				Lifetime = NumberRange.new(0.8, 1.4),
				Rate = 12,
				Speed = NumberRange.new(0.8, 2.0),
				Texture = TEXTURES.Sparkle,
			})
		end,
	})
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
		addOrbiting3DRig(rootPart, activeFolder, {
			Count = 5,
			Size = Vector3.new(0.6, 1.4, 0.6),
			Shape = Enum.PartType.Block,
			Color = Color3.fromRGB(147, 197, 253),
			Radius = 3.4,
			Speed = 1.8,
			BaseHeight = 0.2,
			BobHeight = 0.5,
		})

	elseif shape == "FireColumn" or shape == "Hellfire" or shape == "LavaTide" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(255, 40, 20), pColor, 100, NumberRange.new(6.0, 12.0), {0.8, 3.0, 0.4})
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "Sunburst" or shape == "EclipseCorona" then
		addDenseBodyEnergy(attRoot, Color3.fromRGB(255, 180, 40), Color3.fromRGB(255, 255, 255), 110, NumberRange.new(5.5, 11.0), {0.8, 3.2, 0.4})
		addOrbiting3DRig(rootPart, activeFolder, {
			Count = 3,
			Size = Vector3.new(1.1, 1.1, 1.1),
			Shape = Enum.PartType.Ball,
			Color = Color3.fromRGB(251, 191, 36),
			Radius = 3.6,
			Speed = 2.0,
			BaseHeight = 0.5,
			BobHeight = 0.3,
		})
		addHeadCrown(character, activeFolder, pColor, false)
		addLightPillar(rootPart, activeFolder, pColor)

	elseif shape == "MoonStars" or shape == "NebulaSpiral" or shape == "Singularity" then
		addDenseBodyEnergy(attRoot, pColor, Color3.fromRGB(240, 180, 255), 90, NumberRange.new(4.0, 8.5), {0.7, 2.8, 0.4})
		addOrbiting3DRig(rootPart, activeFolder, {
			Count = 3,
			Size = Vector3.new(1.0, 1.0, 1.0),
			Shape = Enum.PartType.Ball,
			Color = Color3.fromRGB(139, 92, 246),
			Radius = 3.5,
			Speed = 2.2,
			BaseHeight = -0.2,
			BobHeight = 0.6,
		})
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
]===])
installModule("SoundEffects", [===[-- SoundEffects.lua
-- Soft, pleasant, non-fatiguing audio controller for Sol's RNG game.

local SoundEffects = {}

local SOUND_IDS = {
	Click = "rbxasset://sounds/button_press.mp3",
	Tick = "rbxasset://sounds/clickfast.wav",              -- Soft, satisfying subtle mechanical tick
	Spin = "rbxasset://sounds/uianimation.mp3",           -- Smooth soft whoosh
	RevealCommon = "rbxasset://sounds/button_press.mp3",
	RevealRare = "rbxasset://sounds/electronicpingshort.wav",
	RevealLegendary = "rbxassetid://9114220524",         -- Melodic fanfare
	RevealMythic = "rbxassetid://9114222384",            -- Celestial choir
	RevealGodly = "rbxassetid://9114223175",             -- Cosmic blast
	Craft = "rbxassetid://9114221580",                  -- Anvil chime
	Equip = "rbxasset://sounds/uianimation.mp3",
	Coin = "rbxasset://sounds/electronicpingshort.wav",
}

-- Master Volume: 1.0 (Full), 0.5 (Half), 0.0 (Muted)
SoundEffects.MasterVolume = 0.5
SoundEffects.IsMuted = false

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
	if SoundEffects.IsMuted or SoundEffects.MasterVolume <= 0 then
		return
	end

	local assetId = SOUND_IDS[soundKey] or SOUND_IDS.Click
	local folder = getSoundFolder()

	local sound = Instance.new("Sound")
	sound.SoundId = assetId

	-- Calculate soft, pleasant volume that never hurts the ears
	local baseVol = volume or 0.35
	if soundKey == "Tick" then
		baseVol = 0.15 -- Very gentle and subtle tick for the CS2 roulette
	elseif soundKey == "Coin" then
		baseVol = 0.25
	end

	sound.Volume = baseVol * SoundEffects.MasterVolume
	sound.PlaybackSpeed = playbackSpeed or (soundKey == "Coin" and 1.4 or 1.0)
	sound.PlayOnRemove = false
	sound.Parent = folder

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	sound:Play()

	task.delay(4, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

function SoundEffects.ToggleMute()
	SoundEffects.IsMuted = not SoundEffects.IsMuted
	return SoundEffects.IsMuted
end

return SoundEffects
]===])
local craftSetupModule = installModule("CraftingStationSetup", [===[-- CraftingStationSetup.lua
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
local PurchaseProductFunc = getRemoteFunction("PurchaseProduct")
local UpgradeAuraFunc = getRemoteFunction("UpgradeAura")
local PvPChallengeFunc = getRemoteFunction("PvPChallenge")
local PvPUseSkillFunc = getRemoteFunction("PvPUseSkill")
local EquipAuraEvent = getRemoteEvent("EquipAura")
local DeleteAuraEvent = getRemoteEvent("DeleteAura")
local SetAutoDeleteEvent = getRemoteEvent("SetAutoDelete")
local ToggleTestPerkEvent = getRemoteEvent("ToggleTestPerk")
local DataSyncEvent = getRemoteEvent("DataSync")
local GlobalAnnouncementEvent = getRemoteEvent("GlobalAnnouncement")
local PvPResponseEvent = getRemoteEvent("PvPResponse")
local PvPStateEvent = getRemoteEvent("PvPState")
local PvPVFXEvent = getRemoteEvent("PvPVFX")

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

	-- x3 Luck Gamepass or Test Perk
	if data.Gamepasses.X3Luck or data.TestPerks.X3Luck then
		luck = luck * 3.0
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

	-- Mega Potion (x5 Luck)
	if data.MegaPotionExpiry and os.time() < data.MegaPotionExpiry then
		luck = luck * 5.0
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
		MegaPotionExpiry = data.MegaPotionExpiry,
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
	local scrapValue = auraData and AuraConfig.GetScrapValue(auraData.Rarity) or 5
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

-- PURCHASE PRODUCT HANDLER (DONATION & DEVPRODUCTS)
PurchaseProductFunc.OnServerInvoke = function(player, productKey)
	local data = sessionData[player]
	if not data then return { Success = false, Message = "Нет данных игрока" } end

	data.Coins = data.Coins or 0
	data.Inventory = data.Inventory or {}
	data.TestPerks = data.TestPerks or {}

	if productKey == "CoinPack10k" then
		data.Coins = data.Coins + 10000
	elseif productKey == "CoinPack50k" then
		data.Coins = data.Coins + 50000
	elseif productKey == "CoinPack250k" then
		data.Coins = data.Coins + 250000
	elseif productKey == "MegaPotion" then
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 900 -- 15 mins x5 luck!
	elseif productKey == "InstantLegendary" then
		local pool = { "Ruby", "Undead", "Solar" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "InstantMythic" then
		local pool = { "Lunar", "Poseidon", "Hades", "Galaxy", "AncientTurtle", "MythicDragon" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "StarterPack" then
		data.Coins = data.Coins + 25000
		data.TestPerks.X2Luck = true
		data.TestPerks.VIP = true
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 1800
	end

	syncClient(player)
	return { Success = true, Message = "Покупка успешно совершена!" }
end

-- REAL MARKETPLACE SERVICE RECEIPT HANDLER (IF DEVPRODUCTS CONFIGURED IN AURACONFIG)
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = sessionData[player]
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local devProds = AuraConfig.Settings.DevProductIds or {}
	local productId = receiptInfo.ProductId

	if productId == devProds.CoinPack10k then
		data.Coins = (data.Coins or 0) + 10000
	elseif productId == devProds.CoinPack50k then
		data.Coins = (data.Coins or 0) + 50000
	elseif productId == devProds.CoinPack250k then
		data.Coins = (data.Coins or 0) + 250000
	elseif productId == devProds.MegaPotion then
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 900
	elseif productId == devProds.InstantLegendary then
		local pool = { "Ruby", "Undead", "Solar" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productId == devProds.InstantMythic then
		local pool = { "Lunar", "Poseidon", "Hades", "Galaxy", "AncientTurtle", "MythicDragon" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productId == devProds.StarterPack then
		data.Coins = (data.Coins or 0) + 25000
		data.TestPerks.X2Luck = true
		data.TestPerks.VIP = true
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 1800
	end

	syncClient(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- TEST PERK TOGGLE (Allows free testing of all monetization features without Robux!)
ToggleTestPerkEvent.OnServerEvent:Connect(function(player, perkName)
	local data = sessionData[player]
	if not data then return end

	data.TestPerks = data.TestPerks or {}
	data.TestPerks[perkName] = not data.TestPerks[perkName]

	-- If VIP was toggled on, give VIP Crown
	if perkName == "VIP" and data.TestPerks.VIP then
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
	end

	syncClient(player)
end)

-- AURA UPGRADER HANDLER (RISK MACHINE)
UpgradeAuraFunc.OnServerInvoke = function(player, sourceAuraId, targetAuraId, customChance, modeType, modeValue)
	local data = sessionData[player]
	if not data then return { Success = false, Message = "No data" } end
	if not sourceAuraId or not data.Inventory[sourceAuraId] or data.Inventory[sourceAuraId] <= 0 then
		return { Success = false, Message = "Исходная аура не найдена в инвентаре!" }
	end

	local sourceAura = AuraConfig.Auras[sourceAuraId]
	if not sourceAura then
		return { Success = false, Message = "Неизвестная аура!" }
	end

	-- Deduct 1 source aura
	data.Inventory[sourceAuraId] = data.Inventory[sourceAuraId] - 1
	if data.Inventory[sourceAuraId] <= 0 then data.Inventory[sourceAuraId] = nil end
	if data.EquippedAura == sourceAuraId and not data.Inventory[sourceAuraId] then
		data.EquippedAura = "None"
		if player.Character then AuraVisuals.ClearAura(player.Character) end
	end

	local chance = 50.0
	local finalTargetAuraId = targetAuraId
	local finalTargetAura = targetAuraId and AuraConfig.Auras[targetAuraId]

	if finalTargetAura then
		if customChance and tonumber(customChance) then
			chance = math.clamp(math.floor(tonumber(customChance) * 10) / 10, 1.0, 85.0)
		else
			local sR = math.max(sourceAura.Rarity or 2, 2)
			local tR = math.max(finalTargetAura.Rarity or 10, 4)
			if sR >= tR then
				chance = 85.0
			else
				chance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
			end
		end
	elseif modeType == "Custom" and customChance then
		chance = math.clamp(math.floor(tonumber(customChance) * 10) / 10, 1.0, 85.0)
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local step = math.max(1, math.floor((100 - chance) / 18))
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + step)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	elseif modeType == "Chance" then
		chance = math.clamp(tonumber(modeValue) or 50, 5, 85)
		local tierStep = 1
		if chance >= 75 then tierStep = 1
		elseif chance >= 50 then tierStep = 2
		else tierStep = 4 end
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + tierStep)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	elseif modeType == "Multiplier" then
		local mult = tonumber(modeValue) or 2
		local tierStep = 2
		if mult == 2 then chance = 48.0; tierStep = 2
		elseif mult == 5 then chance = 19.0; tierStep = 5
		elseif mult == 10 then chance = 9.0; tierStep = 8 end
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + tierStep)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	else
		chance = 50.0
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + 2)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	end

	-- High-precision roll from 0.1 to 100.0
	local roll = math.random(1, 1000) / 10.0
	local won = (roll <= chance)

	if won and finalTargetAuraId and finalTargetAura then
		data.Inventory[finalTargetAuraId] = (data.Inventory[finalTargetAuraId] or 0) + 1
		local jackpot = 1500 + math.floor((finalTargetAura.Rarity or 100) * 0.05)
		data.Coins = (data.Coins or 0) + jackpot

		syncClient(player)
		return {
			Success = true,
			Won = true,
			Roll = roll,
			Chance = chance,
			TargetAura = finalTargetAura,
			SourceAura = sourceAura,
			Jackpot = jackpot,
		}
	else
		local scrap = AuraConfig.GetScrapValue(sourceAura.Rarity) * 2
		data.Coins = (data.Coins or 0) + scrap
		syncClient(player)
		return {
			Success = true,
			Won = false,
			Roll = roll,
			Chance = chance,
			TargetAura = finalTargetAura,
			SourceAura = sourceAura,
			Scrap = scrap,
		}
	end
end

-- PVP DUEL ENGINE
local activeDuels = {}

PvPChallengeFunc.OnServerInvoke = function(challenger, targetName)
	local targetPlayer = Players:FindFirstChild(targetName)
	if not targetPlayer or targetPlayer == challenger then
		return { Success = false, Message = "Игрок не найден!" }
	end
	if activeDuels[challenger] or activeDuels[targetPlayer] then
		return { Success = false, Message = "Один из игроков уже сражается!" }
	end

	PvPResponseEvent:FireClient(targetPlayer, {
		Challenger = challenger.Name,
		ChallengerDisplay = challenger.DisplayName or challenger.Name,
	})
	return { Success = true, Message = "Вызов отправлен!" }
end

PvPResponseEvent.OnServerEvent:Connect(function(targetPlayer, challengerName, accepted)
	local challenger = Players:FindFirstChild(challengerName)
	if not challenger then return end

	if accepted then
		local cData = sessionData[challenger]
		local tData = sessionData[targetPlayer]
		local cAura = cData and AuraConfig.Auras[cData.EquippedAura]
		local tAura = tData and AuraConfig.Auras[tData.EquippedAura]
		local cPower = cAura and cAura.Power or 100
		local tPower = tAura and tAura.Power or 100

		local cMaxHp = 1000 + math.floor(math.sqrt(cPower) * 12)
		local tMaxHp = 1000 + math.floor(math.sqrt(tPower) * 12)

		activeDuels[challenger] = {
			Opponent = targetPlayer,
			MaxHp = cMaxHp,
			Hp = cMaxHp,
			Power = cPower,
			Color = cAura and cAura.Color or Color3.fromRGB(56, 189, 248),
			LastSkill = {},
		}
		activeDuels[targetPlayer] = {
			Opponent = challenger,
			MaxHp = tMaxHp,
			Hp = tMaxHp,
			Power = tPower,
			Color = tAura and tAura.Color or Color3.fromRGB(245, 158, 11),
			LastSkill = {},
		}

		PvPStateEvent:FireClient(challenger, { InBattle = true, Opponent = targetPlayer.DisplayName or targetPlayer.Name, MyHp = cMaxHp, MyMaxHp = cMaxHp, OpHp = tMaxHp, OpMaxHp = tMaxHp })
		PvPStateEvent:FireClient(targetPlayer, { InBattle = true, Opponent = challenger.DisplayName or challenger.Name, MyHp = tMaxHp, MyMaxHp = tMaxHp, OpHp = cMaxHp, OpMaxHp = cMaxHp })
	end
end)

PvPUseSkillFunc.OnServerInvoke = function(caster, skillIndex)
	local duel = activeDuels[caster]
	if not duel then return { Success = false } end
	local target = duel.Opponent
	local targetDuel = activeDuels[target]
	if not targetDuel then return { Success = false } end

	local now = os.clock()
	local cd = (skillIndex == 1 and 1.2) or (skillIndex == 2 and 3.5) or 7.0
	if (now - (duel.LastSkill[skillIndex] or 0)) < cd then
		return { Success = false, Message = "Кулдаун!" }
	end
	duel.LastSkill[skillIndex] = now

	local baseDmg = (skillIndex == 1 and (120 + math.floor(math.sqrt(duel.Power) * 2)))
		or (skillIndex == 2 and (280 + math.floor(math.sqrt(duel.Power) * 4)))
		or (650 + math.floor(math.sqrt(duel.Power) * 8))

	local isCrit = (math.random(1, 100) <= 25)
	if isCrit then baseDmg = math.floor(baseDmg * 1.5) end

	targetDuel.Hp = math.max(0, targetDuel.Hp - baseDmg)

	PvPVFXEvent:FireAllClients({
		SkillIndex = skillIndex,
		Caster = caster.Name,
		Target = target.Name,
		Damage = baseDmg,
		IsCrit = isCrit,
		Color = duel.Color,
	})

	if targetDuel.Hp <= 0 then
		local cData = sessionData[caster]
		if cData then cData.Coins = (cData.Coins or 0) + 5000 end
		syncClient(caster)

		activeDuels[caster] = nil
		activeDuels[target] = nil

		PvPStateEvent:FireClient(caster, { InBattle = false, Won = true, Reward = 5000 })
		PvPStateEvent:FireClient(target, { InBattle = false, Won = false })
	else
		PvPStateEvent:FireClient(caster, { InBattle = true, MyHp = duel.Hp, MyMaxHp = duel.MaxHp, OpHp = targetDuel.Hp, OpMaxHp = targetDuel.MaxHp })
		PvPStateEvent:FireClient(target, { InBattle = true, MyHp = targetDuel.Hp, MyMaxHp = targetDuel.MaxHp, OpHp = duel.Hp, OpMaxHp = duel.MaxHp })
	end

	return { Success = true, Damage = baseDmg }
end

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
local PurchaseProductFunc = getRemoteFunction("PurchaseProduct")
local UpgradeAuraFunc = getRemoteFunction("UpgradeAura")
local PvPChallengeFunc = getRemoteFunction("PvPChallenge")
local PvPUseSkillFunc = getRemoteFunction("PvPUseSkill")
local EquipAuraEvent = getRemoteEvent("EquipAura")
local DeleteAuraEvent = getRemoteEvent("DeleteAura")
local SetAutoDeleteEvent = getRemoteEvent("SetAutoDelete")
local ToggleTestPerkEvent = getRemoteEvent("ToggleTestPerk")
local DataSyncEvent = getRemoteEvent("DataSync")
local GlobalAnnouncementEvent = getRemoteEvent("GlobalAnnouncement")
local PvPResponseEvent = getRemoteEvent("PvPResponse")
local PvPStateEvent = getRemoteEvent("PvPState")
local PvPVFXEvent = getRemoteEvent("PvPVFX")

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

	-- x3 Luck Gamepass or Test Perk
	if data.Gamepasses.X3Luck or data.TestPerks.X3Luck then
		luck = luck * 3.0
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

	-- Mega Potion (x5 Luck)
	if data.MegaPotionExpiry and os.time() < data.MegaPotionExpiry then
		luck = luck * 5.0
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
		MegaPotionExpiry = data.MegaPotionExpiry,
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
	local scrapValue = auraData and AuraConfig.GetScrapValue(auraData.Rarity) or 5
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

-- PURCHASE PRODUCT HANDLER (DONATION & DEVPRODUCTS)
PurchaseProductFunc.OnServerInvoke = function(player, productKey)
	local data = sessionData[player]
	if not data then return { Success = false, Message = "Нет данных игрока" } end

	data.Coins = data.Coins or 0
	data.Inventory = data.Inventory or {}
	data.TestPerks = data.TestPerks or {}

	if productKey == "CoinPack10k" then
		data.Coins = data.Coins + 10000
	elseif productKey == "CoinPack50k" then
		data.Coins = data.Coins + 50000
	elseif productKey == "CoinPack250k" then
		data.Coins = data.Coins + 250000
	elseif productKey == "MegaPotion" then
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 900 -- 15 mins x5 luck!
	elseif productKey == "InstantLegendary" then
		local pool = { "Ruby", "Undead", "Solar" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "InstantMythic" then
		local pool = { "Lunar", "Poseidon", "Hades", "Galaxy", "AncientTurtle", "MythicDragon" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "StarterPack" then
		data.Coins = data.Coins + 25000
		data.TestPerks.X2Luck = true
		data.TestPerks.VIP = true
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 1800
	end

	syncClient(player)
	return { Success = true, Message = "Покупка успешно совершена!" }
end

-- REAL MARKETPLACE SERVICE RECEIPT HANDLER (IF DEVPRODUCTS CONFIGURED IN AURACONFIG)
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = sessionData[player]
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local devProds = AuraConfig.Settings.DevProductIds or {}
	local productId = receiptInfo.ProductId

	if productId == devProds.CoinPack10k then
		data.Coins = (data.Coins or 0) + 10000
	elseif productId == devProds.CoinPack50k then
		data.Coins = (data.Coins or 0) + 50000
	elseif productId == devProds.CoinPack250k then
		data.Coins = (data.Coins or 0) + 250000
	elseif productId == devProds.MegaPotion then
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 900
	elseif productId == devProds.InstantLegendary then
		local pool = { "Ruby", "Undead", "Solar" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productId == devProds.InstantMythic then
		local pool = { "Lunar", "Poseidon", "Hades", "Galaxy", "AncientTurtle", "MythicDragon" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productId == devProds.StarterPack then
		data.Coins = (data.Coins or 0) + 25000
		data.TestPerks.X2Luck = true
		data.TestPerks.VIP = true
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		data.MegaPotionExpiry = math.max(data.MegaPotionExpiry or 0, os.time()) + 1800
	end

	syncClient(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- TEST PERK TOGGLE (Allows free testing of all monetization features without Robux!)
ToggleTestPerkEvent.OnServerEvent:Connect(function(player, perkName)
	local data = sessionData[player]
	if not data then return end

	data.TestPerks = data.TestPerks or {}
	data.TestPerks[perkName] = not data.TestPerks[perkName]

	-- If VIP was toggled on, give VIP Crown
	if perkName == "VIP" and data.TestPerks.VIP then
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
	end

	syncClient(player)
end)

-- AURA UPGRADER HANDLER (RISK MACHINE)
UpgradeAuraFunc.OnServerInvoke = function(player, sourceAuraId, targetAuraId, customChance, modeType, modeValue)
	local data = sessionData[player]
	if not data then return { Success = false, Message = "No data" } end
	if not sourceAuraId or not data.Inventory[sourceAuraId] or data.Inventory[sourceAuraId] <= 0 then
		return { Success = false, Message = "Исходная аура не найдена в инвентаре!" }
	end

	local sourceAura = AuraConfig.Auras[sourceAuraId]
	if not sourceAura then
		return { Success = false, Message = "Неизвестная аура!" }
	end

	-- Deduct 1 source aura
	data.Inventory[sourceAuraId] = data.Inventory[sourceAuraId] - 1
	if data.Inventory[sourceAuraId] <= 0 then data.Inventory[sourceAuraId] = nil end
	if data.EquippedAura == sourceAuraId and not data.Inventory[sourceAuraId] then
		data.EquippedAura = "None"
		if player.Character then AuraVisuals.ClearAura(player.Character) end
	end

	local chance = 50.0
	local finalTargetAuraId = targetAuraId
	local finalTargetAura = targetAuraId and AuraConfig.Auras[targetAuraId]

	if finalTargetAura then
		if customChance and tonumber(customChance) then
			chance = math.clamp(math.floor(tonumber(customChance) * 10) / 10, 1.0, 85.0)
		else
			local sR = math.max(sourceAura.Rarity or 2, 2)
			local tR = math.max(finalTargetAura.Rarity or 10, 4)
			if sR >= tR then
				chance = 85.0
			else
				chance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
			end
		end
	elseif modeType == "Custom" and customChance then
		chance = math.clamp(math.floor(tonumber(customChance) * 10) / 10, 1.0, 85.0)
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local step = math.max(1, math.floor((100 - chance) / 18))
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + step)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	elseif modeType == "Chance" then
		chance = math.clamp(tonumber(modeValue) or 50, 5, 85)
		local tierStep = 1
		if chance >= 75 then tierStep = 1
		elseif chance >= 50 then tierStep = 2
		else tierStep = 4 end
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + tierStep)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	elseif modeType == "Multiplier" then
		local mult = tonumber(modeValue) or 2
		local tierStep = 2
		if mult == 2 then chance = 48.0; tierStep = 2
		elseif mult == 5 then chance = 19.0; tierStep = 5
		elseif mult == 10 then chance = 9.0; tierStep = 8 end
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + tierStep)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	else
		chance = 50.0
		local curIdx = AuraConfig.GetLadderIndex(sourceAuraId)
		local nextIdx = math.min(#AuraConfig.UpgradeLadder, curIdx + 2)
		finalTargetAuraId = AuraConfig.UpgradeLadder[nextIdx]
		finalTargetAura = AuraConfig.Auras[finalTargetAuraId]
	end

	-- High-precision roll from 0.1 to 100.0
	local roll = math.random(1, 1000) / 10.0
	local won = (roll <= chance)

	if won and finalTargetAuraId and finalTargetAura then
		data.Inventory[finalTargetAuraId] = (data.Inventory[finalTargetAuraId] or 0) + 1
		local jackpot = 1500 + math.floor((finalTargetAura.Rarity or 100) * 0.05)
		data.Coins = (data.Coins or 0) + jackpot

		syncClient(player)
		return {
			Success = true,
			Won = true,
			Roll = roll,
			Chance = chance,
			TargetAura = finalTargetAura,
			SourceAura = sourceAura,
			Jackpot = jackpot,
		}
	else
		local scrap = AuraConfig.GetScrapValue(sourceAura.Rarity) * 2
		data.Coins = (data.Coins or 0) + scrap
		syncClient(player)
		return {
			Success = true,
			Won = false,
			Roll = roll,
			Chance = chance,
			TargetAura = finalTargetAura,
			SourceAura = sourceAura,
			Scrap = scrap,
		}
	end
end

-- PVP DUEL ENGINE
local activeDuels = {}

PvPChallengeFunc.OnServerInvoke = function(challenger, targetName)
	local targetPlayer = Players:FindFirstChild(targetName)
	if not targetPlayer or targetPlayer == challenger then
		return { Success = false, Message = "Игрок не найден!" }
	end
	if activeDuels[challenger] or activeDuels[targetPlayer] then
		return { Success = false, Message = "Один из игроков уже сражается!" }
	end

	PvPResponseEvent:FireClient(targetPlayer, {
		Challenger = challenger.Name,
		ChallengerDisplay = challenger.DisplayName or challenger.Name,
	})
	return { Success = true, Message = "Вызов отправлен!" }
end

PvPResponseEvent.OnServerEvent:Connect(function(targetPlayer, challengerName, accepted)
	local challenger = Players:FindFirstChild(challengerName)
	if not challenger then return end

	if accepted then
		local cData = sessionData[challenger]
		local tData = sessionData[targetPlayer]
		local cAura = cData and AuraConfig.Auras[cData.EquippedAura]
		local tAura = tData and AuraConfig.Auras[tData.EquippedAura]
		local cPower = cAura and cAura.Power or 100
		local tPower = tAura and tAura.Power or 100

		local cMaxHp = 1000 + math.floor(math.sqrt(cPower) * 12)
		local tMaxHp = 1000 + math.floor(math.sqrt(tPower) * 12)

		activeDuels[challenger] = {
			Opponent = targetPlayer,
			MaxHp = cMaxHp,
			Hp = cMaxHp,
			Power = cPower,
			Color = cAura and cAura.Color or Color3.fromRGB(56, 189, 248),
			LastSkill = {},
		}
		activeDuels[targetPlayer] = {
			Opponent = challenger,
			MaxHp = tMaxHp,
			Hp = tMaxHp,
			Power = tPower,
			Color = tAura and tAura.Color or Color3.fromRGB(245, 158, 11),
			LastSkill = {},
		}

		PvPStateEvent:FireClient(challenger, { InBattle = true, Opponent = targetPlayer.DisplayName or targetPlayer.Name, MyHp = cMaxHp, MyMaxHp = cMaxHp, OpHp = tMaxHp, OpMaxHp = tMaxHp })
		PvPStateEvent:FireClient(targetPlayer, { InBattle = true, Opponent = challenger.DisplayName or challenger.Name, MyHp = tMaxHp, MyMaxHp = tMaxHp, OpHp = cMaxHp, OpMaxHp = cMaxHp })
	end
end)

PvPUseSkillFunc.OnServerInvoke = function(caster, skillIndex)
	local duel = activeDuels[caster]
	if not duel then return { Success = false } end
	local target = duel.Opponent
	local targetDuel = activeDuels[target]
	if not targetDuel then return { Success = false } end

	local now = os.clock()
	local cd = (skillIndex == 1 and 1.2) or (skillIndex == 2 and 3.5) or 7.0
	if (now - (duel.LastSkill[skillIndex] or 0)) < cd then
		return { Success = false, Message = "Кулдаун!" }
	end
	duel.LastSkill[skillIndex] = now

	local baseDmg = (skillIndex == 1 and (120 + math.floor(math.sqrt(duel.Power) * 2)))
		or (skillIndex == 2 and (280 + math.floor(math.sqrt(duel.Power) * 4)))
		or (650 + math.floor(math.sqrt(duel.Power) * 8))

	local isCrit = (math.random(1, 100) <= 25)
	if isCrit then baseDmg = math.floor(baseDmg * 1.5) end

	targetDuel.Hp = math.max(0, targetDuel.Hp - baseDmg)

	PvPVFXEvent:FireAllClients({
		SkillIndex = skillIndex,
		Caster = caster.Name,
		Target = target.Name,
		Damage = baseDmg,
		IsCrit = isCrit,
		Color = duel.Color,
	})

	if targetDuel.Hp <= 0 then
		local cData = sessionData[caster]
		if cData then cData.Coins = (cData.Coins or 0) + 5000 end
		syncClient(caster)

		activeDuels[caster] = nil
		activeDuels[target] = nil

		PvPStateEvent:FireClient(caster, { InBattle = false, Won = true, Reward = 5000 })
		PvPStateEvent:FireClient(target, { InBattle = false, Won = false })
	else
		PvPStateEvent:FireClient(caster, { InBattle = true, MyHp = duel.Hp, MyMaxHp = duel.MaxHp, OpHp = targetDuel.Hp, OpMaxHp = targetDuel.MaxHp })
		PvPStateEvent:FireClient(target, { InBattle = true, MyHp = targetDuel.Hp, MyMaxHp = targetDuel.MaxHp, OpHp = duel.Hp, OpMaxHp = duel.MaxHp })
	end

	return { Success = true, Damage = baseDmg }
end

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
-- Dynamic CS2-style Case Opening Roulette, Item Icons on all Cards, Full Player vs Player (PvP) Combat Arena
-- with 3 Unique Skills & Damage Popups, 30%/50%/75% & 2x/5x/10x Aura Upgrader, Clear Sell/Equip Controls,
-- and Rich Multi-Category Donation Shop with Starter Pack Promos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ReplicatedStorage references
local AuraRNGFolder = ReplicatedStorage:WaitForChild("AuraRNG")
local EventsFolder = AuraRNGFolder:WaitForChild("Events")
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")

local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local AuraVisuals = require(ModulesFolder:WaitForChild("AuraVisuals"))
local SoundEffects = require(ModulesFolder:WaitForChild("SoundEffects"))

-- Remotes
local RollRequestFunc = EventsFolder:WaitForChild("RollRequest")
local CraftAuraFunc = EventsFolder:WaitForChild("CraftAura")
local PurchaseProductFunc = EventsFolder:WaitForChild("PurchaseProduct")
local UpgradeAuraFunc = EventsFolder:WaitForChild("UpgradeAura")
local PvPChallengeFunc = EventsFolder:WaitForChild("PvPChallenge")
local PvPUseSkillFunc = EventsFolder:WaitForChild("PvPUseSkill")
local EquipAuraEvent = EventsFolder:WaitForChild("EquipAura")
local DeleteAuraEvent = EventsFolder:WaitForChild("DeleteAura")
local SetAutoDeleteEvent = EventsFolder:WaitForChild("SetAutoDelete")
local ToggleTestPerkEvent = EventsFolder:WaitForChild("ToggleTestPerk")
local DataSyncEvent = EventsFolder:WaitForChild("DataSync")
local GlobalAnnouncementEvent = EventsFolder:WaitForChild("GlobalAnnouncement")
local PvPResponseEvent = EventsFolder:WaitForChild("PvPResponse")
local PvPStateEvent = EventsFolder:WaitForChild("PvPState")
local PvPVFXEvent = EventsFolder:WaitForChild("PvPVFX")

-- Local Player State Cache
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
	MegaPotionExpiry = 0,
	Gamepasses = {},
	TestPerks = {},
	CurrentLuck = 1.0,
}

local isAutoRollOn = false
local isFastRollOn = false
local isRolling = false
local selectedInventoryAura = nil
local selectedCraftRecipe = nil
local activeModal = nil

-- PvP State
local inBattle = false
local battleOpponent = ""
local battleMyHp = 1000
local battleMyMaxHp = 1000
local battleOpHp = 1000
local battleOpMaxHp = 1000
local skillCooldowns = { [1] = 0, [2] = 0, [3] = 0 }

--------------------------------------------------------------------------------
-- UI ROOT & UTILITIES
--------------------------------------------------------------------------------

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RNG_ScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 52, 70)
	stroke.Thickness = thickness or 1.5
	stroke.Transparency = transparency or 0.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function addPadding(parent, top, bottom, left, right)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top or 8)
	pad.PaddingBottom = UDim.new(0, bottom or 8)
	pad.PaddingLeft = UDim.new(0, left or 12)
	pad.PaddingRight = UDim.new(0, right or 12)
	pad.Parent = parent
	return pad
end

--------------------------------------------------------------------------------
-- 1. TOP HUD (RESPONSIVE CAPSULE)
--------------------------------------------------------------------------------

local topHud = Instance.new("Frame")
topHud.Name = "TopHUD"
topHud.AnchorPoint = Vector2.new(0.5, 0)
topHud.Position = UDim2.new(0.5, 0, 0, 12)
topHud.Size = UDim2.new(0.85, 0, 0, 46)
topHud.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
topHud.BackgroundTransparency = 0.15
addCorner(topHud, 14)
addStroke(topHud, Color3.fromRGB(45, 55, 78), 1.5)
addPadding(topHud, 4, 4, 16, 16)
topHud.Parent = screenGui

local topSizeConstraint = Instance.new("UISizeConstraint")
topSizeConstraint.MaxSize = Vector2.new(720, 48)
topSizeConstraint.MinSize = Vector2.new(320, 40)
topSizeConstraint.Parent = topHud

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 16)
topLayout.Parent = topHud

local function createTopStatPill(iconAsset, defaultText, color)
	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 134, 0, 32)
	pill.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	pill.BackgroundTransparency = 0.4
	addCorner(pill, 8)
	addStroke(pill, Color3.fromRGB(35, 42, 60), 1)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 18, 0, 18)
	iconImg.Position = UDim2.new(0, 8, 0.5, -9)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = pill

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -32, 1, 0)
	label.Position = UDim2.new(0, 28, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = color
	label.Text = defaultText
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = pill

	pill.Parent = topHud
	return label, pill
end

local rollsLabel, rollsPill = createTopStatPill("rbxasset://textures/particles/sparkles_main.dds", "Роллы: 0", Color3.fromRGB(220, 225, 240))
local luckLabel, luckPill = createTopStatPill("rbxasset://textures/ui/InspectMenu/ico_favorite.png", "Удача: x1.0", Color3.fromRGB(74, 222, 128))
local coinsLabel, coinsPill = createTopStatPill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "Монеты: 100", Color3.fromRGB(250, 204, 21))
local potionLabel, potionPill = createTopStatPill("rbxassetid://241594432", "Зелье: Нет", Color3.fromRGB(56, 189, 248))

--------------------------------------------------------------------------------
-- 2. TOP-RIGHT SPECIAL OFFER WIDGET (STARTER PACK PROMOTION)
--------------------------------------------------------------------------------

local specialOffer = Instance.new("Frame")
specialOffer.Name = "SpecialOffer"
specialOffer.AnchorPoint = Vector2.new(1, 0)
specialOffer.Position = UDim2.new(1, -14, 0, 12)
specialOffer.Size = UDim2.new(0, 220, 0, 72)
specialOffer.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
specialOffer.BackgroundTransparency = 0.1
addCorner(specialOffer, 12)
addStroke(specialOffer, Color3.fromRGB(245, 158, 11), 1.8)
addPadding(specialOffer, 6, 6, 8, 8)
specialOffer.Parent = screenGui

local offerTitle = Instance.new("TextLabel")
offerTitle.Size = UDim2.new(1, 0, 0, 16)
offerTitle.BackgroundTransparency = 1
offerTitle.Font = Enum.Font.GothamBlack
offerTitle.TextSize = 11
offerTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
offerTitle.Text = "СТАРТЕР ПАК [-80%]"
offerTitle.Parent = specialOffer

local offerSub = Instance.new("TextLabel")
offerSub.Size = UDim2.new(1, 0, 0, 14)
offerSub.Position = UDim2.new(0, 0, 0, 16)
offerSub.BackgroundTransparency = 1
offerSub.Font = Enum.Font.GothamMedium
offerSub.TextSize = 10
offerSub.TextColor3 = Color3.fromRGB(220, 225, 240)
offerSub.Text = "x2 Luck + VIP + 25K Монет"
offerSub.Parent = specialOffer

local offerBuyBtn = Instance.new("TextButton")
offerBuyBtn.Size = UDim2.new(1, 0, 0, 26)
offerBuyBtn.Position = UDim2.new(0, 0, 1, -26)
offerBuyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
offerBuyBtn.Font = Enum.Font.GothamBlack
offerBuyBtn.TextSize = 11
offerBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
offerBuyBtn.Text = "ЗАБРАТЬ (R$ 149 / ТЕСТ)"
addCorner(offerBuyBtn, 6)
offerBuyBtn.Parent = specialOffer

offerBuyBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	offerBuyBtn.Text = "ПОЛУЧЕНО! [+25K / x2 LUCK / VIP]"
	offerBuyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	local res = PurchaseProductFunc:InvokeServer("StarterPack")
	if res and res.Success then
		SoundEffects.Play("RevealMythic")
	end
	task.delay(1.5, function()
		offerBuyBtn.Text = "ЗАБРАТЬ (R$ 149 / ТЕСТ)"
	end)
end)

--------------------------------------------------------------------------------
-- 3. RIGHT FLOATING QUICK-DONATE BAR
--------------------------------------------------------------------------------

local rightDonateBar = Instance.new("Frame")
rightDonateBar.Name = "RightDonateBar"
rightDonateBar.AnchorPoint = Vector2.new(1, 0.5)
rightDonateBar.Position = UDim2.new(1, -14, 0.5, 0)
rightDonateBar.Size = UDim2.new(0, 110, 0, 280)
rightDonateBar.BackgroundTransparency = 1
rightDonateBar.Parent = screenGui

local rightLayout = Instance.new("UIListLayout")
rightLayout.FillDirection = Enum.FillDirection.Vertical
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
rightLayout.Padding = UDim.new(0, 8)
rightLayout.Parent = rightDonateBar

local function createQuickDonatePill(iconAsset, title, color, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	btn.Text = ""
	addCorner(btn, 10)
	local stroke = addStroke(btn, color, 1.5)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 18, 0, 18)
	iconImg.Position = UDim2.new(0, 8, 0.5, -9)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -32, 1, 0)
	lbl.Position = UDim2.new(0, 30, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 10
	lbl.TextColor3 = color
	lbl.Text = title
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(28, 34, 52) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18, 22, 32) }):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		if onClick then onClick() end
	end)

	btn.Parent = rightDonateBar
	return btn
end

local toggleShopModal = nil

createQuickDonatePill("rbxasset://textures/ui/InspectMenu/ico_favorite.png", "МАГАЗИН", Color3.fromRGB(168, 85, 247), function()
	if toggleShopModal then toggleShopModal() end
end)

createQuickDonatePill("rbxasset://textures/particles/sparkles_main.dds", "x2 УДАЧА", Color3.fromRGB(74, 222, 128), function()
	ToggleTestPerkEvent:FireServer("X2Luck")
end)

createQuickDonatePill("rbxassetid://258127006", "VIP СТАТУС", Color3.fromRGB(245, 158, 11), function()
	ToggleTestPerkEvent:FireServer("VIP")
end)

createQuickDonatePill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "АВТО-РОЛЛ", Color3.fromRGB(250, 204, 21), function()
	ToggleTestPerkEvent:FireServer("AutoRoll")
end)

createQuickDonatePill("rbxassetid://241594432", "x5 ЗЕЛЬЕ", Color3.fromRGB(6, 182, 212), function()
	PurchaseProductFunc:InvokeServer("MegaPotion")
end)

createQuickDonatePill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "+50K МОНЕТ", Color3.fromRGB(251, 191, 36), function()
	PurchaseProductFunc:InvokeServer("CoinPack50k")
end)

--------------------------------------------------------------------------------
-- 4. BOTTOM CONTROLS & REDESIGNED MODERN AAA ROLL BUTTON
--------------------------------------------------------------------------------

local bottomControls = Instance.new("Frame")
bottomControls.Name = "BottomControls"
bottomControls.AnchorPoint = Vector2.new(0.5, 1)
bottomControls.Position = UDim2.new(0.5, 0, 1, -16)
bottomControls.Size = UDim2.new(0, 480, 0, 116)
bottomControls.BackgroundTransparency = 1
bottomControls.Parent = screenGui

local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.AnchorPoint = Vector2.new(0.5, 0)
rollButton.Position = UDim2.new(0.5, 0, 0, 0)
rollButton.Size = UDim2.new(0, 260, 0, 68)
rollButton.BackgroundColor3 = Color3.fromRGB(15, 20, 34)
rollButton.AutoButtonColor = false
rollButton.Text = ""
addCorner(rollButton, 18)

local rollStroke = addStroke(rollButton, Color3.fromRGB(56, 189, 248), 2.5)

local rollGrad = Instance.new("UIGradient")
rollGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 58, 138)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(29, 78, 216)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 165, 233)),
})
rollGrad.Rotation = 45
rollGrad.Parent = rollButton

local rollIcon = Instance.new("ImageLabel")
rollIcon.Size = UDim2.new(0, 32, 0, 32)
rollIcon.Position = UDim2.new(0, 16, 0.5, -16)
rollIcon.BackgroundTransparency = 1
rollIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
rollIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
rollIcon.Parent = rollButton

local rollTitle = Instance.new("TextLabel")
rollTitle.Size = UDim2.new(1, -56, 0, 28)
rollTitle.Position = UDim2.new(0, 52, 0, 10)
rollTitle.BackgroundTransparency = 1
rollTitle.Font = Enum.Font.GothamBlack
rollTitle.TextSize = 20
rollTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
rollTitle.Text = "КРУТИТЬ [ ROLL ]"
rollTitle.TextXAlignment = Enum.TextXAlignment.Left
rollTitle.Parent = rollButton

local rollSub = Instance.new("TextLabel")
rollSub.Size = UDim2.new(1, -56, 0, 18)
rollSub.Position = UDim2.new(0, 52, 0, 38)
rollSub.BackgroundTransparency = 1
rollSub.Font = Enum.Font.GothamBold
rollSub.TextSize = 11
rollSub.TextColor3 = Color3.fromRGB(147, 197, 253)
rollSub.Text = "[ ПРОБЕЛ / КЛИК ]"
rollSub.TextXAlignment = Enum.TextXAlignment.Left
rollSub.Parent = rollButton

-- Interactive spring animations
rollButton.MouseEnter:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 272, 0, 72),
		Position = UDim2.new(0.5, 0, 0, -2)
	}):Play()
	rollStroke.Color = Color3.fromRGB(125, 211, 252)
	rollStroke.Thickness = 3.2
end)

rollButton.MouseLeave:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 260, 0, 68),
		Position = UDim2.new(0.5, 0, 0, 0)
	}):Play()
	rollStroke.Color = Color3.fromRGB(56, 189, 248)
	rollStroke.Thickness = 2.5
end)

rollButton.MouseButton1Down:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.08), {
		Size = UDim2.new(0, 248, 0, 64),
		Position = UDim2.new(0.5, 0, 0, 2)
	}):Play()
end)

rollButton.MouseButton1Up:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 272, 0, 72),
		Position = UDim2.new(0.5, 0, 0, -2)
	}):Play()
end)

rollButton.Parent = bottomControls

local secondaryBar = Instance.new("Frame")
secondaryBar.Size = UDim2.new(0, 340, 0, 34)
secondaryBar.AnchorPoint = Vector2.new(0.5, 1)
secondaryBar.Position = UDim2.new(0.5, 0, 1, 0)
secondaryBar.BackgroundTransparency = 1
secondaryBar.Parent = bottomControls

local secLayout = Instance.new("UIListLayout")
secLayout.FillDirection = Enum.FillDirection.Horizontal
secLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
secLayout.Padding = UDim.new(0, 12)
secLayout.Parent = secondaryBar

local autoRollBtn = Instance.new("TextButton")
autoRollBtn.Name = "AutoRollBtn"
autoRollBtn.Size = UDim2.new(0, 160, 1, 0)
autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
autoRollBtn.Font = Enum.Font.GothamBold
autoRollBtn.TextSize = 12
autoRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
autoRollBtn.Text = "АВТО-РОЛЛ: ВЫКЛ"
addCorner(autoRollBtn, 8)
local autoStroke = addStroke(autoRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
autoRollBtn.Parent = secondaryBar

local fastRollBtn = Instance.new("TextButton")
fastRollBtn.Name = "FastRollBtn"
fastRollBtn.Size = UDim2.new(0, 160, 1, 0)
fastRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
fastRollBtn.Font = Enum.Font.GothamBold
fastRollBtn.TextSize = 12
fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
fastRollBtn.Text = "ФАСТ-РОЛЛ: ВЫКЛ"
addCorner(fastRollBtn, 8)
local fastStroke = addStroke(fastRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
fastRollBtn.Parent = secondaryBar

--------------------------------------------------------------------------------
-- 5. LEFT DOCK NAVIGATION BAR (HIGH-TECH MONOGRAM BADGES)
--------------------------------------------------------------------------------

local leftDock = Instance.new("Frame")
leftDock.Name = "LeftDock"
leftDock.AnchorPoint = Vector2.new(0, 0.5)
leftDock.Position = UDim2.new(0, 14, 0.5, 0)
leftDock.Size = UDim2.new(0, 62, 0, 340)
leftDock.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
leftDock.BackgroundTransparency = 0.15
addCorner(leftDock, 14)
addStroke(leftDock, Color3.fromRGB(45, 55, 78), 1.5)
addPadding(leftDock, 8, 8, 4, 4)
leftDock.Parent = screenGui

local dockLayout = Instance.new("UIListLayout")
dockLayout.FillDirection = Enum.FillDirection.Vertical
dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dockLayout.Padding = UDim.new(0, 8)
dockLayout.Parent = leftDock

local function createDockButton(name, iconAsset, tooltipText)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Btn"
	btn.Size = UDim2.new(0, 48, 0, 48)
	btn.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	btn.Text = ""
	addCorner(btn, 10)
	local stroke = addStroke(btn, Color3.fromRGB(45, 55, 78), 1.2)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 26, 0, 26)
	iconImg.Position = UDim2.new(0.5, -13, 0.5, -13)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = Color3.fromRGB(210, 220, 240)
	iconImg.Parent = btn

	local tooltip = Instance.new("TextLabel")
	tooltip.Size = UDim2.new(0, 110, 0, 28)
	tooltip.Position = UDim2.new(1, 10, 0.5, -14)
	tooltip.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
	tooltip.Font = Enum.Font.GothamBold
	tooltip.TextSize = 10
	tooltip.TextColor3 = Color3.fromRGB(240, 245, 255)
	tooltip.Text = tooltipText
	tooltip.Visible = false
	tooltip.ZIndex = 20
	addCorner(tooltip, 6)
	addStroke(tooltip, Color3.fromRGB(56, 189, 248), 1)
	tooltip.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(37, 99, 235),
			Size = UDim2.new(0, 52, 0, 52)
		}):Play()
		iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
		stroke.Color = Color3.fromRGB(96, 165, 250)
		tooltip.Visible = true
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(20, 24, 36),
			Size = UDim2.new(0, 48, 0, 48)
		}):Play()
		iconImg.ImageColor3 = Color3.fromRGB(210, 220, 240)
		stroke.Color = Color3.fromRGB(45, 55, 78)
		tooltip.Visible = false
	end)

	btn.Parent = leftDock
	return btn
end

local navInventoryBtn = createDockButton("Inventory", "rbxasset://textures/ui/TopBar/inventoryOff.png", "Инвентарь")
local navUpgraderBtn = createDockButton("Upgrader", "rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "Апгрейдер Аур")
local navPvPBtn = createDockButton("PvP", "rbxasset://textures/ui/InspectMenu/ico_equipped.png", "Арена Батлов")
local navCraftingBtn = createDockButton("Crafting", "rbxasset://textures/particles/sparkles_main.dds", "Кузница Крафта")
local navShopBtn = createDockButton("Shop", "rbxasset://textures/ui/InspectMenu/ico_favorite.png", "Магазин Доната")
local navSettingsBtn = createDockButton("Settings", "rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png", "Настройки")

--------------------------------------------------------------------------------
-- 6. BOTTOM-LEFT EQUIPPED AURA SHOWCASE CARD
--------------------------------------------------------------------------------

local equippedCard = Instance.new("Frame")
equippedCard.Name = "EquippedCard"
equippedCard.AnchorPoint = Vector2.new(0, 1)
equippedCard.Position = UDim2.new(0, 14, 1, -14)
equippedCard.Size = UDim2.new(0, 200, 0, 60)
equippedCard.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
equippedCard.BackgroundTransparency = 0.2
addCorner(equippedCard, 10)
local eqStroke = addStroke(equippedCard, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(equippedCard, 8, 8, 12, 8)
equippedCard.Parent = screenGui

local eqName = Instance.new("TextLabel")
eqName.Size = UDim2.new(1, -40, 0, 20)
eqName.Position = UDim2.new(0, 0, 0, 2)
eqName.BackgroundTransparency = 1
eqName.Font = Enum.Font.GothamBlack
eqName.TextSize = 14
eqName.TextColor3 = Color3.fromRGB(240, 243, 250)
eqName.TextXAlignment = Enum.TextXAlignment.Left
eqName.Text = "Aura: None"
eqName.Parent = equippedCard

local eqSub = Instance.new("TextLabel")
eqSub.Size = UDim2.new(1, -40, 0, 16)
eqSub.Position = UDim2.new(0, 0, 0, 24)
eqSub.BackgroundTransparency = 1
eqSub.Font = Enum.Font.GothamBold
eqSub.TextSize = 11
eqSub.TextColor3 = Color3.fromRGB(156, 163, 175)
eqSub.TextXAlignment = Enum.TextXAlignment.Left
eqSub.Text = "Not Equipped"
eqSub.Parent = equippedCard

local unequipBtn = Instance.new("TextButton")
unequipBtn.Size = UDim2.new(0, 32, 0, 32)
unequipBtn.Position = UDim2.new(1, -34, 0.5, -16)
unequipBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
unequipBtn.Font = Enum.Font.GothamBold
unequipBtn.TextSize = 12
unequipBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
unequipBtn.Text = "[X]"
addCorner(unequipBtn, 6)
unequipBtn.Parent = equippedCard

--------------------------------------------------------------------------------
-- 7. MODAL WINDOW CREATOR
--------------------------------------------------------------------------------

local function createModal(titleText, width, height)
	local window = Instance.new("Frame")
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.new(0.5, 0, 0.5, 0)
	window.Size = UDim2.new(0, width, 0, height)
	window.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
	window.BackgroundTransparency = 0.08
	window.Visible = false
	addCorner(window, 16)
	addStroke(window, Color3.fromRGB(55, 65, 90), 2)
	window.Parent = screenGui

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	header.BackgroundTransparency = 0.3
	addCorner(header, 16)
	header.Parent = window

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 18, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(240, 243, 250)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = titleText
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 56)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
	closeBtn.Text = "[X]"
	addCorner(closeBtn, 8)
	closeBtn.Parent = header

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -28, 1, -64)
	content.Position = UDim2.new(0, 14, 0, 54)
	content.BackgroundTransparency = 1
	content.Parent = window

	closeBtn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		window.Visible = false
		if activeModal == window then activeModal = nil end
	end)

	return window, content
end

local function toggleModal(modal)
	SoundEffects.Play("Click")
	if activeModal == modal then
		modal.Visible = false
		activeModal = nil
	else
		if activeModal then activeModal.Visible = false end
		modal.Visible = true
		activeModal = modal
		modal.Size = UDim2.new(0, modal.Size.X.Offset * 0.9, 0, modal.Size.Y.Offset * 0.9)
		TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, modal.Size.X.Offset / 0.9, 0, modal.Size.Y.Offset / 0.9),
		}):Play()
	end
end

--------------------------------------------------------------------------------
-- 8. INVENTORY WINDOW (EXPLICIT EQUIP & SELL BUTTONS WITH ITEM ICONS)
--------------------------------------------------------------------------------

local invWindow, invContent = createModal("ИНВЕНТАРЬ АУР", 680, 480)

local topInvBar = Instance.new("Frame")
topInvBar.Size = UDim2.new(1, 0, 0, 28)
topInvBar.BackgroundTransparency = 1
topInvBar.Parent = invContent

local storageBarBg = Instance.new("Frame")
storageBarBg.Size = UDim2.new(0, 220, 0, 24)
storageBarBg.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(storageBarBg, 6)
storageBarBg.Parent = topInvBar

local storageFill = Instance.new("Frame")
storageFill.Size = UDim2.new(0.5, 0, 1, 0)
storageFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
addCorner(storageFill, 6)
storageFill.Parent = storageBarBg

local storageText = Instance.new("TextLabel")
storageText.Size = UDim2.new(1, 0, 1, 0)
storageText.BackgroundTransparency = 1
storageText.Font = Enum.Font.GothamBold
storageText.TextSize = 12
storageText.TextColor3 = Color3.fromRGB(255, 255, 255)
storageText.Text = "Слоты: 0 / 20"
storageText.Parent = storageBarBg

local autoDeleteBtn = Instance.new("TextButton")
autoDeleteBtn.Size = UDim2.new(0, 190, 0, 26)
autoDeleteBtn.Position = UDim2.new(1, -190, 0, 0)
autoDeleteBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
autoDeleteBtn.Font = Enum.Font.GothamMedium
autoDeleteBtn.TextSize = 12
autoDeleteBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
autoDeleteBtn.Text = "Авто-продажа: Нет"
addCorner(autoDeleteBtn, 6)
addStroke(autoDeleteBtn, Color3.fromRGB(50, 60, 82), 1)
autoDeleteBtn.Parent = topInvBar

local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -230, 1, -38)
invScroll.Position = UDim2.new(0, 0, 0, 36)
invScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
invScroll.BackgroundTransparency = 0.4
invScroll.ScrollBarThickness = 5
addCorner(invScroll, 8)
invScroll.Parent = invContent

local invGrid = Instance.new("UIGridLayout")
invGrid.CellSize = UDim2.new(0, 95, 0, 95)
invGrid.CellPadding = UDim2.new(0, 8, 0, 8)
invGrid.Parent = invScroll
addPadding(invScroll, 8, 8, 8, 8)

local detailPanel = Instance.new("Frame")
detailPanel.Size = UDim2.new(0, 215, 1, -38)
detailPanel.Position = UDim2.new(1, -215, 0, 36)
detailPanel.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(detailPanel, 8)
addStroke(detailPanel, Color3.fromRGB(42, 50, 70), 1)
addPadding(detailPanel, 12, 12, 12, 12)
detailPanel.Parent = invContent

-- Item Icon in details panel
local detailEmblemHolder = Instance.new("Frame")
detailEmblemHolder.Size = UDim2.new(0, 48, 0, 48)
detailEmblemHolder.Position = UDim2.new(0.5, -24, 0, 4)
detailEmblemHolder.BackgroundTransparency = 1
detailEmblemHolder.Parent = detailPanel

local detailName = Instance.new("TextLabel")
detailName.Size = UDim2.new(1, 0, 0, 22)
detailName.Position = UDim2.new(0, 0, 0, 56)
detailName.BackgroundTransparency = 1
detailName.Font = Enum.Font.GothamBlack
detailName.TextSize = 15
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.Text = "Выберите Ауру"
detailName.Parent = detailPanel

local detailRarity = Instance.new("TextLabel")
detailRarity.Size = UDim2.new(1, 0, 0, 16)
detailRarity.Position = UDim2.new(0, 0, 0, 78)
detailRarity.BackgroundTransparency = 1
detailRarity.Font = Enum.Font.GothamBold
detailRarity.TextSize = 11
detailRarity.TextColor3 = Color3.fromRGB(156, 163, 175)
detailRarity.Text = ""
detailRarity.Parent = detailPanel

local detailDesc = Instance.new("TextLabel")
detailDesc.Size = UDim2.new(1, 0, 0, 70)
detailDesc.Position = UDim2.new(0, 0, 0, 96)
detailDesc.BackgroundTransparency = 1
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 11
detailDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
detailDesc.TextWrapped = true
detailDesc.TextYAlignment = Enum.TextYAlignment.Top
detailDesc.Text = "Нажмите на ауру слева для управления."
detailDesc.Parent = detailPanel

local equipActionBtn = Instance.new("TextButton")
equipActionBtn.Size = UDim2.new(1, 0, 0, 40)
equipActionBtn.Position = UDim2.new(0, 0, 1, -90)
equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
equipActionBtn.Font = Enum.Font.GothamBlack
equipActionBtn.TextSize = 13
equipActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipActionBtn.Text = "ЭКИПИРОВАТЬ"
equipActionBtn.Visible = false
addCorner(equipActionBtn, 8)
equipActionBtn.Parent = detailPanel

local sellActionBtn = Instance.new("TextButton")
sellActionBtn.Size = UDim2.new(1, 0, 0, 38)
sellActionBtn.Position = UDim2.new(0, 0, 1, -44)
sellActionBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
sellActionBtn.Font = Enum.Font.GothamBlack
sellActionBtn.TextSize = 12
sellActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellActionBtn.Text = "ПРОДАТЬ (+50 МОНЕТ)"
sellActionBtn.Visible = false
addCorner(sellActionBtn, 8)
sellActionBtn.Parent = detailPanel

local function refreshInventoryUI()
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local totalCount = 0
	for auraId, count in pairs(localData.Inventory) do
		totalCount = totalCount + count
		local auraData = AuraConfig.Auras[auraId]
		if auraData then
			local card = Instance.new("TextButton")
			card.Name = "Card_" .. auraId
			card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
			card.Text = ""
			addCorner(card, 8)
			addStroke(card, auraData.Color, 1.5)

			-- Procedural Guaranteed Aura Emblem
			createAuraEmblem(card, auraData, 34, UDim2.new(0.5, -17, 0, 6))

			local symBadge = Instance.new("TextLabel")
			symBadge.Size = UDim2.new(0, 26, 0, 14)
			symBadge.Position = UDim2.new(1, -28, 0, 4)
			symBadge.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
			symBadge.Font = Enum.Font.GothamBlack
			symBadge.TextSize = 8
			symBadge.TextColor3 = auraData.Color
			symBadge.Text = auraData.Symbol or "AUR"
			addCorner(symBadge, 3)
			symBadge.Parent = card

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -8, 0, 20)
			name.Position = UDim2.new(0, 4, 0, 44)
			name.BackgroundTransparency = 1
			name.Font = Enum.Font.GothamBold
			name.TextSize = 11
			name.TextColor3 = auraData.Color
			name.Text = auraData.Name
			name.TextWrapped = true
			name.Parent = card

			local rarity = Instance.new("TextLabel")
			rarity.Size = UDim2.new(1, -8, 0, 14)
			rarity.Position = UDim2.new(0, 4, 0, 64)
			rarity.BackgroundTransparency = 1
			rarity.Font = Enum.Font.GothamMedium
			rarity.TextSize = 9
			rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
			rarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
			rarity.Parent = card

			local countTag = Instance.new("TextLabel")
			countTag.Size = UDim2.new(0, 28, 0, 16)
			countTag.Position = UDim2.new(1, -30, 1, -18)
			countTag.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
			countTag.Font = Enum.Font.GothamBold
			countTag.TextSize = 9
			countTag.TextColor3 = Color3.fromRGB(220, 225, 240)
			countTag.Text = "x" .. tostring(count)
			addCorner(countTag, 4)
			countTag.Parent = card

			if localData.EquippedAura == auraId then
				local eqTag = Instance.new("TextLabel")
				eqTag.Size = UDim2.new(0, 44, 0, 16)
				eqTag.Position = UDim2.new(0, 4, 1, -18)
				eqTag.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				eqTag.Font = Enum.Font.GothamBold
				eqTag.TextSize = 8
				eqTag.TextColor3 = Color3.fromRGB(255, 255, 255)
				eqTag.Text = "НАДЕТО"
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
				detailEmblemHolder:ClearAllChildren()
				createAuraEmblem(detailEmblemHolder, auraData, 48, UDim2.new(0, 0, 0, 0))

				equipActionBtn.Visible = true
				if localData.EquippedAura == auraId then
					equipActionBtn.Text = "СНЯТЬ АУРУ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
				else
					equipActionBtn.Text = "ЭКИПИРОВАТЬ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				end

				local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
				sellActionBtn.Text = string.format("ПРОДАТЬ (+%d МОНЕТ)", scrapCoins)
				sellActionBtn.Visible = true
			end)

			card.Parent = invScroll
		end
	end

	local maxSlots = localData.MaxStorage or 20
	storageText.Text = string.format("Слоты: %d / %d", totalCount, maxSlots)
	local ratio = math.clamp(totalCount / maxSlots, 0, 1)
	storageFill.Size = UDim2.new(ratio, 0, 1, 0)
	if ratio >= 1.0 then
		storageFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	elseif ratio >= 0.8 then
		storageFill.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
	else
		storageFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	end

	invScroll.CanvasSize = UDim2.new(0, 0, 0, invGrid.AbsoluteContentSize.Y + 24)
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

sellActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Coin")
	DeleteAuraEvent:FireServer(selectedInventoryAura)
	selectedInventoryAura = nil
	equipActionBtn.Visible = false
	sellActionBtn.Visible = false
	detailName.Text = "Выберите Ауру"
	detailRarity.Text = ""
	detailDesc.Text = "Аура успешно продана за монеты!"
end)

local thresholds = { 0, 2, 4, 16, 64 }
local thresholdNames = { [0] = "Нет", [2] = "Common (1/2)", [4] = "Uncommon (1/4)", [16] = "Rare (1/16)", [64] = "Crystallized (1/64)" }
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
	SetAutoDeleteEvent:FireServer(thresholds[nextIdx])
end)

--------------------------------------------------------------------------------
-- 9. AURA UPGRADER WINDOW (DYNAMIC GREEN WIN SECTOR & 2 BLOCKS & CUSTOM CHANCE)
--------------------------------------------------------------------------------

local upgWindow, upgContent = createModal("АПГРЕЙДЕР АУР [ РИСК-КОЛЕСО ]", 880, 540)

local selectedSourceAuraId = nil
local selectedTargetAuraId = nil
local isUpgraderFast = false
local upgraderChance = 50.0
local isWheelSpinning = false

-- Top Control Bar of Upgrader (Mode Toggle: Arcade vs Fast)
local upgTopBar = Instance.new("Frame")
upgTopBar.Size = UDim2.new(1, 0, 0, 32)
upgTopBar.Position = UDim2.new(0, 0, 0, 0)
upgTopBar.BackgroundTransparency = 1
upgTopBar.Parent = upgContent

local upgModeToggleBtn = Instance.new("TextButton")
upgModeToggleBtn.Size = UDim2.new(0, 240, 1, 0)
upgModeToggleBtn.Position = UDim2.new(1, -240, 0, 0)
upgModeToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
upgModeToggleBtn.Font = Enum.Font.GothamBold
upgModeToggleBtn.TextSize = 11
upgModeToggleBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
upgModeToggleBtn.Text = "РЕЖИМ: АРКАДНЫЙ (3.2С)"
addCorner(upgModeToggleBtn, 6)
local modeStroke = addStroke(upgModeToggleBtn, Color3.fromRGB(56, 189, 248), 1.2)
upgModeToggleBtn.Parent = upgTopBar

upgModeToggleBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isUpgraderFast = not isUpgraderFast
	if isUpgraderFast then
		upgModeToggleBtn.Text = "РЕЖИМ: БЫСТРЫЙ (0.6С)"
		upgModeToggleBtn.TextColor3 = Color3.fromRGB(251, 191, 36)
		modeStroke.Color = Color3.fromRGB(251, 191, 36)
	else
		upgModeToggleBtn.Text = "РЕЖИМ: АРКАДНЫЙ (3.2С)"
		upgModeToggleBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
		modeStroke.Color = Color3.fromRGB(56, 189, 248)
	end
end)

-- Main 3-Column Layout
-- Column 1: BLOCK 1 - Source Aura / Inventory Selection (Left)
local upgColLeft = Instance.new("Frame")
upgColLeft.Size = UDim2.new(0, 240, 1, -38)
upgColLeft.Position = UDim2.new(0, 0, 0, 38)
upgColLeft.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(upgColLeft, 10)
addStroke(upgColLeft, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColLeft, 8, 8, 8, 8)
upgColLeft.Parent = upgContent

local colLeftTitle = Instance.new("TextLabel")
colLeftTitle.Size = UDim2.new(1, 0, 0, 18)
colLeftTitle.BackgroundTransparency = 1
colLeftTitle.Font = Enum.Font.GothamBlack
colLeftTitle.TextSize = 11
colLeftTitle.TextColor3 = Color3.fromRGB(240, 243, 250)
colLeftTitle.Text = "1. ВАША АУРА (ИНВЕНТАРЬ)"
colLeftTitle.Parent = upgColLeft

-- Source Preview Card
local sourcePreviewFrame = Instance.new("Frame")
sourcePreviewFrame.Size = UDim2.new(1, 0, 0, 68)
sourcePreviewFrame.Position = UDim2.new(0, 0, 0, 22)
sourcePreviewFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(sourcePreviewFrame, 8)
local srcStroke = addStroke(sourcePreviewFrame, Color3.fromRGB(56, 189, 248), 1.2)
sourcePreviewFrame.Parent = upgColLeft

local srcEmblemHolder = Instance.new("Frame")
srcEmblemHolder.Size = UDim2.new(0, 42, 0, 42)
srcEmblemHolder.Position = UDim2.new(0, 8, 0.5, -21)
srcEmblemHolder.BackgroundTransparency = 1
srcEmblemHolder.Parent = sourcePreviewFrame

local srcNameLbl = Instance.new("TextLabel")
srcNameLbl.Size = UDim2.new(1, -56, 0, 18)
srcNameLbl.Position = UDim2.new(0, 52, 0, 8)
srcNameLbl.BackgroundTransparency = 1
srcNameLbl.Font = Enum.Font.GothamBlack
srcNameLbl.TextSize = 12
srcNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
srcNameLbl.Text = "Выберите ауру ниже"
srcNameLbl.TextXAlignment = Enum.TextXAlignment.Left
srcNameLbl.Parent = sourcePreviewFrame

local srcSubLbl = Instance.new("TextLabel")
srcSubLbl.Size = UDim2.new(1, -56, 0, 16)
srcSubLbl.Position = UDim2.new(0, 52, 0, 28)
srcSubLbl.BackgroundTransparency = 1
srcSubLbl.Font = Enum.Font.GothamMedium
srcSubLbl.TextSize = 9
srcSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
srcSubLbl.Text = "Нажмите в списке ниже"
srcSubLbl.TextXAlignment = Enum.TextXAlignment.Left
srcSubLbl.Parent = sourcePreviewFrame

local srcScrapLbl = Instance.new("TextLabel")
srcScrapLbl.Size = UDim2.new(1, -56, 0, 14)
srcScrapLbl.Position = UDim2.new(0, 52, 0, 46)
srcScrapLbl.BackgroundTransparency = 1
srcScrapLbl.Font = Enum.Font.GothamBold
srcScrapLbl.TextSize = 9
srcScrapLbl.TextColor3 = Color3.fromRGB(74, 222, 128)
srcScrapLbl.Text = "Возврат: +50 монет"
srcScrapLbl.TextXAlignment = Enum.TextXAlignment.Left
srcScrapLbl.Parent = sourcePreviewFrame

-- Inventory Scroll
local srcScroll = Instance.new("ScrollingFrame")
srcScroll.Size = UDim2.new(1, 0, 1, -100)
srcScroll.Position = UDim2.new(0, 0, 0, 96)
srcScroll.BackgroundTransparency = 1
srcScroll.ScrollBarThickness = 4
srcScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
srcScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
srcScroll.Parent = upgColLeft

local srcLayout = Instance.new("UIGridLayout")
srcLayout.CellSize = UDim2.new(0, 68, 0, 80)
srcLayout.CellPadding = UDim2.new(0, 6, 0, 6)
srcLayout.Parent = srcScroll

-- Column 2: CENTER - UPGRADER WHEEL & DYNAMIC WIN SECTOR GAUGE
local upgColCenter = Instance.new("Frame")
upgColCenter.Size = UDim2.new(1, -500, 1, -38)
upgColCenter.Position = UDim2.new(0, 250, 0, 38)
upgColCenter.BackgroundColor3 = Color3.fromRGB(14, 17, 26)
addCorner(upgColCenter, 10)
addStroke(upgColCenter, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColCenter, 10, 10, 8, 8)
upgColCenter.Parent = upgContent

-- Upgrader Wheel Circular Container
local wheelFrame = Instance.new("Frame")
wheelFrame.Size = UDim2.new(0, 184, 0, 184)
wheelFrame.AnchorPoint = Vector2.new(0.5, 0)
wheelFrame.Position = UDim2.new(0.5, 0, 0, 4)
wheelFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
addCorner(wheelFrame, 92)
local wheelStroke = addStroke(wheelFrame, Color3.fromRGB(34, 197, 94), 2.5)
wheelFrame.Parent = upgColCenter

-- DYNAMIC WIN SECTOR GAUGE BARS (36 radial sector bars covering 360 degrees)
local sectorRing = Instance.new("Frame")
sectorRing.Size = UDim2.new(1, 0, 1, 0)
sectorRing.BackgroundTransparency = 1
sectorRing.Parent = wheelFrame

local sectorBars = {}
local TOTAL_SECTORS = 36

for i = 1, TOTAL_SECTORS do
	local deg = (i - 1) * 10
	local rad = math.rad(deg - 90)
	local r = 68

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 8, 0, 22)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.new(0.5, math.cos(rad) * r, 0.5, math.sin(rad) * r)
	bar.Rotation = deg
	bar.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	addCorner(bar, 3)
	bar.Parent = sectorRing

	table.insert(sectorBars, { Bar = bar, Angle = deg })
end

-- Needle Pointer Container (Rotates around center)
local needleContainer = Instance.new("Frame")
needleContainer.Size = UDim2.new(1, 0, 1, 0)
needleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
needleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
needleContainer.BackgroundTransparency = 1
needleContainer.ZIndex = 10
needleContainer.Parent = wheelFrame

local needle = Instance.new("Frame")
needle.Size = UDim2.new(0, 4, 0, 78)
needle.AnchorPoint = Vector2.new(0.5, 1)
needle.Position = UDim2.new(0.5, 0, 0.5, 0)
needle.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needle.ZIndex = 10
addCorner(needle, 2)
needle.Parent = needleContainer

local needleArrow = Instance.new("Frame")
needleArrow.Size = UDim2.new(0, 14, 0, 14)
needleArrow.AnchorPoint = Vector2.new(0.5, 0.5)
needleArrow.Position = UDim2.new(0.5, 0, 0, 6)
needleArrow.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
needleArrow.Rotation = 45
needleArrow.ZIndex = 10
needleArrow.Parent = needleContainer

-- Center Hub inside Wheel
local centerHub = Instance.new("Frame")
centerHub.Size = UDim2.new(0, 96, 0, 96)
centerHub.AnchorPoint = Vector2.new(0.5, 0.5)
centerHub.Position = UDim2.new(0.5, 0, 0.5, 0)
centerHub.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
centerHub.ZIndex = 12
addCorner(centerHub, 48)
local hubStroke = addStroke(centerHub, Color3.fromRGB(74, 222, 128), 2.0)
centerHub.Parent = wheelFrame

local chanceDisplay = Instance.new("TextLabel")
chanceDisplay.Size = UDim2.new(1, 0, 0, 24)
chanceDisplay.Position = UDim2.new(0, 0, 0, 16)
chanceDisplay.BackgroundTransparency = 1
chanceDisplay.Font = Enum.Font.GothamBlack
chanceDisplay.TextSize = 17
chanceDisplay.TextColor3 = Color3.fromRGB(74, 222, 128)
chanceDisplay.Text = "50.0%"
chanceDisplay.ZIndex = 13
chanceDisplay.Parent = centerHub

local multDisplay = Instance.new("TextLabel")
multDisplay.Size = UDim2.new(1, 0, 0, 16)
multDisplay.Position = UDim2.new(0, 0, 0, 42)
multDisplay.BackgroundTransparency = 1
multDisplay.Font = Enum.Font.GothamBold
multDisplay.TextSize = 11
multDisplay.TextColor3 = Color3.fromRGB(250, 204, 21)
multDisplay.Text = "2.00x МНОЖИТЕЛЬ"
multDisplay.ZIndex = 13
multDisplay.Parent = centerHub

local sectorDisplay = Instance.new("TextLabel")
sectorDisplay.Size = UDim2.new(1, 0, 0, 14)
sectorDisplay.Position = UDim2.new(0, 0, 0, 62)
sectorDisplay.BackgroundTransparency = 1
sectorDisplay.Font = Enum.Font.GothamMedium
sectorDisplay.TextSize = 8
sectorDisplay.TextColor3 = Color3.fromRGB(147, 197, 253)
sectorDisplay.Text = "ЗОНА ПОБЕДЫ: 0 - 180 град."
sectorDisplay.ZIndex = 13
sectorDisplay.Parent = centerHub

-- Presets Row
local presetRow = Instance.new("Frame")
presetRow.Size = UDim2.new(1, 0, 0, 28)
presetRow.Position = UDim2.new(0, 0, 0, 196)
presetRow.BackgroundTransparency = 1
presetRow.Parent = upgColCenter

local presetLayout = Instance.new("UIListLayout")
presetLayout.FillDirection = Enum.FillDirection.Horizontal
presetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
presetLayout.Padding = UDim.new(0, 6)
presetLayout.Parent = presetRow

-- Custom Chance Row
local customRow = Instance.new("Frame")
customRow.Size = UDim2.new(1, 0, 0, 32)
customRow.Position = UDim2.new(0, 0, 0, 230)
customRow.BackgroundTransparency = 1
customRow.Parent = upgColCenter

local customTitle = Instance.new("TextLabel")
customTitle.Size = UDim2.new(0, 85, 1, 0)
customTitle.BackgroundTransparency = 1
customTitle.Font = Enum.Font.GothamBold
customTitle.TextSize = 10
customTitle.TextColor3 = Color3.fromRGB(200, 205, 220)
customTitle.Text = "СВОЙ ШАНС:"
customTitle.TextXAlignment = Enum.TextXAlignment.Left
customTitle.Parent = customRow

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 38, 1, 0)
minusBtn.Position = UDim2.new(0, 88, 0, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
minusBtn.Font = Enum.Font.GothamBlack
minusBtn.TextSize = 12
minusBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
minusBtn.Text = "-5%"
addCorner(minusBtn, 6)
minusBtn.Parent = customRow

local customBox = Instance.new("TextBox")
customBox.Size = UDim2.new(0, 78, 1, 0)
customBox.Position = UDim2.new(0, 132, 0, 0)
customBox.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
customBox.Font = Enum.Font.GothamBlack
customBox.TextSize = 13
customBox.TextColor3 = Color3.fromRGB(74, 222, 128)
customBox.Text = "50.0"
addCorner(customBox, 6)
addStroke(customBox, Color3.fromRGB(45, 55, 78), 1)
customBox.Parent = customRow

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 38, 1, 0)
plusBtn.Position = UDim2.new(0, 216, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
plusBtn.Font = Enum.Font.GothamBlack
plusBtn.TextSize = 12
plusBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
plusBtn.Text = "+5%"
addCorner(plusBtn, 6)
plusBtn.Parent = customRow

-- Action Button and Result Message
local upgResultMsg = Instance.new("TextLabel")
upgResultMsg.Size = UDim2.new(1, 0, 0, 32)
upgResultMsg.Position = UDim2.new(0, 0, 0, 268)
upgResultMsg.BackgroundTransparency = 1
upgResultMsg.Font = Enum.Font.GothamBold
upgResultMsg.TextSize = 11
upgResultMsg.TextColor3 = Color3.fromRGB(180, 185, 200)
upgResultMsg.Text = "Зеленый сектор - ПОБЕДА! Красный сектор - СГОРАНИЕ."
upgResultMsg.TextWrapped = true
upgResultMsg.Parent = upgColCenter

local doUpgradeBtn = Instance.new("TextButton")
doUpgradeBtn.Size = UDim2.new(1, -20, 0, 46)
doUpgradeBtn.AnchorPoint = Vector2.new(0.5, 1)
doUpgradeBtn.Position = UDim2.new(0.5, 0, 1, -10)
doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
doUpgradeBtn.Font = Enum.Font.GothamBlack
doUpgradeBtn.TextSize = 15
doUpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
doUpgradeBtn.Text = "АПГРЕЙДИТЬ АУРУ"
addCorner(doUpgradeBtn, 10)
local doStroke = addStroke(doUpgradeBtn, Color3.fromRGB(251, 191, 36), 1.5)
doUpgradeBtn.Parent = upgColCenter

-- Column 3: BLOCK 2 - Target Aura Selection Catalog (Right)
local upgColRight = Instance.new("Frame")
upgColRight.Size = UDim2.new(0, 240, 1, -38)
upgColRight.Position = UDim2.new(1, -240, 0, 38)
upgColRight.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(upgColRight, 10)
addStroke(upgColRight, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColRight, 8, 8, 8, 8)
upgColRight.Parent = upgContent

local colRightTitle = Instance.new("TextLabel")
colRightTitle.Size = UDim2.new(1, 0, 0, 18)
colRightTitle.BackgroundTransparency = 1
colRightTitle.Font = Enum.Font.GothamBlack
colRightTitle.TextSize = 11
colRightTitle.TextColor3 = Color3.fromRGB(240, 243, 250)
colRightTitle.Text = "2. ЦЕЛЕВАЯ АУРА (ВЫБОР)"
colRightTitle.Parent = upgColRight

-- Target Preview Card
local targetPreviewFrame = Instance.new("Frame")
targetPreviewFrame.Size = UDim2.new(1, 0, 0, 68)
targetPreviewFrame.Position = UDim2.new(0, 0, 0, 22)
targetPreviewFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(targetPreviewFrame, 8)
local tgtStroke = addStroke(targetPreviewFrame, Color3.fromRGB(245, 158, 11), 1.2)
targetPreviewFrame.Parent = upgColRight

local tgtEmblemHolder = Instance.new("Frame")
tgtEmblemHolder.Size = UDim2.new(0, 42, 0, 42)
tgtEmblemHolder.Position = UDim2.new(0, 8, 0.5, -21)
tgtEmblemHolder.BackgroundTransparency = 1
tgtEmblemHolder.Parent = targetPreviewFrame

local tgtNameLbl = Instance.new("TextLabel")
tgtNameLbl.Size = UDim2.new(1, -56, 0, 18)
tgtNameLbl.Position = UDim2.new(0, 52, 0, 8)
tgtNameLbl.BackgroundTransparency = 1
tgtNameLbl.Font = Enum.Font.GothamBlack
tgtNameLbl.TextSize = 12
tgtNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
tgtNameLbl.Text = "Любая аура из списка"
tgtNameLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtNameLbl.Parent = targetPreviewFrame

local tgtSubLbl = Instance.new("TextLabel")
tgtSubLbl.Size = UDim2.new(1, -56, 0, 16)
tgtSubLbl.Position = UDim2.new(0, 52, 0, 28)
tgtSubLbl.BackgroundTransparency = 1
tgtSubLbl.Font = Enum.Font.GothamMedium
tgtSubLbl.TextSize = 9
tgtSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
tgtSubLbl.Text = "Выберите желаемую ауру"
tgtSubLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtSubLbl.Parent = targetPreviewFrame

local tgtRarityLbl = Instance.new("TextLabel")
tgtRarityLbl.Size = UDim2.new(1, -56, 0, 14)
tgtRarityLbl.Position = UDim2.new(0, 52, 0, 46)
tgtRarityLbl.BackgroundTransparency = 1
tgtRarityLbl.Font = Enum.Font.GothamBold
tgtRarityLbl.TextSize = 9
tgtRarityLbl.TextColor3 = Color3.fromRGB(147, 197, 253)
tgtRarityLbl.Text = "Шанс рассчитается сам"
tgtRarityLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtRarityLbl.Parent = targetPreviewFrame

-- Target Catalog Scroll
local tgtScroll = Instance.new("ScrollingFrame")
tgtScroll.Size = UDim2.new(1, 0, 1, -100)
tgtScroll.Position = UDim2.new(0, 0, 0, 96)
tgtScroll.BackgroundTransparency = 1
tgtScroll.ScrollBarThickness = 4
tgtScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tgtScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tgtScroll.Parent = upgColRight

local tgtLayout = Instance.new("UIGridLayout")
tgtLayout.CellSize = UDim2.new(0, 68, 0, 80)
tgtLayout.CellPadding = UDim2.new(0, 6, 0, 6)
tgtLayout.Parent = tgtScroll

local function updateWheelDisplay()
	upgraderChance = math.clamp(math.floor(upgraderChance * 10) / 10, 1.0, 85.0)
	customBox.Text = string.format("%.1f", upgraderChance)
	chanceDisplay.Text = string.format("%.1f%%", upgraderChance)
	local mult = 100.0 / upgraderChance
	multDisplay.Text = string.format("%.2fx МНОЖИТЕЛЬ", mult)
	local winAngle = (upgraderChance / 100.0) * 360.0
	sectorDisplay.Text = string.format("ЗОНА ПОБЕДЫ: 0 - %d град.", math.floor(winAngle))

	-- Visually paint each sector bar on the wheel: GREEN for win zone, RED for loss zone!
	for _, item in ipairs(sectorBars) do
		if item.Angle < winAngle then
			item.Bar.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Vibrant Green WIN ZONE!
			item.Bar.BackgroundTransparency = 0.05
		else
			item.Bar.BackgroundColor3 = Color3.fromRGB(220, 38, 38) -- Crimson Red LOSE ZONE!
			item.Bar.BackgroundTransparency = 0.65
		end
	end
end

local function addUpgPreset(name, chanceVal)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 9
	btn.TextColor3 = Color3.fromRGB(147, 197, 253)
	btn.Text = name
	addCorner(btn, 5)
	btn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		upgraderChance = chanceVal
		updateWheelDisplay()
	end)
	btn.Parent = presetRow
end

addUpgPreset("75%", 75.0)
addUpgPreset("50%", 50.0)
addUpgPreset("30%", 30.0)
addUpgPreset("2x", 48.0)
addUpgPreset("5x", 19.0)
addUpgPreset("10x", 9.0)

minusBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	upgraderChance = math.max(1.0, upgraderChance - 5.0)
	updateWheelDisplay()
end)

plusBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	upgraderChance = math.min(85.0, upgraderChance + 5.0)
	updateWheelDisplay()
end)

customBox.FocusLost:Connect(function()
	local num = tonumber(customBox.Text)
	if num then
		upgraderChance = num
		updateWheelDisplay()
	else
		customBox.Text = string.format("%.1f", upgraderChance)
	end
end)

local function refreshUpgraderUI()
	for _, ch in ipairs(srcScroll:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIGridLayout") then ch:Destroy() end
	end
	for _, ch in ipairs(tgtScroll:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIGridLayout") then ch:Destroy() end
	end

	local hasAny = false
	for auraId, count in pairs(localData.Inventory or {}) do
		if count > 0 then
			local aura = AuraConfig.Auras[auraId]
			if aura then
				hasAny = true
				local card = Instance.new("TextButton")
				card.Size = UDim2.new(0, 68, 0, 80)
				card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
				card.Text = ""
				addCorner(card, 6)
				addStroke(card, aura.Color, 1.2)

				-- Procedural Guaranteed Aura Emblem
				createAuraEmblem(card, aura, 30, UDim2.new(0.5, -15, 0, 4))

				local sym = Instance.new("TextLabel")
				sym.Size = UDim2.new(0, 22, 0, 12)
				sym.Position = UDim2.new(1, -24, 0, 2)
				sym.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
				sym.Font = Enum.Font.GothamBlack
				sym.TextSize = 7
				sym.TextColor3 = aura.Color
				sym.Text = aura.Symbol or "AUR"
				addCorner(sym, 3)
				sym.Parent = card

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(1, -4, 0, 16)
				name.Position = UDim2.new(0, 2, 0, 38)
				name.BackgroundTransparency = 1
				name.Font = Enum.Font.GothamBold
				name.TextSize = 8
				name.TextColor3 = aura.Color
				name.Text = aura.Name
				name.TextWrapped = true
				name.Parent = card

				local cnt = Instance.new("TextLabel")
				cnt.Size = UDim2.new(0, 22, 0, 12)
				cnt.Position = UDim2.new(1, -24, 1, -14)
				cnt.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
				cnt.Font = Enum.Font.GothamBold
				cnt.TextSize = 7
				cnt.TextColor3 = Color3.fromRGB(220, 225, 240)
				cnt.Text = "x" .. tostring(count)
				addCorner(cnt, 3)
				cnt.Parent = card

				card.MouseButton1Click:Connect(function()
					SoundEffects.Play("Click")
					selectedSourceAuraId = auraId
					srcEmblemHolder:ClearAllChildren()
					createAuraEmblem(srcEmblemHolder, aura, 38, UDim2.new(0, 2, 0, 2))
					srcNameLbl.Text = aura.Name
					srcNameLbl.TextColor3 = aura.Color
					srcSubLbl.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
					local scrap = AuraConfig.GetScrapValue(aura.Rarity) * 2
					srcScrapLbl.Text = string.format("Возврат: +%d монет", scrap)
					srcStroke.Color = aura.Color

					if selectedTargetAuraId then
						local tgtAura = AuraConfig.Auras[selectedTargetAuraId]
						if tgtAura then
							local sR = math.max(aura.Rarity or 2, 2)
							local tR = math.max(tgtAura.Rarity or 10, 4)
							if sR >= tR then
								upgraderChance = 85.0
							else
								upgraderChance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
							end
							updateWheelDisplay()
						end
					end
				end)

				card.Parent = srcScroll
			end
		end
	end

	if not hasAny then
		srcNameLbl.Text = "Инвентарь пуст"
		srcSubLbl.Text = "Крутите роллы!"
	end

	for _, aura in ipairs(AuraConfig.RollableAuras) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(0, 68, 0, 80)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
		card.Text = ""
		addCorner(card, 6)
		addStroke(card, aura.Color, 1.2)

		createAuraEmblem(card, aura, 30, UDim2.new(0.5, -15, 0, 4))

		local sym = Instance.new("TextLabel")
		sym.Size = UDim2.new(0, 22, 0, 12)
		sym.Position = UDim2.new(1, -24, 0, 2)
		sym.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
		sym.Font = Enum.Font.GothamBlack
		sym.TextSize = 7
		sym.TextColor3 = aura.Color
		sym.Text = aura.Symbol or "AUR"
		addCorner(sym, 3)
		sym.Parent = card

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -4, 0, 16)
		name.Position = UDim2.new(0, 2, 0, 38)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 8
		name.TextColor3 = aura.Color
		name.Text = aura.Name
		name.TextWrapped = true
		name.Parent = card

		local rar = Instance.new("TextLabel")
		rar.Size = UDim2.new(1, -4, 0, 12)
		rar.Position = UDim2.new(0, 2, 0, 56)
		rar.BackgroundTransparency = 1
		rar.Font = Enum.Font.GothamMedium
		rar.TextSize = 7
		rar.TextColor3 = Color3.fromRGB(156, 163, 175)
		rar.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
		rar.Parent = card

		card.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedTargetAuraId = aura.Id
			tgtEmblemHolder:ClearAllChildren()
			createAuraEmblem(tgtEmblemHolder, aura, 38, UDim2.new(0, 2, 0, 2))
			tgtNameLbl.Text = aura.Name
			tgtNameLbl.TextColor3 = aura.Color
			tgtSubLbl.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
			tgtRarityLbl.Text = aura.Tier:upper()
			tgtStroke.Color = aura.Color

			if selectedSourceAuraId then
				local srcAura = AuraConfig.Auras[selectedSourceAuraId]
				if srcAura then
					local sR = math.max(srcAura.Rarity or 2, 2)
					local tR = math.max(aura.Rarity or 10, 4)
					if sR >= tR then
						upgraderChance = 85.0
					else
						upgraderChance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
					end
					updateWheelDisplay()
				end
			end
		end)

		card.Parent = tgtScroll
	end

	updateWheelDisplay()
end

doUpgradeBtn.MouseButton1Click:Connect(function()
	if isWheelSpinning then return end

	local sourceId = selectedSourceAuraId or localData.EquippedAura
	if not sourceId or sourceId == "None" or not localData.Inventory[sourceId] or localData.Inventory[sourceId] <= 0 then
		upgResultMsg.Text = "Выберите ауру слева из инвентаря для ставки!"
		upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
		return
	end

	isWheelSpinning = true
	doUpgradeBtn.Text = "ВРАЩЕНИЕ КОЛЕСА..."
	doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
	SoundEffects.Play("Spin")

	local res = UpgradeAuraFunc:InvokeServer(sourceId, selectedTargetAuraId, upgraderChance, "Custom", upgraderChance)

	if res and res.Success then
		local startRot = needleContainer.Rotation % 360
		local targetAngle = (res.Roll / 100.0) * 360
		local spins = isUpgraderFast and 1 or 5
		local endRot = startRot + (spins * 360) + targetAngle
		local duration = isUpgraderFast and 0.6 or 3.2

		TweenService:Create(needleContainer, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Rotation = endRot
		}):Play()

		task.spawn(function()
			local tickInterval = isUpgraderFast and 0.05 or 0.08
			local steps = math.floor(duration / tickInterval)
			for _ = 1, steps do
				task.wait(tickInterval)
				SoundEffects.Play("Tick")
			end
		end)

		task.wait(duration)

		if res.Won then
			SoundEffects.Play("RevealMythic")
			hubStroke.Color = Color3.fromRGB(16, 185, 129)
			upgResultMsg.Text = string.format("ПОБЕДА! Вы получили: %s (+%d монет)!", res.TargetAura.Name:upper(), res.Jackpot or 1500)
			upgResultMsg.TextColor3 = Color3.fromRGB(74, 222, 128)
		else
			SoundEffects.Play("Coin")
			hubStroke.Color = Color3.fromRGB(239, 68, 68)
			upgResultMsg.Text = string.format("НЕУДАЧА! Аура сгорела (компенсация: +%d монет).", res.Scrap or 100)
			upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
		end

		selectedSourceAuraId = nil
		refreshUpgraderUI()
		refreshInventoryUI()
	else
		upgResultMsg.Text = (res and res.Message) or "Ошибка апгрейда!"
		upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
	end

	isWheelSpinning = false
	doUpgradeBtn.Text = "АПГРЕЙДИТЬ АУРУ"
	doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
end)

--------------------------------------------------------------------------------
-- 10. PVP DUEL ARENA WINDOW & COMBAT HUD
--------------------------------------------------------------------------------

local pvpWindow, pvpContent = createModal("АРЕНА БАТЛОВ АУР", 620, 440)

local pvpPlayerList = Instance.new("ScrollingFrame")
pvpPlayerList.Size = UDim2.new(1, 0, 1, 0)
pvpPlayerList.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
pvpPlayerList.BackgroundTransparency = 0.4
pvpPlayerList.ScrollBarThickness = 5
addCorner(pvpPlayerList, 8)
pvpPlayerList.Parent = pvpContent

local pvpListLayout = Instance.new("UIListLayout")
pvpListLayout.Padding = UDim.new(0, 8)
pvpListLayout.Parent = pvpPlayerList
addPadding(pvpPlayerList, 8, 8, 8, 8)

local function refreshPvPWindow()
	for _, child in ipairs(pvpPlayerList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 54)
			row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			addCorner(row, 8)
			addStroke(row, Color3.fromRGB(45, 52, 70), 1)

			local pName = Instance.new("TextLabel")
			pName.Size = UDim2.new(0.6, 0, 1, 0)
			pName.Position = UDim2.new(0, 14, 0, 0)
			pName.BackgroundTransparency = 1
			pName.Font = Enum.Font.GothamBlack
			pName.TextSize = 14
			pName.TextColor3 = Color3.fromRGB(240, 243, 250)
			pName.TextXAlignment = Enum.TextXAlignment.Left
			pName.Text = p.DisplayName or p.Name
			pName.Parent = row

			local challengeBtn = Instance.new("TextButton")
			challengeBtn.Size = UDim2.new(0, 160, 0, 36)
			challengeBtn.Position = UDim2.new(1, -170, 0.5, -18)
			challengeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
			challengeBtn.Font = Enum.Font.GothamBlack
			challengeBtn.TextSize = 12
			challengeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			challengeBtn.Text = "ВЫЗВАТЬ НА БОЙ"
			addCorner(challengeBtn, 8)
			challengeBtn.Parent = row

			challengeBtn.MouseButton1Click:Connect(function()
				SoundEffects.Play("Click")
				PvPChallengeFunc:InvokeServer(p.Name)
				challengeBtn.Text = "ВЫЗОВ ОТПРАВЛЕН!"
				challengeBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 100)
			end)

			row.Parent = pvpPlayerList
		end
	end

	pvpPlayerList.CanvasSize = UDim2.new(0, 0, 0, pvpListLayout.AbsoluteContentSize.Y + 20)
end

-- Active Battle Combat HUD (Health bars & 3 Skill Buttons)
local battleHud = Instance.new("Frame")
battleHud.Name = "PvPBattleHUD"
battleHud.Size = UDim2.new(1, 0, 1, 0)
battleHud.BackgroundTransparency = 1
battleHud.Visible = false
battleHud.Parent = screenGui

-- Top Battle Health Bars
local hpContainer = Instance.new("Frame")
hpContainer.AnchorPoint = Vector2.new(0.5, 0)
hpContainer.Position = UDim2.new(0.5, 0, 0, 68)
hpContainer.Size = UDim2.new(0, 520, 0, 48)
hpContainer.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
hpContainer.BackgroundTransparency = 0.2
addCorner(hpContainer, 12)
addStroke(hpContainer, Color3.fromRGB(239, 68, 68), 1.5)
addPadding(hpContainer, 6, 6, 12, 12)
hpContainer.Parent = battleHud

local myHpBar = Instance.new("Frame")
myHpBar.Size = UDim2.new(0.48, 0, 0, 18)
myHpBar.Position = UDim2.new(0, 0, 0, 18)
myHpBar.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
addCorner(myHpBar, 6)
myHpBar.Parent = hpContainer

local myHpFill = Instance.new("Frame")
myHpFill.Size = UDim2.new(1, 0, 1, 0)
myHpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
addCorner(myHpFill, 6)
myHpFill.Parent = myHpBar

local myHpLabel = Instance.new("TextLabel")
myHpLabel.Size = UDim2.new(0.48, 0, 0, 16)
myHpLabel.Position = UDim2.new(0, 0, 0, 0)
myHpLabel.BackgroundTransparency = 1
myHpLabel.Font = Enum.Font.GothamBlack
myHpLabel.TextSize = 11
myHpLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
myHpLabel.TextXAlignment = Enum.TextXAlignment.Left
myHpLabel.Text = "ВЫ: 1000 / 1000 HP"
myHpLabel.Parent = hpContainer

local opHpBar = Instance.new("Frame")
opHpBar.Size = UDim2.new(0.48, 0, 0, 18)
opHpBar.Position = UDim2.new(0.52, 0, 0, 18)
opHpBar.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
addCorner(opHpBar, 6)
opHpBar.Parent = hpContainer

local opHpFill = Instance.new("Frame")
opHpFill.Size = UDim2.new(1, 0, 1, 0)
opHpFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
addCorner(opHpFill, 6)
opHpFill.Parent = opHpBar

local opHpLabel = Instance.new("TextLabel")
opHpLabel.Size = UDim2.new(0.48, 0, 0, 16)
opHpLabel.Position = UDim2.new(0.52, 0, 0, 0)
opHpLabel.BackgroundTransparency = 1
opHpLabel.Font = Enum.Font.GothamBlack
opHpLabel.TextSize = 11
opHpLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
opHpLabel.TextXAlignment = Enum.TextXAlignment.Right
opHpLabel.Text = "ВРАГ: 1000 / 1000 HP"
opHpLabel.Parent = hpContainer

-- Bottom 3 Combat Skills Bar
local skillsBar = Instance.new("Frame")
skillsBar.AnchorPoint = Vector2.new(0.5, 1)
skillsBar.Position = UDim2.new(0.5, 0, 1, -125)
skillsBar.Size = UDim2.new(0, 480, 0, 52)
skillsBar.BackgroundTransparency = 1
skillsBar.Parent = battleHud

local skillLayout = Instance.new("UIListLayout")
skillLayout.FillDirection = Enum.FillDirection.Horizontal
skillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skillLayout.Padding = UDim.new(0, 12)
skillLayout.Parent = skillsBar

local function createSkillButton(index, iconAsset, name, cdTime, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 145, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	btn.Text = ""
	addCorner(btn, 10)
	local strk = addStroke(btn, color, 1.5)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 22, 0, 22)
	iconImg.Position = UDim2.new(0, 8, 0.5, -11)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -36, 1, 0)
	lbl.Position = UDim2.new(0, 34, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 11
	lbl.TextColor3 = color
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local now = os.clock()
		if (now - (skillCooldowns[index] or 0)) >= cdTime then
			skillCooldowns[index] = now
			SoundEffects.Play("Click")
			PvPUseSkillFunc:InvokeServer(index)

			btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
			task.delay(cdTime, function()
				btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			end)
		end
	end)

	btn.Parent = skillsBar
	return btn
end

createSkillButton(1, "rbxasset://textures/ui/InspectMenu/ico_equipped.png", "[1] УДАР АУРЫ", 1.2, Color3.fromRGB(56, 189, 248))
createSkillButton(2, "rbxasset://textures/particles/fire_main.dds", "[2] ВЗРЫВ СТИХИИ", 3.5, Color3.fromRGB(245, 158, 11))
createSkillButton(3, "rbxasset://textures/particles/sparkles_main.dds", "[3] УЛЬТИМЕЙТ", 7.0, Color3.fromRGB(250, 204, 21))

-- Incoming Duel Challenge Popup
local challengePopup = Instance.new("Frame")
challengePopup.AnchorPoint = Vector2.new(0.5, 0)
challengePopup.Position = UDim2.new(0.5, 0, 0, 70)
challengePopup.Size = UDim2.new(0, 380, 0, 90)
challengePopup.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
challengePopup.Visible = false
addCorner(challengePopup, 12)
addStroke(challengePopup, Color3.fromRGB(239, 68, 68), 2)
addPadding(challengePopup, 8, 8, 12, 12)
challengePopup.Parent = screenGui

local chText = Instance.new("TextLabel")
chText.Size = UDim2.new(1, 0, 0, 24)
chText.BackgroundTransparency = 1
chText.Font = Enum.Font.GothamBlack
chText.TextSize = 13
chText.TextColor3 = Color3.fromRGB(255, 235, 120)
chText.Text = "Игрок вызывает вас на Дуэль Аур!"
chText.Parent = challengePopup

local currentChallengerName = ""

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0.48, 0, 0, 36)
acceptBtn.Position = UDim2.new(0, 0, 1, -36)
acceptBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
acceptBtn.Font = Enum.Font.GothamBlack
acceptBtn.TextSize = 12
acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptBtn.Text = "ПРИНЯТЬ"
addCorner(acceptBtn, 8)
acceptBtn.Parent = challengePopup

local declineBtn = Instance.new("TextButton")
declineBtn.Size = UDim2.new(0.48, 0, 0, 36)
declineBtn.Position = UDim2.new(0.52, 0, 1, -36)
declineBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
declineBtn.Font = Enum.Font.GothamBlack
declineBtn.TextSize = 12
declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
declineBtn.Text = "[X] ОТКЛОНИТЬ"
addCorner(declineBtn, 8)
declineBtn.Parent = challengePopup

PvPResponseEvent.OnClientEvent:Connect(function(info)
	currentChallengerName = info.Challenger
	chText.Text = string.format("%s вызывает вас на Дуэль!", info.ChallengerDisplay or info.Challenger)
	challengePopup.Visible = true
	SoundEffects.Play("RevealRare")
end)

acceptBtn.MouseButton1Click:Connect(function()
	challengePopup.Visible = false
	PvPResponseEvent:FireServer(currentChallengerName, true)
end)

declineBtn.MouseButton1Click:Connect(function()
	challengePopup.Visible = false
	PvPResponseEvent:FireServer(currentChallengerName, false)
end)

PvPStateEvent.OnClientEvent:Connect(function(state)
	if state.InBattle then
		battleHud.Visible = true
		myHpLabel.Text = string.format("ВЫ: %d / %d HP", state.MyHp, state.MyMaxHp)
		opHpLabel.Text = string.format("ВРАГ: %d / %d HP", state.OpHp, state.OpMaxHp)
		myHpFill.Size = UDim2.new(math.clamp(state.MyHp / state.MyMaxHp, 0, 1), 0, 1, 0)
		opHpFill.Size = UDim2.new(math.clamp(state.OpHp / state.OpMaxHp, 0, 1), 0, 1, 0)
	else
		battleHud.Visible = false
		if state.Won then
			SoundEffects.Play("RevealGodly")
		else
			SoundEffects.Play("Click")
		end
	end
end)

PvPVFXEvent.OnClientEvent:Connect(function(info)
	local caster = Players:FindFirstChild(info.Caster)
	local target = Players:FindFirstChild(info.Target)
	local cChar = caster and caster.Character
	local tChar = target and target.Character

	if info.SkillIndex == 1 then
		AuraVisuals.PlaySkill1VFX(cChar, tChar, info.Color)
		SoundEffects.Play("Click")
	elseif info.SkillIndex == 2 then
		AuraVisuals.PlaySkill2VFX(tChar, info.Color)
		SoundEffects.Play("RevealRare")
	elseif info.SkillIndex == 3 then
		AuraVisuals.PlaySkill3VFX(tChar, info.Color)
		SoundEffects.Play("RevealGodly")
	end

	if tChar then
		AuraVisuals.ShowDamageNumber(tChar, info.Damage, info.IsCrit, info.Color)
	end
end)

--------------------------------------------------------------------------------
-- 11. CRAFTING ALCHEMIST FORGE
--------------------------------------------------------------------------------

local craftWindow, craftContent = createModal("КУЗНИЦА КРАФТА АУР", 720, 500)

local recipeScroll = Instance.new("ScrollingFrame")
recipeScroll.Size = UDim2.new(0, 240, 1, 0)
recipeScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
recipeScroll.BackgroundTransparency = 0.4
recipeScroll.ScrollBarThickness = 4
addCorner(recipeScroll, 8)
recipeScroll.Parent = craftContent

local recLayout = Instance.new("UIListLayout")
recLayout.Padding = UDim.new(0, 8)
recLayout.Parent = recipeScroll
addPadding(recipeScroll, 6, 6, 6, 6)

local craftDetail = Instance.new("Frame")
craftDetail.Size = UDim2.new(1, -255, 1, 0)
craftDetail.Position = UDim2.new(0, 255, 0, 0)
craftDetail.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(craftDetail, 8)
addStroke(craftDetail, Color3.fromRGB(42, 50, 70), 1)
addPadding(craftDetail, 12, 12, 12, 12)
craftDetail.Parent = craftContent

local craftTitle = Instance.new("TextLabel")
craftTitle.Size = UDim2.new(1, 0, 0, 28)
craftTitle.BackgroundTransparency = 1
craftTitle.Font = Enum.Font.GothamBlack
craftTitle.TextSize = 18
craftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
craftTitle.Text = "Выберите Рецепт"
craftTitle.Parent = craftDetail

local craftDesc = Instance.new("TextLabel")
craftDesc.Size = UDim2.new(1, 0, 0, 44)
craftDesc.Position = UDim2.new(0, 0, 0, 32)
craftDesc.BackgroundTransparency = 1
craftDesc.Font = Enum.Font.Gotham
craftDesc.TextSize = 12
craftDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
craftDesc.TextWrapped = true
craftDesc.Text = "Объединяйте ауры для создания богоподобных аур, рукавиц удачи и зелий!"
craftDesc.Parent = craftDetail

local ingHeader = Instance.new("TextLabel")
ingHeader.Size = UDim2.new(1, 0, 0, 20)
ingHeader.Position = UDim2.new(0, 0, 0, 82)
ingHeader.BackgroundTransparency = 1
ingHeader.Font = Enum.Font.GothamBold
ingHeader.TextSize = 12
ingHeader.TextColor3 = Color3.fromRGB(156, 163, 175)
ingHeader.Text = "ТРЕБУЕМЫЕ ИНГРЕДИЕНТЫ:"
ingHeader.TextXAlignment = Enum.TextXAlignment.Left
ingHeader.Parent = craftDetail

local ingListFrame = Instance.new("Frame")
ingListFrame.Size = UDim2.new(1, 0, 0, 180)
ingListFrame.Position = UDim2.new(0, 0, 0, 106)
ingListFrame.BackgroundTransparency = 1
ingListFrame.Parent = craftDetail

local ingLayout = Instance.new("UIListLayout")
ingLayout.Padding = UDim.new(0, 6)
ingLayout.Parent = ingListFrame

local forgeBtn = Instance.new("TextButton")
forgeBtn.Size = UDim2.new(1, 0, 0, 46)
forgeBtn.Position = UDim2.new(0, 0, 1, -48)
forgeBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
forgeBtn.Font = Enum.Font.GothamBlack
forgeBtn.TextSize = 16
forgeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
forgeBtn.Text = "КОВАТЬ РЕЦЕПТ"
forgeBtn.Visible = false
addCorner(forgeBtn, 10)
forgeBtn.Parent = craftDetail

local function refreshCraftingUI()
	for _, child in ipairs(recipeScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, recipe in ipairs(AuraConfig.Recipes) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 54)
		btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		btn.Text = ""
		addCorner(btn, 8)
		addStroke(btn, recipe.Color, 1.2)

		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, -12, 0, 22)
		t.Position = UDim2.new(0, 8, 0, 6)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBold
		t.TextSize = 13
		t.TextColor3 = recipe.Color
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Text = recipe.Name
		t.Parent = btn

		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -12, 0, 16)
		sub.Position = UDim2.new(0, 8, 0, 28)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 11
		sub.TextColor3 = Color3.fromRGB(156, 163, 175)
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = string.format("Тип: %s", recipe.ResultType)
		sub.Parent = btn

		btn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedCraftRecipe = recipe
			craftTitle.Text = recipe.Name
			craftTitle.TextColor3 = recipe.Color
			craftDesc.Text = recipe.Description

			for _, c in ipairs(ingListFrame:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() end
			end

			local canCraftAll = true
			for _, ing in ipairs(recipe.Ingredients) do
				local owned = localData.Inventory[ing.AuraId] or 0
				local auraData = AuraConfig.Auras[ing.AuraId]
				local auraName = auraData and auraData.Name or ing.AuraId
				local auraColor = auraData and auraData.Color or Color3.fromRGB(220, 225, 240)

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 34)
				row.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
				addCorner(row, 6)
				row.Parent = ingListFrame

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 10, 0, 0)
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
					countLbl.Text = string.format(" %d / %d", owned, ing.Count)
				else
					countLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
					countLbl.Text = string.format("[X] %d / %d", owned, ing.Count)
					canCraftAll = false
				end
				countLbl.Parent = row
			end

			forgeBtn.Visible = true
			if canCraftAll then
				forgeBtn.Text = " КОВАТЬ СЕЙЧАС"
				forgeBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			else
				forgeBtn.Text = "Не хватает аур"
				forgeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
			end
		end)

		btn.Parent = recipeScroll
	end

	recipeScroll.CanvasSize = UDim2.new(0, 0, 0, recLayout.AbsoluteContentSize.Y + 20)
end

forgeBtn.MouseButton1Click:Connect(function()
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
-- 12. MULTI-CATEGORY DONATION SHOP
--------------------------------------------------------------------------------

local shopWindow, shopContent = createModal(" МАГАЗИН ДОНАТА И ПАССОВ (АКЦИИ -80%)", 740, 520)

toggleShopModal = function()
	toggleModal(shopWindow)
	refreshShopUI()
end

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, 0)
shopScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
shopScroll.BackgroundTransparency = 0.4
shopScroll.ScrollBarThickness = 5
shopScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
addCorner(shopScroll, 8)
shopScroll.Parent = shopContent

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.Parent = shopScroll
addPadding(shopScroll, 8, 8, 8, 8)

local donateCatalog = {
	{
		Category = "ГЕЙМПАССЫ НАВСЕГДА",
		Items = {
			{
				Id = "X2Luck",
				Badge = " ХИТ",
				Name = " x2 Luck Pass (Навсегда)",
				Color = Color3.fromRGB(74, 222, 128),
				Desc = "Удваивает шанс выпадения всех редких, мифических и богоподобных аур навсегда!",
				Price = "R$ 199",
				Type = "Perk",
				PerkKey = "X2Luck",
			},
			{
				Id = "X3Luck",
				Badge = " СВЕРХУДАЧА",
				Name = " x3 Luck Overload (Навсегда)",
				Color = Color3.fromRGB(16, 185, 129),
				Desc = "Тройной шанс на все ауры! Стакается со всеми другими бонусами!",
				Price = "R$ 499",
				Type = "Perk",
				PerkKey = "X3Luck",
			},
			{
				Id = "AutoRoll",
				Badge = " АВТО-РОЛЛ",
				Name = " Auto Roll Pass (Навсегда)",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Автоматический ролл в фоне пока вы общаетесь, гуляете или стоите AFK!",
				Price = "R$ 99",
				Type = "Perk",
				PerkKey = "AutoRoll",
			},
			{
				Id = "ExtraStorage",
				Badge = " +50 СЛОТОВ",
				Name = " Aura Storage (+50)",
				Color = Color3.fromRGB(56, 189, 248),
				Desc = "Расширяет ваш инвентарь на +50 дополнительных слотов для редких аур!",
				Price = "R$ 149",
				Type = "Perk",
				PerkKey = "ExtraStorage",
			},
			{
				Id = "VIP",
				Badge = " VIP КЛУБ",
				Name = " VIP Supporter Pass",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Аура VIP Crown + x1.5 Удача + Золотой титул VIP над головой и в чате!",
				Price = "R$ 299",
				Type = "Perk",
				PerkKey = "VIP",
			},
			{
				Id = "FastRoll",
				Badge = " БЫСТРЫЙ РОЛЛ",
				Name = " Fast Roll Instant Pass",
				Color = Color3.fromRGB(236, 72, 153),
				Desc = "Моментальное раскрытие роллов без ожидания рулетки!",
				Price = "R$ 79",
				Type = "Perk",
				PerkKey = "FastRoll",
			},
		}
	},
	{
		Category = "МЕГА-БУСТЫ И ЗЕЛЬЯ",
		Items = {
			{
				Id = "MegaPotion",
				Badge = " 5x LUCK",
				Name = " Мега-Зелье Удачи x5 (15 мин)",
				Color = Color3.fromRGB(6, 182, 212),
				Desc = "Дает бешеное пятикратное (5x) увеличение шансов на 15 минут!",
				Price = "R$ 129",
				Type = "Product",
				ProductKey = "MegaPotion",
			},
		}
	},
	{
		Category = "ПАКЕТЫ МОНЕТ",
		Items = {
			{
				Id = "Coins10k",
				Badge = " 10K",
				Name = " 10,000 Монет",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Стартовый запас монет для крафта и улучшений.",
				Price = "R$ 49",
				Type = "Product",
				ProductKey = "CoinPack10k",
			},
			{
				Id = "Coins50k",
				Badge = " ХИТ",
				Name = " 50,000 Монет",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Большой мешок золота для покупки слотов и расходников!",
				Price = "R$ 149",
				Type = "Product",
				ProductKey = "CoinPack50k",
			},
			{
				Id = "Coins250k",
				Badge = " БОГАТСТВО",
				Name = " 250,000 Монет",
				Color = Color3.fromRGB(251, 191, 36),
				Desc = "Сундук с золотом - никогда больше не беспокойтесь о монетах!",
				Price = "R$ 399",
				Type = "Product",
				ProductKey = "CoinPack250k",
			},
		}
	},
	{
		Category = "МГНОВЕННЫЙ ВЫБИВ АУР",
		Items = {
			{
				Id = "InstantLegendary",
				Badge = " 1/1,000+",
				Name = " Гарантированная Легендарная Аура",
				Color = Color3.fromRGB(239, 68, 68),
				Desc = "Мгновенно начисляет случайную Легендарную ауру (Ruby, Undead, Solar)!",
				Price = "R$ 199",
				Type = "Product",
				ProductKey = "InstantLegendary",
			},
			{
				Id = "InstantMythic",
				Badge = " 1/10,000+",
				Name = " Гарантированная Мифическая Аура",
				Color = Color3.fromRGB(168, 85, 247),
				Desc = "Мгновенно начисляет случайную Мифическую ауру (Lunar, Poseidon, Hades, Galaxy)!",
				Price = "R$ 499",
				Type = "Product",
				ProductKey = "InstantMythic",
			},
		}
	},
}

local function refreshShopUI()
	for _, child in ipairs(shopScroll:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
	end

	for _, cat in ipairs(donateCatalog) do
		local catHeader = Instance.new("TextLabel")
		catHeader.Size = UDim2.new(1, 0, 0, 24)
		catHeader.BackgroundTransparency = 1
		catHeader.Font = Enum.Font.GothamBlack
		catHeader.TextSize = 13
		catHeader.TextColor3 = Color3.fromRGB(250, 204, 21)
		catHeader.TextXAlignment = Enum.TextXAlignment.Left
		catHeader.Text = " " .. cat.Category
		catHeader.Parent = shopScroll

		for _, item in ipairs(cat.Items) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 84)
			row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			addCorner(row, 8)
			addStroke(row, item.Color, 1.2)
			addPadding(row, 8, 8, 12, 12)

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(0.65, 0, 0, 22)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Font = Enum.Font.GothamBlack
			nameLbl.TextSize = 15
			nameLbl.TextColor3 = item.Color
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.Text = string.format("%s [%s]", item.Name, item.Badge)
			nameLbl.Parent = row

			local descLbl = Instance.new("TextLabel")
			descLbl.Size = UDim2.new(0.65, 0, 0, 38)
			descLbl.Position = UDim2.new(0, 0, 0, 24)
			descLbl.BackgroundTransparency = 1
			descLbl.Font = Enum.Font.Gotham
			descLbl.TextSize = 12
			descLbl.TextColor3 = Color3.fromRGB(180, 185, 200)
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.TextWrapped = true
			descLbl.Text = item.Desc
			descLbl.Parent = row

			local testBtn = Instance.new("TextButton")
			testBtn.Size = UDim2.new(0, 180, 0, 42)
			testBtn.Position = UDim2.new(1, -180, 0.5, -21)
			testBtn.Font = Enum.Font.GothamBold
			testBtn.TextSize = 11
			addCorner(testBtn, 8)

			if item.Type == "Perk" then
				local isOwned = (localData.Gamepasses and localData.Gamepasses[item.PerkKey])
					or (localData.TestPerks and localData.TestPerks[item.PerkKey])

				if isOwned then
					testBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
					testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					testBtn.Text = "АКТИВЕН (ТЕСТ ВКЛ)"
				else
					testBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
					testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					testBtn.Text = string.format("КУПИТЬ %s (ТЕСТ)", item.Price)
				end

				testBtn.MouseButton1Click:Connect(function()
					SoundEffects.Play("Click")
					testBtn.Text = "ОБНОВЛЕНИЕ..."
					ToggleTestPerkEvent:FireServer(item.PerkKey)
					task.delay(0.2, function()
						if shopWindow.Visible then refreshShopUI() end
					end)
				end)
			else
				testBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
				testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				testBtn.Text = string.format("КУПИТЬ %s (ТЕСТ)", item.Price)

				testBtn.MouseButton1Click:Connect(function()
					SoundEffects.Play("Coin")
					testBtn.Text = "ПОКУПКА..."
					local res = PurchaseProductFunc:InvokeServer(item.ProductKey)
					if res and res.Success then
						SoundEffects.Play("RevealMythic")
					end
					task.delay(0.2, function()
						if shopWindow.Visible then refreshShopUI() end
					end)
				end)
			end

			testBtn.Parent = row
			row.Parent = shopScroll
		end
	end

	shopScroll.CanvasSize = UDim2.new(0, 0, 0, shopLayout.AbsoluteContentSize.Y + 24)
end

--------------------------------------------------------------------------------
-- 13. SETTINGS WINDOW
--------------------------------------------------------------------------------

local setWindow, setContent = createModal(" НАСТРОЙКИ", 460, 260)

local setFastBtn = Instance.new("TextButton")
setFastBtn.Size = UDim2.new(1, 0, 0, 44)
setFastBtn.Position = UDim2.new(0, 0, 0, 10)
setFastBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setFastBtn.Font = Enum.Font.GothamBold
setFastBtn.TextSize = 14
setFastBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
addCorner(setFastBtn, 8)
addStroke(setFastBtn, Color3.fromRGB(45, 55, 75), 1)
setFastBtn.Parent = setContent

local setSoundBtn = Instance.new("TextButton")
setSoundBtn.Size = UDim2.new(1, 0, 0, 44)
setSoundBtn.Position = UDim2.new(0, 0, 0, 64)
setSoundBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setSoundBtn.Font = Enum.Font.GothamBold
setSoundBtn.TextSize = 14
setSoundBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
setSoundBtn.Text = " Звуки Игры: ВКЛ (Мягкие)"
addCorner(setSoundBtn, 8)
addStroke(setSoundBtn, Color3.fromRGB(45, 55, 75), 1)
setSoundBtn.Parent = setContent

local setInfo = Instance.new("TextLabel")
setInfo.Size = UDim2.new(1, 0, 0, 44)
setInfo.Position = UDim2.new(0, 0, 0, 120)
setInfo.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
setInfo.Font = Enum.Font.GothamMedium
setInfo.TextSize = 13
setInfo.TextColor3 = Color3.fromRGB(180, 185, 200)
setInfo.Text = "Авто-продажу и экипировку можно настроить в Инвентаре."
addCorner(setInfo, 8)
setInfo.Parent = setContent

setFastBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВКЛ"
		fastRollBtn.Text = " FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
		fastRollBtn.Text = " FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
	end
end)

setSoundBtn.MouseButton1Click:Connect(function()
	local isMuted = SoundEffects.ToggleMute()
	if isMuted then
		setSoundBtn.Text = " Звуки Игры: ВЫКЛЮЧЕНЫ"
		setSoundBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
	else
		setSoundBtn.Text = " Звуки Игры: ВКЛ (Мягкие)"
		setSoundBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		SoundEffects.Play("Click")
	end
end)

--------------------------------------------------------------------------------
-- 14. CS2-STYLE DYNAMIC HORIZONTAL CASE OPENING ROULETTE (WITH ITEM ICONS)
--------------------------------------------------------------------------------

local rouletteContainer = Instance.new("Frame")
rouletteContainer.Name = "CS2RouletteContainer"
rouletteContainer.AnchorPoint = Vector2.new(0.5, 0.5)
rouletteContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
rouletteContainer.Size = UDim2.new(0.9, 0, 0, 170)
rouletteContainer.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
rouletteContainer.BackgroundTransparency = 0.05
rouletteContainer.ClipsDescendants = true
rouletteContainer.Visible = false
addCorner(rouletteContainer, 16)
local rStroke = addStroke(rouletteContainer, Color3.fromRGB(245, 158, 11), 2.5)
rouletteContainer.Parent = screenGui

local rSizeConstraint = Instance.new("UISizeConstraint")
rSizeConstraint.MaxSize = Vector2.new(880, 180)
rSizeConstraint.MinSize = Vector2.new(340, 150)
rSizeConstraint.Parent = rouletteContainer

local rouletteTape = Instance.new("Frame")
rouletteTape.Name = "Tape"
rouletteTape.Size = UDim2.new(0, 10000, 1, 0)
rouletteTape.Position = UDim2.new(0, 0, 0, 0)
rouletteTape.BackgroundTransparency = 1
rouletteTape.Parent = rouletteContainer

local needleLine = Instance.new("Frame")
needleLine.Name = "Needle"
needleLine.AnchorPoint = Vector2.new(0.5, 0)
needleLine.Position = UDim2.new(0.5, 0, 0, 0)
needleLine.Size = UDim2.new(0, 4, 1, 0)
needleLine.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleLine.ZIndex = 10
needleLine.Parent = rouletteContainer

local needleTop = Instance.new("Frame")
needleTop.AnchorPoint = Vector2.new(0.5, 0)
needleTop.Position = UDim2.new(0.5, 0, 0, 0)
needleTop.Size = UDim2.new(0, 18, 0, 14)
needleTop.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleTop.ZIndex = 11
addCorner(needleTop, 4)
needleTop.Parent = rouletteContainer

local needleBottom = Instance.new("Frame")
needleBottom.AnchorPoint = Vector2.new(0.5, 1)
needleBottom.Position = UDim2.new(0.5, 0, 1, 0)
needleBottom.Size = UDim2.new(0, 18, 0, 14)
needleBottom.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleBottom.ZIndex = 11
addCorner(needleBottom, 4)
needleBottom.Parent = rouletteContainer

--------------------------------------------------------------------------------
-- 15. REVEAL POPUP WITH EXPLICIT EQUIP & SELL BUTTONS + ITEM ICON
--------------------------------------------------------------------------------

local cutsceneOverlay = Instance.new("Frame")
cutsceneOverlay.Name = "CutsceneOverlay"
cutsceneOverlay.Size = UDim2.new(1, 0, 1, 0)
cutsceneOverlay.BackgroundColor3 = Color3.fromRGB(4, 5, 8)
cutsceneOverlay.BackgroundTransparency = 0.25
cutsceneOverlay.Visible = false
cutsceneOverlay.Parent = screenGui

local revealCard = Instance.new("Frame")
revealCard.Name = "RevealCard"
revealCard.AnchorPoint = Vector2.new(0.5, 0.5)
revealCard.Position = UDim2.new(0.5, 0, 0.5, 0)
revealCard.Size = UDim2.new(0, 420, 0, 480)
revealCard.BackgroundColor3 = Color3.fromRGB(14, 17, 26)
addCorner(revealCard, 18)
local cardStroke = addStroke(revealCard, Color3.fromRGB(255, 255, 255), 3)
addPadding(revealCard, 18, 18, 22, 22)
revealCard.Parent = cutsceneOverlay

local cardHeaderTitle = Instance.new("TextLabel")
cardHeaderTitle.Size = UDim2.new(1, 0, 0, 20)
cardHeaderTitle.BackgroundTransparency = 1
cardHeaderTitle.Font = Enum.Font.GothamBlack
cardHeaderTitle.TextSize = 13
cardHeaderTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
cardHeaderTitle.Text = " ВЫ ВЫБИЛИ НОВУЮ АУРУ!"
cardHeaderTitle.Parent = revealCard

-- Item Icon in Reveal Card!
local revealEmblemHolder = Instance.new("Frame")
revealEmblemHolder.Size = UDim2.new(0, 64, 0, 64)
revealEmblemHolder.Position = UDim2.new(0.5, -32, 0, 24)
revealEmblemHolder.BackgroundTransparency = 1
revealEmblemHolder.Parent = revealCard

local cardTierTag = Instance.new("TextLabel")
cardTierTag.Size = UDim2.new(1, 0, 0, 22)
cardTierTag.Position = UDim2.new(0, 0, 0, 92)
cardTierTag.BackgroundTransparency = 1
cardTierTag.Font = Enum.Font.GothamBlack
cardTierTag.TextSize = 13
cardTierTag.TextColor3 = Color3.fromRGB(156, 163, 175)
cardTierTag.Text = "[ TIER ]"
cardTierTag.Parent = revealCard

local cardName = Instance.new("TextLabel")
cardName.Size = UDim2.new(1, 0, 0, 42)
cardName.Position = UDim2.new(0, 0, 0, 114)
cardName.BackgroundTransparency = 1
cardName.Font = Enum.Font.GothamBlack
cardName.TextSize = 28
cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
cardName.Text = "Aura Name"
cardName.Parent = revealCard

local cardRarity = Instance.new("TextLabel")
cardRarity.Size = UDim2.new(1, 0, 0, 24)
cardRarity.Position = UDim2.new(0, 0, 0, 156)
cardRarity.BackgroundTransparency = 1
cardRarity.Font = Enum.Font.GothamBold
cardRarity.TextSize = 16
cardRarity.TextColor3 = Color3.fromRGB(240, 243, 250)
cardRarity.Text = "1 in 100,000"
cardRarity.Parent = revealCard

local cardDesc = Instance.new("TextLabel")
cardDesc.Size = UDim2.new(1, 0, 0, 80)
cardDesc.Position = UDim2.new(0, 0, 0, 184)
cardDesc.BackgroundTransparency = 1
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextSize = 12
cardDesc.TextColor3 = Color3.fromRGB(180, 185, 205)
cardDesc.TextWrapped = true
cardDesc.Text = "Aura lore description..."
cardDesc.Parent = revealCard

local cardEquipBtn = Instance.new("TextButton")
cardEquipBtn.Size = UDim2.new(1, 0, 0, 44)
cardEquipBtn.Position = UDim2.new(0, 0, 1, -126)
cardEquipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
cardEquipBtn.Font = Enum.Font.GothamBlack
cardEquipBtn.TextSize = 15
cardEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardEquipBtn.Text = "ЭКИПИРОВАТЬ СЕЙЧАС"
addCorner(cardEquipBtn, 10)
cardEquipBtn.Parent = revealCard

local cardSellBtn = Instance.new("TextButton")
cardSellBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardSellBtn.Position = UDim2.new(0, 0, 1, -72)
cardSellBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
cardSellBtn.Font = Enum.Font.GothamBlack
cardSellBtn.TextSize = 13
cardSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardSellBtn.Text = "ПРОДАТЬ (+50)"
addCorner(cardSellBtn, 10)
cardSellBtn.Parent = revealCard

local cardCollectBtn = Instance.new("TextButton")
cardCollectBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardCollectBtn.Position = UDim2.new(0.52, 0, 1, -72)
cardCollectBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
cardCollectBtn.Font = Enum.Font.GothamBlack
cardCollectBtn.TextSize = 13
cardCollectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardCollectBtn.Text = " В ИНВЕНТАРЬ"
addCorner(cardCollectBtn, 10)
cardCollectBtn.Parent = revealCard

local currentRolledAura = nil

local function showRevealPopup(auraData)
	currentRolledAura = auraData
	cardTierTag.Text = string.format("[  %s  ]", auraData.Tier:upper())
	cardName.Text = auraData.Name
	cardName.TextColor3 = auraData.Color
	cardRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
	cardDesc.Text = auraData.Description
	cardStroke.Color = auraData.Color
	revealEmblemHolder:ClearAllChildren()
	createAuraEmblem(revealEmblemHolder, auraData, 64, UDim2.new(0, 0, 0, 0))

	local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
	cardSellBtn.Text = string.format("ПРОДАТЬ (+%d)", scrapCoins)

	cutsceneOverlay.Visible = true

	revealCard.Size = UDim2.new(0, 100, 0, 110)
	TweenService:Create(revealCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 420, 0, 480),
	}):Play()
end

cardEquipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		EquipAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardSellBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Coin")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		DeleteAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardCollectBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	cutsceneOverlay.Visible = false
end)

--------------------------------------------------------------------------------
-- 16. RUN CS2 CASE ROULETTE (WITH ITEM ICONS & TACTILE TICKS)
--------------------------------------------------------------------------------

local function runCS2Roulette(winningAura, onFinished)
	rouletteContainer.Visible = true
	rStroke.Color = winningAura.Color

	for _, child in ipairs(rouletteTape:GetChildren()) do
		child:Destroy()
	end

	local CARD_WIDTH = 120
	local CARD_GAP = 10
	local PITCH = CARD_WIDTH + CARD_GAP
	local WIN_INDEX = 34
	local TOTAL_CARDS = 44

	local allAuras = AuraConfig.RollableAuras
	local cardsList = {}

	for i = 1, TOTAL_CARDS do
		local aura = nil
		if i == WIN_INDEX then
			aura = winningAura
		else
			aura = allAuras[math.random(1, #allAuras)]
		end

		local card = Instance.new("Frame")
		card.Name = "Card_" .. tostring(i)
		card.Size = UDim2.new(0, CARD_WIDTH, 0, 140)
		card.Position = UDim2.new(0, (i - 1) * PITCH + 20, 0.5, -70)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
		addCorner(card, 10)
		addStroke(card, aura.Color, 2)

		-- Procedural Guaranteed Aura Emblem in Roulette Card
		createAuraEmblem(card, aura, 40, UDim2.new(0.5, -20, 0, 8))

		local rSym = Instance.new("TextLabel")
		rSym.Size = UDim2.new(0, 28, 0, 14)
		rSym.Position = UDim2.new(1, -32, 0, 6)
		rSym.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
		rSym.Font = Enum.Font.GothamBlack
		rSym.TextSize = 8
		rSym.TextColor3 = aura.Color
		rSym.Text = aura.Symbol or "AUR"
		addCorner(rSym, 3)
		rSym.Parent = card

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -8, 0, 24)
		name.Position = UDim2.new(0, 4, 0, 52)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBlack
		name.TextSize = 11
		name.TextColor3 = aura.Color
		name.Text = aura.Name
		name.TextWrapped = true
		name.Parent = card

		local rarity = Instance.new("TextLabel")
		rarity.Size = UDim2.new(1, -8, 0, 18)
		rarity.Position = UDim2.new(0, 4, 0, 78)
		rarity.BackgroundTransparency = 1
		rarity.Font = Enum.Font.GothamBold
		rarity.TextSize = 10
		rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
		rarity.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
		rarity.Parent = card

		local tierPill = Instance.new("TextLabel")
		tierPill.Size = UDim2.new(1, -16, 0, 22)
		tierPill.Position = UDim2.new(0, 8, 1, -30)
		tierPill.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
		tierPill.Font = Enum.Font.GothamBlack
		tierPill.TextSize = 9
		tierPill.TextColor3 = aura.Color
		tierPill.Text = aura.Tier:upper()
		addCorner(tierPill, 4)
		tierPill.Parent = card

		card.Parent = rouletteTape
		table.insert(cardsList, card)
	end

	local containerWidth = rouletteContainer.AbsoluteSize.X
	local centerOffset = containerWidth / 2
	local cardCenterInTape = (WIN_INDEX - 1) * PITCH + 20 + (CARD_WIDTH / 2)
	local randomJitter = math.random(-20, 20)
	local targetTapeX = -(cardCenterInTape - centerOffset + randomJitter)

	rouletteTape.Position = UDim2.new(0, 0, 0, 0)

	local duration = isFastRollOn and 0.8 or 3.2
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(rouletteTape, tweenInfo, {
		Position = UDim2.new(0, targetTapeX, 0, 0)
	})

	local lastCardIndex = -1
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local curX = rouletteTape.Position.X.Offset
		local passedDist = -curX + centerOffset - 20
		local currentCard = math.floor(passedDist / PITCH) + 1
		if currentCard ~= lastCardIndex and currentCard >= 1 and currentCard <= TOTAL_CARDS then
			lastCardIndex = currentCard
			SoundEffects.Play("Tick", 0.15, 1.2)
		end
	end)

	tween:Play()
	tween.Completed:Connect(function()
		if conn then conn:Disconnect() end

		needleLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(needleLine, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(250, 204, 21) }):Play()

		if winningAura.Rarity >= 250000 then
			SoundEffects.Play("RevealGodly")
		elseif winningAura.Rarity >= 10000 then
			SoundEffects.Play("RevealMythic")
		elseif winningAura.Rarity >= 1000 then
			SoundEffects.Play("RevealLegendary")
		elseif winningAura.Rarity >= 16 then
			SoundEffects.Play("RevealRare")
		else
			SoundEffects.Play("RevealCommon")
		end

		task.wait(0.4)
		rouletteContainer.Visible = false
		if onFinished then onFinished() end
	end)
end

--------------------------------------------------------------------------------
-- 17. GLOBAL SERVER BANNER
--------------------------------------------------------------------------------

local banner = Instance.new("Frame")
banner.Name = "GlobalBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Size = UDim2.new(0, 540, 0, 46)
banner.Position = UDim2.new(0.5, 0, 0, -65)
banner.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
banner.BackgroundTransparency = 0.1
addCorner(banner, 12)
local bannerStroke = addStroke(banner, Color3.fromRGB(250, 204, 21), 2)
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.new(1, -20, 1, 0)
bannerText.Position = UDim2.new(0, 10, 0, 0)
bannerText.BackgroundTransparency = 1
bannerText.Font = Enum.Font.GothamBlack
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.fromRGB(255, 235, 120)
bannerText.Text = " Player rolled MYTHIC!"
bannerText.Parent = banner

GlobalAnnouncementEvent.OnClientEvent:Connect(function(info)
	local tierColor = AuraConfig.GetTierColor(info.Tier)
	bannerStroke.Color = tierColor
	bannerText.Text = string.format(" %s rolled %s (%s)!", info.PlayerName, info.AuraName:upper(), AuraConfig.FormatRarity(info.Rarity))
	bannerText.TextColor3 = tierColor

	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 68),
	}):Play()

	task.delay(4.5, function()
		TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0, -65),
		}):Play()
	end)
end)

--------------------------------------------------------------------------------
-- 18. ROLL EXECUTION WITH CS2 ROULETTE
--------------------------------------------------------------------------------

local function doRoll()
	if isRolling then return end
	isRolling = true

	TweenService:Create(rollButton, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 225, 0, 58),
	}):Play()

	SoundEffects.Play("Spin")

	local result = RollRequestFunc:InvokeServer(isFastRollOn)

	task.wait(0.1)
	TweenService:Create(rollButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 240, 0, 64),
	}):Play()

	if result and result.Success and result.Aura then
		runCS2Roulette(result.Aura, function()
			showRevealPopup(result.Aura)
			isRolling = false
		end)
	else
		isRolling = false
	end
end

rollButton.MouseButton1Click:Connect(function()
	doRoll()
end)

autoRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isAutoRollOn = not isAutoRollOn
	if isAutoRollOn then
		autoRollBtn.Text = " AUTO: ON"
		autoRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(22, 50, 35)
		autoStroke.Color = Color3.fromRGB(74, 222, 128)
	else
		autoRollBtn.Text = " AUTO: OFF"
		autoRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		autoStroke.Color = Color3.fromRGB(45, 52, 70)
	end
end)

task.spawn(function()
	while true do
		task.wait(AuraConfig.Settings.AutoRollInterval)
		if isAutoRollOn and not isRolling and not cutsceneOverlay.Visible and not rouletteContainer.Visible then
			doRoll()
		end
	end
end)

fastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		fastRollBtn.Text = " FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВКЛ"
	else
		fastRollBtn.Text = " FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
	end
end)

unequipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	EquipAuraEvent:FireServer("None")
end)

navInventoryBtn.MouseButton1Click:Connect(function()
	toggleModal(invWindow)
	refreshInventoryUI()
end)

navUpgraderBtn.MouseButton1Click:Connect(function()
	toggleModal(upgWindow)
	refreshUpgraderUI()
end)

navPvPBtn.MouseButton1Click:Connect(function()
	toggleModal(pvpWindow)
	refreshPvPWindow()
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
	toggleModal(setWindow)
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	if prompt.Name == "CraftingPrompt" and player == LocalPlayer then
		if not craftWindow.Visible then toggleModal(craftWindow) end
		refreshCraftingUI()
	end
end)

--------------------------------------------------------------------------------
-- 19. DATA SYNCHRONIZATION
--------------------------------------------------------------------------------

DataSyncEvent.OnClientEvent:Connect(function(data)
	for k, v in pairs(data) do
		localData[k] = v
	end

	rollsLabel.Text = string.format(" Rolls: %s", AuraConfig.FormatNumber(localData.Rolls or 0))
	luckLabel.Text = string.format(" Luck: x%.1f", localData.CurrentLuck or 1.0)
	coinsLabel.Text = string.format(" %s", AuraConfig.FormatNumber(localData.Coins or 0))

	if localData.MegaPotionExpiry and localData.MegaPotionExpiry > os.time() then
		local remaining = localData.MegaPotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format(" 5x Mega: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(6, 182, 212)
	elseif localData.PotionExpiry and localData.PotionExpiry > os.time() then
		local remaining = localData.PotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format(" 2x Pot: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		potionLabel.Text = " Pot: None"
		potionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
	end

	local eqAura = AuraConfig.Auras[localData.EquippedAura]
	if eqAura then
		eqName.Text = eqAura.Name
		eqName.TextColor3 = eqAura.Color
		eqSub.Text = AuraConfig.FormatRarity(eqAura.Rarity or 0)
		eqStroke.Color = eqAura.Color
	else
		eqName.Text = "Aura: None"
		eqName.TextColor3 = Color3.fromRGB(220, 225, 235)
		eqSub.Text = "Not Equipped"
		eqStroke.Color = Color3.fromRGB(45, 55, 78)
	end

	local autoDelText = thresholdNames[localData.AutoDeleteThreshold or 0] or "Нет"
	autoDeleteBtn.Text = "Авто-продажа: " .. autoDelText

	if invWindow.Visible then refreshInventoryUI() end
	if craftWindow.Visible then refreshCraftingUI() end
	if shopWindow.Visible then refreshShopUI() end
	if upgWindow.Visible then refreshUpgraderUI() end
end)

print("[Sols RNG] CS2 Roulette, PvP Battles, Aura Upgrader & Icons loaded!")
]===]
else
	if existingClientScript then existingClientScript:Destroy() end
	local clientScript = Instance.new("LocalScript")
	clientScript.Name = "RNGClient"
	clientScript.Source = [===[-- RNGClient.client.lua
-- Dynamic CS2-style Case Opening Roulette, Item Icons on all Cards, Full Player vs Player (PvP) Combat Arena
-- with 3 Unique Skills & Damage Popups, 30%/50%/75% & 2x/5x/10x Aura Upgrader, Clear Sell/Equip Controls,
-- and Rich Multi-Category Donation Shop with Starter Pack Promos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ReplicatedStorage references
local AuraRNGFolder = ReplicatedStorage:WaitForChild("AuraRNG")
local EventsFolder = AuraRNGFolder:WaitForChild("Events")
local ModulesFolder = AuraRNGFolder:WaitForChild("Modules")

local AuraConfig = require(ModulesFolder:WaitForChild("AuraConfig"))
local AuraVisuals = require(ModulesFolder:WaitForChild("AuraVisuals"))
local SoundEffects = require(ModulesFolder:WaitForChild("SoundEffects"))

-- Remotes
local RollRequestFunc = EventsFolder:WaitForChild("RollRequest")
local CraftAuraFunc = EventsFolder:WaitForChild("CraftAura")
local PurchaseProductFunc = EventsFolder:WaitForChild("PurchaseProduct")
local UpgradeAuraFunc = EventsFolder:WaitForChild("UpgradeAura")
local PvPChallengeFunc = EventsFolder:WaitForChild("PvPChallenge")
local PvPUseSkillFunc = EventsFolder:WaitForChild("PvPUseSkill")
local EquipAuraEvent = EventsFolder:WaitForChild("EquipAura")
local DeleteAuraEvent = EventsFolder:WaitForChild("DeleteAura")
local SetAutoDeleteEvent = EventsFolder:WaitForChild("SetAutoDelete")
local ToggleTestPerkEvent = EventsFolder:WaitForChild("ToggleTestPerk")
local DataSyncEvent = EventsFolder:WaitForChild("DataSync")
local GlobalAnnouncementEvent = EventsFolder:WaitForChild("GlobalAnnouncement")
local PvPResponseEvent = EventsFolder:WaitForChild("PvPResponse")
local PvPStateEvent = EventsFolder:WaitForChild("PvPState")
local PvPVFXEvent = EventsFolder:WaitForChild("PvPVFX")

-- Local Player State Cache
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
	MegaPotionExpiry = 0,
	Gamepasses = {},
	TestPerks = {},
	CurrentLuck = 1.0,
}

local isAutoRollOn = false
local isFastRollOn = false
local isRolling = false
local selectedInventoryAura = nil
local selectedCraftRecipe = nil
local activeModal = nil

-- PvP State
local inBattle = false
local battleOpponent = ""
local battleMyHp = 1000
local battleMyMaxHp = 1000
local battleOpHp = 1000
local battleOpMaxHp = 1000
local skillCooldowns = { [1] = 0, [2] = 0, [3] = 0 }

--------------------------------------------------------------------------------
-- UI ROOT & UTILITIES
--------------------------------------------------------------------------------

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RNG_ScreenGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui
end

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	corner.Parent = parent
	return corner
end

local function addStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(45, 52, 70)
	stroke.Thickness = thickness or 1.5
	stroke.Transparency = transparency or 0.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function addPadding(parent, top, bottom, left, right)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top or 8)
	pad.PaddingBottom = UDim.new(0, bottom or 8)
	pad.PaddingLeft = UDim.new(0, left or 12)
	pad.PaddingRight = UDim.new(0, right or 12)
	pad.Parent = parent
	return pad
end

--------------------------------------------------------------------------------
-- 1. TOP HUD (RESPONSIVE CAPSULE)
--------------------------------------------------------------------------------

local topHud = Instance.new("Frame")
topHud.Name = "TopHUD"
topHud.AnchorPoint = Vector2.new(0.5, 0)
topHud.Position = UDim2.new(0.5, 0, 0, 12)
topHud.Size = UDim2.new(0.85, 0, 0, 46)
topHud.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
topHud.BackgroundTransparency = 0.15
addCorner(topHud, 14)
addStroke(topHud, Color3.fromRGB(45, 55, 78), 1.5)
addPadding(topHud, 4, 4, 16, 16)
topHud.Parent = screenGui

local topSizeConstraint = Instance.new("UISizeConstraint")
topSizeConstraint.MaxSize = Vector2.new(720, 48)
topSizeConstraint.MinSize = Vector2.new(320, 40)
topSizeConstraint.Parent = topHud

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 16)
topLayout.Parent = topHud

local function createTopStatPill(iconAsset, defaultText, color)
	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 134, 0, 32)
	pill.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	pill.BackgroundTransparency = 0.4
	addCorner(pill, 8)
	addStroke(pill, Color3.fromRGB(35, 42, 60), 1)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 18, 0, 18)
	iconImg.Position = UDim2.new(0, 8, 0.5, -9)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = pill

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -32, 1, 0)
	label.Position = UDim2.new(0, 28, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextColor3 = color
	label.Text = defaultText
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = pill

	pill.Parent = topHud
	return label, pill
end

local rollsLabel, rollsPill = createTopStatPill("rbxasset://textures/particles/sparkles_main.dds", "Роллы: 0", Color3.fromRGB(220, 225, 240))
local luckLabel, luckPill = createTopStatPill("rbxasset://textures/ui/InspectMenu/ico_favorite.png", "Удача: x1.0", Color3.fromRGB(74, 222, 128))
local coinsLabel, coinsPill = createTopStatPill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "Монеты: 100", Color3.fromRGB(250, 204, 21))
local potionLabel, potionPill = createTopStatPill("rbxassetid://241594432", "Зелье: Нет", Color3.fromRGB(56, 189, 248))

--------------------------------------------------------------------------------
-- 2. TOP-RIGHT SPECIAL OFFER WIDGET (STARTER PACK PROMOTION)
--------------------------------------------------------------------------------

local specialOffer = Instance.new("Frame")
specialOffer.Name = "SpecialOffer"
specialOffer.AnchorPoint = Vector2.new(1, 0)
specialOffer.Position = UDim2.new(1, -14, 0, 12)
specialOffer.Size = UDim2.new(0, 220, 0, 72)
specialOffer.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
specialOffer.BackgroundTransparency = 0.1
addCorner(specialOffer, 12)
addStroke(specialOffer, Color3.fromRGB(245, 158, 11), 1.8)
addPadding(specialOffer, 6, 6, 8, 8)
specialOffer.Parent = screenGui

local offerTitle = Instance.new("TextLabel")
offerTitle.Size = UDim2.new(1, 0, 0, 16)
offerTitle.BackgroundTransparency = 1
offerTitle.Font = Enum.Font.GothamBlack
offerTitle.TextSize = 11
offerTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
offerTitle.Text = "СТАРТЕР ПАК [-80%]"
offerTitle.Parent = specialOffer

local offerSub = Instance.new("TextLabel")
offerSub.Size = UDim2.new(1, 0, 0, 14)
offerSub.Position = UDim2.new(0, 0, 0, 16)
offerSub.BackgroundTransparency = 1
offerSub.Font = Enum.Font.GothamMedium
offerSub.TextSize = 10
offerSub.TextColor3 = Color3.fromRGB(220, 225, 240)
offerSub.Text = "x2 Luck + VIP + 25K Монет"
offerSub.Parent = specialOffer

local offerBuyBtn = Instance.new("TextButton")
offerBuyBtn.Size = UDim2.new(1, 0, 0, 26)
offerBuyBtn.Position = UDim2.new(0, 0, 1, -26)
offerBuyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
offerBuyBtn.Font = Enum.Font.GothamBlack
offerBuyBtn.TextSize = 11
offerBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
offerBuyBtn.Text = "ЗАБРАТЬ (R$ 149 / ТЕСТ)"
addCorner(offerBuyBtn, 6)
offerBuyBtn.Parent = specialOffer

offerBuyBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	offerBuyBtn.Text = "ПОЛУЧЕНО! [+25K / x2 LUCK / VIP]"
	offerBuyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	local res = PurchaseProductFunc:InvokeServer("StarterPack")
	if res and res.Success then
		SoundEffects.Play("RevealMythic")
	end
	task.delay(1.5, function()
		offerBuyBtn.Text = "ЗАБРАТЬ (R$ 149 / ТЕСТ)"
	end)
end)

--------------------------------------------------------------------------------
-- 3. RIGHT FLOATING QUICK-DONATE BAR
--------------------------------------------------------------------------------

local rightDonateBar = Instance.new("Frame")
rightDonateBar.Name = "RightDonateBar"
rightDonateBar.AnchorPoint = Vector2.new(1, 0.5)
rightDonateBar.Position = UDim2.new(1, -14, 0.5, 0)
rightDonateBar.Size = UDim2.new(0, 110, 0, 280)
rightDonateBar.BackgroundTransparency = 1
rightDonateBar.Parent = screenGui

local rightLayout = Instance.new("UIListLayout")
rightLayout.FillDirection = Enum.FillDirection.Vertical
rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
rightLayout.Padding = UDim.new(0, 8)
rightLayout.Parent = rightDonateBar

local function createQuickDonatePill(iconAsset, title, color, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	btn.Text = ""
	addCorner(btn, 10)
	local stroke = addStroke(btn, color, 1.5)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 18, 0, 18)
	iconImg.Position = UDim2.new(0, 8, 0.5, -9)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -32, 1, 0)
	lbl.Position = UDim2.new(0, 30, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 10
	lbl.TextColor3 = color
	lbl.Text = title
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(28, 34, 52) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18, 22, 32) }):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		if onClick then onClick() end
	end)

	btn.Parent = rightDonateBar
	return btn
end

local toggleShopModal = nil

createQuickDonatePill("rbxasset://textures/ui/InspectMenu/ico_favorite.png", "МАГАЗИН", Color3.fromRGB(168, 85, 247), function()
	if toggleShopModal then toggleShopModal() end
end)

createQuickDonatePill("rbxasset://textures/particles/sparkles_main.dds", "x2 УДАЧА", Color3.fromRGB(74, 222, 128), function()
	ToggleTestPerkEvent:FireServer("X2Luck")
end)

createQuickDonatePill("rbxassetid://258127006", "VIP СТАТУС", Color3.fromRGB(245, 158, 11), function()
	ToggleTestPerkEvent:FireServer("VIP")
end)

createQuickDonatePill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "АВТО-РОЛЛ", Color3.fromRGB(250, 204, 21), function()
	ToggleTestPerkEvent:FireServer("AutoRoll")
end)

createQuickDonatePill("rbxassetid://241594432", "x5 ЗЕЛЬЕ", Color3.fromRGB(6, 182, 212), function()
	PurchaseProductFunc:InvokeServer("MegaPotion")
end)

createQuickDonatePill("rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "+50K МОНЕТ", Color3.fromRGB(251, 191, 36), function()
	PurchaseProductFunc:InvokeServer("CoinPack50k")
end)

--------------------------------------------------------------------------------
-- 4. BOTTOM CONTROLS & REDESIGNED MODERN AAA ROLL BUTTON
--------------------------------------------------------------------------------

local bottomControls = Instance.new("Frame")
bottomControls.Name = "BottomControls"
bottomControls.AnchorPoint = Vector2.new(0.5, 1)
bottomControls.Position = UDim2.new(0.5, 0, 1, -16)
bottomControls.Size = UDim2.new(0, 480, 0, 116)
bottomControls.BackgroundTransparency = 1
bottomControls.Parent = screenGui

local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.AnchorPoint = Vector2.new(0.5, 0)
rollButton.Position = UDim2.new(0.5, 0, 0, 0)
rollButton.Size = UDim2.new(0, 260, 0, 68)
rollButton.BackgroundColor3 = Color3.fromRGB(15, 20, 34)
rollButton.AutoButtonColor = false
rollButton.Text = ""
addCorner(rollButton, 18)

local rollStroke = addStroke(rollButton, Color3.fromRGB(56, 189, 248), 2.5)

local rollGrad = Instance.new("UIGradient")
rollGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 58, 138)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(29, 78, 216)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 165, 233)),
})
rollGrad.Rotation = 45
rollGrad.Parent = rollButton

local rollIcon = Instance.new("ImageLabel")
rollIcon.Size = UDim2.new(0, 32, 0, 32)
rollIcon.Position = UDim2.new(0, 16, 0.5, -16)
rollIcon.BackgroundTransparency = 1
rollIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
rollIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
rollIcon.Parent = rollButton

local rollTitle = Instance.new("TextLabel")
rollTitle.Size = UDim2.new(1, -56, 0, 28)
rollTitle.Position = UDim2.new(0, 52, 0, 10)
rollTitle.BackgroundTransparency = 1
rollTitle.Font = Enum.Font.GothamBlack
rollTitle.TextSize = 20
rollTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
rollTitle.Text = "КРУТИТЬ [ ROLL ]"
rollTitle.TextXAlignment = Enum.TextXAlignment.Left
rollTitle.Parent = rollButton

local rollSub = Instance.new("TextLabel")
rollSub.Size = UDim2.new(1, -56, 0, 18)
rollSub.Position = UDim2.new(0, 52, 0, 38)
rollSub.BackgroundTransparency = 1
rollSub.Font = Enum.Font.GothamBold
rollSub.TextSize = 11
rollSub.TextColor3 = Color3.fromRGB(147, 197, 253)
rollSub.Text = "[ ПРОБЕЛ / КЛИК ]"
rollSub.TextXAlignment = Enum.TextXAlignment.Left
rollSub.Parent = rollButton

-- Interactive spring animations
rollButton.MouseEnter:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 272, 0, 72),
		Position = UDim2.new(0.5, 0, 0, -2)
	}):Play()
	rollStroke.Color = Color3.fromRGB(125, 211, 252)
	rollStroke.Thickness = 3.2
end)

rollButton.MouseLeave:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 260, 0, 68),
		Position = UDim2.new(0.5, 0, 0, 0)
	}):Play()
	rollStroke.Color = Color3.fromRGB(56, 189, 248)
	rollStroke.Thickness = 2.5
end)

rollButton.MouseButton1Down:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.08), {
		Size = UDim2.new(0, 248, 0, 64),
		Position = UDim2.new(0.5, 0, 0, 2)
	}):Play()
end)

rollButton.MouseButton1Up:Connect(function()
	TweenService:Create(rollButton, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 272, 0, 72),
		Position = UDim2.new(0.5, 0, 0, -2)
	}):Play()
end)

rollButton.Parent = bottomControls

local secondaryBar = Instance.new("Frame")
secondaryBar.Size = UDim2.new(0, 340, 0, 34)
secondaryBar.AnchorPoint = Vector2.new(0.5, 1)
secondaryBar.Position = UDim2.new(0.5, 0, 1, 0)
secondaryBar.BackgroundTransparency = 1
secondaryBar.Parent = bottomControls

local secLayout = Instance.new("UIListLayout")
secLayout.FillDirection = Enum.FillDirection.Horizontal
secLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
secLayout.Padding = UDim.new(0, 12)
secLayout.Parent = secondaryBar

local autoRollBtn = Instance.new("TextButton")
autoRollBtn.Name = "AutoRollBtn"
autoRollBtn.Size = UDim2.new(0, 160, 1, 0)
autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
autoRollBtn.Font = Enum.Font.GothamBold
autoRollBtn.TextSize = 12
autoRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
autoRollBtn.Text = "АВТО-РОЛЛ: ВЫКЛ"
addCorner(autoRollBtn, 8)
local autoStroke = addStroke(autoRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
autoRollBtn.Parent = secondaryBar

local fastRollBtn = Instance.new("TextButton")
fastRollBtn.Name = "FastRollBtn"
fastRollBtn.Size = UDim2.new(0, 160, 1, 0)
fastRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
fastRollBtn.Font = Enum.Font.GothamBold
fastRollBtn.TextSize = 12
fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
fastRollBtn.Text = "ФАСТ-РОЛЛ: ВЫКЛ"
addCorner(fastRollBtn, 8)
local fastStroke = addStroke(fastRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
fastRollBtn.Parent = secondaryBar

--------------------------------------------------------------------------------
-- 5. LEFT DOCK NAVIGATION BAR (HIGH-TECH MONOGRAM BADGES)
--------------------------------------------------------------------------------

local leftDock = Instance.new("Frame")
leftDock.Name = "LeftDock"
leftDock.AnchorPoint = Vector2.new(0, 0.5)
leftDock.Position = UDim2.new(0, 14, 0.5, 0)
leftDock.Size = UDim2.new(0, 62, 0, 340)
leftDock.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
leftDock.BackgroundTransparency = 0.15
addCorner(leftDock, 14)
addStroke(leftDock, Color3.fromRGB(45, 55, 78), 1.5)
addPadding(leftDock, 8, 8, 4, 4)
leftDock.Parent = screenGui

local dockLayout = Instance.new("UIListLayout")
dockLayout.FillDirection = Enum.FillDirection.Vertical
dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dockLayout.Padding = UDim.new(0, 8)
dockLayout.Parent = leftDock

local function createDockButton(name, iconAsset, tooltipText)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Btn"
	btn.Size = UDim2.new(0, 48, 0, 48)
	btn.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	btn.Text = ""
	addCorner(btn, 10)
	local stroke = addStroke(btn, Color3.fromRGB(45, 55, 78), 1.2)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 26, 0, 26)
	iconImg.Position = UDim2.new(0.5, -13, 0.5, -13)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = Color3.fromRGB(210, 220, 240)
	iconImg.Parent = btn

	local tooltip = Instance.new("TextLabel")
	tooltip.Size = UDim2.new(0, 110, 0, 28)
	tooltip.Position = UDim2.new(1, 10, 0.5, -14)
	tooltip.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
	tooltip.Font = Enum.Font.GothamBold
	tooltip.TextSize = 10
	tooltip.TextColor3 = Color3.fromRGB(240, 245, 255)
	tooltip.Text = tooltipText
	tooltip.Visible = false
	tooltip.ZIndex = 20
	addCorner(tooltip, 6)
	addStroke(tooltip, Color3.fromRGB(56, 189, 248), 1)
	tooltip.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(37, 99, 235),
			Size = UDim2.new(0, 52, 0, 52)
		}):Play()
		iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
		stroke.Color = Color3.fromRGB(96, 165, 250)
		tooltip.Visible = true
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(20, 24, 36),
			Size = UDim2.new(0, 48, 0, 48)
		}):Play()
		iconImg.ImageColor3 = Color3.fromRGB(210, 220, 240)
		stroke.Color = Color3.fromRGB(45, 55, 78)
		tooltip.Visible = false
	end)

	btn.Parent = leftDock
	return btn
end

local navInventoryBtn = createDockButton("Inventory", "rbxasset://textures/ui/TopBar/inventoryOff.png", "Инвентарь")
local navUpgraderBtn = createDockButton("Upgrader", "rbxasset://textures/ui/Emotes/EmotesWheelCenter.png", "Апгрейдер Аур")
local navPvPBtn = createDockButton("PvP", "rbxasset://textures/ui/InspectMenu/ico_equipped.png", "Арена Батлов")
local navCraftingBtn = createDockButton("Crafting", "rbxasset://textures/particles/sparkles_main.dds", "Кузница Крафта")
local navShopBtn = createDockButton("Shop", "rbxasset://textures/ui/InspectMenu/ico_favorite.png", "Магазин Доната")
local navSettingsBtn = createDockButton("Settings", "rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png", "Настройки")

--------------------------------------------------------------------------------
-- 6. BOTTOM-LEFT EQUIPPED AURA SHOWCASE CARD
--------------------------------------------------------------------------------

local equippedCard = Instance.new("Frame")
equippedCard.Name = "EquippedCard"
equippedCard.AnchorPoint = Vector2.new(0, 1)
equippedCard.Position = UDim2.new(0, 14, 1, -14)
equippedCard.Size = UDim2.new(0, 200, 0, 60)
equippedCard.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
equippedCard.BackgroundTransparency = 0.2
addCorner(equippedCard, 10)
local eqStroke = addStroke(equippedCard, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(equippedCard, 8, 8, 12, 8)
equippedCard.Parent = screenGui

local eqName = Instance.new("TextLabel")
eqName.Size = UDim2.new(1, -40, 0, 20)
eqName.Position = UDim2.new(0, 0, 0, 2)
eqName.BackgroundTransparency = 1
eqName.Font = Enum.Font.GothamBlack
eqName.TextSize = 14
eqName.TextColor3 = Color3.fromRGB(240, 243, 250)
eqName.TextXAlignment = Enum.TextXAlignment.Left
eqName.Text = "Aura: None"
eqName.Parent = equippedCard

local eqSub = Instance.new("TextLabel")
eqSub.Size = UDim2.new(1, -40, 0, 16)
eqSub.Position = UDim2.new(0, 0, 0, 24)
eqSub.BackgroundTransparency = 1
eqSub.Font = Enum.Font.GothamBold
eqSub.TextSize = 11
eqSub.TextColor3 = Color3.fromRGB(156, 163, 175)
eqSub.TextXAlignment = Enum.TextXAlignment.Left
eqSub.Text = "Not Equipped"
eqSub.Parent = equippedCard

local unequipBtn = Instance.new("TextButton")
unequipBtn.Size = UDim2.new(0, 32, 0, 32)
unequipBtn.Position = UDim2.new(1, -34, 0.5, -16)
unequipBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
unequipBtn.Font = Enum.Font.GothamBold
unequipBtn.TextSize = 12
unequipBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
unequipBtn.Text = "[X]"
addCorner(unequipBtn, 6)
unequipBtn.Parent = equippedCard

--------------------------------------------------------------------------------
-- 7. MODAL WINDOW CREATOR
--------------------------------------------------------------------------------

local function createModal(titleText, width, height)
	local window = Instance.new("Frame")
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.new(0.5, 0, 0.5, 0)
	window.Size = UDim2.new(0, width, 0, height)
	window.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
	window.BackgroundTransparency = 0.08
	window.Visible = false
	addCorner(window, 16)
	addStroke(window, Color3.fromRGB(55, 65, 90), 2)
	window.Parent = screenGui

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	header.BackgroundTransparency = 0.3
	addCorner(header, 16)
	header.Parent = window

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 18, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(240, 243, 250)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = titleText
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 56)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
	closeBtn.Text = "[X]"
	addCorner(closeBtn, 8)
	closeBtn.Parent = header

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -28, 1, -64)
	content.Position = UDim2.new(0, 14, 0, 54)
	content.BackgroundTransparency = 1
	content.Parent = window

	closeBtn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		window.Visible = false
		if activeModal == window then activeModal = nil end
	end)

	return window, content
end

local function toggleModal(modal)
	SoundEffects.Play("Click")
	if activeModal == modal then
		modal.Visible = false
		activeModal = nil
	else
		if activeModal then activeModal.Visible = false end
		modal.Visible = true
		activeModal = modal
		modal.Size = UDim2.new(0, modal.Size.X.Offset * 0.9, 0, modal.Size.Y.Offset * 0.9)
		TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, modal.Size.X.Offset / 0.9, 0, modal.Size.Y.Offset / 0.9),
		}):Play()
	end
end

--------------------------------------------------------------------------------
-- 8. INVENTORY WINDOW (EXPLICIT EQUIP & SELL BUTTONS WITH ITEM ICONS)
--------------------------------------------------------------------------------

local invWindow, invContent = createModal("ИНВЕНТАРЬ АУР", 680, 480)

local topInvBar = Instance.new("Frame")
topInvBar.Size = UDim2.new(1, 0, 0, 28)
topInvBar.BackgroundTransparency = 1
topInvBar.Parent = invContent

local storageBarBg = Instance.new("Frame")
storageBarBg.Size = UDim2.new(0, 220, 0, 24)
storageBarBg.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(storageBarBg, 6)
storageBarBg.Parent = topInvBar

local storageFill = Instance.new("Frame")
storageFill.Size = UDim2.new(0.5, 0, 1, 0)
storageFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
addCorner(storageFill, 6)
storageFill.Parent = storageBarBg

local storageText = Instance.new("TextLabel")
storageText.Size = UDim2.new(1, 0, 1, 0)
storageText.BackgroundTransparency = 1
storageText.Font = Enum.Font.GothamBold
storageText.TextSize = 12
storageText.TextColor3 = Color3.fromRGB(255, 255, 255)
storageText.Text = "Слоты: 0 / 20"
storageText.Parent = storageBarBg

local autoDeleteBtn = Instance.new("TextButton")
autoDeleteBtn.Size = UDim2.new(0, 190, 0, 26)
autoDeleteBtn.Position = UDim2.new(1, -190, 0, 0)
autoDeleteBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
autoDeleteBtn.Font = Enum.Font.GothamMedium
autoDeleteBtn.TextSize = 12
autoDeleteBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
autoDeleteBtn.Text = "Авто-продажа: Нет"
addCorner(autoDeleteBtn, 6)
addStroke(autoDeleteBtn, Color3.fromRGB(50, 60, 82), 1)
autoDeleteBtn.Parent = topInvBar

local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -230, 1, -38)
invScroll.Position = UDim2.new(0, 0, 0, 36)
invScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
invScroll.BackgroundTransparency = 0.4
invScroll.ScrollBarThickness = 5
addCorner(invScroll, 8)
invScroll.Parent = invContent

local invGrid = Instance.new("UIGridLayout")
invGrid.CellSize = UDim2.new(0, 95, 0, 95)
invGrid.CellPadding = UDim2.new(0, 8, 0, 8)
invGrid.Parent = invScroll
addPadding(invScroll, 8, 8, 8, 8)

local detailPanel = Instance.new("Frame")
detailPanel.Size = UDim2.new(0, 215, 1, -38)
detailPanel.Position = UDim2.new(1, -215, 0, 36)
detailPanel.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(detailPanel, 8)
addStroke(detailPanel, Color3.fromRGB(42, 50, 70), 1)
addPadding(detailPanel, 12, 12, 12, 12)
detailPanel.Parent = invContent

-- Item Icon in details panel
local detailEmblemHolder = Instance.new("Frame")
detailEmblemHolder.Size = UDim2.new(0, 48, 0, 48)
detailEmblemHolder.Position = UDim2.new(0.5, -24, 0, 4)
detailEmblemHolder.BackgroundTransparency = 1
detailEmblemHolder.Parent = detailPanel

local detailName = Instance.new("TextLabel")
detailName.Size = UDim2.new(1, 0, 0, 22)
detailName.Position = UDim2.new(0, 0, 0, 56)
detailName.BackgroundTransparency = 1
detailName.Font = Enum.Font.GothamBlack
detailName.TextSize = 15
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.Text = "Выберите Ауру"
detailName.Parent = detailPanel

local detailRarity = Instance.new("TextLabel")
detailRarity.Size = UDim2.new(1, 0, 0, 16)
detailRarity.Position = UDim2.new(0, 0, 0, 78)
detailRarity.BackgroundTransparency = 1
detailRarity.Font = Enum.Font.GothamBold
detailRarity.TextSize = 11
detailRarity.TextColor3 = Color3.fromRGB(156, 163, 175)
detailRarity.Text = ""
detailRarity.Parent = detailPanel

local detailDesc = Instance.new("TextLabel")
detailDesc.Size = UDim2.new(1, 0, 0, 70)
detailDesc.Position = UDim2.new(0, 0, 0, 96)
detailDesc.BackgroundTransparency = 1
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 11
detailDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
detailDesc.TextWrapped = true
detailDesc.TextYAlignment = Enum.TextYAlignment.Top
detailDesc.Text = "Нажмите на ауру слева для управления."
detailDesc.Parent = detailPanel

local equipActionBtn = Instance.new("TextButton")
equipActionBtn.Size = UDim2.new(1, 0, 0, 40)
equipActionBtn.Position = UDim2.new(0, 0, 1, -90)
equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
equipActionBtn.Font = Enum.Font.GothamBlack
equipActionBtn.TextSize = 13
equipActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipActionBtn.Text = "ЭКИПИРОВАТЬ"
equipActionBtn.Visible = false
addCorner(equipActionBtn, 8)
equipActionBtn.Parent = detailPanel

local sellActionBtn = Instance.new("TextButton")
sellActionBtn.Size = UDim2.new(1, 0, 0, 38)
sellActionBtn.Position = UDim2.new(0, 0, 1, -44)
sellActionBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
sellActionBtn.Font = Enum.Font.GothamBlack
sellActionBtn.TextSize = 12
sellActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellActionBtn.Text = "ПРОДАТЬ (+50 МОНЕТ)"
sellActionBtn.Visible = false
addCorner(sellActionBtn, 8)
sellActionBtn.Parent = detailPanel

local function refreshInventoryUI()
	for _, child in ipairs(invScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local totalCount = 0
	for auraId, count in pairs(localData.Inventory) do
		totalCount = totalCount + count
		local auraData = AuraConfig.Auras[auraId]
		if auraData then
			local card = Instance.new("TextButton")
			card.Name = "Card_" .. auraId
			card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
			card.Text = ""
			addCorner(card, 8)
			addStroke(card, auraData.Color, 1.5)

			-- Procedural Guaranteed Aura Emblem
			createAuraEmblem(card, auraData, 34, UDim2.new(0.5, -17, 0, 6))

			local symBadge = Instance.new("TextLabel")
			symBadge.Size = UDim2.new(0, 26, 0, 14)
			symBadge.Position = UDim2.new(1, -28, 0, 4)
			symBadge.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
			symBadge.Font = Enum.Font.GothamBlack
			symBadge.TextSize = 8
			symBadge.TextColor3 = auraData.Color
			symBadge.Text = auraData.Symbol or "AUR"
			addCorner(symBadge, 3)
			symBadge.Parent = card

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -8, 0, 20)
			name.Position = UDim2.new(0, 4, 0, 44)
			name.BackgroundTransparency = 1
			name.Font = Enum.Font.GothamBold
			name.TextSize = 11
			name.TextColor3 = auraData.Color
			name.Text = auraData.Name
			name.TextWrapped = true
			name.Parent = card

			local rarity = Instance.new("TextLabel")
			rarity.Size = UDim2.new(1, -8, 0, 14)
			rarity.Position = UDim2.new(0, 4, 0, 64)
			rarity.BackgroundTransparency = 1
			rarity.Font = Enum.Font.GothamMedium
			rarity.TextSize = 9
			rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
			rarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
			rarity.Parent = card

			local countTag = Instance.new("TextLabel")
			countTag.Size = UDim2.new(0, 28, 0, 16)
			countTag.Position = UDim2.new(1, -30, 1, -18)
			countTag.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
			countTag.Font = Enum.Font.GothamBold
			countTag.TextSize = 9
			countTag.TextColor3 = Color3.fromRGB(220, 225, 240)
			countTag.Text = "x" .. tostring(count)
			addCorner(countTag, 4)
			countTag.Parent = card

			if localData.EquippedAura == auraId then
				local eqTag = Instance.new("TextLabel")
				eqTag.Size = UDim2.new(0, 44, 0, 16)
				eqTag.Position = UDim2.new(0, 4, 1, -18)
				eqTag.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				eqTag.Font = Enum.Font.GothamBold
				eqTag.TextSize = 8
				eqTag.TextColor3 = Color3.fromRGB(255, 255, 255)
				eqTag.Text = "НАДЕТО"
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
				detailEmblemHolder:ClearAllChildren()
				createAuraEmblem(detailEmblemHolder, auraData, 48, UDim2.new(0, 0, 0, 0))

				equipActionBtn.Visible = true
				if localData.EquippedAura == auraId then
					equipActionBtn.Text = "СНЯТЬ АУРУ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
				else
					equipActionBtn.Text = "ЭКИПИРОВАТЬ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				end

				local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
				sellActionBtn.Text = string.format("ПРОДАТЬ (+%d МОНЕТ)", scrapCoins)
				sellActionBtn.Visible = true
			end)

			card.Parent = invScroll
		end
	end

	local maxSlots = localData.MaxStorage or 20
	storageText.Text = string.format("Слоты: %d / %d", totalCount, maxSlots)
	local ratio = math.clamp(totalCount / maxSlots, 0, 1)
	storageFill.Size = UDim2.new(ratio, 0, 1, 0)
	if ratio >= 1.0 then
		storageFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	elseif ratio >= 0.8 then
		storageFill.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
	else
		storageFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	end

	invScroll.CanvasSize = UDim2.new(0, 0, 0, invGrid.AbsoluteContentSize.Y + 24)
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

sellActionBtn.MouseButton1Click:Connect(function()
	if not selectedInventoryAura then return end
	SoundEffects.Play("Coin")
	DeleteAuraEvent:FireServer(selectedInventoryAura)
	selectedInventoryAura = nil
	equipActionBtn.Visible = false
	sellActionBtn.Visible = false
	detailName.Text = "Выберите Ауру"
	detailRarity.Text = ""
	detailDesc.Text = "Аура успешно продана за монеты!"
end)

local thresholds = { 0, 2, 4, 16, 64 }
local thresholdNames = { [0] = "Нет", [2] = "Common (1/2)", [4] = "Uncommon (1/4)", [16] = "Rare (1/16)", [64] = "Crystallized (1/64)" }
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
	SetAutoDeleteEvent:FireServer(thresholds[nextIdx])
end)

--------------------------------------------------------------------------------
-- 9. AURA UPGRADER WINDOW (DYNAMIC GREEN WIN SECTOR & 2 BLOCKS & CUSTOM CHANCE)
--------------------------------------------------------------------------------

local upgWindow, upgContent = createModal("АПГРЕЙДЕР АУР [ РИСК-КОЛЕСО ]", 880, 540)

local selectedSourceAuraId = nil
local selectedTargetAuraId = nil
local isUpgraderFast = false
local upgraderChance = 50.0
local isWheelSpinning = false

-- Top Control Bar of Upgrader (Mode Toggle: Arcade vs Fast)
local upgTopBar = Instance.new("Frame")
upgTopBar.Size = UDim2.new(1, 0, 0, 32)
upgTopBar.Position = UDim2.new(0, 0, 0, 0)
upgTopBar.BackgroundTransparency = 1
upgTopBar.Parent = upgContent

local upgModeToggleBtn = Instance.new("TextButton")
upgModeToggleBtn.Size = UDim2.new(0, 240, 1, 0)
upgModeToggleBtn.Position = UDim2.new(1, -240, 0, 0)
upgModeToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
upgModeToggleBtn.Font = Enum.Font.GothamBold
upgModeToggleBtn.TextSize = 11
upgModeToggleBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
upgModeToggleBtn.Text = "РЕЖИМ: АРКАДНЫЙ (3.2С)"
addCorner(upgModeToggleBtn, 6)
local modeStroke = addStroke(upgModeToggleBtn, Color3.fromRGB(56, 189, 248), 1.2)
upgModeToggleBtn.Parent = upgTopBar

upgModeToggleBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isUpgraderFast = not isUpgraderFast
	if isUpgraderFast then
		upgModeToggleBtn.Text = "РЕЖИМ: БЫСТРЫЙ (0.6С)"
		upgModeToggleBtn.TextColor3 = Color3.fromRGB(251, 191, 36)
		modeStroke.Color = Color3.fromRGB(251, 191, 36)
	else
		upgModeToggleBtn.Text = "РЕЖИМ: АРКАДНЫЙ (3.2С)"
		upgModeToggleBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
		modeStroke.Color = Color3.fromRGB(56, 189, 248)
	end
end)

-- Main 3-Column Layout
-- Column 1: BLOCK 1 - Source Aura / Inventory Selection (Left)
local upgColLeft = Instance.new("Frame")
upgColLeft.Size = UDim2.new(0, 240, 1, -38)
upgColLeft.Position = UDim2.new(0, 0, 0, 38)
upgColLeft.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(upgColLeft, 10)
addStroke(upgColLeft, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColLeft, 8, 8, 8, 8)
upgColLeft.Parent = upgContent

local colLeftTitle = Instance.new("TextLabel")
colLeftTitle.Size = UDim2.new(1, 0, 0, 18)
colLeftTitle.BackgroundTransparency = 1
colLeftTitle.Font = Enum.Font.GothamBlack
colLeftTitle.TextSize = 11
colLeftTitle.TextColor3 = Color3.fromRGB(240, 243, 250)
colLeftTitle.Text = "1. ВАША АУРА (ИНВЕНТАРЬ)"
colLeftTitle.Parent = upgColLeft

-- Source Preview Card
local sourcePreviewFrame = Instance.new("Frame")
sourcePreviewFrame.Size = UDim2.new(1, 0, 0, 68)
sourcePreviewFrame.Position = UDim2.new(0, 0, 0, 22)
sourcePreviewFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(sourcePreviewFrame, 8)
local srcStroke = addStroke(sourcePreviewFrame, Color3.fromRGB(56, 189, 248), 1.2)
sourcePreviewFrame.Parent = upgColLeft

local srcEmblemHolder = Instance.new("Frame")
srcEmblemHolder.Size = UDim2.new(0, 42, 0, 42)
srcEmblemHolder.Position = UDim2.new(0, 8, 0.5, -21)
srcEmblemHolder.BackgroundTransparency = 1
srcEmblemHolder.Parent = sourcePreviewFrame

local srcNameLbl = Instance.new("TextLabel")
srcNameLbl.Size = UDim2.new(1, -56, 0, 18)
srcNameLbl.Position = UDim2.new(0, 52, 0, 8)
srcNameLbl.BackgroundTransparency = 1
srcNameLbl.Font = Enum.Font.GothamBlack
srcNameLbl.TextSize = 12
srcNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
srcNameLbl.Text = "Выберите ауру ниже"
srcNameLbl.TextXAlignment = Enum.TextXAlignment.Left
srcNameLbl.Parent = sourcePreviewFrame

local srcSubLbl = Instance.new("TextLabel")
srcSubLbl.Size = UDim2.new(1, -56, 0, 16)
srcSubLbl.Position = UDim2.new(0, 52, 0, 28)
srcSubLbl.BackgroundTransparency = 1
srcSubLbl.Font = Enum.Font.GothamMedium
srcSubLbl.TextSize = 9
srcSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
srcSubLbl.Text = "Нажмите в списке ниже"
srcSubLbl.TextXAlignment = Enum.TextXAlignment.Left
srcSubLbl.Parent = sourcePreviewFrame

local srcScrapLbl = Instance.new("TextLabel")
srcScrapLbl.Size = UDim2.new(1, -56, 0, 14)
srcScrapLbl.Position = UDim2.new(0, 52, 0, 46)
srcScrapLbl.BackgroundTransparency = 1
srcScrapLbl.Font = Enum.Font.GothamBold
srcScrapLbl.TextSize = 9
srcScrapLbl.TextColor3 = Color3.fromRGB(74, 222, 128)
srcScrapLbl.Text = "Возврат: +50 монет"
srcScrapLbl.TextXAlignment = Enum.TextXAlignment.Left
srcScrapLbl.Parent = sourcePreviewFrame

-- Inventory Scroll
local srcScroll = Instance.new("ScrollingFrame")
srcScroll.Size = UDim2.new(1, 0, 1, -100)
srcScroll.Position = UDim2.new(0, 0, 0, 96)
srcScroll.BackgroundTransparency = 1
srcScroll.ScrollBarThickness = 4
srcScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
srcScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
srcScroll.Parent = upgColLeft

local srcLayout = Instance.new("UIGridLayout")
srcLayout.CellSize = UDim2.new(0, 68, 0, 80)
srcLayout.CellPadding = UDim2.new(0, 6, 0, 6)
srcLayout.Parent = srcScroll

-- Column 2: CENTER - UPGRADER WHEEL & DYNAMIC WIN SECTOR GAUGE
local upgColCenter = Instance.new("Frame")
upgColCenter.Size = UDim2.new(1, -500, 1, -38)
upgColCenter.Position = UDim2.new(0, 250, 0, 38)
upgColCenter.BackgroundColor3 = Color3.fromRGB(14, 17, 26)
addCorner(upgColCenter, 10)
addStroke(upgColCenter, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColCenter, 10, 10, 8, 8)
upgColCenter.Parent = upgContent

-- Upgrader Wheel Circular Container
local wheelFrame = Instance.new("Frame")
wheelFrame.Size = UDim2.new(0, 184, 0, 184)
wheelFrame.AnchorPoint = Vector2.new(0.5, 0)
wheelFrame.Position = UDim2.new(0.5, 0, 0, 4)
wheelFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
addCorner(wheelFrame, 92)
local wheelStroke = addStroke(wheelFrame, Color3.fromRGB(34, 197, 94), 2.5)
wheelFrame.Parent = upgColCenter

-- DYNAMIC WIN SECTOR GAUGE BARS (36 radial sector bars covering 360 degrees)
local sectorRing = Instance.new("Frame")
sectorRing.Size = UDim2.new(1, 0, 1, 0)
sectorRing.BackgroundTransparency = 1
sectorRing.Parent = wheelFrame

local sectorBars = {}
local TOTAL_SECTORS = 36

for i = 1, TOTAL_SECTORS do
	local deg = (i - 1) * 10
	local rad = math.rad(deg - 90)
	local r = 68

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 8, 0, 22)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.new(0.5, math.cos(rad) * r, 0.5, math.sin(rad) * r)
	bar.Rotation = deg
	bar.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	addCorner(bar, 3)
	bar.Parent = sectorRing

	table.insert(sectorBars, { Bar = bar, Angle = deg })
end

-- Needle Pointer Container (Rotates around center)
local needleContainer = Instance.new("Frame")
needleContainer.Size = UDim2.new(1, 0, 1, 0)
needleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
needleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
needleContainer.BackgroundTransparency = 1
needleContainer.ZIndex = 10
needleContainer.Parent = wheelFrame

local needle = Instance.new("Frame")
needle.Size = UDim2.new(0, 4, 0, 78)
needle.AnchorPoint = Vector2.new(0.5, 1)
needle.Position = UDim2.new(0.5, 0, 0.5, 0)
needle.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needle.ZIndex = 10
addCorner(needle, 2)
needle.Parent = needleContainer

local needleArrow = Instance.new("Frame")
needleArrow.Size = UDim2.new(0, 14, 0, 14)
needleArrow.AnchorPoint = Vector2.new(0.5, 0.5)
needleArrow.Position = UDim2.new(0.5, 0, 0, 6)
needleArrow.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
needleArrow.Rotation = 45
needleArrow.ZIndex = 10
needleArrow.Parent = needleContainer

-- Center Hub inside Wheel
local centerHub = Instance.new("Frame")
centerHub.Size = UDim2.new(0, 96, 0, 96)
centerHub.AnchorPoint = Vector2.new(0.5, 0.5)
centerHub.Position = UDim2.new(0.5, 0, 0.5, 0)
centerHub.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
centerHub.ZIndex = 12
addCorner(centerHub, 48)
local hubStroke = addStroke(centerHub, Color3.fromRGB(74, 222, 128), 2.0)
centerHub.Parent = wheelFrame

local chanceDisplay = Instance.new("TextLabel")
chanceDisplay.Size = UDim2.new(1, 0, 0, 24)
chanceDisplay.Position = UDim2.new(0, 0, 0, 16)
chanceDisplay.BackgroundTransparency = 1
chanceDisplay.Font = Enum.Font.GothamBlack
chanceDisplay.TextSize = 17
chanceDisplay.TextColor3 = Color3.fromRGB(74, 222, 128)
chanceDisplay.Text = "50.0%"
chanceDisplay.ZIndex = 13
chanceDisplay.Parent = centerHub

local multDisplay = Instance.new("TextLabel")
multDisplay.Size = UDim2.new(1, 0, 0, 16)
multDisplay.Position = UDim2.new(0, 0, 0, 42)
multDisplay.BackgroundTransparency = 1
multDisplay.Font = Enum.Font.GothamBold
multDisplay.TextSize = 11
multDisplay.TextColor3 = Color3.fromRGB(250, 204, 21)
multDisplay.Text = "2.00x МНОЖИТЕЛЬ"
multDisplay.ZIndex = 13
multDisplay.Parent = centerHub

local sectorDisplay = Instance.new("TextLabel")
sectorDisplay.Size = UDim2.new(1, 0, 0, 14)
sectorDisplay.Position = UDim2.new(0, 0, 0, 62)
sectorDisplay.BackgroundTransparency = 1
sectorDisplay.Font = Enum.Font.GothamMedium
sectorDisplay.TextSize = 8
sectorDisplay.TextColor3 = Color3.fromRGB(147, 197, 253)
sectorDisplay.Text = "ЗОНА ПОБЕДЫ: 0 - 180 град."
sectorDisplay.ZIndex = 13
sectorDisplay.Parent = centerHub

-- Presets Row
local presetRow = Instance.new("Frame")
presetRow.Size = UDim2.new(1, 0, 0, 28)
presetRow.Position = UDim2.new(0, 0, 0, 196)
presetRow.BackgroundTransparency = 1
presetRow.Parent = upgColCenter

local presetLayout = Instance.new("UIListLayout")
presetLayout.FillDirection = Enum.FillDirection.Horizontal
presetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
presetLayout.Padding = UDim.new(0, 6)
presetLayout.Parent = presetRow

-- Custom Chance Row
local customRow = Instance.new("Frame")
customRow.Size = UDim2.new(1, 0, 0, 32)
customRow.Position = UDim2.new(0, 0, 0, 230)
customRow.BackgroundTransparency = 1
customRow.Parent = upgColCenter

local customTitle = Instance.new("TextLabel")
customTitle.Size = UDim2.new(0, 85, 1, 0)
customTitle.BackgroundTransparency = 1
customTitle.Font = Enum.Font.GothamBold
customTitle.TextSize = 10
customTitle.TextColor3 = Color3.fromRGB(200, 205, 220)
customTitle.Text = "СВОЙ ШАНС:"
customTitle.TextXAlignment = Enum.TextXAlignment.Left
customTitle.Parent = customRow

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 38, 1, 0)
minusBtn.Position = UDim2.new(0, 88, 0, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
minusBtn.Font = Enum.Font.GothamBlack
minusBtn.TextSize = 12
minusBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
minusBtn.Text = "-5%"
addCorner(minusBtn, 6)
minusBtn.Parent = customRow

local customBox = Instance.new("TextBox")
customBox.Size = UDim2.new(0, 78, 1, 0)
customBox.Position = UDim2.new(0, 132, 0, 0)
customBox.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
customBox.Font = Enum.Font.GothamBlack
customBox.TextSize = 13
customBox.TextColor3 = Color3.fromRGB(74, 222, 128)
customBox.Text = "50.0"
addCorner(customBox, 6)
addStroke(customBox, Color3.fromRGB(45, 55, 78), 1)
customBox.Parent = customRow

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 38, 1, 0)
plusBtn.Position = UDim2.new(0, 216, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
plusBtn.Font = Enum.Font.GothamBlack
plusBtn.TextSize = 12
plusBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
plusBtn.Text = "+5%"
addCorner(plusBtn, 6)
plusBtn.Parent = customRow

-- Action Button and Result Message
local upgResultMsg = Instance.new("TextLabel")
upgResultMsg.Size = UDim2.new(1, 0, 0, 32)
upgResultMsg.Position = UDim2.new(0, 0, 0, 268)
upgResultMsg.BackgroundTransparency = 1
upgResultMsg.Font = Enum.Font.GothamBold
upgResultMsg.TextSize = 11
upgResultMsg.TextColor3 = Color3.fromRGB(180, 185, 200)
upgResultMsg.Text = "Зеленый сектор - ПОБЕДА! Красный сектор - СГОРАНИЕ."
upgResultMsg.TextWrapped = true
upgResultMsg.Parent = upgColCenter

local doUpgradeBtn = Instance.new("TextButton")
doUpgradeBtn.Size = UDim2.new(1, -20, 0, 46)
doUpgradeBtn.AnchorPoint = Vector2.new(0.5, 1)
doUpgradeBtn.Position = UDim2.new(0.5, 0, 1, -10)
doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
doUpgradeBtn.Font = Enum.Font.GothamBlack
doUpgradeBtn.TextSize = 15
doUpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
doUpgradeBtn.Text = "АПГРЕЙДИТЬ АУРУ"
addCorner(doUpgradeBtn, 10)
local doStroke = addStroke(doUpgradeBtn, Color3.fromRGB(251, 191, 36), 1.5)
doUpgradeBtn.Parent = upgColCenter

-- Column 3: BLOCK 2 - Target Aura Selection Catalog (Right)
local upgColRight = Instance.new("Frame")
upgColRight.Size = UDim2.new(0, 240, 1, -38)
upgColRight.Position = UDim2.new(1, -240, 0, 38)
upgColRight.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(upgColRight, 10)
addStroke(upgColRight, Color3.fromRGB(45, 55, 78), 1.2)
addPadding(upgColRight, 8, 8, 8, 8)
upgColRight.Parent = upgContent

local colRightTitle = Instance.new("TextLabel")
colRightTitle.Size = UDim2.new(1, 0, 0, 18)
colRightTitle.BackgroundTransparency = 1
colRightTitle.Font = Enum.Font.GothamBlack
colRightTitle.TextSize = 11
colRightTitle.TextColor3 = Color3.fromRGB(240, 243, 250)
colRightTitle.Text = "2. ЦЕЛЕВАЯ АУРА (ВЫБОР)"
colRightTitle.Parent = upgColRight

-- Target Preview Card
local targetPreviewFrame = Instance.new("Frame")
targetPreviewFrame.Size = UDim2.new(1, 0, 0, 68)
targetPreviewFrame.Position = UDim2.new(0, 0, 0, 22)
targetPreviewFrame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
addCorner(targetPreviewFrame, 8)
local tgtStroke = addStroke(targetPreviewFrame, Color3.fromRGB(245, 158, 11), 1.2)
targetPreviewFrame.Parent = upgColRight

local tgtEmblemHolder = Instance.new("Frame")
tgtEmblemHolder.Size = UDim2.new(0, 42, 0, 42)
tgtEmblemHolder.Position = UDim2.new(0, 8, 0.5, -21)
tgtEmblemHolder.BackgroundTransparency = 1
tgtEmblemHolder.Parent = targetPreviewFrame

local tgtNameLbl = Instance.new("TextLabel")
tgtNameLbl.Size = UDim2.new(1, -56, 0, 18)
tgtNameLbl.Position = UDim2.new(0, 52, 0, 8)
tgtNameLbl.BackgroundTransparency = 1
tgtNameLbl.Font = Enum.Font.GothamBlack
tgtNameLbl.TextSize = 12
tgtNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
tgtNameLbl.Text = "Любая аура из списка"
tgtNameLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtNameLbl.Parent = targetPreviewFrame

local tgtSubLbl = Instance.new("TextLabel")
tgtSubLbl.Size = UDim2.new(1, -56, 0, 16)
tgtSubLbl.Position = UDim2.new(0, 52, 0, 28)
tgtSubLbl.BackgroundTransparency = 1
tgtSubLbl.Font = Enum.Font.GothamMedium
tgtSubLbl.TextSize = 9
tgtSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
tgtSubLbl.Text = "Выберите желаемую ауру"
tgtSubLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtSubLbl.Parent = targetPreviewFrame

local tgtRarityLbl = Instance.new("TextLabel")
tgtRarityLbl.Size = UDim2.new(1, -56, 0, 14)
tgtRarityLbl.Position = UDim2.new(0, 52, 0, 46)
tgtRarityLbl.BackgroundTransparency = 1
tgtRarityLbl.Font = Enum.Font.GothamBold
tgtRarityLbl.TextSize = 9
tgtRarityLbl.TextColor3 = Color3.fromRGB(147, 197, 253)
tgtRarityLbl.Text = "Шанс рассчитается сам"
tgtRarityLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtRarityLbl.Parent = targetPreviewFrame

-- Target Catalog Scroll
local tgtScroll = Instance.new("ScrollingFrame")
tgtScroll.Size = UDim2.new(1, 0, 1, -100)
tgtScroll.Position = UDim2.new(0, 0, 0, 96)
tgtScroll.BackgroundTransparency = 1
tgtScroll.ScrollBarThickness = 4
tgtScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tgtScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tgtScroll.Parent = upgColRight

local tgtLayout = Instance.new("UIGridLayout")
tgtLayout.CellSize = UDim2.new(0, 68, 0, 80)
tgtLayout.CellPadding = UDim2.new(0, 6, 0, 6)
tgtLayout.Parent = tgtScroll

local function updateWheelDisplay()
	upgraderChance = math.clamp(math.floor(upgraderChance * 10) / 10, 1.0, 85.0)
	customBox.Text = string.format("%.1f", upgraderChance)
	chanceDisplay.Text = string.format("%.1f%%", upgraderChance)
	local mult = 100.0 / upgraderChance
	multDisplay.Text = string.format("%.2fx МНОЖИТЕЛЬ", mult)
	local winAngle = (upgraderChance / 100.0) * 360.0
	sectorDisplay.Text = string.format("ЗОНА ПОБЕДЫ: 0 - %d град.", math.floor(winAngle))

	-- Visually paint each sector bar on the wheel: GREEN for win zone, RED for loss zone!
	for _, item in ipairs(sectorBars) do
		if item.Angle < winAngle then
			item.Bar.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Vibrant Green WIN ZONE!
			item.Bar.BackgroundTransparency = 0.05
		else
			item.Bar.BackgroundColor3 = Color3.fromRGB(220, 38, 38) -- Crimson Red LOSE ZONE!
			item.Bar.BackgroundTransparency = 0.65
		end
	end
end

local function addUpgPreset(name, chanceVal)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 9
	btn.TextColor3 = Color3.fromRGB(147, 197, 253)
	btn.Text = name
	addCorner(btn, 5)
	btn.MouseButton1Click:Connect(function()
		SoundEffects.Play("Click")
		upgraderChance = chanceVal
		updateWheelDisplay()
	end)
	btn.Parent = presetRow
end

addUpgPreset("75%", 75.0)
addUpgPreset("50%", 50.0)
addUpgPreset("30%", 30.0)
addUpgPreset("2x", 48.0)
addUpgPreset("5x", 19.0)
addUpgPreset("10x", 9.0)

minusBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	upgraderChance = math.max(1.0, upgraderChance - 5.0)
	updateWheelDisplay()
end)

plusBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	upgraderChance = math.min(85.0, upgraderChance + 5.0)
	updateWheelDisplay()
end)

customBox.FocusLost:Connect(function()
	local num = tonumber(customBox.Text)
	if num then
		upgraderChance = num
		updateWheelDisplay()
	else
		customBox.Text = string.format("%.1f", upgraderChance)
	end
end)

local function refreshUpgraderUI()
	for _, ch in ipairs(srcScroll:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIGridLayout") then ch:Destroy() end
	end
	for _, ch in ipairs(tgtScroll:GetChildren()) do
		if ch:IsA("GuiObject") and not ch:IsA("UIGridLayout") then ch:Destroy() end
	end

	local hasAny = false
	for auraId, count in pairs(localData.Inventory or {}) do
		if count > 0 then
			local aura = AuraConfig.Auras[auraId]
			if aura then
				hasAny = true
				local card = Instance.new("TextButton")
				card.Size = UDim2.new(0, 68, 0, 80)
				card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
				card.Text = ""
				addCorner(card, 6)
				addStroke(card, aura.Color, 1.2)

				-- Procedural Guaranteed Aura Emblem
				createAuraEmblem(card, aura, 30, UDim2.new(0.5, -15, 0, 4))

				local sym = Instance.new("TextLabel")
				sym.Size = UDim2.new(0, 22, 0, 12)
				sym.Position = UDim2.new(1, -24, 0, 2)
				sym.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
				sym.Font = Enum.Font.GothamBlack
				sym.TextSize = 7
				sym.TextColor3 = aura.Color
				sym.Text = aura.Symbol or "AUR"
				addCorner(sym, 3)
				sym.Parent = card

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(1, -4, 0, 16)
				name.Position = UDim2.new(0, 2, 0, 38)
				name.BackgroundTransparency = 1
				name.Font = Enum.Font.GothamBold
				name.TextSize = 8
				name.TextColor3 = aura.Color
				name.Text = aura.Name
				name.TextWrapped = true
				name.Parent = card

				local cnt = Instance.new("TextLabel")
				cnt.Size = UDim2.new(0, 22, 0, 12)
				cnt.Position = UDim2.new(1, -24, 1, -14)
				cnt.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
				cnt.Font = Enum.Font.GothamBold
				cnt.TextSize = 7
				cnt.TextColor3 = Color3.fromRGB(220, 225, 240)
				cnt.Text = "x" .. tostring(count)
				addCorner(cnt, 3)
				cnt.Parent = card

				card.MouseButton1Click:Connect(function()
					SoundEffects.Play("Click")
					selectedSourceAuraId = auraId
					srcEmblemHolder:ClearAllChildren()
					createAuraEmblem(srcEmblemHolder, aura, 38, UDim2.new(0, 2, 0, 2))
					srcNameLbl.Text = aura.Name
					srcNameLbl.TextColor3 = aura.Color
					srcSubLbl.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
					local scrap = AuraConfig.GetScrapValue(aura.Rarity) * 2
					srcScrapLbl.Text = string.format("Возврат: +%d монет", scrap)
					srcStroke.Color = aura.Color

					if selectedTargetAuraId then
						local tgtAura = AuraConfig.Auras[selectedTargetAuraId]
						if tgtAura then
							local sR = math.max(aura.Rarity or 2, 2)
							local tR = math.max(tgtAura.Rarity or 10, 4)
							if sR >= tR then
								upgraderChance = 85.0
							else
								upgraderChance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
							end
							updateWheelDisplay()
						end
					end
				end)

				card.Parent = srcScroll
			end
		end
	end

	if not hasAny then
		srcNameLbl.Text = "Инвентарь пуст"
		srcSubLbl.Text = "Крутите роллы!"
	end

	for _, aura in ipairs(AuraConfig.RollableAuras) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(0, 68, 0, 80)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
		card.Text = ""
		addCorner(card, 6)
		addStroke(card, aura.Color, 1.2)

		createAuraEmblem(card, aura, 30, UDim2.new(0.5, -15, 0, 4))

		local sym = Instance.new("TextLabel")
		sym.Size = UDim2.new(0, 22, 0, 12)
		sym.Position = UDim2.new(1, -24, 0, 2)
		sym.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
		sym.Font = Enum.Font.GothamBlack
		sym.TextSize = 7
		sym.TextColor3 = aura.Color
		sym.Text = aura.Symbol or "AUR"
		addCorner(sym, 3)
		sym.Parent = card

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -4, 0, 16)
		name.Position = UDim2.new(0, 2, 0, 38)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBold
		name.TextSize = 8
		name.TextColor3 = aura.Color
		name.Text = aura.Name
		name.TextWrapped = true
		name.Parent = card

		local rar = Instance.new("TextLabel")
		rar.Size = UDim2.new(1, -4, 0, 12)
		rar.Position = UDim2.new(0, 2, 0, 56)
		rar.BackgroundTransparency = 1
		rar.Font = Enum.Font.GothamMedium
		rar.TextSize = 7
		rar.TextColor3 = Color3.fromRGB(156, 163, 175)
		rar.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
		rar.Parent = card

		card.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedTargetAuraId = aura.Id
			tgtEmblemHolder:ClearAllChildren()
			createAuraEmblem(tgtEmblemHolder, aura, 38, UDim2.new(0, 2, 0, 2))
			tgtNameLbl.Text = aura.Name
			tgtNameLbl.TextColor3 = aura.Color
			tgtSubLbl.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
			tgtRarityLbl.Text = aura.Tier:upper()
			tgtStroke.Color = aura.Color

			if selectedSourceAuraId then
				local srcAura = AuraConfig.Auras[selectedSourceAuraId]
				if srcAura then
					local sR = math.max(srcAura.Rarity or 2, 2)
					local tR = math.max(aura.Rarity or 10, 4)
					if sR >= tR then
						upgraderChance = 85.0
					else
						upgraderChance = math.clamp(math.floor((sR / tR) * 85 * 10) / 10, 1.0, 85.0)
					end
					updateWheelDisplay()
				end
			end
		end)

		card.Parent = tgtScroll
	end

	updateWheelDisplay()
end

doUpgradeBtn.MouseButton1Click:Connect(function()
	if isWheelSpinning then return end

	local sourceId = selectedSourceAuraId or localData.EquippedAura
	if not sourceId or sourceId == "None" or not localData.Inventory[sourceId] or localData.Inventory[sourceId] <= 0 then
		upgResultMsg.Text = "Выберите ауру слева из инвентаря для ставки!"
		upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
		return
	end

	isWheelSpinning = true
	doUpgradeBtn.Text = "ВРАЩЕНИЕ КОЛЕСА..."
	doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
	SoundEffects.Play("Spin")

	local res = UpgradeAuraFunc:InvokeServer(sourceId, selectedTargetAuraId, upgraderChance, "Custom", upgraderChance)

	if res and res.Success then
		local startRot = needleContainer.Rotation % 360
		local targetAngle = (res.Roll / 100.0) * 360
		local spins = isUpgraderFast and 1 or 5
		local endRot = startRot + (spins * 360) + targetAngle
		local duration = isUpgraderFast and 0.6 or 3.2

		TweenService:Create(needleContainer, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Rotation = endRot
		}):Play()

		task.spawn(function()
			local tickInterval = isUpgraderFast and 0.05 or 0.08
			local steps = math.floor(duration / tickInterval)
			for _ = 1, steps do
				task.wait(tickInterval)
				SoundEffects.Play("Tick")
			end
		end)

		task.wait(duration)

		if res.Won then
			SoundEffects.Play("RevealMythic")
			hubStroke.Color = Color3.fromRGB(16, 185, 129)
			upgResultMsg.Text = string.format("ПОБЕДА! Вы получили: %s (+%d монет)!", res.TargetAura.Name:upper(), res.Jackpot or 1500)
			upgResultMsg.TextColor3 = Color3.fromRGB(74, 222, 128)
		else
			SoundEffects.Play("Coin")
			hubStroke.Color = Color3.fromRGB(239, 68, 68)
			upgResultMsg.Text = string.format("НЕУДАЧА! Аура сгорела (компенсация: +%d монет).", res.Scrap or 100)
			upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
		end

		selectedSourceAuraId = nil
		refreshUpgraderUI()
		refreshInventoryUI()
	else
		upgResultMsg.Text = (res and res.Message) or "Ошибка апгрейда!"
		upgResultMsg.TextColor3 = Color3.fromRGB(248, 113, 113)
	end

	isWheelSpinning = false
	doUpgradeBtn.Text = "АПГРЕЙДИТЬ АУРУ"
	doUpgradeBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
end)

--------------------------------------------------------------------------------
-- 10. PVP DUEL ARENA WINDOW & COMBAT HUD
--------------------------------------------------------------------------------

local pvpWindow, pvpContent = createModal("АРЕНА БАТЛОВ АУР", 620, 440)

local pvpPlayerList = Instance.new("ScrollingFrame")
pvpPlayerList.Size = UDim2.new(1, 0, 1, 0)
pvpPlayerList.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
pvpPlayerList.BackgroundTransparency = 0.4
pvpPlayerList.ScrollBarThickness = 5
addCorner(pvpPlayerList, 8)
pvpPlayerList.Parent = pvpContent

local pvpListLayout = Instance.new("UIListLayout")
pvpListLayout.Padding = UDim.new(0, 8)
pvpListLayout.Parent = pvpPlayerList
addPadding(pvpPlayerList, 8, 8, 8, 8)

local function refreshPvPWindow()
	for _, child in ipairs(pvpPlayerList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 54)
			row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			addCorner(row, 8)
			addStroke(row, Color3.fromRGB(45, 52, 70), 1)

			local pName = Instance.new("TextLabel")
			pName.Size = UDim2.new(0.6, 0, 1, 0)
			pName.Position = UDim2.new(0, 14, 0, 0)
			pName.BackgroundTransparency = 1
			pName.Font = Enum.Font.GothamBlack
			pName.TextSize = 14
			pName.TextColor3 = Color3.fromRGB(240, 243, 250)
			pName.TextXAlignment = Enum.TextXAlignment.Left
			pName.Text = p.DisplayName or p.Name
			pName.Parent = row

			local challengeBtn = Instance.new("TextButton")
			challengeBtn.Size = UDim2.new(0, 160, 0, 36)
			challengeBtn.Position = UDim2.new(1, -170, 0.5, -18)
			challengeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
			challengeBtn.Font = Enum.Font.GothamBlack
			challengeBtn.TextSize = 12
			challengeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			challengeBtn.Text = "ВЫЗВАТЬ НА БОЙ"
			addCorner(challengeBtn, 8)
			challengeBtn.Parent = row

			challengeBtn.MouseButton1Click:Connect(function()
				SoundEffects.Play("Click")
				PvPChallengeFunc:InvokeServer(p.Name)
				challengeBtn.Text = "ВЫЗОВ ОТПРАВЛЕН!"
				challengeBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 100)
			end)

			row.Parent = pvpPlayerList
		end
	end

	pvpPlayerList.CanvasSize = UDim2.new(0, 0, 0, pvpListLayout.AbsoluteContentSize.Y + 20)
end

-- Active Battle Combat HUD (Health bars & 3 Skill Buttons)
local battleHud = Instance.new("Frame")
battleHud.Name = "PvPBattleHUD"
battleHud.Size = UDim2.new(1, 0, 1, 0)
battleHud.BackgroundTransparency = 1
battleHud.Visible = false
battleHud.Parent = screenGui

-- Top Battle Health Bars
local hpContainer = Instance.new("Frame")
hpContainer.AnchorPoint = Vector2.new(0.5, 0)
hpContainer.Position = UDim2.new(0.5, 0, 0, 68)
hpContainer.Size = UDim2.new(0, 520, 0, 48)
hpContainer.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
hpContainer.BackgroundTransparency = 0.2
addCorner(hpContainer, 12)
addStroke(hpContainer, Color3.fromRGB(239, 68, 68), 1.5)
addPadding(hpContainer, 6, 6, 12, 12)
hpContainer.Parent = battleHud

local myHpBar = Instance.new("Frame")
myHpBar.Size = UDim2.new(0.48, 0, 0, 18)
myHpBar.Position = UDim2.new(0, 0, 0, 18)
myHpBar.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
addCorner(myHpBar, 6)
myHpBar.Parent = hpContainer

local myHpFill = Instance.new("Frame")
myHpFill.Size = UDim2.new(1, 0, 1, 0)
myHpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
addCorner(myHpFill, 6)
myHpFill.Parent = myHpBar

local myHpLabel = Instance.new("TextLabel")
myHpLabel.Size = UDim2.new(0.48, 0, 0, 16)
myHpLabel.Position = UDim2.new(0, 0, 0, 0)
myHpLabel.BackgroundTransparency = 1
myHpLabel.Font = Enum.Font.GothamBlack
myHpLabel.TextSize = 11
myHpLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
myHpLabel.TextXAlignment = Enum.TextXAlignment.Left
myHpLabel.Text = "ВЫ: 1000 / 1000 HP"
myHpLabel.Parent = hpContainer

local opHpBar = Instance.new("Frame")
opHpBar.Size = UDim2.new(0.48, 0, 0, 18)
opHpBar.Position = UDim2.new(0.52, 0, 0, 18)
opHpBar.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
addCorner(opHpBar, 6)
opHpBar.Parent = hpContainer

local opHpFill = Instance.new("Frame")
opHpFill.Size = UDim2.new(1, 0, 1, 0)
opHpFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
addCorner(opHpFill, 6)
opHpFill.Parent = opHpBar

local opHpLabel = Instance.new("TextLabel")
opHpLabel.Size = UDim2.new(0.48, 0, 0, 16)
opHpLabel.Position = UDim2.new(0.52, 0, 0, 0)
opHpLabel.BackgroundTransparency = 1
opHpLabel.Font = Enum.Font.GothamBlack
opHpLabel.TextSize = 11
opHpLabel.TextColor3 = Color3.fromRGB(248, 113, 113)
opHpLabel.TextXAlignment = Enum.TextXAlignment.Right
opHpLabel.Text = "ВРАГ: 1000 / 1000 HP"
opHpLabel.Parent = hpContainer

-- Bottom 3 Combat Skills Bar
local skillsBar = Instance.new("Frame")
skillsBar.AnchorPoint = Vector2.new(0.5, 1)
skillsBar.Position = UDim2.new(0.5, 0, 1, -125)
skillsBar.Size = UDim2.new(0, 480, 0, 52)
skillsBar.BackgroundTransparency = 1
skillsBar.Parent = battleHud

local skillLayout = Instance.new("UIListLayout")
skillLayout.FillDirection = Enum.FillDirection.Horizontal
skillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skillLayout.Padding = UDim.new(0, 12)
skillLayout.Parent = skillsBar

local function createSkillButton(index, iconAsset, name, cdTime, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 145, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	btn.Text = ""
	addCorner(btn, 10)
	local strk = addStroke(btn, color, 1.5)

	local iconImg = Instance.new("ImageLabel")
	iconImg.Size = UDim2.new(0, 22, 0, 22)
	iconImg.Position = UDim2.new(0, 8, 0.5, -11)
	iconImg.BackgroundTransparency = 1
	iconImg.Image = iconAsset
	iconImg.ImageColor3 = color
	iconImg.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -36, 1, 0)
	lbl.Position = UDim2.new(0, 34, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 11
	lbl.TextColor3 = color
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local now = os.clock()
		if (now - (skillCooldowns[index] or 0)) >= cdTime then
			skillCooldowns[index] = now
			SoundEffects.Play("Click")
			PvPUseSkillFunc:InvokeServer(index)

			btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
			task.delay(cdTime, function()
				btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			end)
		end
	end)

	btn.Parent = skillsBar
	return btn
end

createSkillButton(1, "rbxasset://textures/ui/InspectMenu/ico_equipped.png", "[1] УДАР АУРЫ", 1.2, Color3.fromRGB(56, 189, 248))
createSkillButton(2, "rbxasset://textures/particles/fire_main.dds", "[2] ВЗРЫВ СТИХИИ", 3.5, Color3.fromRGB(245, 158, 11))
createSkillButton(3, "rbxasset://textures/particles/sparkles_main.dds", "[3] УЛЬТИМЕЙТ", 7.0, Color3.fromRGB(250, 204, 21))

-- Incoming Duel Challenge Popup
local challengePopup = Instance.new("Frame")
challengePopup.AnchorPoint = Vector2.new(0.5, 0)
challengePopup.Position = UDim2.new(0.5, 0, 0, 70)
challengePopup.Size = UDim2.new(0, 380, 0, 90)
challengePopup.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
challengePopup.Visible = false
addCorner(challengePopup, 12)
addStroke(challengePopup, Color3.fromRGB(239, 68, 68), 2)
addPadding(challengePopup, 8, 8, 12, 12)
challengePopup.Parent = screenGui

local chText = Instance.new("TextLabel")
chText.Size = UDim2.new(1, 0, 0, 24)
chText.BackgroundTransparency = 1
chText.Font = Enum.Font.GothamBlack
chText.TextSize = 13
chText.TextColor3 = Color3.fromRGB(255, 235, 120)
chText.Text = "Игрок вызывает вас на Дуэль Аур!"
chText.Parent = challengePopup

local currentChallengerName = ""

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0.48, 0, 0, 36)
acceptBtn.Position = UDim2.new(0, 0, 1, -36)
acceptBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
acceptBtn.Font = Enum.Font.GothamBlack
acceptBtn.TextSize = 12
acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptBtn.Text = "ПРИНЯТЬ"
addCorner(acceptBtn, 8)
acceptBtn.Parent = challengePopup

local declineBtn = Instance.new("TextButton")
declineBtn.Size = UDim2.new(0.48, 0, 0, 36)
declineBtn.Position = UDim2.new(0.52, 0, 1, -36)
declineBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
declineBtn.Font = Enum.Font.GothamBlack
declineBtn.TextSize = 12
declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
declineBtn.Text = "[X] ОТКЛОНИТЬ"
addCorner(declineBtn, 8)
declineBtn.Parent = challengePopup

PvPResponseEvent.OnClientEvent:Connect(function(info)
	currentChallengerName = info.Challenger
	chText.Text = string.format("%s вызывает вас на Дуэль!", info.ChallengerDisplay or info.Challenger)
	challengePopup.Visible = true
	SoundEffects.Play("RevealRare")
end)

acceptBtn.MouseButton1Click:Connect(function()
	challengePopup.Visible = false
	PvPResponseEvent:FireServer(currentChallengerName, true)
end)

declineBtn.MouseButton1Click:Connect(function()
	challengePopup.Visible = false
	PvPResponseEvent:FireServer(currentChallengerName, false)
end)

PvPStateEvent.OnClientEvent:Connect(function(state)
	if state.InBattle then
		battleHud.Visible = true
		myHpLabel.Text = string.format("ВЫ: %d / %d HP", state.MyHp, state.MyMaxHp)
		opHpLabel.Text = string.format("ВРАГ: %d / %d HP", state.OpHp, state.OpMaxHp)
		myHpFill.Size = UDim2.new(math.clamp(state.MyHp / state.MyMaxHp, 0, 1), 0, 1, 0)
		opHpFill.Size = UDim2.new(math.clamp(state.OpHp / state.OpMaxHp, 0, 1), 0, 1, 0)
	else
		battleHud.Visible = false
		if state.Won then
			SoundEffects.Play("RevealGodly")
		else
			SoundEffects.Play("Click")
		end
	end
end)

PvPVFXEvent.OnClientEvent:Connect(function(info)
	local caster = Players:FindFirstChild(info.Caster)
	local target = Players:FindFirstChild(info.Target)
	local cChar = caster and caster.Character
	local tChar = target and target.Character

	if info.SkillIndex == 1 then
		AuraVisuals.PlaySkill1VFX(cChar, tChar, info.Color)
		SoundEffects.Play("Click")
	elseif info.SkillIndex == 2 then
		AuraVisuals.PlaySkill2VFX(tChar, info.Color)
		SoundEffects.Play("RevealRare")
	elseif info.SkillIndex == 3 then
		AuraVisuals.PlaySkill3VFX(tChar, info.Color)
		SoundEffects.Play("RevealGodly")
	end

	if tChar then
		AuraVisuals.ShowDamageNumber(tChar, info.Damage, info.IsCrit, info.Color)
	end
end)

--------------------------------------------------------------------------------
-- 11. CRAFTING ALCHEMIST FORGE
--------------------------------------------------------------------------------

local craftWindow, craftContent = createModal("КУЗНИЦА КРАФТА АУР", 720, 500)

local recipeScroll = Instance.new("ScrollingFrame")
recipeScroll.Size = UDim2.new(0, 240, 1, 0)
recipeScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
recipeScroll.BackgroundTransparency = 0.4
recipeScroll.ScrollBarThickness = 4
addCorner(recipeScroll, 8)
recipeScroll.Parent = craftContent

local recLayout = Instance.new("UIListLayout")
recLayout.Padding = UDim.new(0, 8)
recLayout.Parent = recipeScroll
addPadding(recipeScroll, 6, 6, 6, 6)

local craftDetail = Instance.new("Frame")
craftDetail.Size = UDim2.new(1, -255, 1, 0)
craftDetail.Position = UDim2.new(0, 255, 0, 0)
craftDetail.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
addCorner(craftDetail, 8)
addStroke(craftDetail, Color3.fromRGB(42, 50, 70), 1)
addPadding(craftDetail, 12, 12, 12, 12)
craftDetail.Parent = craftContent

local craftTitle = Instance.new("TextLabel")
craftTitle.Size = UDim2.new(1, 0, 0, 28)
craftTitle.BackgroundTransparency = 1
craftTitle.Font = Enum.Font.GothamBlack
craftTitle.TextSize = 18
craftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
craftTitle.Text = "Выберите Рецепт"
craftTitle.Parent = craftDetail

local craftDesc = Instance.new("TextLabel")
craftDesc.Size = UDim2.new(1, 0, 0, 44)
craftDesc.Position = UDim2.new(0, 0, 0, 32)
craftDesc.BackgroundTransparency = 1
craftDesc.Font = Enum.Font.Gotham
craftDesc.TextSize = 12
craftDesc.TextColor3 = Color3.fromRGB(180, 185, 200)
craftDesc.TextWrapped = true
craftDesc.Text = "Объединяйте ауры для создания богоподобных аур, рукавиц удачи и зелий!"
craftDesc.Parent = craftDetail

local ingHeader = Instance.new("TextLabel")
ingHeader.Size = UDim2.new(1, 0, 0, 20)
ingHeader.Position = UDim2.new(0, 0, 0, 82)
ingHeader.BackgroundTransparency = 1
ingHeader.Font = Enum.Font.GothamBold
ingHeader.TextSize = 12
ingHeader.TextColor3 = Color3.fromRGB(156, 163, 175)
ingHeader.Text = "ТРЕБУЕМЫЕ ИНГРЕДИЕНТЫ:"
ingHeader.TextXAlignment = Enum.TextXAlignment.Left
ingHeader.Parent = craftDetail

local ingListFrame = Instance.new("Frame")
ingListFrame.Size = UDim2.new(1, 0, 0, 180)
ingListFrame.Position = UDim2.new(0, 0, 0, 106)
ingListFrame.BackgroundTransparency = 1
ingListFrame.Parent = craftDetail

local ingLayout = Instance.new("UIListLayout")
ingLayout.Padding = UDim.new(0, 6)
ingLayout.Parent = ingListFrame

local forgeBtn = Instance.new("TextButton")
forgeBtn.Size = UDim2.new(1, 0, 0, 46)
forgeBtn.Position = UDim2.new(0, 0, 1, -48)
forgeBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
forgeBtn.Font = Enum.Font.GothamBlack
forgeBtn.TextSize = 16
forgeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
forgeBtn.Text = "КОВАТЬ РЕЦЕПТ"
forgeBtn.Visible = false
addCorner(forgeBtn, 10)
forgeBtn.Parent = craftDetail

local function refreshCraftingUI()
	for _, child in ipairs(recipeScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, recipe in ipairs(AuraConfig.Recipes) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 54)
		btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		btn.Text = ""
		addCorner(btn, 8)
		addStroke(btn, recipe.Color, 1.2)

		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, -12, 0, 22)
		t.Position = UDim2.new(0, 8, 0, 6)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBold
		t.TextSize = 13
		t.TextColor3 = recipe.Color
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Text = recipe.Name
		t.Parent = btn

		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -12, 0, 16)
		sub.Position = UDim2.new(0, 8, 0, 28)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 11
		sub.TextColor3 = Color3.fromRGB(156, 163, 175)
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = string.format("Тип: %s", recipe.ResultType)
		sub.Parent = btn

		btn.MouseButton1Click:Connect(function()
			SoundEffects.Play("Click")
			selectedCraftRecipe = recipe
			craftTitle.Text = recipe.Name
			craftTitle.TextColor3 = recipe.Color
			craftDesc.Text = recipe.Description

			for _, c in ipairs(ingListFrame:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() end
			end

			local canCraftAll = true
			for _, ing in ipairs(recipe.Ingredients) do
				local owned = localData.Inventory[ing.AuraId] or 0
				local auraData = AuraConfig.Auras[ing.AuraId]
				local auraName = auraData and auraData.Name or ing.AuraId
				local auraColor = auraData and auraData.Color or Color3.fromRGB(220, 225, 240)

				local row = Instance.new("Frame")
				row.Size = UDim2.new(1, 0, 0, 34)
				row.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
				addCorner(row, 6)
				row.Parent = ingListFrame

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.65, 0, 1, 0)
				nameLbl.Position = UDim2.new(0, 10, 0, 0)
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
					countLbl.Text = string.format(" %d / %d", owned, ing.Count)
				else
					countLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
					countLbl.Text = string.format("[X] %d / %d", owned, ing.Count)
					canCraftAll = false
				end
				countLbl.Parent = row
			end

			forgeBtn.Visible = true
			if canCraftAll then
				forgeBtn.Text = " КОВАТЬ СЕЙЧАС"
				forgeBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
			else
				forgeBtn.Text = "Не хватает аур"
				forgeBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
			end
		end)

		btn.Parent = recipeScroll
	end

	recipeScroll.CanvasSize = UDim2.new(0, 0, 0, recLayout.AbsoluteContentSize.Y + 20)
end

forgeBtn.MouseButton1Click:Connect(function()
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
-- 12. MULTI-CATEGORY DONATION SHOP
--------------------------------------------------------------------------------

local shopWindow, shopContent = createModal(" МАГАЗИН ДОНАТА И ПАССОВ (АКЦИИ -80%)", 740, 520)

toggleShopModal = function()
	toggleModal(shopWindow)
	refreshShopUI()
end

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, 0)
shopScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
shopScroll.BackgroundTransparency = 0.4
shopScroll.ScrollBarThickness = 5
shopScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
addCorner(shopScroll, 8)
shopScroll.Parent = shopContent

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.Parent = shopScroll
addPadding(shopScroll, 8, 8, 8, 8)

local donateCatalog = {
	{
		Category = "ГЕЙМПАССЫ НАВСЕГДА",
		Items = {
			{
				Id = "X2Luck",
				Badge = " ХИТ",
				Name = " x2 Luck Pass (Навсегда)",
				Color = Color3.fromRGB(74, 222, 128),
				Desc = "Удваивает шанс выпадения всех редких, мифических и богоподобных аур навсегда!",
				Price = "R$ 199",
				Type = "Perk",
				PerkKey = "X2Luck",
			},
			{
				Id = "X3Luck",
				Badge = " СВЕРХУДАЧА",
				Name = " x3 Luck Overload (Навсегда)",
				Color = Color3.fromRGB(16, 185, 129),
				Desc = "Тройной шанс на все ауры! Стакается со всеми другими бонусами!",
				Price = "R$ 499",
				Type = "Perk",
				PerkKey = "X3Luck",
			},
			{
				Id = "AutoRoll",
				Badge = " АВТО-РОЛЛ",
				Name = " Auto Roll Pass (Навсегда)",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Автоматический ролл в фоне пока вы общаетесь, гуляете или стоите AFK!",
				Price = "R$ 99",
				Type = "Perk",
				PerkKey = "AutoRoll",
			},
			{
				Id = "ExtraStorage",
				Badge = " +50 СЛОТОВ",
				Name = " Aura Storage (+50)",
				Color = Color3.fromRGB(56, 189, 248),
				Desc = "Расширяет ваш инвентарь на +50 дополнительных слотов для редких аур!",
				Price = "R$ 149",
				Type = "Perk",
				PerkKey = "ExtraStorage",
			},
			{
				Id = "VIP",
				Badge = " VIP КЛУБ",
				Name = " VIP Supporter Pass",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Аура VIP Crown + x1.5 Удача + Золотой титул VIP над головой и в чате!",
				Price = "R$ 299",
				Type = "Perk",
				PerkKey = "VIP",
			},
			{
				Id = "FastRoll",
				Badge = " БЫСТРЫЙ РОЛЛ",
				Name = " Fast Roll Instant Pass",
				Color = Color3.fromRGB(236, 72, 153),
				Desc = "Моментальное раскрытие роллов без ожидания рулетки!",
				Price = "R$ 79",
				Type = "Perk",
				PerkKey = "FastRoll",
			},
		}
	},
	{
		Category = "МЕГА-БУСТЫ И ЗЕЛЬЯ",
		Items = {
			{
				Id = "MegaPotion",
				Badge = " 5x LUCK",
				Name = " Мега-Зелье Удачи x5 (15 мин)",
				Color = Color3.fromRGB(6, 182, 212),
				Desc = "Дает бешеное пятикратное (5x) увеличение шансов на 15 минут!",
				Price = "R$ 129",
				Type = "Product",
				ProductKey = "MegaPotion",
			},
		}
	},
	{
		Category = "ПАКЕТЫ МОНЕТ",
		Items = {
			{
				Id = "Coins10k",
				Badge = " 10K",
				Name = " 10,000 Монет",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Стартовый запас монет для крафта и улучшений.",
				Price = "R$ 49",
				Type = "Product",
				ProductKey = "CoinPack10k",
			},
			{
				Id = "Coins50k",
				Badge = " ХИТ",
				Name = " 50,000 Монет",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Большой мешок золота для покупки слотов и расходников!",
				Price = "R$ 149",
				Type = "Product",
				ProductKey = "CoinPack50k",
			},
			{
				Id = "Coins250k",
				Badge = " БОГАТСТВО",
				Name = " 250,000 Монет",
				Color = Color3.fromRGB(251, 191, 36),
				Desc = "Сундук с золотом - никогда больше не беспокойтесь о монетах!",
				Price = "R$ 399",
				Type = "Product",
				ProductKey = "CoinPack250k",
			},
		}
	},
	{
		Category = "МГНОВЕННЫЙ ВЫБИВ АУР",
		Items = {
			{
				Id = "InstantLegendary",
				Badge = " 1/1,000+",
				Name = " Гарантированная Легендарная Аура",
				Color = Color3.fromRGB(239, 68, 68),
				Desc = "Мгновенно начисляет случайную Легендарную ауру (Ruby, Undead, Solar)!",
				Price = "R$ 199",
				Type = "Product",
				ProductKey = "InstantLegendary",
			},
			{
				Id = "InstantMythic",
				Badge = " 1/10,000+",
				Name = " Гарантированная Мифическая Аура",
				Color = Color3.fromRGB(168, 85, 247),
				Desc = "Мгновенно начисляет случайную Мифическую ауру (Lunar, Poseidon, Hades, Galaxy)!",
				Price = "R$ 499",
				Type = "Product",
				ProductKey = "InstantMythic",
			},
		}
	},
}

local function refreshShopUI()
	for _, child in ipairs(shopScroll:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
	end

	for _, cat in ipairs(donateCatalog) do
		local catHeader = Instance.new("TextLabel")
		catHeader.Size = UDim2.new(1, 0, 0, 24)
		catHeader.BackgroundTransparency = 1
		catHeader.Font = Enum.Font.GothamBlack
		catHeader.TextSize = 13
		catHeader.TextColor3 = Color3.fromRGB(250, 204, 21)
		catHeader.TextXAlignment = Enum.TextXAlignment.Left
		catHeader.Text = " " .. cat.Category
		catHeader.Parent = shopScroll

		for _, item in ipairs(cat.Items) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 84)
			row.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
			addCorner(row, 8)
			addStroke(row, item.Color, 1.2)
			addPadding(row, 8, 8, 12, 12)

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(0.65, 0, 0, 22)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Font = Enum.Font.GothamBlack
			nameLbl.TextSize = 15
			nameLbl.TextColor3 = item.Color
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.Text = string.format("%s [%s]", item.Name, item.Badge)
			nameLbl.Parent = row

			local descLbl = Instance.new("TextLabel")
			descLbl.Size = UDim2.new(0.65, 0, 0, 38)
			descLbl.Position = UDim2.new(0, 0, 0, 24)
			descLbl.BackgroundTransparency = 1
			descLbl.Font = Enum.Font.Gotham
			descLbl.TextSize = 12
			descLbl.TextColor3 = Color3.fromRGB(180, 185, 200)
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.TextWrapped = true
			descLbl.Text = item.Desc
			descLbl.Parent = row

			local testBtn = Instance.new("TextButton")
			testBtn.Size = UDim2.new(0, 180, 0, 42)
			testBtn.Position = UDim2.new(1, -180, 0.5, -21)
			testBtn.Font = Enum.Font.GothamBold
			testBtn.TextSize = 11
			addCorner(testBtn, 8)

			if item.Type == "Perk" then
				local isOwned = (localData.Gamepasses and localData.Gamepasses[item.PerkKey])
					or (localData.TestPerks and localData.TestPerks[item.PerkKey])

				if isOwned then
					testBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
					testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					testBtn.Text = "АКТИВЕН (ТЕСТ ВКЛ)"
				else
					testBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
					testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					testBtn.Text = string.format("КУПИТЬ %s (ТЕСТ)", item.Price)
				end

				testBtn.MouseButton1Click:Connect(function()
					SoundEffects.Play("Click")
					testBtn.Text = "ОБНОВЛЕНИЕ..."
					ToggleTestPerkEvent:FireServer(item.PerkKey)
					task.delay(0.2, function()
						if shopWindow.Visible then refreshShopUI() end
					end)
				end)
			else
				testBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
				testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				testBtn.Text = string.format("КУПИТЬ %s (ТЕСТ)", item.Price)

				testBtn.MouseButton1Click:Connect(function()
					SoundEffects.Play("Coin")
					testBtn.Text = "ПОКУПКА..."
					local res = PurchaseProductFunc:InvokeServer(item.ProductKey)
					if res and res.Success then
						SoundEffects.Play("RevealMythic")
					end
					task.delay(0.2, function()
						if shopWindow.Visible then refreshShopUI() end
					end)
				end)
			end

			testBtn.Parent = row
			row.Parent = shopScroll
		end
	end

	shopScroll.CanvasSize = UDim2.new(0, 0, 0, shopLayout.AbsoluteContentSize.Y + 24)
end

--------------------------------------------------------------------------------
-- 13. SETTINGS WINDOW
--------------------------------------------------------------------------------

local setWindow, setContent = createModal(" НАСТРОЙКИ", 460, 260)

local setFastBtn = Instance.new("TextButton")
setFastBtn.Size = UDim2.new(1, 0, 0, 44)
setFastBtn.Position = UDim2.new(0, 0, 0, 10)
setFastBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setFastBtn.Font = Enum.Font.GothamBold
setFastBtn.TextSize = 14
setFastBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
addCorner(setFastBtn, 8)
addStroke(setFastBtn, Color3.fromRGB(45, 55, 75), 1)
setFastBtn.Parent = setContent

local setSoundBtn = Instance.new("TextButton")
setSoundBtn.Size = UDim2.new(1, 0, 0, 44)
setSoundBtn.Position = UDim2.new(0, 0, 0, 64)
setSoundBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setSoundBtn.Font = Enum.Font.GothamBold
setSoundBtn.TextSize = 14
setSoundBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
setSoundBtn.Text = " Звуки Игры: ВКЛ (Мягкие)"
addCorner(setSoundBtn, 8)
addStroke(setSoundBtn, Color3.fromRGB(45, 55, 75), 1)
setSoundBtn.Parent = setContent

local setInfo = Instance.new("TextLabel")
setInfo.Size = UDim2.new(1, 0, 0, 44)
setInfo.Position = UDim2.new(0, 0, 0, 120)
setInfo.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
setInfo.Font = Enum.Font.GothamMedium
setInfo.TextSize = 13
setInfo.TextColor3 = Color3.fromRGB(180, 185, 200)
setInfo.Text = "Авто-продажу и экипировку можно настроить в Инвентаре."
addCorner(setInfo, 8)
setInfo.Parent = setContent

setFastBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВКЛ"
		fastRollBtn.Text = " FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
		fastRollBtn.Text = " FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
	end
end)

setSoundBtn.MouseButton1Click:Connect(function()
	local isMuted = SoundEffects.ToggleMute()
	if isMuted then
		setSoundBtn.Text = " Звуки Игры: ВЫКЛЮЧЕНЫ"
		setSoundBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
	else
		setSoundBtn.Text = " Звуки Игры: ВКЛ (Мягкие)"
		setSoundBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		SoundEffects.Play("Click")
	end
end)

--------------------------------------------------------------------------------
-- 14. CS2-STYLE DYNAMIC HORIZONTAL CASE OPENING ROULETTE (WITH ITEM ICONS)
--------------------------------------------------------------------------------

local rouletteContainer = Instance.new("Frame")
rouletteContainer.Name = "CS2RouletteContainer"
rouletteContainer.AnchorPoint = Vector2.new(0.5, 0.5)
rouletteContainer.Position = UDim2.new(0.5, 0, 0.45, 0)
rouletteContainer.Size = UDim2.new(0.9, 0, 0, 170)
rouletteContainer.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
rouletteContainer.BackgroundTransparency = 0.05
rouletteContainer.ClipsDescendants = true
rouletteContainer.Visible = false
addCorner(rouletteContainer, 16)
local rStroke = addStroke(rouletteContainer, Color3.fromRGB(245, 158, 11), 2.5)
rouletteContainer.Parent = screenGui

local rSizeConstraint = Instance.new("UISizeConstraint")
rSizeConstraint.MaxSize = Vector2.new(880, 180)
rSizeConstraint.MinSize = Vector2.new(340, 150)
rSizeConstraint.Parent = rouletteContainer

local rouletteTape = Instance.new("Frame")
rouletteTape.Name = "Tape"
rouletteTape.Size = UDim2.new(0, 10000, 1, 0)
rouletteTape.Position = UDim2.new(0, 0, 0, 0)
rouletteTape.BackgroundTransparency = 1
rouletteTape.Parent = rouletteContainer

local needleLine = Instance.new("Frame")
needleLine.Name = "Needle"
needleLine.AnchorPoint = Vector2.new(0.5, 0)
needleLine.Position = UDim2.new(0.5, 0, 0, 0)
needleLine.Size = UDim2.new(0, 4, 1, 0)
needleLine.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleLine.ZIndex = 10
needleLine.Parent = rouletteContainer

local needleTop = Instance.new("Frame")
needleTop.AnchorPoint = Vector2.new(0.5, 0)
needleTop.Position = UDim2.new(0.5, 0, 0, 0)
needleTop.Size = UDim2.new(0, 18, 0, 14)
needleTop.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleTop.ZIndex = 11
addCorner(needleTop, 4)
needleTop.Parent = rouletteContainer

local needleBottom = Instance.new("Frame")
needleBottom.AnchorPoint = Vector2.new(0.5, 1)
needleBottom.Position = UDim2.new(0.5, 0, 1, 0)
needleBottom.Size = UDim2.new(0, 18, 0, 14)
needleBottom.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
needleBottom.ZIndex = 11
addCorner(needleBottom, 4)
needleBottom.Parent = rouletteContainer

--------------------------------------------------------------------------------
-- 15. REVEAL POPUP WITH EXPLICIT EQUIP & SELL BUTTONS + ITEM ICON
--------------------------------------------------------------------------------

local cutsceneOverlay = Instance.new("Frame")
cutsceneOverlay.Name = "CutsceneOverlay"
cutsceneOverlay.Size = UDim2.new(1, 0, 1, 0)
cutsceneOverlay.BackgroundColor3 = Color3.fromRGB(4, 5, 8)
cutsceneOverlay.BackgroundTransparency = 0.25
cutsceneOverlay.Visible = false
cutsceneOverlay.Parent = screenGui

local revealCard = Instance.new("Frame")
revealCard.Name = "RevealCard"
revealCard.AnchorPoint = Vector2.new(0.5, 0.5)
revealCard.Position = UDim2.new(0.5, 0, 0.5, 0)
revealCard.Size = UDim2.new(0, 420, 0, 480)
revealCard.BackgroundColor3 = Color3.fromRGB(14, 17, 26)
addCorner(revealCard, 18)
local cardStroke = addStroke(revealCard, Color3.fromRGB(255, 255, 255), 3)
addPadding(revealCard, 18, 18, 22, 22)
revealCard.Parent = cutsceneOverlay

local cardHeaderTitle = Instance.new("TextLabel")
cardHeaderTitle.Size = UDim2.new(1, 0, 0, 20)
cardHeaderTitle.BackgroundTransparency = 1
cardHeaderTitle.Font = Enum.Font.GothamBlack
cardHeaderTitle.TextSize = 13
cardHeaderTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
cardHeaderTitle.Text = " ВЫ ВЫБИЛИ НОВУЮ АУРУ!"
cardHeaderTitle.Parent = revealCard

-- Item Icon in Reveal Card!
local revealEmblemHolder = Instance.new("Frame")
revealEmblemHolder.Size = UDim2.new(0, 64, 0, 64)
revealEmblemHolder.Position = UDim2.new(0.5, -32, 0, 24)
revealEmblemHolder.BackgroundTransparency = 1
revealEmblemHolder.Parent = revealCard

local cardTierTag = Instance.new("TextLabel")
cardTierTag.Size = UDim2.new(1, 0, 0, 22)
cardTierTag.Position = UDim2.new(0, 0, 0, 92)
cardTierTag.BackgroundTransparency = 1
cardTierTag.Font = Enum.Font.GothamBlack
cardTierTag.TextSize = 13
cardTierTag.TextColor3 = Color3.fromRGB(156, 163, 175)
cardTierTag.Text = "[ TIER ]"
cardTierTag.Parent = revealCard

local cardName = Instance.new("TextLabel")
cardName.Size = UDim2.new(1, 0, 0, 42)
cardName.Position = UDim2.new(0, 0, 0, 114)
cardName.BackgroundTransparency = 1
cardName.Font = Enum.Font.GothamBlack
cardName.TextSize = 28
cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
cardName.Text = "Aura Name"
cardName.Parent = revealCard

local cardRarity = Instance.new("TextLabel")
cardRarity.Size = UDim2.new(1, 0, 0, 24)
cardRarity.Position = UDim2.new(0, 0, 0, 156)
cardRarity.BackgroundTransparency = 1
cardRarity.Font = Enum.Font.GothamBold
cardRarity.TextSize = 16
cardRarity.TextColor3 = Color3.fromRGB(240, 243, 250)
cardRarity.Text = "1 in 100,000"
cardRarity.Parent = revealCard

local cardDesc = Instance.new("TextLabel")
cardDesc.Size = UDim2.new(1, 0, 0, 80)
cardDesc.Position = UDim2.new(0, 0, 0, 184)
cardDesc.BackgroundTransparency = 1
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextSize = 12
cardDesc.TextColor3 = Color3.fromRGB(180, 185, 205)
cardDesc.TextWrapped = true
cardDesc.Text = "Aura lore description..."
cardDesc.Parent = revealCard

local cardEquipBtn = Instance.new("TextButton")
cardEquipBtn.Size = UDim2.new(1, 0, 0, 44)
cardEquipBtn.Position = UDim2.new(0, 0, 1, -126)
cardEquipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
cardEquipBtn.Font = Enum.Font.GothamBlack
cardEquipBtn.TextSize = 15
cardEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardEquipBtn.Text = "ЭКИПИРОВАТЬ СЕЙЧАС"
addCorner(cardEquipBtn, 10)
cardEquipBtn.Parent = revealCard

local cardSellBtn = Instance.new("TextButton")
cardSellBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardSellBtn.Position = UDim2.new(0, 0, 1, -72)
cardSellBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
cardSellBtn.Font = Enum.Font.GothamBlack
cardSellBtn.TextSize = 13
cardSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardSellBtn.Text = "ПРОДАТЬ (+50)"
addCorner(cardSellBtn, 10)
cardSellBtn.Parent = revealCard

local cardCollectBtn = Instance.new("TextButton")
cardCollectBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardCollectBtn.Position = UDim2.new(0.52, 0, 1, -72)
cardCollectBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
cardCollectBtn.Font = Enum.Font.GothamBlack
cardCollectBtn.TextSize = 13
cardCollectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardCollectBtn.Text = " В ИНВЕНТАРЬ"
addCorner(cardCollectBtn, 10)
cardCollectBtn.Parent = revealCard

local currentRolledAura = nil

local function showRevealPopup(auraData)
	currentRolledAura = auraData
	cardTierTag.Text = string.format("[  %s  ]", auraData.Tier:upper())
	cardName.Text = auraData.Name
	cardName.TextColor3 = auraData.Color
	cardRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
	cardDesc.Text = auraData.Description
	cardStroke.Color = auraData.Color
	revealEmblemHolder:ClearAllChildren()
	createAuraEmblem(revealEmblemHolder, auraData, 64, UDim2.new(0, 0, 0, 0))

	local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
	cardSellBtn.Text = string.format("ПРОДАТЬ (+%d)", scrapCoins)

	cutsceneOverlay.Visible = true

	revealCard.Size = UDim2.new(0, 100, 0, 110)
	TweenService:Create(revealCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 420, 0, 480),
	}):Play()
end

cardEquipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		EquipAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardSellBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Coin")
	cutsceneOverlay.Visible = false
	if currentRolledAura then
		DeleteAuraEvent:FireServer(currentRolledAura.Id)
	end
end)

cardCollectBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	cutsceneOverlay.Visible = false
end)

--------------------------------------------------------------------------------
-- 16. RUN CS2 CASE ROULETTE (WITH ITEM ICONS & TACTILE TICKS)
--------------------------------------------------------------------------------

local function runCS2Roulette(winningAura, onFinished)
	rouletteContainer.Visible = true
	rStroke.Color = winningAura.Color

	for _, child in ipairs(rouletteTape:GetChildren()) do
		child:Destroy()
	end

	local CARD_WIDTH = 120
	local CARD_GAP = 10
	local PITCH = CARD_WIDTH + CARD_GAP
	local WIN_INDEX = 34
	local TOTAL_CARDS = 44

	local allAuras = AuraConfig.RollableAuras
	local cardsList = {}

	for i = 1, TOTAL_CARDS do
		local aura = nil
		if i == WIN_INDEX then
			aura = winningAura
		else
			aura = allAuras[math.random(1, #allAuras)]
		end

		local card = Instance.new("Frame")
		card.Name = "Card_" .. tostring(i)
		card.Size = UDim2.new(0, CARD_WIDTH, 0, 140)
		card.Position = UDim2.new(0, (i - 1) * PITCH + 20, 0.5, -70)
		card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
		addCorner(card, 10)
		addStroke(card, aura.Color, 2)

		-- Procedural Guaranteed Aura Emblem in Roulette Card
		createAuraEmblem(card, aura, 40, UDim2.new(0.5, -20, 0, 8))

		local rSym = Instance.new("TextLabel")
		rSym.Size = UDim2.new(0, 28, 0, 14)
		rSym.Position = UDim2.new(1, -32, 0, 6)
		rSym.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
		rSym.Font = Enum.Font.GothamBlack
		rSym.TextSize = 8
		rSym.TextColor3 = aura.Color
		rSym.Text = aura.Symbol or "AUR"
		addCorner(rSym, 3)
		rSym.Parent = card

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -8, 0, 24)
		name.Position = UDim2.new(0, 4, 0, 52)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBlack
		name.TextSize = 11
		name.TextColor3 = aura.Color
		name.Text = aura.Name
		name.TextWrapped = true
		name.Parent = card

		local rarity = Instance.new("TextLabel")
		rarity.Size = UDim2.new(1, -8, 0, 18)
		rarity.Position = UDim2.new(0, 4, 0, 78)
		rarity.BackgroundTransparency = 1
		rarity.Font = Enum.Font.GothamBold
		rarity.TextSize = 10
		rarity.TextColor3 = Color3.fromRGB(156, 163, 175)
		rarity.Text = AuraConfig.FormatRarity(aura.Rarity or 0)
		rarity.Parent = card

		local tierPill = Instance.new("TextLabel")
		tierPill.Size = UDim2.new(1, -16, 0, 22)
		tierPill.Position = UDim2.new(0, 8, 1, -30)
		tierPill.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
		tierPill.Font = Enum.Font.GothamBlack
		tierPill.TextSize = 9
		tierPill.TextColor3 = aura.Color
		tierPill.Text = aura.Tier:upper()
		addCorner(tierPill, 4)
		tierPill.Parent = card

		card.Parent = rouletteTape
		table.insert(cardsList, card)
	end

	local containerWidth = rouletteContainer.AbsoluteSize.X
	local centerOffset = containerWidth / 2
	local cardCenterInTape = (WIN_INDEX - 1) * PITCH + 20 + (CARD_WIDTH / 2)
	local randomJitter = math.random(-20, 20)
	local targetTapeX = -(cardCenterInTape - centerOffset + randomJitter)

	rouletteTape.Position = UDim2.new(0, 0, 0, 0)

	local duration = isFastRollOn and 0.8 or 3.2
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(rouletteTape, tweenInfo, {
		Position = UDim2.new(0, targetTapeX, 0, 0)
	})

	local lastCardIndex = -1
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local curX = rouletteTape.Position.X.Offset
		local passedDist = -curX + centerOffset - 20
		local currentCard = math.floor(passedDist / PITCH) + 1
		if currentCard ~= lastCardIndex and currentCard >= 1 and currentCard <= TOTAL_CARDS then
			lastCardIndex = currentCard
			SoundEffects.Play("Tick", 0.15, 1.2)
		end
	end)

	tween:Play()
	tween.Completed:Connect(function()
		if conn then conn:Disconnect() end

		needleLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(needleLine, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(250, 204, 21) }):Play()

		if winningAura.Rarity >= 250000 then
			SoundEffects.Play("RevealGodly")
		elseif winningAura.Rarity >= 10000 then
			SoundEffects.Play("RevealMythic")
		elseif winningAura.Rarity >= 1000 then
			SoundEffects.Play("RevealLegendary")
		elseif winningAura.Rarity >= 16 then
			SoundEffects.Play("RevealRare")
		else
			SoundEffects.Play("RevealCommon")
		end

		task.wait(0.4)
		rouletteContainer.Visible = false
		if onFinished then onFinished() end
	end)
end

--------------------------------------------------------------------------------
-- 17. GLOBAL SERVER BANNER
--------------------------------------------------------------------------------

local banner = Instance.new("Frame")
banner.Name = "GlobalBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Size = UDim2.new(0, 540, 0, 46)
banner.Position = UDim2.new(0.5, 0, 0, -65)
banner.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
banner.BackgroundTransparency = 0.1
addCorner(banner, 12)
local bannerStroke = addStroke(banner, Color3.fromRGB(250, 204, 21), 2)
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Size = UDim2.new(1, -20, 1, 0)
bannerText.Position = UDim2.new(0, 10, 0, 0)
bannerText.BackgroundTransparency = 1
bannerText.Font = Enum.Font.GothamBlack
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.fromRGB(255, 235, 120)
bannerText.Text = " Player rolled MYTHIC!"
bannerText.Parent = banner

GlobalAnnouncementEvent.OnClientEvent:Connect(function(info)
	local tierColor = AuraConfig.GetTierColor(info.Tier)
	bannerStroke.Color = tierColor
	bannerText.Text = string.format(" %s rolled %s (%s)!", info.PlayerName, info.AuraName:upper(), AuraConfig.FormatRarity(info.Rarity))
	bannerText.TextColor3 = tierColor

	TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 68),
	}):Play()

	task.delay(4.5, function()
		TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0, -65),
		}):Play()
	end)
end)

--------------------------------------------------------------------------------
-- 18. ROLL EXECUTION WITH CS2 ROULETTE
--------------------------------------------------------------------------------

local function doRoll()
	if isRolling then return end
	isRolling = true

	TweenService:Create(rollButton, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 225, 0, 58),
	}):Play()

	SoundEffects.Play("Spin")

	local result = RollRequestFunc:InvokeServer(isFastRollOn)

	task.wait(0.1)
	TweenService:Create(rollButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 240, 0, 64),
	}):Play()

	if result and result.Success and result.Aura then
		runCS2Roulette(result.Aura, function()
			showRevealPopup(result.Aura)
			isRolling = false
		end)
	else
		isRolling = false
	end
end

rollButton.MouseButton1Click:Connect(function()
	doRoll()
end)

autoRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isAutoRollOn = not isAutoRollOn
	if isAutoRollOn then
		autoRollBtn.Text = " AUTO: ON"
		autoRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(22, 50, 35)
		autoStroke.Color = Color3.fromRGB(74, 222, 128)
	else
		autoRollBtn.Text = " AUTO: OFF"
		autoRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
		autoStroke.Color = Color3.fromRGB(45, 52, 70)
	end
end)

task.spawn(function()
	while true do
		task.wait(AuraConfig.Settings.AutoRollInterval)
		if isAutoRollOn and not isRolling and not cutsceneOverlay.Visible and not rouletteContainer.Visible then
			doRoll()
		end
	end
end)

fastRollBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	isFastRollOn = not isFastRollOn
	if isFastRollOn then
		fastRollBtn.Text = " FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВКЛ"
	else
		fastRollBtn.Text = " FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
		setFastBtn.Text = " Быстрый Ролл (Без Рулетки): ВЫКЛ"
	end
end)

unequipBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Equip")
	EquipAuraEvent:FireServer("None")
end)

navInventoryBtn.MouseButton1Click:Connect(function()
	toggleModal(invWindow)
	refreshInventoryUI()
end)

navUpgraderBtn.MouseButton1Click:Connect(function()
	toggleModal(upgWindow)
	refreshUpgraderUI()
end)

navPvPBtn.MouseButton1Click:Connect(function()
	toggleModal(pvpWindow)
	refreshPvPWindow()
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
	toggleModal(setWindow)
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	if prompt.Name == "CraftingPrompt" and player == LocalPlayer then
		if not craftWindow.Visible then toggleModal(craftWindow) end
		refreshCraftingUI()
	end
end)

--------------------------------------------------------------------------------
-- 19. DATA SYNCHRONIZATION
--------------------------------------------------------------------------------

DataSyncEvent.OnClientEvent:Connect(function(data)
	for k, v in pairs(data) do
		localData[k] = v
	end

	rollsLabel.Text = string.format(" Rolls: %s", AuraConfig.FormatNumber(localData.Rolls or 0))
	luckLabel.Text = string.format(" Luck: x%.1f", localData.CurrentLuck or 1.0)
	coinsLabel.Text = string.format(" %s", AuraConfig.FormatNumber(localData.Coins or 0))

	if localData.MegaPotionExpiry and localData.MegaPotionExpiry > os.time() then
		local remaining = localData.MegaPotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format(" 5x Mega: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(6, 182, 212)
	elseif localData.PotionExpiry and localData.PotionExpiry > os.time() then
		local remaining = localData.PotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format(" 2x Pot: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		potionLabel.Text = " Pot: None"
		potionLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
	end

	local eqAura = AuraConfig.Auras[localData.EquippedAura]
	if eqAura then
		eqName.Text = eqAura.Name
		eqName.TextColor3 = eqAura.Color
		eqSub.Text = AuraConfig.FormatRarity(eqAura.Rarity or 0)
		eqStroke.Color = eqAura.Color
	else
		eqName.Text = "Aura: None"
		eqName.TextColor3 = Color3.fromRGB(220, 225, 235)
		eqSub.Text = "Not Equipped"
		eqStroke.Color = Color3.fromRGB(45, 55, 78)
	end

	local autoDelText = thresholdNames[localData.AutoDeleteThreshold or 0] or "Нет"
	autoDeleteBtn.Text = "Авто-продажа: " .. autoDelText

	if invWindow.Visible then refreshInventoryUI() end
	if craftWindow.Visible then refreshCraftingUI() end
	if shopWindow.Visible then refreshShopUI() end
	if upgWindow.Visible then refreshUpgraderUI() end
end)

print("[Sols RNG] CS2 Roulette, PvP Battles, Aura Upgrader & Icons loaded!")
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
