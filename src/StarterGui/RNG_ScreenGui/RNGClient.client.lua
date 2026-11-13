-- RNGClient.client.lua
-- Dynamic CS2-style Case Opening Roulette, Glassmorphic UI, Clear Sell & Equip Controls,
-- Rich Multi-Category Donation Shop, Quick-Donate HUD Bar, Special Offers, and Soft Audio Controls.

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
local SoundEffects = require(ModulesFolder:WaitForChild("SoundEffects"))

-- Remotes
local RollRequestFunc = EventsFolder:WaitForChild("RollRequest")
local CraftAuraFunc = EventsFolder:WaitForChild("CraftAura")
local PurchaseProductFunc = EventsFolder:WaitForChild("PurchaseProduct")
local EquipAuraEvent = EventsFolder:WaitForChild("EquipAura")
local DeleteAuraEvent = EventsFolder:WaitForChild("DeleteAura")
local SetAutoDeleteEvent = EventsFolder:WaitForChild("SetAutoDelete")
local ToggleTestPerkEvent = EventsFolder:WaitForChild("ToggleTestPerk")
local DataSyncEvent = EventsFolder:WaitForChild("DataSync")
local GlobalAnnouncementEvent = EventsFolder:WaitForChild("GlobalAnnouncement")

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

local function createTopStatPill(icon, defaultText, color)
	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 130, 0, 32)
	pill.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	pill.BackgroundTransparency = 0.4
	addCorner(pill, 8)
	addStroke(pill, Color3.fromRGB(35, 42, 60), 1)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextColor3 = color
	label.Text = icon .. " " .. defaultText
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = pill

	pill.Parent = topHud
	return label, pill
end

local rollsLabel, rollsPill = createTopStatPill("🎲", "Rolls: 0", Color3.fromRGB(220, 225, 240))
local luckLabel, luckPill = createTopStatPill("🍀", "Luck: x1.0", Color3.fromRGB(74, 222, 128))
local coinsLabel, coinsPill = createTopStatPill("🪙", "Coins: 100", Color3.fromRGB(250, 204, 21))
local potionLabel, potionPill = createTopStatPill("⏳", "Pot: None", Color3.fromRGB(56, 189, 248))

--------------------------------------------------------------------------------
-- 2. TOP-RIGHT SPECIAL OFFER WIDGET (DONATE PROMOTION)
--------------------------------------------------------------------------------

local specialOffer = Instance.new("Frame")
specialOffer.Name = "SpecialOffer"
specialOffer.AnchorPoint = Vector2.new(1, 0)
specialOffer.Position = UDim2.new(1, -14, 0, 12)
specialOffer.Size = UDim2.new(0, 220, 0, 72)
specialOffer.BackgroundColor3 = Color3.fromRGB(22, 18, 32)
specialOffer.BackgroundTransparency = 0.1
addCorner(specialOffer, 12)
local offerStroke = addStroke(specialOffer, Color3.fromRGB(245, 158, 11), 1.8)
addPadding(specialOffer, 6, 6, 8, 8)
specialOffer.Parent = screenGui

local offerTitle = Instance.new("TextLabel")
offerTitle.Size = UDim2.new(1, 0, 0, 16)
offerTitle.BackgroundTransparency = 1
offerTitle.Font = Enum.Font.GothamBlack
offerTitle.TextSize = 11
offerTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
offerTitle.Text = "🔥 СТАРТЕР ПАК [-80%]"
offerTitle.Parent = specialOffer

local offerSub = Instance.new("TextLabel")
offerSub.Size = UDim2.new(1, 0, 0, 14)
offerSub.Position = UDim2.new(0, 0, 0, 16)
offerSub.BackgroundTransparency = 1
offerSub.Font = Enum.Font.GothamMedium
offerSub.TextSize = 10
offerSub.TextColor3 = Color3.fromRGB(220, 225, 240)
offerSub.Text = "x2 Luck + VIP + 25,000 Монет"
offerSub.Parent = specialOffer

