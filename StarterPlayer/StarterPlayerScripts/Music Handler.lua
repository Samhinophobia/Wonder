-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
wait(1) 
local musicGui = playerGui:WaitForChild("MusicHUD", 5) 
if not musicGui then
	musicGui = playerGui:FindFirstChild("MusicHUD", true)
end

if not musicGui then
	warn("MusicHUD is completely missing from PlayerGui! Please make sure it is directly inside StarterGui and enabled!")
	return 
end
local container = musicGui:WaitForChild("Container")
local titleLabel = container:WaitForChild("Title")
local authorLabel = container:WaitForChild("Author")
local stripe = container:WaitForChild("Stripe")
local albumArt = container:WaitForChild("AlbumArt") 

local muteBtn = musicGui:WaitForChild("MuteButton") 
pcall(function()
	local pressureEffect = game.Lighting:WaitForChild("Pressure", 3)
	if pressureEffect then
		pressureEffect.Enabled = false
	end
end)

local FADE_TIME = 1.5
local NOTIFICATION_DURATION = 5
local ZONE_FOLDER_NAME = "MusicZones"
local MAX_VOLUME = 0.45 
local ROTATION_SPEED = 1 

local ICON_ON = "rbxassetid://6031068420"
local ICON_OFF = "rbxassetid://6031068421"
local DEFAULT_IMAGE = "rbxassetid://13951019328" 

local BTN_VISIBLE_POS = muteBtn.Position
local BTN_HIDDEN_POS = UDim2.new(BTN_VISIBLE_POS.X.Scale, BTN_VISIBLE_POS.X.Offset, 1, 150)
local CONTAINER_VISIBLE_POS = UDim2.new(1, -320, 1, -30)
local CONTAINER_HIDDEN_POS = UDim2.new(1, -280, 1, 150)

