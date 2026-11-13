-- RNGServer.server.lua
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
	if not data then return { Success = false } end

	if productKey == "CoinPack10k" then
		data.Coins = (data.Coins or 0) + 10000
	elseif productKey == "CoinPack50k" then
		data.Coins = (data.Coins or 0) + 50000
	elseif productKey == "CoinPack250k" then
		data.Coins = (data.Coins or 0) + 250000
	elseif productKey == "MegaPotion" then
		data.MegaPotionExpiry = os.time() + 900 -- 15 mins x5 luck!
	elseif productKey == "InstantLegendary" then
		local pool = { "Ruby", "Undead", "Solar" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "InstantMythic" then
		local pool = { "Lunar", "Poseidon", "Hades", "Galaxy" }
		local pick = pool[math.random(1, #pool)]
		data.Inventory[pick] = (data.Inventory[pick] or 0) + 1
	elseif productKey == "StarterPack" then
		data.Coins = (data.Coins or 0) + 25000
		data.TestPerks.X2Luck = true
		data.TestPerks.VIP = true
		data.Inventory["VIPCrown"] = (data.Inventory["VIPCrown"] or 0) + 1
		data.MegaPotionExpiry = os.time() + 1800
	end

	syncClient(player)
	return { Success = true, Message = "Purchase Successful!" }
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