local offerBuyBtn = Instance.new("TextButton")
offerBuyBtn.Size = UDim2.new(1, 0, 0, 26)
offerBuyBtn.Position = UDim2.new(0, 0, 1, -26)
offerBuyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
offerBuyBtn.Font = Enum.Font.GothamBlack
offerBuyBtn.TextSize = 11
offerBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
offerBuyBtn.Text = "💎 ЗАБРАТЬ (R$ 149 / ТЕСТ)"
addCorner(offerBuyBtn, 6)
offerBuyBtn.Parent = specialOffer

offerBuyBtn.MouseButton1Click:Connect(function()
	SoundEffects.Play("Click")
	PurchaseProductFunc:InvokeServer("StarterPack")
end)

--------------------------------------------------------------------------------
-- 3. RIGHT FLOATING QUICK-DONATE BAR (ДОНАТ КНОПКИ)
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

local function createQuickDonatePill(icon, title, color, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
	btn.Text = ""
	addCorner(btn, 10)
	local stroke = addStroke(btn, color, 1.5)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 11
	lbl.TextColor3 = color
	lbl.Text = icon .. " " .. title
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

-- Forward declaration of shop modal toggle
local toggleShopModal = nil

createQuickDonatePill("💎", "ДОНАТ", Color3.fromRGB(168, 85, 247), function()
	if toggleShopModal then toggleShopModal() end
end)

createQuickDonatePill("🍀", "x2 LUCK", Color3.fromRGB(74, 222, 128), function()
	ToggleTestPerkEvent:FireServer("X2Luck")
end)

createQuickDonatePill("⭐", "VIP", Color3.fromRGB(245, 158, 11), function()
	ToggleTestPerkEvent:FireServer("VIP")
end)

createQuickDonatePill("⚡", "AUTO-ROLL", Color3.fromRGB(250, 204, 21), function()
	ToggleTestPerkEvent:FireServer("AutoRoll")
end)

createQuickDonatePill("🧪", "x5 ЗЕЛЬЕ", Color3.fromRGB(6, 182, 212), function()
	PurchaseProductFunc:InvokeServer("MegaPotion")
end)

createQuickDonatePill("🪙", "+50K МОНЕТ", Color3.fromRGB(251, 191, 36), function()
	PurchaseProductFunc:InvokeServer("CoinPack50k")
end)

--------------------------------------------------------------------------------
-- 4. BOTTOM CONTROLS & MASSIVE ROLL BUTTON
--------------------------------------------------------------------------------

local bottomControls = Instance.new("Frame")
bottomControls.Name = "BottomControls"
bottomControls.AnchorPoint = Vector2.new(0.5, 1)
bottomControls.Position = UDim2.new(0.5, 0, 1, -18)
bottomControls.Size = UDim2.new(0, 460, 0, 110)
bottomControls.BackgroundTransparency = 1
bottomControls.Parent = screenGui

local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.AnchorPoint = Vector2.new(0.5, 0)
rollButton.Position = UDim2.new(0.5, 0, 0, 0)
rollButton.Size = UDim2.new(0, 240, 0, 64)
rollButton.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
rollButton.Font = Enum.Font.GothamBlack
rollButton.TextSize = 26
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.Text = "🎲 ROLL"
addCorner(rollButton, 16)
local rollStroke = addStroke(rollButton, Color3.fromRGB(96, 165, 250), 2.5)

local rollGrad = Instance.new("UIGradient")
rollGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 130, 246)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 78, 216)),
})
rollGrad.Rotation = 45
rollGrad.Parent = rollButton
rollButton.Parent = bottomControls

