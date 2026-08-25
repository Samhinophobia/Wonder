-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams") 
local ServerScriptService = game:GetService("ServerScriptService")
local ScarlettShardService = require(ServerScriptService:WaitForChild("ScarlettShardService"))


local DataStoreService = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")
local playerData = DataStoreService:GetDataStore("FrozenSoulData_v1")
local FIRST_DREAM_BADGE_ID = 4312280043259056


local pressureEffect = Lighting:FindFirstChild("Pressure")
if pressureEffect then
	pressureEffect.Enabled = false
end

local defaultLightingBackup = Instance.new("Folder")
defaultLightingBackup.Name = "DefaultLightingBackup"
defaultLightingBackup.Parent = ServerStorage

for _, child in ipairs(Lighting:GetChildren()) do
	if not child:IsA("Script") then
		child:Clone().Parent = defaultLightingBackup
	end
end

local defaultProperties = {
	Ambient = Lighting.Ambient,
	Brightness = Lighting.Brightness,
	ColorShift_Bottom = Lighting.ColorShift_Bottom,
	ColorShift_Top = Lighting.ColorShift_Top,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ShadowSoftness = Lighting.ShadowSoftness,
	GeographicLatitude = Lighting.GeographicLatitude,
	ExposureCompensation = Lighting.ExposureCompensation,
	FogColor = Lighting.FogColor,
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd
}

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus") 

local function updateTimeBasedLighting()
	if currentDreamStatus.Value == "" then
		if Lighting.ClockTime >= 18 or Lighting.ClockTime < 6 then
			Lighting.OutdoorAmbient = Color3.fromRGB(54, 54, 54)
			Lighting.FogColor = Color3.fromRGB(192, 192, 192)
			Lighting.Ambient = Color3.fromRGB(36, 36, 36)
		else
			Lighting.OutdoorAmbient = defaultProperties.OutdoorAmbient
			Lighting.FogColor = defaultProperties.FogColor
			Lighting.Ambient = defaultProperties.Ambient
		end
	end
end

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(updateTimeBasedLighting)

local COOLDOWN_TIME = 15 
local COUNTDOWN_TIME = 5
local LOAD_DELAY_TIME = 4 
local KING_ID = 4477038552
local RARE_AUDIO_ID = "rbxassetid://92039715426333"

local DREAM_MAP_NAMES = {
	"Bibliotheca Infinita", "Nivalis", "Taberna", "Convivium Potationis Perpetuum"
}

local events = ReplicatedStorage:WaitForChild("DreamEvents")
local voteStatusEvent = events:WaitForChild("VoteStatus")
local sendVoteEvent = events:WaitForChild("SendVote")

local isDreamActive = false
local isVoting = false
local isOnCooldown = false
local votes = {} 
local voteType = "Sleep" 
local lastMapName = ""

local mainMap = workspace:WaitForChild("MainMap") 
local mapsFolder = ServerStorage:WaitForChild("Maps")
local currentDreamMap = nil 
local currentClickConnection = nil
local tempPlatforms = {} 

local function setupTeams()
	local nightmare = Teams:FindFirstChild("Safe Place")
	if not nightmare then
		nightmare = Instance.new("Team"); nightmare.Name = "Safe Place"; nightmare.TeamColor = BrickColor.new("White"); nightmare.AutoAssignable = false; nightmare.Parent = Teams
	else nightmare.TeamColor = BrickColor.new("White") end

	local dreamers = Teams:FindFirstChild("Dreamers")
	if not dreamers then
		dreamers = Instance.new("Team"); dreamers.Name = "Dreamers"; dreamers.TeamColor = BrickColor.new("Really black"); dreamers.AutoAssignable = true; dreamers.Parent = Teams
	else dreamers.TeamColor = BrickColor.new("Really black") end
end

setupTeams()


local function loadData(player)
	local ls = Instance.new("Folder", player); ls.Name = "leaderstats"
	local souls = Instance.new("IntValue", ls); souls.Name = "Souls"
	local dreams = Instance.new("IntValue", ls); dreams.Name = "Dreams"

	-- [[ THE FIX: PARENT TO PLAYER INSTEAD OF LEADERSTATS TO HIDE IT ]]
	local luckCharm = Instance.new("BoolValue", player); luckCharm.Name = "LuckCharmActive"

	local s, d = pcall(function() return playerData:GetAsync("Player_" .. player.UserId) end)
	if s and d then 
		souls.Value = d.Souls or 0
		dreams.Value = d.Dreams or 0 
		luckCharm.Value = d.LuckCharmActive or false 
	end 
end

local function saveData(player)
	local ls = player:FindFirstChild("leaderstats")
	local luckCharm = player:FindFirstChild("LuckCharmActive") -- [[ FETCH FROM PLAYER ]]

	if ls then
		local data = {
			Souls = ls.Souls.Value, 
			Dreams = ls.Dreams.Value,
			LuckCharmActive = luckCharm and luckCharm.Value or false
		}
		pcall(function() playerData:SetAsync("Player_" .. player.UserId, data) end)
	end
