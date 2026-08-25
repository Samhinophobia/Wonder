-- @ScriptType: ModuleScript
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScarlettShardService = {}

local REQUIRED_SHARDS = 5
local shardCount = 0
local memoryTriggered = false

local orbTemplate = ServerStorage:WaitForChild("AmaryllisMemoryOrb")

local publicShardCount = ReplicatedStorage:FindFirstChild("ScarlettTotalShards")
if not publicShardCount then
	publicShardCount = Instance.new("IntValue")
	publicShardCount.Name = "ScarlettTotalShards"
	publicShardCount.Parent = ReplicatedStorage
end

local dreamEvents = ReplicatedStorage:FindFirstChild("DreamEvents")
local triggerRemote = dreamEvents:FindFirstChild("TriggerMemoryOrb")
if not triggerRemote then
	triggerRemote = Instance.new("RemoteEvent")
	triggerRemote.Name = "TriggerMemoryOrb"
	triggerRemote.Parent = dreamEvents
end

triggerRemote.OnServerEvent:Connect(function(player)
	if shardCount >= REQUIRED_SHARDS and not memoryTriggered then
		ScarlettShardService:TriggerMemorySequence()
	end
end)

function ScarlettShardService:GetShardCount()
	return shardCount
end

function ScarlettShardService:HasMemoryTriggered()
	return memoryTriggered
end

function ScarlettShardService:GiveShard(player)
	if memoryTriggered then return end

	shardCount += 1
	publicShardCount.Value = shardCount
	print("Shard Given. Total:", shardCount)
end

function ScarlettShardService:TriggerMemorySequence()
	if memoryTriggered then return end
	memoryTriggered = true

	local scarlettModel
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Red" and obj:FindFirstChild("Humanoid") then
			scarlettModel = obj
			break
		end
	end

	local orbTarget = workspace:FindFirstChild("AmaryllisOrbDestination", true)

	if not scarlettModel or not orbTarget then
		warn("Could not find Scarlett ('Red') Model or the Orb Destination!")
		return
	end

	local root = scarlettModel:FindFirstChild("HumanoidRootPart") or scarlettModel.PrimaryPart
	if not root then return end

	task.spawn(function()
		local highlight = scarlettModel:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 100, 150)
		highlight.OutlineColor = Color3.fromRGB(255, 100, 150)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = scarlettModel

		for i = 1, 4 do
			local fadeIn = TweenService:Create(highlight, TweenInfo.new(0.4), {FillTransparency = 0.3, OutlineTransparency = 0.5})
			local fadeOut = TweenService:Create(highlight, TweenInfo.new(0.4), {FillTransparency = 1, OutlineTransparency = 1})

			fadeIn:Play()
			fadeIn.Completed:Wait()
			fadeOut:Play()
			fadeOut.Completed:Wait()
		end
		highlight:Destroy()
	end)

	local sfx = Instance.new("Sound", root)
	sfx.SoundId = "rbxassetid://6008620807"
	sfx.Volume = 0.7
	sfx:Play()

	local orb = orbTemplate:Clone()
	orb.CFrame = root.CFrame * CFrame.new(0, 3, -2)
	orb.Anchored = true
	orb.CanCollide = false
	orb.Parent = workspace

	-- 1. Pop Up Animation
	local popUpTween = TweenService:Create(orb, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {CFrame = orb.CFrame * CFrame.new(0, 3, 0)})
	popUpTween:Play()
	popUpTween.Completed:Wait()

	
	local endPos = orbTarget:IsA("Attachment") and orbTarget.WorldPosition or orbTarget.Position

	-- 2. Move to Destination
	local moveTween = TweenService:Create(orb, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = CFrame.new(endPos)})
	moveTween:Play()
	moveTween.Completed:Wait()


	local baseCF = CFrame.new(endPos)


	local floatInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local floatTween = TweenService:Create(orb, floatInfo, {
		CFrame = baseCF * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, math.pi, 0) 
	})

	floatTween:Play()

	--print("Memory Orb Spawned & Reached Destination")
end

function ScarlettShardService:Reset()
	shardCount = 0
	publicShardCount.Value = 0
	memoryTriggered = false
	--print("Scarlett shard data wiped for new map.")
end

return ScarlettShardService