local secondaryBar = Instance.new("Frame")
secondaryBar.Size = UDim2.new(0, 320, 0, 34)
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
autoRollBtn.Size = UDim2.new(0, 150, 1, 0)
autoRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
autoRollBtn.Font = Enum.Font.GothamBold
autoRollBtn.TextSize = 12
autoRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
autoRollBtn.Text = "⚡ AUTO: OFF"
addCorner(autoRollBtn, 8)
local autoStroke = addStroke(autoRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
autoRollBtn.Parent = secondaryBar

local fastRollBtn = Instance.new("TextButton")
fastRollBtn.Name = "FastRollBtn"
fastRollBtn.Size = UDim2.new(0, 150, 1, 0)
fastRollBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
fastRollBtn.Font = Enum.Font.GothamBold
fastRollBtn.TextSize = 12
fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
fastRollBtn.Text = "⏩ FAST: OFF"
addCorner(fastRollBtn, 8)
local fastStroke = addStroke(fastRollBtn, Color3.fromRGB(45, 52, 70), 1.2)
fastRollBtn.Parent = secondaryBar

--------------------------------------------------------------------------------
-- 5. LEFT DOCK NAVIGATION BAR
--------------------------------------------------------------------------------

local leftDock = Instance.new("Frame")
leftDock.Name = "LeftDock"
leftDock.AnchorPoint = Vector2.new(0, 0.5)
leftDock.Position = UDim2.new(0, 14, 0.5, 0)
leftDock.Size = UDim2.new(0, 62, 0, 260)
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
dockLayout.Padding = UDim.new(0, 10)
dockLayout.Parent = leftDock

local function createDockButton(name, icon, tooltipText)
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Btn"
	btn.Size = UDim2.new(0, 48, 0, 48)
	btn.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 22
	btn.Text = icon
	addCorner(btn, 10)
	local stroke = addStroke(btn, Color3.fromRGB(45, 52, 72), 1)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(37, 99, 235) }):Play()
		stroke.Color = Color3.fromRGB(96, 165, 250)
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(22, 26, 38) }):Play()
		stroke.Color = Color3.fromRGB(45, 52, 72)
	end)

	btn.Parent = leftDock
	return btn
end

local navInventoryBtn = createDockButton("Inventory", "🎒", "Инвентарь")
local navCraftingBtn = createDockButton("Crafting", "⚗️", "Кузница Крафта")
local navShopBtn = createDockButton("Shop", "🛒", "Магазин Доната")
local navSettingsBtn = createDockButton("Settings", "⚙️", "Настройки")

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
unequipBtn.Text = "✕"
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
	closeBtn.Text = "✕"
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
-- 8. INVENTORY WINDOW (EXPLICIT EQUIP & SELL BUTTONS)
--------------------------------------------------------------------------------

local invWindow, invContent = createModal("🎒 ИНВЕНТАРЬ АУР", 680, 480)

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

local detailName = Instance.new("TextLabel")
detailName.Size = UDim2.new(1, 0, 0, 26)
detailName.BackgroundTransparency = 1
detailName.Font = Enum.Font.GothamBlack
detailName.TextSize = 16
detailName.TextColor3 = Color3.fromRGB(255, 255, 255)
detailName.Text = "Выберите Ауру"
detailName.Parent = detailPanel

local detailRarity = Instance.new("TextLabel")
detailRarity.Size = UDim2.new(1, 0, 0, 18)
detailRarity.Position = UDim2.new(0, 0, 0, 28)
detailRarity.BackgroundTransparency = 1
detailRarity.Font = Enum.Font.GothamBold
detailRarity.TextSize = 12
detailRarity.TextColor3 = Color3.fromRGB(156, 163, 175)
detailRarity.Text = ""
detailRarity.Parent = detailPanel

local detailDesc = Instance.new("TextLabel")
detailDesc.Size = UDim2.new(1, 0, 0, 100)
detailDesc.Position = UDim2.new(0, 0, 0, 52)
detailDesc.BackgroundTransparency = 1
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 12
detailDesc.TextColor3 = Color3.fromRGB(200, 205, 220)
detailDesc.TextWrapped = true
detailDesc.TextYAlignment = Enum.TextYAlignment.Top
detailDesc.Text = "Нажмите на ауру слева для управления."
detailDesc.Parent = detailPanel