local MusicData = {
	["Forest"] = { SoundId = "rbxassetid://78586871653791", Title = "Forest", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 0), ImageId = "rbxassetid://69504549" },
	["Village"] = { SoundId = "rbxassetid://129008738578569", Title = "Village Hidden Away", Author = "Made By Leef", Color = Color3.fromRGB(170, 85, 255), ImageId = "rbxassetid://69504549" },
	["Lies"] = { SoundId = "rbxassetid://129008738578569", Title = "Forest of Lies", Author = "Made By Leef", Color = Color3.fromRGB(0, 0, 127), ImageId = "rbxassetid://69504549" },
	["EndlessForest"] = { SoundId = "rbxassetid://90132616847184", Title = "The Trees of Illusion", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 0), ImageId = "rbxassetid://69504549" },
	["Forgotten World"] = { SoundId = "rbxassetid://114182370085534", Title = "The Forgotten Dreamsphere", Author = "Made By Rdein", Color = Color3.fromRGB(255, 255, 255), ImageId = "rbxassetid://69504549" },
	["Clock"] = { SoundId = "rbxassetid://93527502658640", Title = "Endless Tea Party", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 0), ImageId = "rbxassetid://93527502658640" },
	["Home"] = { SoundId = "rbxassetid://86139167995412", Title = "Far From Home", Author = "Made By Leef", Color = Color3.fromRGB(255, 170, 255), ImageId = "rbxassetid://69504549" },
	["Shop"] = { SoundId = "rbxassetid://76069530959614", Title = "Shadow and Patrico?", Author = "Made By Leef", Color = Color3.fromRGB(170, 0, 127), ImageId = "rbxassetid://69504549" },
	["Bed"] = { SoundId = "rbxassetid://86139167995412", Title = "Never Ending Slumber", Author = "Made By LunarLaw", Color = Color3.fromRGB(85, 0, 127), ImageId = "rbxassetid://126656177522401" },
	["Kingdom"] = { SoundId = "rbxassetid://111164249510570", Title = "Royal Court", Author = "Made By LunarLaw", Color = Color3.fromRGB(255, 0, 0), ImageId = "" },
	["Realm"] = { SoundId = "rbxassetid://94349596135494", Title = "His Domain", Author = "Made By Leef", Color = Color3.fromRGB(255, 0, 0), ImageId = "" },
	["Cards"] = { SoundId = "rbxassetid://129008738578569", Title = "Card Village", Author = "Made By Leef", Color = Color3.fromRGB(255, 0, 0), ImageId = "" },
	["Her"] = { SoundId = "rbxassetid://93610343280760", Title = "She's The World", Author = "Made By Leef", Color = Color3.fromRGB(255, 0, 0), ImageId = "" },
	["Ice Kingdom"] = { SoundId = "rbxassetid://117320342630939", Title = "A Forgotten Path.", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 255), ImageId = "" },
	["Why?"] = { SoundId = "rbxassetid://126343355393678", Title = "Pointless", Author = "Made By Leef", Color = Color3.fromRGB(255, 255, 127), ImageId = "" },
	["Start"] = { SoundId = "rbxassetid://1839853920", Title = "A Forgotten Dream.", Author = "Made By Leef", Color = Color3.fromRGB(255, 85, 0), ImageId = "" },
	["Stars"] = { SoundId = "rbxassetid://86139167995412", Title = "A Starry Night.", Author = "Made By Leef", Color = Color3.fromRGB(255, 255, 0), ImageId = "" },
	["Void"] = { SoundId = "rbxassetid://1845566373", Title = "The Empty", Author = "Unknown", Color = Color3.fromRGB(170, 0, 255) },

	["Convivium Potationis Perpetuum"] = { SoundId = "rbxassetid://90132616847184", Title = "Endless Tea Party", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 0), ImageId = "rbxassetid://93527502658640" },
	["Regnum Chartarum"] = { SoundId = "rbxassetid://129008738578569", Title = "Card Village", Author = "Made By Leef", Color = Color3.fromRGB(255, 0, 0), ImageId = "" },
	["Nivalis"] = { SoundId = "rbxassetid://117320342630939", Title = "A Forgotten Path.", Author = "Made By Leef", Color = Color3.fromRGB(85, 170, 255), ImageId = "" },
}

local BossMusicData = {
	SoundId = "rbxassetid://126343355393678", 
	Title = "Spiritual Pressure",
	Author = "The Threat",
	Color = Color3.fromRGB(150, 0, 0), 
	ImageId = DEFAULT_IMAGE
}


local QuestMusicData = {
	SoundId = "rbxassetid://74570917549777", 
	Title = "A Broken Loop",
	Author = "???",
	Color = Color3.fromRGB(30, 30, 35), 
	ImageId = DEFAULT_IMAGE
}

local function formatImageId(id)
	if not id or id == "" then return DEFAULT_IMAGE end
	local idStr = tostring(id)
	if not string.find(idStr, "rbxassetid://") then return "rbxassetid://" .. idStr end
	return idStr
end

local function GetDefaultMusic()
	local dreamStatus = ReplicatedStorage:FindFirstChild("CurrentDreamStatus")

	if dreamStatus and dreamStatus.Value ~= "" then
		if MusicData[dreamStatus.Value] then
			return MusicData[dreamStatus.Value]
		else
			return { SoundId = "rbxassetid://117320342630939", Title = "Dream World", Author = "Leef", Color = Color3.fromRGB(150, 0, 255), ImageId = DEFAULT_IMAGE }
		end
	else
		-- Main Waking World
		return { SoundId = "rbxassetid://126656177522401", Title = "The Waking World", Author = "LunarLaw", Color = Color3.fromRGB(200, 200, 200), ImageId = DEFAULT_IMAGE }
	end
end

local currentSound = Instance.new("Sound"); currentSound.Name = "ZoneMusic"; currentSound.Parent = SoundService; currentSound.Looped = true; currentSound.Volume = 0
local currentZone = nil
local isMuted = false 
local isRotating = false 