end

-- Save on leave and server shutdown
Players.PlayerRemoving:Connect(saveData)
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveData(player)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.Neutral = false
	player.Team = Teams:FindFirstChild("Dreamers")

	loadData(player)
end)

local function updateAllClients(msg)
	voteStatusEvent:FireAllClients("UpdateTopText", msg)
end


local function securePlayersInPlace()
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			root.Anchored = true
			root.Velocity = Vector3.new(0, 0, 0)

			if not player.Character:FindFirstChild("TransitionSafety") then
				local ff = Instance.new("ForceField")
				ff.Name = "TransitionSafety"
				ff.Visible = false
				ff.Parent = player.Character
			end
		end
	end
end

local function freezeAndTeleport(targetCFrame)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum then hum.Sit = false; hum:ChangeState(Enum.HumanoidStateType.Physics) end


			local plat = Instance.new("Part")
			plat.Size = Vector3.new(200, 5, 200); plat.Anchored = true; plat.Transparency = 1; plat.CanCollide = true
			plat.Position = targetCFrame.Position - Vector3.new(0, 5, 0); plat.Parent = workspace
			table.insert(tempPlatforms, plat)

			root.CFrame = targetCFrame; root.Anchored = true; root.Velocity = Vector3.new(0,0,0)
		end
	end
end

local function unfreezePlayers()

	for _, p in pairs(tempPlatforms) do 
		if p then p:Destroy() end 
	end
	tempPlatforms = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local hum = player.Character:FindFirstChild("Humanoid")
			root.Anchored = false
			if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end


			local ff = player.Character:FindFirstChild("TransitionSafety")
			if ff then ff:Destroy() end
		end
	end
end

local function applyMapLighting(mapModel)

	for propName, propValue in pairs(defaultProperties) do
		pcall(function() Lighting[propName] = propValue end)
	end

	local settingsFolder = mapModel:FindFirstChild("LightingSettings")
	if not settingsFolder then return end 

	local clockTimeVal = settingsFolder:FindFirstChild("ClockTime")
	if clockTimeVal then Lighting.ClockTime = clockTimeVal.Value end

	local fogColorVal = settingsFolder:FindFirstChild("FogColor")
	if fogColorVal then Lighting.FogColor = fogColorVal.Value end

	local fogStartVal = settingsFolder:FindFirstChild("FogStart")
	if fogStartVal then Lighting.FogStart = fogStartVal.Value end

	local fogEndVal = settingsFolder:FindFirstChild("FogEnd")
	if fogEndVal then Lighting.FogEnd = fogEndVal.Value end

	for _, child in pairs(Lighting:GetChildren()) do
		if not child:IsA("Script") then child:Destroy() end
	end

	for _, child in pairs(settingsFolder:GetChildren()) do
		if not child:IsA("ValueBase") then
			child:Clone().Parent = Lighting
		end
	end
end

local function triggerKingEvent()
	local isKingPresent = false
	for _, p in pairs(Players:GetPlayers()) do
		if p.UserId == KING_ID then isKingPresent = true break end
	end
	if math.random(1, 100) <= (isKingPresent and 25 or 5) then
		local sound = Instance.new("Sound", workspace)
		sound.SoundId = RARE_AUDIO_ID; sound.Volume = 2; sound.PlayOnRemove = true; sound:Destroy()
		voteStatusEvent:FireAllClients("ShowIntroText", "Welcome to the Card Kingdom", Color3.fromRGB(255, 0, 0))
	end
end

local function finishVote()
	voteStatusEvent:FireAllClients("HideVote")
	local yesCount = 0
	local totalPlayers = #Players:GetPlayers()
	for _, vote in pairs(votes) do if vote == true then yesCount += 1 end end

	if yesCount > 0 and yesCount >= (totalPlayers / 2) then
		for i = COUNTDOWN_TIME, 1, -1 do
			updateAllClients("Transition in " .. i .. "...")
			if i <= 3 then voteStatusEvent:FireAllClients("PlaySound") end
			task.wait(1)
		end
		if voteType == "Sleep" then _G.LoadDream() else _G.UnloadDream() end
		task.wait(3)
		voteStatusEvent:FireAllClients("ClearTopText")
		isVoting = false
	else
		isOnCooldown = true
		updateAllClients("Vote Failed.")
		task.wait(3)
		voteStatusEvent:FireAllClients("ClearTopText") 
		isVoting = false 
		task.wait(math.max(0, COOLDOWN_TIME - 3))
		isOnCooldown = false
	end
end

local function startVote(player, type)
	if isVoting or isOnCooldown then return end
	isVoting = true; voteType = type; votes = {}; votes[player] = true 
	voteStatusEvent:FireAllClients("ShowVote", player.Name, type)
	updateAllClients("Vote initiated by " .. player.Name)
	task.wait(10) 
	finishVote()
end