local equipActionBtn = Instance.new("TextButton")
equipActionBtn.Size = UDim2.new(1, 0, 0, 42)
equipActionBtn.Position = UDim2.new(0, 0, 1, -94)
equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
equipActionBtn.Font = Enum.Font.GothamBlack
equipActionBtn.TextSize = 14
equipActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipActionBtn.Text = "⚔️ ЭКИПИРОВАТЬ"
equipActionBtn.Visible = false
addCorner(equipActionBtn, 8)
equipActionBtn.Parent = detailPanel

local sellActionBtn = Instance.new("TextButton")
sellActionBtn.Size = UDim2.new(1, 0, 0, 40)
sellActionBtn.Position = UDim2.new(0, 0, 1, -44)
sellActionBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
sellActionBtn.Font = Enum.Font.GothamBlack
sellActionBtn.TextSize = 13
sellActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellActionBtn.Text = "💰 ПРОДАТЬ (+50 МОНЕТ)"
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

			local name = Instance.new("TextLabel")
			name.Size = UDim2.new(1, -8, 0, 30)
			name.Position = UDim2.new(0, 4, 0, 4)
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
			countTag.Size = UDim2.new(0, 32, 0, 18)
			countTag.Position = UDim2.new(1, -36, 1, -22)
			countTag.BackgroundColor3 = Color3.fromRGB(28, 33, 48)
			countTag.Font = Enum.Font.GothamBold
			countTag.TextSize = 10
			countTag.TextColor3 = Color3.fromRGB(220, 225, 240)
			countTag.Text = "x" .. tostring(count)
			addCorner(countTag, 4)
			countTag.Parent = card

			if localData.EquippedAura == auraId then
				local eqTag = Instance.new("TextLabel")
				eqTag.Size = UDim2.new(0, 50, 0, 18)
				eqTag.Position = UDim2.new(0, 4, 1, -22)
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

				equipActionBtn.Visible = true
				if localData.EquippedAura == auraId then
					equipActionBtn.Text = "✕ СНЯТЬ АУРУ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
				else
					equipActionBtn.Text = "⚔️ ЭКИПИРОВАТЬ"
					equipActionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				end

				local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
				sellActionBtn.Text = string.format("💰 ПРОДАТЬ (+%d МОНЕТ)", scrapCoins)
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
-- 9. CRAFTING ALCHEMIST FORGE
--------------------------------------------------------------------------------

local craftWindow, craftContent = createModal("⚗️ КУЗНИЦА КРАФТА АУР", 720, 500)

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
forgeBtn.Text = "⚗️ КОВАТЬ РЕЦЕПТ"
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
					countLbl.Text = string.format("✓ %d / %d", owned, ing.Count)
				else
					countLbl.TextColor3 = Color3.fromRGB(248, 113, 113)
					countLbl.Text = string.format("✕ %d / %d", owned, ing.Count)
					canCraftAll = false
				end
				countLbl.Parent = row
			end

			forgeBtn.Visible = true
			if canCraftAll then
				forgeBtn.Text = "⚗️ КОВАТЬ СЕЙЧАС"
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
-- 10. MULTI-CATEGORY DONATION SHOP (ДОНАТ ДОНАТ ДОНАТ)
--------------------------------------------------------------------------------

local shopWindow, shopContent = createModal("💎 МАГАЗИН ДОНАТА И ПАССОВ (АКЦИИ -80%)", 740, 520)

toggleShopModal = function()
	toggleModal(shopWindow)
end

local shopScroll = Instance.new("ScrollingFrame")
shopScroll.Size = UDim2.new(1, 0, 1, 0)
shopScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
shopScroll.BackgroundTransparency = 0.4
shopScroll.ScrollBarThickness = 5
addCorner(shopScroll, 8)
shopScroll.Parent = shopContent

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.Parent = shopScroll
addPadding(shopScroll, 8, 8, 8, 8)

