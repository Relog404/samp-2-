-- RNGClient.client.lua
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

-- Upgrader State
local selectedUpgradeAura = nil
local upgraderMode = "Chance"
local upgraderValue = 50

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
	PurchaseProductFunc:InvokeServer("StarterPack")
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
local detailIcon = Instance.new("ImageLabel")
detailIcon.Size = UDim2.new(0, 48, 0, 48)
detailIcon.Position = UDim2.new(0.5, -24, 0, 4)
detailIcon.BackgroundTransparency = 1
detailIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
detailIcon.Parent = detailPanel

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

			-- Item Icon in Card!
			local iconImg = Instance.new("ImageLabel")
			iconImg.Size = UDim2.new(0, 36, 0, 36)
			iconImg.Position = UDim2.new(0.5, -18, 0, 6)
			iconImg.BackgroundTransparency = 1
			iconImg.Image = auraData.Icon or "rbxasset://textures/particles/sparkles_main.dds"
			iconImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
			iconImg.Parent = card

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
				detailIcon.Image = auraData.Icon or "rbxasset://textures/particles/sparkles_main.dds"
				detailIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

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
-- 9. AURA UPGRADER WINDOW (WHEEL ANIMATION, 2 BLOCKS & CUSTOM CHANCE)
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

local srcIcon = Instance.new("ImageLabel")
srcIcon.Size = UDim2.new(0, 38, 0, 38)
srcIcon.Position = UDim2.new(0, 8, 0.5, -19)
srcIcon.BackgroundTransparency = 1
srcIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
srcIcon.Parent = sourcePreviewFrame

local srcNameLbl = Instance.new("TextLabel")
srcNameLbl.Size = UDim2.new(1, -54, 0, 18)
srcNameLbl.Position = UDim2.new(0, 50, 0, 8)
srcNameLbl.BackgroundTransparency = 1
srcNameLbl.Font = Enum.Font.GothamBlack
srcNameLbl.TextSize = 12
srcNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
srcNameLbl.Text = "Выберите ауру ниже"
srcNameLbl.TextXAlignment = Enum.TextXAlignment.Left
srcNameLbl.Parent = sourcePreviewFrame

local srcSubLbl = Instance.new("TextLabel")
srcSubLbl.Size = UDim2.new(1, -54, 0, 16)
srcSubLbl.Position = UDim2.new(0, 50, 0, 28)
srcSubLbl.BackgroundTransparency = 1
srcSubLbl.Font = Enum.Font.GothamMedium
srcSubLbl.TextSize = 9
srcSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
srcSubLbl.Text = "Нажмите в списке ниже"
srcSubLbl.TextXAlignment = Enum.TextXAlignment.Left
srcSubLbl.Parent = sourcePreviewFrame

local srcScrapLbl = Instance.new("TextLabel")
srcScrapLbl.Size = UDim2.new(1, -54, 0, 14)
srcScrapLbl.Position = UDim2.new(0, 50, 0, 46)
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

-- Column 2: CENTER - UPGRADER WHEEL & CONTROLS
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
wheelFrame.Size = UDim2.new(0, 180, 0, 180)
wheelFrame.AnchorPoint = Vector2.new(0.5, 0)
wheelFrame.Position = UDim2.new(0.5, 0, 0, 4)
wheelFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
addCorner(wheelFrame, 90)
local wheelStroke = addStroke(wheelFrame, Color3.fromRGB(56, 189, 248), 2.8)
wheelFrame.Parent = upgColCenter

-- Needle Pointer Container (Rotates around center)
local needleContainer = Instance.new("Frame")
needleContainer.Size = UDim2.new(1, 0, 1, 0)
needleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
needleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
needleContainer.BackgroundTransparency = 1
needleContainer.Parent = wheelFrame

local needle = Instance.new("Frame")
needle.Size = UDim2.new(0, 4, 0, 78)
needle.AnchorPoint = Vector2.new(0.5, 1)
needle.Position = UDim2.new(0.5, 0, 0.5, 0)
needle.BackgroundColor3 = Color3.fromRGB(250, 204, 21)
addCorner(needle, 2)
needle.Parent = needleContainer

local needleArrow = Instance.new("Frame")
needleArrow.Size = UDim2.new(0, 12, 0, 12)
needleArrow.AnchorPoint = Vector2.new(0.5, 0.5)
needleArrow.Position = UDim2.new(0.5, 0, 0, 4)
needleArrow.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
needleArrow.Rotation = 45
needleArrow.Parent = needleContainer

-- Center Hub inside Wheel
local centerHub = Instance.new("Frame")
centerHub.Size = UDim2.new(0, 98, 0, 98)
centerHub.AnchorPoint = Vector2.new(0.5, 0.5)
centerHub.Position = UDim2.new(0.5, 0, 0.5, 0)
centerHub.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
addCorner(centerHub, 49)
local hubStroke = addStroke(centerHub, Color3.fromRGB(74, 222, 128), 2.0)
centerHub.Parent = wheelFrame

local chanceDisplay = Instance.new("TextLabel")
chanceDisplay.Size = UDim2.new(1, 0, 0, 24)
chanceDisplay.Position = UDim2.new(0, 0, 0, 18)
chanceDisplay.BackgroundTransparency = 1
chanceDisplay.Font = Enum.Font.GothamBlack
chanceDisplay.TextSize = 17
chanceDisplay.TextColor3 = Color3.fromRGB(74, 222, 128)
chanceDisplay.Text = "50.0%"
chanceDisplay.Parent = centerHub

