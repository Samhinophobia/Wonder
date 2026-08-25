-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CutsceneEvent = ReplicatedStorage:WaitForChild("PlayCutscene")

local ALLOWED_ADMINS = {
	["ricuano"] = true,
	["babymztr"] = true,
	["Torreesbloxfruits"] = true,
	["FrozenbindingDawn"] = true,
	["Huskared"] = true,
}

local RICUANO_ID = 779537167
local TORRES_ID = 7745255477

local function applyDescFromPlayer(rig, player)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local desc = hum:GetAppliedDescription()
	if desc then
		-- Primero parental al workspace, luego aplica
		rig.Parent = workspace
		pcall(function() rig.Humanoid:ApplyDescription(desc) end)
	end
end

local function onPlayerChatted(adminPlayer, msg)
	if not ALLOWED_ADMINS[adminPlayer.Name] then return end

	local args = string.split(msg, " ")
	local command = string.lower(args[1])

	if command == "!lore" or command == "!custom" or command == "!scene" then

		local rig1 = ServerStorage:WaitForChild("Player1Rig"):Clone()
		local rig2 = ServerStorage:WaitForChild("AliceRig"):Clone()

		if command == "!custom" and args[2] and args[3] then
			local target1 = Players:FindFirstChild(args[2])
			local target2 = Players:FindFirstChild(args[3])
			if target1 and target2 then
				applyDescFromPlayer(rig1, target1)
				applyDescFromPlayer(rig2, target2)
				CutsceneEvent:FireAllClients("Normal", target1.Name, target2.Name)
			else
				warn("No se encontraron los jugadores en el servidor.")
				rig1:Destroy(); rig2:Destroy(); return
			end

		elseif command == "!scene" then
			local p1 = Players:FindFirstChild("ricuano") or Players:GetPlayerByUserId(RICUANO_ID)
			local p2 = Players:FindFirstChild("Torreesbloxfruits") or Players:GetPlayerByUserId(TORRES_ID)
			if p1 then applyDescFromPlayer(rig1, p1) else rig1.Parent = workspace end
			if p2 then applyDescFromPlayer(rig2, p2) else rig2.Parent = workspace end
			CutsceneEvent:FireAllClients("Normal", "ricuano", "Torreesbloxfruits")

		elseif command == "!lore" then
			rig1.Parent = workspace
			rig2.Parent = workspace
			CutsceneEvent:FireAllClients("Lore", "Alact", "Alice")
		end

		task.delay(20, function()
			if rig1 and rig1.Parent then rig1:Destroy() end
			if rig2 and rig2.Parent then rig2:Destroy() end
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg) onPlayerChatted(player, msg) end)
end)
for _, player in pairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(msg) onPlayerChatted(player, msg) end)
end
