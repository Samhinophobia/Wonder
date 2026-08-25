-- @ScriptType: Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Janitor = require(script.Parent.Janitor)

-- CONFIGURATION
local COMMAND = "!paced"
local SYNC_RADIUS = 25
local DUO_JOIN_RADIUS = 10

-- Since your duo was authored with both rigs at the same origin,
-- keep the default offset basically zero and only flip the follower to face back.
local DEFAULT_DUO_OFFSET = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0)

local DEFAULT_SPIRAL_ID = "rbxassetid://132237339151423"
local VIP_SPIRALS = {
	[4477038552] = "rbxassetid://107846289553416",
	[22156521]   = "rbxassetid://112212901659242",
	[986225083]  = "rbxassetid://107846289553416",
	[2978454934] = "rbxassetid://118784099004138",
}

local dummyRigsFolder = ServerStorage:FindFirstChild("DummyRigs")

-- Load every emote module by name
local emoteModules = {}
for _, mod in ipairs(script.Parent.Emotes:GetChildren()) do
	local emoteData = require(mod)
	emoteData.Name = mod.Name
	emoteModules[mod.Name] = emoteData
end

local activeEmotes = {}

local function setCharacterCollision(character, canCollide)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = canCollide
		end
	end
end

local function attachDummy(leaderPlayer, emote, leaderData)
	local leaderChar = leaderPlayer.Character
	if not leaderChar then return end

	local leaderHRP = leaderChar:FindFirstChild("HumanoidRootPart")
	if not leaderHRP then return end

	local template = dummyRigsFolder and (dummyRigsFolder:FindFirstChild(emote.Name) or dummyRigsFolder:FindFirstChild("Default"))
	if not template then return end
	if not emote.FollowAnim then return end

	local janitor = Janitor.new()
	local dummy = janitor:Add(template:Clone())
	local dummyHum = dummy:FindFirstChild("Humanoid")
	local dummyHRP = dummy:FindFirstChild("HumanoidRootPart")
	if not dummyHum or not dummyHRP then
		janitor:Destroy()
		return
	end

	local animator = dummyHum:FindFirstChild("Animator") or Instance.new("Animator", dummyHum)

	local followAnim = Instance.new("Animation")
	followAnim.AnimationId = emote.FollowAnim
	local followTrack = janitor:Add(animator:LoadAnimation(followAnim))
	followTrack.Priority = Enum.AnimationPriority.Action
	followTrack.Looped = true

	for _, obj in ipairs(dummy:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
			obj.Anchored = false
			obj.Massless = true
		end
	end

	dummyHRP.Anchored = true
	dummyHRP.CFrame = leaderHRP.CFrame * (emote.DuoOffset or DEFAULT_DUO_OFFSET)
	dummy.Parent = workspace

	followTrack:Play()
	if leaderData.Track then
		followTrack.TimePosition = leaderData.Track.TimePosition
	end

	leaderData.Dummy = dummy
	leaderData.FollowJanitor = janitor
end

local function revertLeaderToDummy(leaderPlayer)
	local leaderData = activeEmotes[leaderPlayer]
	if not leaderData then return end

	leaderData.PartnerPlayer = nil
	attachDummy(leaderPlayer, leaderData.Emote, leaderData)
end

local function stopEmote(player, _skipPartnerCascade)
	local data = activeEmotes[player]
	if not data then return end
	activeEmotes[player] = nil

	if data.Emote.OnStop then
		task.spawn(data.Emote.OnStop, data.Ctx)
	end

	if data.FollowJanitor then
		data.FollowJanitor:Destroy()
		data.FollowJanitor = nil
		data.Dummy = nil
	end

	if data.PartnerPlayer then
		if data.Role == "Follower" then
			if not _skipPartnerCascade then
				revertLeaderToDummy(data.PartnerPlayer)
			end
		else
			if not _skipPartnerCascade then
				stopEmote(data.PartnerPlayer, true)
			end
		end
	end

	data.Janitor:Destroy()
end

local function getEmoteForCharacter(char)
	local skin = char:GetAttribute("ActiveSkin")

	if skin == "ButcherKarma" or skin == "ButcherPatrico" then
		return emoteModules.Killer
	end

	if skin == "StarKarma" or skin == "StarPatrico" then
		return emoteModules.Stars
	end

	return emoteModules[skin] or emoteModules.Default
end

local function canStartEmote(char, emote)
	local skin = char:GetAttribute("ActiveSkin")

	if emote == emoteModules.Stars then
		return skin == "StarKarma" or skin == "StarPatrico"
	end

	return true
end

local function pickAudio(audio)
	if typeof(audio) == "table" then
		return audio[math.random(1, #audio)]
	end
	return audio
end

local function joinAsDuoFollower(followerPlayer, leaderPlayer, emote)
	local leaderData = activeEmotes[leaderPlayer]
	if not leaderData then return end

	local followerChar = followerPlayer.Character
	local leaderChar = leaderPlayer.Character
	if not followerChar or not leaderChar then return end

	local followerHRP = followerChar:FindFirstChild("HumanoidRootPart")
	local followerHum = followerChar:FindFirstChild("Humanoid")
	local leaderHRP = leaderChar:FindFirstChild("HumanoidRootPart")
	if not followerHRP or not followerHum or not leaderHRP or followerHum.Health <= 0 then return end
	if not emote.FollowAnim then return end

	if leaderData.FollowJanitor then
		leaderData.FollowJanitor:Destroy()
		leaderData.FollowJanitor = nil
		leaderData.Dummy = nil
	end

	local janitor = Janitor.new()
	local animator = followerHum:FindFirstChild("Animator") or Instance.new("Animator", followerHum)

	local followAnim = Instance.new("Animation")
	followAnim.AnimationId = emote.FollowAnim
	local followTrack = janitor:Add(animator:LoadAnimation(followAnim))
	followTrack.Priority = Enum.AnimationPriority.Action
	followTrack.Looped = true

	setCharacterCollision(followerChar, false)
	janitor:Add(function()
		if followerChar and followerChar.Parent then
			setCharacterCollision(followerChar, true)
		end
	end)

	followerHRP.Anchored = true
	followerHRP.CFrame = leaderHRP.CFrame * (emote.DuoOffset or DEFAULT_DUO_OFFSET)

	janitor:Add(function()
		if followerHRP and followerHRP.Parent then
			followerHRP.Anchored = false
		end
	end)

	followTrack:Play()
	if leaderData.Track then
		followTrack.TimePosition = leaderData.Track.TimePosition
	end

	janitor:Add(followerHum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if followerHum.MoveDirection.Magnitude > 0 then
			stopEmote(followerPlayer)
		end
	end))
	janitor:Add(followerHum.Died:Connect(function()
		stopEmote(followerPlayer)
	end))
	janitor:Add(followerChar:GetAttributeChangedSignal("OutfitChanged"):Connect(function()
		stopEmote(followerPlayer)
	end))

	local ctx = {
		Player = followerPlayer,
		Character = followerChar,
		HRP = followerHRP,
		Humanoid = followerHum,
		Janitor = janitor,
	}

	activeEmotes[followerPlayer] = {
		Emote = emote,
		Ctx = ctx,
		Janitor = janitor,
		Track = followTrack,
		SyncKey = emote.SyncKey,
		Role = "Follower",
		PartnerPlayer = leaderPlayer,
	}

	leaderData.PartnerPlayer = followerPlayer

	if emote.OnStart then
		task.spawn(emote.OnStart, ctx)
	end
end

local function startEmote(player)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end

	local emote = getEmoteForCharacter(char)
	if not emote then return end

	if not canStartEmote(char, emote) then
		return
	end

	-- Sync / block / duo-join check against nearby active emotes
	local syncTime = 0
	for otherPlr, data in pairs(activeEmotes) do
		if otherPlr ~= player and otherPlr.Character and otherPlr.Character:FindFirstChild("HumanoidRootPart") and data.Track then
			local dist = (hrp.Position - otherPlr.Character.HumanoidRootPart.Position).Magnitude
			if dist <= SYNC_RADIUS and data.Track.IsPlaying then
				if data.Emote == emoteModules.Stars and data.Role == "Leader" and not data.PartnerPlayer and dist <= DUO_JOIN_RADIUS then
					joinAsDuoFollower(player, otherPlr, data.Emote)
					return
				end

				if data.SyncKey ~= emote.SyncKey then
					return
				elseif emote.Duo and data.Role == "Leader" and not data.PartnerPlayer and dist <= DUO_JOIN_RADIUS then
					joinAsDuoFollower(player, otherPlr, emote)
					return
				elseif emote.Duo then
					return
				else
					syncTime = data.Track.TimePosition
				end
			end
		end
	end

	local janitor = Janitor.new()
	local animator = hum:FindFirstChild("Animator") or Instance.new("Animator", hum)

	setCharacterCollision(char, false)
	janitor:Add(function()
		if char and char.Parent then
			setCharacterCollision(char, true)
		end
	end)

	hrp.Anchored = true
	janitor:Add(function()
		if hrp and hrp.Parent then
			hrp.Anchored = false
		end
	end)

	-- Main loop animation
	local anim = Instance.new("Animation")
	anim.AnimationId = emote.LoopAnim
	local track = janitor:Add(animator:LoadAnimation(anim))
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true

	-- Optional windup animation
	local windupTrack = nil
	if emote.WindupAnim then
		local wAnim = Instance.new("Animation")
		wAnim.AnimationId = emote.WindupAnim
		windupTrack = janitor:Add(animator:LoadAnimation(wAnim))
		windupTrack.Priority = Enum.AnimationPriority.Action
		windupTrack.Looped = false
	end

	-- Music
	local sound = nil
	if emote.Audio then
		sound = janitor:Add(Instance.new("Sound"))
		sound.Name = "EmoteMusic"
		sound.SoundId = pickAudio(emote.Audio)
		sound.Looped = true
		sound.Volume = 1
		sound.RollOffMaxDistance = 40
		sound.Parent = hrp
	end

	-- Spiral disc
	local mySpiralId = VIP_SPIRALS[player.UserId] or DEFAULT_SPIRAL_ID

	local background = janitor:Add(Instance.new("Part"))
	background.Name = "SpiralDisc"
	background.Size = Vector3.new(0.1, 7, 7)
	background.Transparency = 1
	background.Massless = true
	background.CanCollide = false
	background.CanTouch = false
	background.CanQuery = false

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Cylinder
	mesh.Parent = background

	local decal = Instance.new("Decal")
	decal.Texture = mySpiralId
	decal.Transparency = 0.5
	decal.Face = Enum.NormalId.Right
	decal.Parent = background

	local weld = Instance.new("Weld")
	weld.Part0 = hrp
	weld.Part1 = background
	weld.C0 = CFrame.new(0, 0, 2.5) * CFrame.Angles(0, math.rad(90), 0)
	weld.Parent = background

	background.Parent = char

	local currentAngle = 0
	janitor:Add(RunService.Heartbeat:Connect(function(dt)
		if background.Parent then
			currentAngle = currentAngle + (math.rad(150) * dt)
			weld.C1 = CFrame.Angles(currentAngle, 0, 0)
		end
	end))

	-- Play logic
	if windupTrack and syncTime == 0 then
		windupTrack:Play()
		if sound then
			sound:Play()
		end

		task.spawn(function()
			windupTrack.Stopped:Wait()
			local data = activeEmotes[player]
			if data and data.Janitor == janitor then
				track:Play()
			end
		end)
	else
		track:Play()
		if sound then
			sound:Play()
		end
		if syncTime > 0 then
			track.TimePosition = syncTime
			if sound then
				sound.TimePosition = syncTime
			end
		end
	end

	janitor:Add(hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if hum.MoveDirection.Magnitude > 0 then
			stopEmote(player)
		end
	end))
	janitor:Add(hum.Died:Connect(function()
		stopEmote(player)
	end))
	janitor:Add(char:GetAttributeChangedSignal("OutfitChanged"):Connect(function()
		stopEmote(player)
	end))

	local ctx = {
		Player = player,
		Character = char,
		HRP = hrp,
		Humanoid = hum,
		Janitor = janitor,
	}

	activeEmotes[player] = {
		Emote = emote,
		Ctx = ctx,
		Janitor = janitor,
		Track = track,
		Sound = sound,
		SyncKey = emote.SyncKey,
		Role = "Leader",
		PartnerPlayer = nil,
	}

	if emote.OnStart then
		task.spawn(emote.OnStart, ctx)
	end

	if emote.Duo then
		attachDummy(player, emote, activeEmotes[player])
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if string.lower(msg) ~= COMMAND then return end
		if activeEmotes[player] then
			stopEmote(player)
		else
			startEmote(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	stopEmote(player)
end)