local multDisplay = Instance.new("TextLabel")
multDisplay.Size = UDim2.new(1, 0, 0, 16)
multDisplay.Position = UDim2.new(0, 0, 0, 44)
multDisplay.BackgroundTransparency = 1
multDisplay.Font = Enum.Font.GothamBold
multDisplay.TextSize = 11
multDisplay.TextColor3 = Color3.fromRGB(250, 204, 21)
multDisplay.Text = "2.00x МНОЖИТЕЛЬ"
multDisplay.Parent = centerHub

local sectorDisplay = Instance.new("TextLabel")
sectorDisplay.Size = UDim2.new(1, 0, 0, 14)
sectorDisplay.Position = UDim2.new(0, 0, 0, 64)
sectorDisplay.BackgroundTransparency = 1
sectorDisplay.Font = Enum.Font.GothamMedium
sectorDisplay.TextSize = 8
sectorDisplay.TextColor3 = Color3.fromRGB(147, 197, 253)
sectorDisplay.Text = "СЕКТОР: 0 град. - 180 град."
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
upgResultMsg.Text = "Выберите исходную и целевую ауру, затем крутите!"
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

local tgtIcon = Instance.new("ImageLabel")
tgtIcon.Size = UDim2.new(0, 38, 0, 38)
tgtIcon.Position = UDim2.new(0, 8, 0.5, -19)
tgtIcon.BackgroundTransparency = 1
tgtIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
tgtIcon.Parent = targetPreviewFrame

local tgtNameLbl = Instance.new("TextLabel")
tgtNameLbl.Size = UDim2.new(1, -54, 0, 18)
tgtNameLbl.Position = UDim2.new(0, 50, 0, 8)
tgtNameLbl.BackgroundTransparency = 1
tgtNameLbl.Font = Enum.Font.GothamBlack
tgtNameLbl.TextSize = 12
tgtNameLbl.TextColor3 = Color3.fromRGB(250, 204, 21)
tgtNameLbl.Text = "Любая аура из списка"
tgtNameLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtNameLbl.Parent = targetPreviewFrame

local tgtSubLbl = Instance.new("TextLabel")
tgtSubLbl.Size = UDim2.new(1, -54, 0, 16)
tgtSubLbl.Position = UDim2.new(0, 50, 0, 28)
tgtSubLbl.BackgroundTransparency = 1
tgtSubLbl.Font = Enum.Font.GothamMedium
tgtSubLbl.TextSize = 9
tgtSubLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
tgtSubLbl.Text = "Выберите желаемую ауру"
tgtSubLbl.TextXAlignment = Enum.TextXAlignment.Left
tgtSubLbl.Parent = targetPreviewFrame

local tgtRarityLbl = Instance.new("TextLabel")
tgtRarityLbl.Size = UDim2.new(1, -54, 0, 14)
tgtRarityLbl.Position = UDim2.new(0, 50, 0, 46)
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
	local maxDeg = math.floor((upgraderChance / 100.0) * 360)
	sectorDisplay.Text = string.format("СЕКТОР: 0 град. - %d град.", maxDeg)
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

				local icon = Instance.new("ImageLabel")
				icon.Size = UDim2.new(0, 32, 0, 32)
				icon.Position = UDim2.new(0.5, -16, 0, 4)
				icon.BackgroundTransparency = 1
				icon.Image = aura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
				icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
				icon.Parent = card

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
					srcIcon.Image = aura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
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

		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 32, 0, 32)
		icon.Position = UDim2.new(0.5, -16, 0, 4)
		icon.BackgroundTransparency = 1
		icon.Image = aura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		icon.Parent = card

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
			tgtIcon.Image = aura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
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
local cardItemIcon = Instance.new("ImageLabel")
cardItemIcon.Size = UDim2.new(0, 64, 0, 64)
cardItemIcon.Position = UDim2.new(0.5, -32, 0, 24)
cardItemIcon.BackgroundTransparency = 1
cardItemIcon.Image = "rbxasset://textures/particles/sparkles_main.dds"
cardItemIcon.Parent = revealCard

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
	cardItemIcon.Image = auraData.Icon or "rbxasset://textures/particles/sparkles_main.dds"
	cardItemIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

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

		-- Item Icon in Roulette Card!
		local cardIcon = Instance.new("ImageLabel")
		cardIcon.Size = UDim2.new(0, 42, 0, 42)
		cardIcon.Position = UDim2.new(0.5, -21, 0, 8)
		cardIcon.BackgroundTransparency = 1
		cardIcon.Image = aura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
		cardIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		cardIcon.Parent = card

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

		-- Update Upgrader Slot if not chosen
		if not selectedUpgradeAura then
			upgSlotName.Text = eqAura.Name
			upgSlotName.TextColor3 = eqAura.Color
			upgSlotIcon.Image = eqAura.Icon or "rbxasset://textures/particles/sparkles_main.dds"
			upgSlotIcon.ImageColor3 = eqAura.Color
		end
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

print("[Sols RNG] CS2 Roulette, PvP Battles, Aura Upgrader & Icons loaded!")
