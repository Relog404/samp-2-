-- SoundEffects.lua
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