local donateCatalog = {
	-- GAMEPASSES
	{
		Category = "ГЕЙМПАССЫ НАВСЕГДА",
		Items = {
			{
				Id = "X2Luck",
				Badge = "🔥 ХИТ",
				Name = "🎲 x2 Luck Pass (Навсегда)",
				Color = Color3.fromRGB(74, 222, 128),
				Desc = "Удваивает шанс выпадения всех редких, мифических и богоподобных аур навсегда!",
				Price = "R$ 199",
				Type = "Perk",
				PerkKey = "X2Luck",
			},
			{
				Id = "X3Luck",
				Badge = "⚡ СВЕРХУДАЧА",
				Name = "🍀 x3 Luck Overload (Навсегда)",
				Color = Color3.fromRGB(16, 185, 129),
				Desc = "Тройной шанс на все ауры! Стакается со всеми другими бонусами!",
				Price = "R$ 499",
				Type = "Perk",
				PerkKey = "X3Luck",
			},
			{
				Id = "AutoRoll",
				Badge = "⚡ АВТО-РОЛЛ",
				Name = "⚡ Auto Roll Pass (Навсегда)",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Автоматический ролл в фоне пока вы общаетесь, гуляете или стоите AFK!",
				Price = "R$ 99",
				Type = "Perk",
				PerkKey = "AutoRoll",
			},
			{
				Id = "ExtraStorage",
				Badge = "📦 +50 СЛОТОВ",
				Name = "🎨 Aura Storage (+50)",
				Color = Color3.fromRGB(56, 189, 248),
				Desc = "Расширяет ваш инвентарь на +50 дополнительных слотов для редких аур!",
				Price = "R$ 149",
				Type = "Perk",
				PerkKey = "ExtraStorage",
			},
			{
				Id = "VIP",
				Badge = "⭐ VIP КЛУБ",
				Name = "⭐ VIP Supporter Pass",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Аура VIP Crown + x1.5 Удача + Золотой титул VIP над головой и в чате!",
				Price = "R$ 299",
				Type = "Perk",
				PerkKey = "VIP",
			},
			{
				Id = "FastRoll",
				Badge = "⏩ БЫСТРЫЙ РОЛЛ",
				Name = "⏩ Fast Roll Instant Pass",
				Color = Color3.fromRGB(236, 72, 153),
				Desc = "Моментальное раскрытие роллов без ожидания рулетки!",
				Price = "R$ 79",
				Type = "Perk",
				PerkKey = "FastRoll",
			},
		}
	},
	-- POTIONS & BOOSTS
	{
		Category = "МЕГА-БУСТЫ И ЗЕЛЬЯ",
		Items = {
			{
				Id = "MegaPotion",
				Badge = "🌟 5x LUCK",
				Name = "🧪 Мега-Зелье Удачи x5 (15 мин)",
				Color = Color3.fromRGB(6, 182, 212),
				Desc = "Дает бешеное пятикратное (5x) увеличение шансов на 15 минут!",
				Price = "R$ 129",
				Type = "Product",
				ProductKey = "MegaPotion",
			},
		}
	},
	-- COINS
	{
		Category = "ПАКЕТЫ МОНЕТ",
		Items = {
			{
				Id = "Coins10k",
				Badge = "🪙 10K",
				Name = "🪙 10,000 Монет",
				Color = Color3.fromRGB(250, 204, 21),
				Desc = "Стартовый запас монет для крафта и улучшений.",
				Price = "R$ 49",
				Type = "Product",
				ProductKey = "CoinPack10k",
			},
			{
				Id = "Coins50k",
				Badge = "🔥 ХИТ",
				Name = "🪙 50,000 Монет",
				Color = Color3.fromRGB(245, 158, 11),
				Desc = "Большой мешок золота для покупки слотов и расходников!",
				Price = "R$ 149",
				Type = "Product",
				ProductKey = "CoinPack50k",
			},
			{
				Id = "Coins250k",
				Badge = "💎 БОГАТСТВО",
				Name = "🪙 250,000 Монет",
				Color = Color3.fromRGB(251, 191, 36),
				Desc = "Сундук с золотом — никогда больше не беспокойтесь о монетах!",
				Price = "R$ 399",
				Type = "Product",
				ProductKey = "CoinPack250k",
			},
		}
	},
	-- INSTANT GOD ROLLS
	{
		Category = "МГНОВЕННЫЙ ВЫБИВ АУР",
		Items = {
			{
				Id = "InstantLegendary",
				Badge = "👑 1/1,000+",
				Name = "🎰 Гарантированная Легендарная Аура",
				Color = Color3.fromRGB(239, 68, 68),
				Desc = "Мгновенно начисляет случайную Легендарную ауру (Ruby, Undead, Solar)!",
				Price = "R$ 199",
				Type = "Product",
				ProductKey = "InstantLegendary",
			},
			{
				Id = "InstantMythic",
				Badge = "🌌 1/10,000+",
				Name = "🌌 Гарантированная Мифическая Аура",
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
		catHeader.Text = "✦ " .. cat.Category
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
					ToggleTestPerkEvent:FireServer(item.PerkKey)
				end)
			else
				testBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
				testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				testBtn.Text = string.format("КУПИТЬ %s (ТЕСТ)", item.Price)

				testBtn.MouseButton1Click:Connect(function()
					SoundEffects.Play("Coin")
					PurchaseProductFunc:InvokeServer(item.ProductKey)
				end)
			end

			testBtn.Parent = row
			row.Parent = shopScroll
		end
	end

	shopScroll.CanvasSize = UDim2.new(0, 0, 0, shopLayout.AbsoluteContentSize.Y + 24)
end

--------------------------------------------------------------------------------
-- 11. SETTINGS WINDOW (WITH SOUND VOLUME & MUTE CONTROLS)
--------------------------------------------------------------------------------

local setWindow, setContent = createModal("⚙️ НАСТРОЙКИ", 460, 260)

local setFastBtn = Instance.new("TextButton")
setFastBtn.Size = UDim2.new(1, 0, 0, 44)
setFastBtn.Position = UDim2.new(0, 0, 0, 10)
setFastBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
setFastBtn.Font = Enum.Font.GothamBold
setFastBtn.TextSize = 14
setFastBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
setFastBtn.Text = "⏩ Быстрый Ролл (Без Рулетки): ВЫКЛ"
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
setSoundBtn.Text = "🔊 Звуки Игры: ВКЛ (Мягкие)"
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
		setFastBtn.Text = "⏩ Быстрый Ролл (Без Рулетки): ВКЛ"
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		setFastBtn.Text = "⏩ Быстрый Ролл (Без Рулетки): ВЫКЛ"
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
	end
end)

setSoundBtn.MouseButton1Click:Connect(function()
	local isMuted = SoundEffects.ToggleMute()
	if isMuted then
		setSoundBtn.Text = "🔇 Звуки Игры: ВЫКЛЮЧЕНЫ"
		setSoundBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
	else
		setSoundBtn.Text = "🔊 Звуки Игры: ВКЛ (Мягкие)"
		setSoundBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		SoundEffects.Play("Click")
	end
end)

--------------------------------------------------------------------------------
-- 12. CS2-STYLE DYNAMIC HORIZONTAL CASE OPENING ROULETTE
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
-- 13. REVEAL POPUP WITH EXPLICIT EQUIP & SELL BUTTONS
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
revealCard.Size = UDim2.new(0, 420, 0, 460)
revealCard.BackgroundColor3 = Color3.fromRGB(14, 17, 26)
addCorner(revealCard, 18)
local cardStroke = addStroke(revealCard, Color3.fromRGB(255, 255, 255), 3)
addPadding(revealCard, 20, 20, 24, 24)
revealCard.Parent = cutsceneOverlay

local cardHeaderTitle = Instance.new("TextLabel")
cardHeaderTitle.Size = UDim2.new(1, 0, 0, 22)
cardHeaderTitle.BackgroundTransparency = 1
cardHeaderTitle.Font = Enum.Font.GothamBlack
cardHeaderTitle.TextSize = 13
cardHeaderTitle.TextColor3 = Color3.fromRGB(250, 204, 21)
cardHeaderTitle.Text = "🎉 ВЫ ВЫБИЛИ НОВУЮ АУРУ!"
cardHeaderTitle.Parent = revealCard

local cardTierTag = Instance.new("TextLabel")
cardTierTag.Size = UDim2.new(1, 0, 0, 24)
cardTierTag.Position = UDim2.new(0, 0, 0, 24)
cardTierTag.BackgroundTransparency = 1
cardTierTag.Font = Enum.Font.GothamBlack
cardTierTag.TextSize = 14
cardTierTag.TextColor3 = Color3.fromRGB(156, 163, 175)
cardTierTag.Text = "[ TIER ]"
cardTierTag.Parent = revealCard

local cardName = Instance.new("TextLabel")
cardName.Size = UDim2.new(1, 0, 0, 46)
cardName.Position = UDim2.new(0, 0, 0, 50)
cardName.BackgroundTransparency = 1
cardName.Font = Enum.Font.GothamBlack
cardName.TextSize = 32
cardName.TextColor3 = Color3.fromRGB(255, 255, 255)
cardName.Text = "Aura Name"
cardName.Parent = revealCard

local cardRarity = Instance.new("TextLabel")
cardRarity.Size = UDim2.new(1, 0, 0, 28)
cardRarity.Position = UDim2.new(0, 0, 0, 102)
cardRarity.BackgroundTransparency = 1
cardRarity.Font = Enum.Font.GothamBold
cardRarity.TextSize = 18
cardRarity.TextColor3 = Color3.fromRGB(240, 243, 250)
cardRarity.Text = "1 in 100,000"
cardRarity.Parent = revealCard

local cardDesc = Instance.new("TextLabel")
cardDesc.Size = UDim2.new(1, 0, 0, 90)
cardDesc.Position = UDim2.new(0, 0, 0, 136)
cardDesc.BackgroundTransparency = 1
cardDesc.Font = Enum.Font.Gotham
cardDesc.TextSize = 13
cardDesc.TextColor3 = Color3.fromRGB(180, 185, 205)
cardDesc.TextWrapped = true
cardDesc.Text = "Aura lore description..."
cardDesc.Parent = revealCard

local cardEquipBtn = Instance.new("TextButton")
cardEquipBtn.Size = UDim2.new(1, 0, 0, 44)
cardEquipBtn.Position = UDim2.new(0, 0, 1, -128)
cardEquipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
cardEquipBtn.Font = Enum.Font.GothamBlack
cardEquipBtn.TextSize = 15
cardEquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardEquipBtn.Text = "⚔️ ЭКИПИРОВАТЬ СЕЙЧАС"
addCorner(cardEquipBtn, 10)
cardEquipBtn.Parent = revealCard

local cardSellBtn = Instance.new("TextButton")
cardSellBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardSellBtn.Position = UDim2.new(0, 0, 1, -74)
cardSellBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
cardSellBtn.Font = Enum.Font.GothamBlack
cardSellBtn.TextSize = 13
cardSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardSellBtn.Text = "💰 ПРОДАТЬ (+50)"
addCorner(cardSellBtn, 10)
cardSellBtn.Parent = revealCard

local cardCollectBtn = Instance.new("TextButton")
cardCollectBtn.Size = UDim2.new(0.48, 0, 0, 42)
cardCollectBtn.Position = UDim2.new(0.52, 0, 1, -74)
cardCollectBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
cardCollectBtn.Font = Enum.Font.GothamBlack
cardCollectBtn.TextSize = 13
cardCollectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cardCollectBtn.Text = "🎒 В ИНВЕНТАРЬ"
addCorner(cardCollectBtn, 10)
cardCollectBtn.Parent = revealCard

local currentRolledAura = nil

local function showRevealPopup(auraData)
	currentRolledAura = auraData
	cardTierTag.Text = string.format("[ ✦ %s ✦ ]", auraData.Tier:upper())
	cardName.Text = auraData.Name
	cardName.TextColor3 = auraData.Color
	cardRarity.Text = AuraConfig.FormatRarity(auraData.Rarity or 0)
	cardDesc.Text = auraData.Description
	cardStroke.Color = auraData.Color

	local scrapCoins = AuraConfig.GetScrapValue(auraData.Rarity or 0)
	cardSellBtn.Text = string.format("💰 ПРОДАТЬ (+%d)", scrapCoins)

	cutsceneOverlay.Visible = true

	revealCard.Size = UDim2.new(0, 100, 0, 110)
	TweenService:Create(revealCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 420, 0, 460),
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
-- 14. RUN CS2 CASE ROULETTE (WITH GENTLE, SOFT MECHANICAL TICKS)
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

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -8, 0, 32)
		name.Position = UDim2.new(0, 4, 0, 8)
		name.BackgroundTransparency = 1
		name.Font = Enum.Font.GothamBlack
		name.TextSize = 12
		name.TextColor3 = aura.Color
		name.Text = aura.Name
		name.TextWrapped = true
		name.Parent = card

		local rarity = Instance.new("TextLabel")
		rarity.Size = UDim2.new(1, -8, 0, 20)
		rarity.Position = UDim2.new(0, 4, 0, 42)
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
			-- Soft, gentle tick sound that never hurts the ears!
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
-- 15. GLOBAL SERVER BANNER
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
bannerText.Text = "🎉 Player rolled MYTHIC!"
bannerText.Parent = banner

GlobalAnnouncementEvent.OnClientEvent:Connect(function(info)
	local tierColor = AuraConfig.GetTierColor(info.Tier)
	bannerStroke.Color = tierColor
	bannerText.Text = string.format("🎉 %s rolled %s (%s)!", info.PlayerName, info.AuraName:upper(), AuraConfig.FormatRarity(info.Rarity))
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
-- 16. ROLL TRIGGER & BUTTON EVENTS
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
		autoRollBtn.Text = "⚡ AUTO: ON"
		autoRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		autoRollBtn.BackgroundColor3 = Color3.fromRGB(22, 50, 35)
		autoStroke.Color = Color3.fromRGB(74, 222, 128)
	else
		autoRollBtn.Text = "⚡ AUTO: OFF"
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
		fastRollBtn.Text = "⏩ FAST: ON"
		fastRollBtn.TextColor3 = Color3.fromRGB(74, 222, 128)
		setFastBtn.Text = "⏩ Быстрый Ролл (Без Рулетки): ВКЛ"
	else
		fastRollBtn.Text = "⏩ FAST: OFF"
		fastRollBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
		setFastBtn.Text = "⏩ Быстрый Ролл (Без Рулетки): ВЫКЛ"
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
-- 17. DATA SYNCHRONIZATION
--------------------------------------------------------------------------------

DataSyncEvent.OnClientEvent:Connect(function(data)
	for k, v in pairs(data) do
		localData[k] = v
	end

	rollsLabel.Text = string.format("🎲 Rolls: %s", AuraConfig.FormatNumber(localData.Rolls or 0))
	luckLabel.Text = string.format("🍀 Luck: x%.1f", localData.CurrentLuck or 1.0)
	coinsLabel.Text = string.format("🪙 %s", AuraConfig.FormatNumber(localData.Coins or 0))

	-- Check active potions
	if localData.MegaPotionExpiry and localData.MegaPotionExpiry > os.time() then
		local remaining = localData.MegaPotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format("⏳ 5x Mega: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(6, 182, 212)
	elseif localData.PotionExpiry and localData.PotionExpiry > os.time() then
		local remaining = localData.PotionExpiry - os.time()
		local mins = math.floor(remaining / 60)
		local secs = remaining % 60
		potionLabel.Text = string.format("⏳ 2x Pot: %02d:%02d", mins, secs)
		potionLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
	else
		potionLabel.Text = "⏳ Pot: None"
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
end)

print("[Sols RNG] Full CS2 Roulette, Soft Audio & Massive Donation Shop loaded!")