local isNearEmote = false 
local EMOTE_MUTE_RADIUS = 35 

-- [[ NEW: Quest State Variables ]]
local isQuestActive = false
local originalLighting = {}
local DreamEvents = ReplicatedStorage:WaitForChild("DreamEvents")
local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")

-- Undoes whatever DarkenAtmosphere changed. Called both when the quest
-- reaches its own conclusion (WakeUpFade, "the bomb explodes") and when the
-- player leaves the dream any other way — woke up without finishing, the
-- dream cycled to a new map, etc. Safe to call even if the quest was never
-- triggered this session; it just no-ops.
local function resetQuestState()
	if not isQuestActive then return end
	isQuestActive = false
	if originalLighting.Ambient then
		Lighting.Ambient = originalLighting.Ambient
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ClockTime = originalLighting.ClockTime
	end
end

container.Position = CONTAINER_HIDDEN_POS
muteBtn.Position = BTN_HIDDEN_POS
muteBtn.Image = ICON_ON 

RunService.RenderStepped:Connect(function()
	if isRotating and albumArt then albumArt.Rotation = albumArt.Rotation + ROTATION_SPEED end
end)

muteBtn.MouseButton1Click:Connect(function()
	isMuted = not isMuted
	if isMuted then
		muteBtn.Image = ICON_OFF 
		currentSound.Volume = 0 
	else
		muteBtn.Image = ICON_ON 
		if not isNearEmote then
			TweenService:Create(currentSound, TweenInfo.new(0.5), {Volume = MAX_VOLUME}):Play()
		end
	end
end)

local function showNotification(data)
	titleLabel.Text = data.Title; authorLabel.Text = data.Author; stripe.BackgroundColor3 = data.Color or Color3.new(1,1,1)
	albumArt.Image = formatImageId(data.ImageId)
	container.Position = CONTAINER_HIDDEN_POS; muteBtn.Position = BTN_HIDDEN_POS; albumArt.Rotation = 0 
	isRotating = true 

	container:TweenPosition(CONTAINER_VISIBLE_POS, Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)
	muteBtn:TweenPosition(BTN_VISIBLE_POS, Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.6, true)

	task.delay(NOTIFICATION_DURATION, function()
		container:TweenPosition(CONTAINER_HIDDEN_POS, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true)
		muteBtn:TweenPosition(BTN_HIDDEN_POS, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.5, true)
		task.wait(0.5); isRotating = false 
	end)
end

local function playMusic(data)
	if not data then return end
	if currentSound.SoundId == data.SoundId and currentSound.IsPlaying then return end

	local fadeOut = TweenService:Create(currentSound, TweenInfo.new(FADE_TIME), {Volume = 0})
	fadeOut:Play(); fadeOut.Completed:Wait()

	currentSound.SoundId = data.SoundId
	currentSound:Play()
	showNotification(data)

	local targetVol = (isMuted or isNearEmote) and 0 or MAX_VOLUME
	local fadeIn = TweenService:Create(currentSound, TweenInfo.new(FADE_TIME), {Volume = targetVol})
	fadeIn:Play()
end

-- Fallback to check specific small zones inside a map
local function getZone()
	local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local overlapParams = OverlapParams.new(); overlapParams.FilterDescendantsInstances = {char}; overlapParams.FilterType = Enum.RaycastFilterType.Exclude

	local parts = Workspace:GetPartsInPart(char.HumanoidRootPart, overlapParams)
	for _, part in ipairs(parts) do
		if part.Parent and part.Parent.Name == ZONE_FOLDER_NAME then return part.Name end
	end
	return nil
end

