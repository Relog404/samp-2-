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
