-- AuraConfig.lua
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