-- [[ NEW: Triggered when the Cross is placed! ]]
DreamEvents:WaitForChild("DarkenAtmosphere").OnClientEvent:Connect(function()
	originalLighting.Ambient = Lighting.Ambient
	originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
	originalLighting.Brightness = Lighting.Brightness
	originalLighting.ClockTime = Lighting.ClockTime

	TweenService:Create(Lighting, TweenInfo.new(4), {
		Ambient = Color3.fromRGB(15, 15, 20),
		OutdoorAmbient = Color3.fromRGB(5, 5, 10),
		Brightness = 0.1,
		ClockTime = 0
	}):Play()

	isQuestActive = true -- This tells the Heartbeat loop to switch the music!
end)

-- [[ NEW: Triggered when the Bomb explodes! ]]
DreamEvents:WaitForChild("WakeUpFade").OnClientEvent:Connect(function()
	local sg = Instance.new("ScreenGui", playerGui)
	sg.IgnoreGuiInset = true 

	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1

	-- Fade to black
	local tw1 = TweenService:Create(frame, TweenInfo.new(2.5), {BackgroundTransparency = 0})
	tw1:Play()
	tw1.Completed:Wait()

	-- Restore Lighting and Music state while the screen is black
	resetQuestState()

	task.wait(2) 

	-- Fade back to reality
	local tw2 = TweenService:Create(frame, TweenInfo.new(2.5), {BackgroundTransparency = 1})
	tw2:Play()
	tw2.Completed:Wait()

	sg:Destroy()
end)

-- [[ FIX: Safety net for aborted quests ]]
-- WakeUpFade only ever fired on the quest's own successful conclusion. If a
-- player instead just wakes up normally mid-quest (or the shared dream ends
-- for any other reason), CurrentDreamStatus going back to "" is what that
-- looks like regardless of cause — so that's the signal that actually
-- guarantees quest state gets cleaned up.
currentDreamStatus:GetPropertyChangedSignal("Value"):Connect(function()
	if currentDreamStatus.Value == "" then
		resetQuestState()
	end
end)

RunService.Heartbeat:Connect(function()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	local currentlyNearEmote = false
	if myRoot then
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			local oChar = otherPlayer.Character
			local oRoot = oChar and oChar:FindFirstChild("HumanoidRootPart")
			if oRoot then
				local emoteSound = oRoot:FindFirstChild("EmoteMusic")
				if emoteSound and emoteSound.IsPlaying then
					local dist = (myRoot.Position - oRoot.Position).Magnitude
					if dist <= EMOTE_MUTE_RADIUS then currentlyNearEmote = true; break end
				end
			end
		end
	end

	if currentlyNearEmote ~= isNearEmote then
		isNearEmote = currentlyNearEmote
		if isNearEmote then TweenService:Create(currentSound, TweenInfo.new(1), {Volume = 0}):Play()
		else local targetVol = isMuted and 0 or MAX_VOLUME; TweenService:Create(currentSound, TweenInfo.new(1), {Volume = targetVol}):Play() end
	end

	local lightingPressure = game.Lighting:FindFirstChild("Pressure")
	local isBossActive = lightingPressure and lightingPressure.Enabled

	local expectedZone = nil

	-- [[ UPDATED: Check for Quest state first! ]]
	if isQuestActive then
		expectedZone = "QUEST_MODE"
	elseif isBossActive then
		expectedZone = "BOSS_MODE"
	else
		-- Checks micro-zones, then defaults to Map theme
		expectedZone = getZone() or "DEFAULT"
	end

	if expectedZone ~= currentZone then
		currentZone = expectedZone
		if currentZone == "QUEST_MODE" then
			playMusic(QuestMusicData)
		elseif currentZone == "BOSS_MODE" then
			playMusic(BossMusicData)
		elseif currentZone == "DEFAULT" then
			playMusic(GetDefaultMusic())
		elseif MusicData[currentZone] then
			playMusic(MusicData[currentZone])
		end
	end
end)

player.CharacterAdded:Connect(function()
	container.Position = CONTAINER_HIDDEN_POS
	muteBtn.Position = BTN_HIDDEN_POS
	isRotating = false
end)