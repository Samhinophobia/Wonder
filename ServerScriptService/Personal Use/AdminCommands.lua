-- @ScriptType: Script
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local ADMINS = {
	["ricuano"] = true,
	["babymztr"] = true,
	["Torreesbloxfruits"] = true,
	["FrozenBindingDawn"] = true,
	["Huskared"] = true,
}

local toolsFolder = ServerStorage:WaitForChild("AdminTools")

local function findTargets(speaker, nameString)
	if not nameString then return {} end
	nameString = nameString:lower()
	local targets = {}
	if nameString == "me" then
		table.insert(targets, speaker)
	elseif nameString == "all" then
		for _, p in pairs(Players:GetPlayers()) do table.insert(targets, p) end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if string.find(p.Name:lower(), nameString) == 1 then table.insert(targets, p) end
		end
	end
	return targets
end

local function findTool(searchName)
	searchName = searchName:lower()
	if toolsFolder:FindFirstChild(searchName) then return toolsFolder[searchName] end
	for _, tool in pairs(toolsFolder:GetChildren()) do
		if string.find(tool.Name:lower(), searchName) == 1 then return tool end
	end
	return nil
end

local function enableFly(player)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	if root:FindFirstChild("FlyBP") then return end -- ya esta volando

	hum.PlatformStand = true

	local bp = Instance.new("BodyPosition")
	bp.Name = "FlyBP"
	bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bp.D = 1000
	bp.P = 10000
	bp.Position = root.Position
	bp.Parent = root

	local bg = Instance.new("BodyGyro")
	bg.Name = "FlyBG"
	bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bg.D = 400
	bg.CFrame = root.CFrame
	bg.Parent = root

	player:SetAttribute("IsFlying", true)
end

local function disableFly(player)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	local bp = root:FindFirstChild("FlyBP")
	local bg = root:FindFirstChild("FlyBG")
	if bp then bp:Destroy() end
	if bg then bg:Destroy() end

	hum.PlatformStand = false
	player:SetAttribute("IsFlying", false)
end

local function onChat(player, message)
	if not ADMINS[player.Name] and not ADMINS[player.UserId] then return end

	local args = message:split(" ")
	if #args < 1 then return end

	local command = args[1]:lower()
	local targetName = args[2]

	if command == ":give" and #args >= 3 then
		local toolSearchName = table.concat(args, " ", 3)
		local targets = findTargets(player, targetName)
		local toolTemplate = findTool(toolSearchName)
		if toolTemplate and #targets > 0 then
			for _, t in pairs(targets) do
				local newTool = toolTemplate:Clone()
				newTool.Parent = t.Backpack
				local sfx = Instance.new("Sound")
				sfx.SoundId = "rbxassetid://12221967"
				sfx.Parent = t.Character.Head
				sfx:Play()
				game.Debris:AddItem(sfx, 1)
			end
		end
	end

	if command == ":heal" then
		for _, t in pairs(findTargets(player, targetName)) do
			if t.Character then
				local hum = t.Character:FindFirstChild("Humanoid")
				if hum then hum.Health = hum.MaxHealth end
				local s = Instance.new("Sparkles", t.Character:FindFirstChild("HumanoidRootPart"))
				game.Debris:AddItem(s, 1)
			end
		end
	end

	if command == ":bring" then
		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			for _, t in pairs(findTargets(player, targetName)) do
				if t ~= player and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
					t.Character.HumanoidRootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, -4)
				end
			end
		end
	end

	if command == ":tp" or command == ":teleport" then
		if #args == 2 then
			local targets = findTargets(player, targetName)
			local dest = targets[1]
			if dest and dest.Character and dest.Character:FindFirstChild("HumanoidRootPart") then
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					player.Character.HumanoidRootPart.CFrame = dest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
				end
			end
		elseif #args >= 3 then
			local victims = findTargets(player, args[2])
			local destinations = findTargets(player, args[3])
			local dest = destinations[1]
			if dest and dest.Character and dest.Character:FindFirstChild("HumanoidRootPart") then
				for _, v in pairs(victims) do
					if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
						v.Character.HumanoidRootPart.CFrame = dest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
					end
				end
			end
		end
	end

	if command == ":set" and #args >= 4 then
		local statName = args[3]:lower()
		local value = tonumber(args[4])
		for _, t in pairs(findTargets(player, targetName)) do
			local ls = t:FindFirstChild("leaderstats")
			if ls and value then
				for _, s in pairs(ls:GetChildren()) do
					if s.Name:lower() == statName then s.Value = value end
				end
			end
		end
	end

	if command == ":kick" then
		local reason = #args >= 3 and table.concat(args, " ", 3) or "Kicked by Admin"
		for _, t in pairs(findTargets(player, targetName)) do
			t:Kick(reason)
		end
	end

	if command == ":clear" then
		player.Backpack:ClearAllChildren()
	end

	if command == ":fly" then
		for _, t in pairs(findTargets(player, targetName)) do
			if t:GetAttribute("IsFlying") then
				disableFly(t)
			else
				enableFly(t)
			end
		end
	end
end

local function onPlayerAdded(player)
	player.Chatted:Connect(function(message)
		onChat(player, message)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end