local function connectButton(buttonPart, type)
	if currentClickConnection then currentClickConnection:Disconnect() end
	local clicker = buttonPart:FindFirstChild("ClickDetector")
	if clicker then
		currentClickConnection = clicker.MouseClick:Connect(function(player) startVote(player, type) end)
	end
end

_G.LoadDream = function()
	updateAllClients("ENTERING THE DREAM...")
	voteStatusEvent:FireAllClients("FadeOut") 


	securePlayersInPlace()

	task.wait(2.2) 
	mainMap.Parent = ServerStorage 

	local nextMapName = nil
	if _G.ForcedNextDream then
		if mapsFolder:FindFirstChild(_G.ForcedNextDream) then nextMapName = _G.ForcedNextDream end
		_G.ForcedNextDream = nil 
	end

	if not nextMapName then
		local availableMaps = {}
		for _, name in ipairs(DREAM_MAP_NAMES) do
			if name ~= lastMapName then table.insert(availableMaps, name) end
		end
		if #availableMaps == 0 then availableMaps = DREAM_MAP_NAMES end
		nextMapName = availableMaps[math.random(1, #availableMaps)]
	end

	lastMapName = nextMapName
	local selectedMapTemplate = mapsFolder:FindFirstChild(nextMapName)
	if not selectedMapTemplate then
		warn("MAP ERROR: Could not find '" .. tostring(nextMapName) .. "' in ServerStorage/Maps! Forcing Regnum Chartarum.")
		selectedMapTemplate = mapsFolder:FindFirstChild("Regnum Chartarum")
	end

	currentDreamMap = selectedMapTemplate:Clone()
	currentDreamMap.Parent = workspace
	currentDreamStatus.Value = currentDreamMap.Name 

	for _, team in pairs(Teams:GetTeams()) do
		if team.Name ~= "Dreamers" then team.Name = currentDreamMap.Name end
	end

	applyMapLighting(currentDreamMap)

	local spawnPoint = currentDreamMap:FindFirstChild("SpawnLocation") 
	local targetCFrame = spawnPoint and (spawnPoint.CFrame + Vector3.new(0, 10, 0)) or CFrame.new(0, 50, 0) 
	freezeAndTeleport(targetCFrame)

	for _, player in pairs(Players:GetPlayers()) do
		local stats = player:FindFirstChild("leaderstats")
		if stats then 
			stats.Souls.Value += 1 
			stats.Dreams.Value += 1 


			if stats.Dreams.Value == 1 then
				pcall(function()
					if not BadgeService:UserHasBadgeAsync(player.UserId, FIRST_DREAM_BADGE_ID) then
						BadgeService:AwardBadge(player.UserId, FIRST_DREAM_BADGE_ID)
					end
				end)
			end
		end
	end

	isDreamActive = true
	local wakePart = currentDreamMap:FindFirstChild("WakeUpPart", true) 
	if wakePart then connectButton(wakePart, "Wake") end

	if currentDreamMap.Name == "Regnum Chartarum" then triggerKingEvent() end

	task.wait(LOAD_DELAY_TIME) 
	unfreezePlayers() 
	voteStatusEvent:FireAllClients("FadeIn") 
end

_G.UnloadDream = function()
	updateAllClients("WAKING UP...")
	voteStatusEvent:FireAllClients("FadeOut", "Waking Up")


	securePlayersInPlace()

	task.wait(2.2)
	ScarlettShardService:Reset()
	if currentDreamMap then currentDreamMap:Destroy(); currentDreamMap = nil end
	mainMap.Parent = workspace
	currentDreamStatus.Value = "" 

	for _, team in pairs(Teams:GetTeams()) do
		if team.Name ~= "Dreamers" then team.Name = "Safe Place" end
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		if not child:IsA("Script") then child:Destroy() end
	end

	for _, child in ipairs(defaultLightingBackup:GetChildren()) do
		local clone = child:Clone()
		if clone.Name == "Pressure" then clone.Enabled = false end
		clone.Parent = Lighting
	end

	for propName, propValue in pairs(defaultProperties) do
		pcall(function() Lighting[propName] = propValue end)
	end

	Lighting.ClockTime = math.random() * 24
	updateTimeBasedLighting()

	local destPart = mainMap:FindFirstChild("DreamBed", true) or mainMap:FindFirstChild("SpawnLocation")
	local targetCFrame = destPart and (destPart.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 20, 0)
	freezeAndTeleport(targetCFrame)

	isDreamActive = false
	if mainMap:FindFirstChild("DreamBed", true) then connectButton(mainMap:FindFirstChild("DreamBed", true), "Sleep") end

	task.wait(LOAD_DELAY_TIME)
	unfreezePlayers()
	voteStatusEvent:FireAllClients("FadeIn")
end

currentDreamStatus.Value = "" 
task.wait(2) 
local initialBed = mainMap:FindFirstChild("DreamBed", true)
if initialBed then connectButton(initialBed, "Sleep") end

sendVoteEvent.OnServerEvent:Connect(function(player, voteChoice)
	if isVoting then votes[player] = voteChoice end
end)