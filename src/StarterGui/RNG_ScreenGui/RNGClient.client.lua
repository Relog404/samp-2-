-- RNGClient.client.lua
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
