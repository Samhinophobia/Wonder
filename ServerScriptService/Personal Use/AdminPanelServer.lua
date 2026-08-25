-- @ScriptType: Script


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- [[ EVENT SETUP ]]
local adminEvent = ReplicatedStorage:FindFirstChild("AdminCommandEvent")
if not adminEvent then
	adminEvent = Instance.new("RemoteEvent")
	adminEvent.Name = "AdminCommandEvent"
	adminEvent.Parent = ReplicatedStorage
end

local adminForceOutfit = ServerStorage:FindFirstChild("AdminForceOutfit")
if not adminForceOutfit then
	adminForceOutfit = Instance.new("BindableEvent")
	adminForceOutfit.Name = "AdminForceOutfit"
	adminForceOutfit.Parent = ServerStorage
end

-- [[ SECURE WHITELIST ]]
local ADMINS = {
	[779537167] = true,
	[3762045417] = true,
	[7745255477] = true,
	[4477038552] = true, --Humdgueon - Testing reasons
	[5782558987] = true, --LunarLaw
}

-- [[ HELPER: SMART FIND PLAYER ]]
local function findPlayer(nameStr)
	if not nameStr then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name):find(string.lower(nameStr)) or string.lower(p.DisplayName):find(string.lower(nameStr)) then
			return p
		end
	end
	return nil
end

-- [[ HELPER: SMART FIND DREAM MAP ]]
local function findDreamName(searchStr)
	if not searchStr or searchStr == "" then return nil end
	local mapsFolder = ServerStorage:FindFirstChild("Maps")
	if not mapsFolder then return nil end

	for _, map in ipairs(mapsFolder:GetChildren()) do
		if string.find(string.lower(map.Name), string.lower(searchStr)) then
			return map.Name 
		end
	end
	return nil
end

-- [[ HELPER: SMART FIND LIQUID ]]
local function findLiquidName(searchStr)
	local VALID_LIQUIDS = {
		"Blood", "Tap Water", "Pond Water", "Holy Water", "Energy Drink", 
		"Spring Water", "Salty Water", "Lava", "Dream Water", "Water", "Water?"
	}

	local lowerSearch = string.lower(searchStr)
	for _, liq in ipairs(VALID_LIQUIDS) do
		if string.find(string.lower(liq), lowerSearch) then
			return liq
		end
	end
	return nil
end

-- [[ HELPER: SMART FIND ADMIN TOOL (NEW) ]]
local function findAdminTool(searchStr)
	if not searchStr or searchStr == "" then return nil end

	-- Look specifically in the AdminTools folder!
	local toolsFolder = ServerStorage:FindFirstChild("AdminTools")
	if not toolsFolder then 
		warn("Could not find 'AdminTools' folder in ServerStorage!")
		return nil 
	end

	local lowerSearch = string.lower(searchStr)
	for _, item in ipairs(toolsFolder:GetChildren()) do
		if item:IsA("Tool") and string.find(string.lower(item.Name), lowerSearch) then
			return item
		end
	end
	return nil
end


adminEvent.OnServerEvent:Connect(function(caller, commandString)
	if not ADMINS[caller.UserId] then 
		warn(caller.Name .. " attempted to fire an admin command without permission!")
		return 
	end

	local args = string.split(commandString, " ")
	local cmd = string.lower(args[1] or "")
	local target = findPlayer(args[2])


	if cmd == "kick" and target then
		local reason = table.concat(args, " ", 3)
		if reason == "" then reason = "You have been removed from the server." end
		target:Kick("Kicked by Admin: " .. reason)
		print("Kicked " .. target.Name)

	elseif cmd == "erase" and target then
		if target.Character then target.Character:Destroy() end
		task.wait(0.5) 
		target:Kick("You have been erased from the script.")
		print("Erased " .. target.Name)

	elseif cmd == "vanish" and target and target.Character then
		local char = target.Character
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			task.spawn(function()
				local hl = Instance.new("Highlight", char)
				hl.FillColor = Color3.fromRGB(255, 255, 255)
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.FillTransparency = 1

				local partsToFade = {}
				for _, desc in ipairs(char:GetDescendants()) do
					if desc:IsA("BasePart") or desc:IsA("Decal") then
						table.insert(partsToFade, {part = desc, origTrans = desc.Transparency})
					end
				end

				local steps = 55; local waitTime = 5.5 / steps
				for i = 1, steps do
					if not char or not char.Parent then break end 
					hl.FillTransparency = 0.3 + 0.7 * math.abs(math.sin(i * 0.4))
					for _, data in ipairs(partsToFade) do
						if data.part and data.part.Parent then
							data.part.Transparency = data.origTrans + (1 - data.origTrans) * (i / steps)
						end
					end
					task.wait(waitTime)
				end
				if hl then hl:Destroy() end
				if hum and hum.Parent then hum.Health = 0 end
			end)
		end

	
	elseif cmd == "setdream" then
		local searchStr = table.concat(args, " ", 2)
		local fullDreamName = findDreamName(searchStr)
		if fullDreamName then
			_G.ForcedNextDream = fullDreamName
		end


	elseif cmd == "liquid" then
		if target then
			local searchStr = table.concat(args, " ", 3)
			local exactLiquidName = findLiquidName(searchStr)

			if exactLiquidName then
				target:SetAttribute("SavedMugLiquid", exactLiquidName)
				print("Filled " .. target.Name .. "'s mug with " .. exactLiquidName)

				if target.Character then
					local tool = target.Character:FindFirstChild("MagicMug") or (target.Backpack and target.Backpack:FindFirstChild("MagicMug"))
					if tool then
						local hum = target.Character:FindFirstChild("Humanoid")
						if hum then hum:UnequipTools() end
					end
				end
			else
				warn("Could not find liquid matching: " .. searchStr)
			end
		end

	
	elseif cmd == "give" then
		if target then
			local searchStr = table.concat(args, " ", 3)
			local itemTemplate = findAdminTool(searchStr)

			if itemTemplate then
				itemTemplate:Clone().Parent = target.Backpack
				print("Gave " .. itemTemplate.Name .. " to " .. target.Name)
			else
				warn("Could not find tool in AdminTools matching: " .. searchStr)
			end
		end

	elseif cmd == "morph" or cmd == "outfit" then
		if target and adminForceOutfit then
			local style = string.lower(args[3] or "default")
			adminForceOutfit:Fire(target, style)
		end


	elseif cmd == "speed" and target and target.Character then
		local hum = target.Character:FindFirstChild("Humanoid")
		if hum and args[3] then hum.WalkSpeed = tonumber(args[3]) end

	elseif cmd == "jump" and target and target.Character then
		local hum = target.Character:FindFirstChild("Humanoid")
		if hum and args[3] then
			hum.UseJumpPower = true
			hum.JumpPower = tonumber(args[3])
		end

	elseif cmd == "hp" and target and target.Character then
		local hum = target.Character:FindFirstChild("Humanoid")
		if hum and args[3] then
			hum.MaxHealth = tonumber(args[3])
			hum.Health = tonumber(args[3])
		end


	elseif cmd == "bring" and target and target.Character and caller.Character then
		local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
		local cHRP = caller.Character:FindFirstChild("HumanoidRootPart")
		if tHRP and cHRP then tHRP.CFrame = cHRP.CFrame * CFrame.new(0, 0, -3) end

	elseif cmd == "tp" and target and target.Character and caller.Character then
		local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
		local cHRP = caller.Character:FindFirstChild("HumanoidRootPart")
		if tHRP and cHRP then cHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3) end
	end
end)