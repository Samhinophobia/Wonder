-- @ScriptType: Script


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")


local ORB_EVENTS = {
	{
		TriggerWord = "Wake",
		RequiredDream = "Bibliotheca Infinita",
		BookName = "MagicBook",
		TargetName = "OrbDestination",
		OrbTemplateName = "MemoryOrb",
		TrailColor = Color3.fromRGB(150, 200, 255),
		FlightDuration = 5,
		Bounces = 4,
		BounceHeight = 2.5
	},
	{
		TriggerWord = "Honest",
		RequiredDream = "Bibliotheca Infinita",
		BookName = "MagicBook3",
		TargetName = "OrbDestination",
		OrbTemplateName = "MemoryOrb3",
		TrailColor = Color3.fromRGB(150, 200, 255),
		FlightDuration = 5,
		Bounces = 4,
		BounceHeight = 2.5
	},
	{
		TriggerWord = "Disappointment",
		RequiredDream = "Bibliotheca Infinita",
		BookName = "MagicBook2",
		TargetName = "OrbDestination",
		OrbTemplateName = "MemoryOrb2",
		TrailColor = Color3.fromRGB(255, 0, 0),
		FlightDuration = 5,
		Bounces = 4,
		BounceHeight = 2.5
	}
}


local activeOrbsByTarget = {}     
local destinationLocks = {}     

local KING_ID = 4477038552        


local function despawnOldOrb(orb)
	if not orb or not orb.Parent then return end

	
	local originalSize = orb.Size
	local pulseSize = originalSize * 1.3

	local pulseTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true)
	local pulseTween = TweenService:Create(orb, pulseTweenInfo, {Size = pulseSize})

	local sfx = Instance.new("Sound", orb)
	sfx.SoundId = "rbxassetid://6008620807"
	sfx.Volume = 0.5
	sfx:Play()

	pulseTween:Play()
	pulseTween.Completed:Wait()


	local fadeTween = TweenService:Create(orb, TweenInfo.new(1, Enum.EasingStyle.Linear), {Transparency = 1})
	fadeTween:Play()
	fadeTween.Completed:Wait()

	orb:Destroy()
end


local function triggerOrbSequence(config)
	local target = workspace:FindFirstChild(config.TargetName, true)
	local orbTemplate = ServerStorage:FindFirstChild(config.OrbTemplateName)

	if not target or not orbTemplate then
		warn("Missing Target or Orb Template for word '" .. config.TriggerWord .. "'.")
		destinationLocks[config.TargetName] = false
		return
	end


	if activeOrbsByTarget[config.TargetName] then
		despawnOldOrb(activeOrbsByTarget[config.TargetName])
		activeOrbsByTarget[config.TargetName] = nil
		task.wait(1.5) 
	end

	local startPos = nil
	local isSecretTriggered = false

	if string.lower(config.TriggerWord) == "disappointment" then
		local alactPlayer = Players:GetPlayerByUserId(KING_ID)


		if alactPlayer and alactPlayer.Character and alactPlayer.Character:FindFirstChild("HumanoidRootPart") then
			isSecretTriggered = true
			local char = alactPlayer.Character
			local hrp = char.HumanoidRootPart

			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(255, 0, 0)
			hl.OutlineColor = Color3.fromRGB(255, 0, 0)
			hl.FillTransparency = 1
			hl.Parent = char

	
			local sparkles = Instance.new("ParticleEmitter")
			sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
			sparkles.Size = NumberSequence.new(0.5)
			sparkles.Rate = 50
			sparkles.Speed = NumberRange.new(2, 4)
			sparkles.Parent = hrp

			
			for i = 1, 5 do
				if not char or not char.Parent then break end 
				local tIn = TweenService:Create(hl, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {FillTransparency = 0.2})
				tIn:Play(); tIn.Completed:Wait()

				if not char or not char.Parent then break end
				local tOut = TweenService:Create(hl, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {FillTransparency = 1})
				tOut:Play(); tOut.Completed:Wait()
			end

			
			if hl then hl:Destroy() end
			if sparkles then sparkles:Destroy() end

		
			if hrp and hrp.Parent then
				startPos = hrp.Position
			end
		end
	end


	if not startPos then
		local book = workspace:FindFirstChild(config.BookName, true)
		if not book then
			warn("Missing Book '" .. config.BookName .. "'.")
			destinationLocks[config.TargetName] = false
			return
		end
		startPos = book.Position
	end

	-- 3. CLONE THE ORB
	local orb = orbTemplate:Clone()
	orb.Position = startPos
	orb.Anchored = true
	orb.CanCollide = false

	-- 4. CREATE TRAIL
	local att0 = Instance.new("Attachment", orb)
	att0.Position = Vector3.new(0, orb.Size.Y / 2, 0)
	local att1 = Instance.new("Attachment", orb)
	att1.Position = Vector3.new(0, -orb.Size.Y / 2, 0)

	local trail = Instance.new("Trail", orb)
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Lifetime = 1.5
	trail.LightEmission = 1
	trail.Color = ColorSequence.new(config.TrailColor)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})

	orb.Parent = workspace


	local popUpGoal = {Position = startPos + Vector3.new(0, 6, 0)}
	local popTween = TweenService:Create(orb, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), popUpGoal)

	popTween:Play()
	popTween.Completed:Wait()
	task.wait(0.5) 


	local endPos = target.Position
	local elapsedTime = 0

	while elapsedTime < config.FlightDuration do
		elapsedTime = elapsedTime + RunService.Heartbeat:Wait()
		local alpha = math.min(elapsedTime / config.FlightDuration, 1)
		local easedAlpha = -(math.cos(math.pi * alpha) - 1) / 2
		local basePos = popUpGoal.Position:Lerp(endPos, easedAlpha)
		local waveOffset = math.sin(alpha * math.pi * config.Bounces) * config.BounceHeight
		orb.Position = basePos + Vector3.new(0, waveOffset, 0)
	end

	orb.Position = endPos 
	trail.Enabled = false

	local sound = Instance.new("Sound", orb)
	sound.SoundId = "rbxassetid://9119713990" 
	sound.Volume = 0.8
	sound:Play()


	local floatTween = TweenService:Create(
		orb, 
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
		{Position = endPos + Vector3.new(0, 1.5, 0)} 
	)
	floatTween:Play()

	local spinSpeed = 45 
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not orb or not orb.Parent then
			connection:Disconnect() 
			return
		end
		orb.CFrame = orb.CFrame * CFrame.Angles(0, math.rad(spinSpeed * dt), 0)
	end)

	activeOrbsByTarget[config.TargetName] = orb
	destinationLocks[config.TargetName] = false
end


local function setupPlayer(player)
	player.Chatted:Connect(function(msg)
		local lowerMsg = string.lower(msg)
		local currentDream = currentDreamStatus.Value

		for _, config in ipairs(ORB_EVENTS) do
			
			if currentDream == config.RequiredDream then
				if not destinationLocks[config.TargetName] then
					if string.find(lowerMsg, string.lower(config.TriggerWord)) then

						destinationLocks[config.TargetName] = true 

						task.spawn(function()
							triggerOrbSequence(config)
						end)

					end
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end


currentDreamStatus.Changed:Connect(function()
	-- Destroy all currently existing orbs
	for targetName, orb in pairs(activeOrbsByTarget) do
		if orb and orb.Parent then
			orb:Destroy()
		end
	end

	-- Wipe the trackers clean
	table.clear(activeOrbsByTarget)
	table.clear(destinationLocks)
end)