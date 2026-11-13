-- SoundEffects.lua
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
