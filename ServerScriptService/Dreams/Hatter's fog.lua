-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local dreamEvents = ReplicatedStorage:WaitForChild("DreamEvents")
local voteStatusEvent = dreamEvents:WaitForChild("VoteStatus")
local fogConsumedEvent = dreamEvents:WaitForChild("FogConsumed")

local resetFogEvent = dreamEvents:WaitForChild("ResetFogState") 

local TARGET_DREAM = "Convivium Potationis Perpetuum"

fogConsumedEvent.OnServerEvent:Connect(function(player)
	local char = player.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if hum and root and hum.Health > 0 then
		root.Anchored = true
		voteStatusEvent:FireClient(player, "FadeOut", "Let’s try that again...")
		task.wait(2.5) 

		local dreamMap = Workspace:FindFirstChild(TARGET_DREAM)
		local spawnPart = dreamMap and dreamMap:FindFirstChild("SpawnLocation")

		if spawnPart then
			char:PivotTo(spawnPart.CFrame + Vector3.new(0, 5, 0))
		else
			char:PivotTo(Workspace.MainMap.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
		end

		task.wait(1)

		-- [[ THE FIX: UNLOCK FOG ]]
		resetFogEvent:FireClient(player) 

		if player.Parent and char.Parent then
			voteStatusEvent:FireClient(player, "FadeIn")
			root.Anchored = false 
		end
	end
end)