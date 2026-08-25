-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")
local MugEvents = ReplicatedStorage:WaitForChild("MugEvents")
local MugAction = MugEvents:WaitForChild("MugAction")
local VoteStatusEvent = ReplicatedStorage:WaitForChild("DreamEvents"):WaitForChild("VoteStatus")

local FILL_DISTANCE_LIMIT = 2500 

-- [[ CONFIGURATION ]]
local LIQUID_STATS = {
	["Blood"] = { Type = "Heal", TotalAmount = 20, Duration = 4, Pulse = true, Color = Color3.fromRGB(255, 80, 120) },
	["Tap Water"] = { Type = "Heal", TotalAmount = 7, Duration = 3, Pulse = false, Color = Color3.fromRGB(0, 170, 255) },
	["Pond Water"] = { Type = "Heal", TotalAmount = 5, Duration = 3, Pulse = false, Color = Color3.fromRGB(0, 0, 127) },
	["Holy Water"] = { Type = "Heal", TotalAmount = 17, Duration = 5, Pulse = true, Color = Color3.fromRGB(253, 238, 255) },
	["Energy Drink"] = { Type = "Speed", Amount = 10, Duration = 5, Pulse = true, Color = Color3.fromRGB(0, 100, 255) },
	["Spring Water"] = { Type = "Jump", Amount = 75, Duration = 5, Pulse = true, Color = Color3.fromRGB(255, 255, 255) },
	["Salty Water"] = { Type = "Damage", TotalAmount = 20, Duration = 5, Pulse = true, Color = Color3.fromRGB(120, 255, 120), HeadColor = Color3.fromRGB(107, 142, 35) },
	["Spirit Water"] = { Type = "InstantDamage", TotalAmount = 50, Duration = 3, Pulse = true, Color = Color3.fromRGB(170, 0, 255), ScreenEffect = "Darken", EffectTime = 30, SoundId = "rbxassetid://138081686", SpecialAction = "GhostWalk"},
	["Dream Water"] = { Type = "Heal", TotalAmount = 5, Duration = 3, Pulse = false, Color = Color3.fromRGB(170, 0, 255) },
	["Water"] = { Type = "Heal", TotalAmount = 5, Duration = 3, Pulse = false, Color = Color3.fromRGB(85, 170, 255) },
	["Water?"] = { Type = "InstantDamage", Amount = 3, Pulse = false, Color = Color3.fromRGB(85, 170, 255), ScreenEffect = "Darken", EffectTime = 30, SoundId = "rbxassetid://138081686", SpecialAction = "GhostWalk" }
}

local REALM_TRANSFORMS = {
	NormalToDream = {
		["Pond Water"] = { { Chance = 0.05, Result = "Holy Water" }, { Chance = 1.00, Result = "Pond Water" } },
		["Water"] = "Dream Water", 
		["Holy Water"] = "Pond Water", 
		["Salty Water"] = "Water?", 
		["Spring Water"] = "Energy Drink" 
	},
	DreamToNormal = { 
		["Dream Water"] = "Water", 
		["Holy Water"] = "Pond Water", 
		["Water?"] = "Salty Water", 
		["Energy Drink"] = "Spring Water" 
	}
}

local DREAM_COLLECT_OVERRIDES = { 
	["Holy Water"] = "Pond Water", 
	["Salty Water"] = "Water?" 
}

local activeDrinkers = {}

local function findDeep(parent, name) for _, child in pairs(parent:GetDescendants()) do if child.Name == name then return child end end return nil end

local function isDreaming() 
	return currentDreamStatus.Value ~= "" 
end

local function updateMugVisuals(tool, liquidName)
	if not tool then return end

	local liquid, sparkles = findDeep(tool, "Liquid"), findDeep(tool, "Sparkles")
	local currentEffect = tool:FindFirstChild("CurrentEffect") or Instance.new("StringValue", tool); currentEffect.Name = "CurrentEffect"

	if not liquidName or liquidName == "" then
		if liquid then liquid.Transparency = 1 end
		if sparkles then sparkles.Enabled = false end
		currentEffect.Value = ""; tool.ToolTip = "Empty Mug"
	else
		local stats = LIQUID_STATS[liquidName]
		local color = stats and stats.Color or Color3.new(1,1,1)
		if liquid then liquid.Transparency = 0; liquid.Color = color; liquid.Material = Enum.Material.Neon end
		if sparkles then
			if sparkles:IsA("Sparkles") then sparkles.SparkleColor = color elseif sparkles:IsA("ParticleEmitter") then sparkles.Color = ColorSequence.new(color) elseif sparkles:IsA("Light") then sparkles.Color = color end
			sparkles.Enabled = true
		end
		currentEffect.Value = liquidName; tool.ToolTip = liquidName
	end
end

local function triggerGhostWalk(player, duration)
	local targets = {}
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "Important" then table.insert(targets, v) end
	end
	if #targets == 0 then return end

	-- Apply Effect
	for _, part in pairs(targets) do
		if not part:GetAttribute("GhostActive") then
			part:SetAttribute("OriginalTransparency", part.Transparency) 
			part:SetAttribute("GhostActive", true)
		end

		part.CanCollide = false
		part.Transparency = 0.5 

		if not part:FindFirstChild("GhostSparkles") then
			local s = Instance.new("Sparkles", part); s.SparkleColor = Color3.new(1,1,1); s.Name = "GhostSparkles"
		end
	end

	-- Cleanup after duration
	task.delay(duration, function()
		for _, part in pairs(targets) do
			if part and part:GetAttribute("GhostActive") then
				part.CanCollide = true
				local original = part:GetAttribute("OriginalTransparency")
				part.Transparency = original or 0
				part:SetAttribute("OriginalTransparency", nil)
				part:SetAttribute("GhostActive", nil)
				if part:FindFirstChild("GhostSparkles") then part.GhostSparkles:Destroy() end
			end
		end
	end)
end

local function checkRealmTransform(player)
	local currentLiquid = player:GetAttribute("SavedMugLiquid")
	if not currentLiquid or currentLiquid == "" then return end

	local dreaming = isDreaming()
	local mapping = dreaming and REALM_TRANSFORMS.NormalToDream or REALM_TRANSFORMS.DreamToNormal
	local rawTransform = mapping[currentLiquid]
	local newVal = currentLiquid

	if rawTransform then
		if type(rawTransform) == "string" then 
			newVal = rawTransform
		elseif type(rawTransform) == "table" then
			local rng = math.random()
			for _, outcome in ipairs(rawTransform) do 
				if rng <= outcome.Chance then newVal = outcome.Result; break end 
			end
		end
	end

	if newVal ~= currentLiquid then
		player:SetAttribute("SavedMugLiquid", newVal)
		if player.Character then updateMugVisuals(player.Character:FindFirstChild("MagicMug"), newVal) end
		if player.Backpack then updateMugVisuals(player.Backpack:FindFirstChild("MagicMug"), newVal) end
	end
end

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("SavedMugLiquid", "")

	player:GetAttributeChangedSignal("SavedMugLiquid"):Connect(function()
		local newLiquid = player:GetAttribute("SavedMugLiquid")

		-- Look for the mug in their hands or in their backpack
		local char = player.Character
		local mug = nil
		if char then mug = char:FindFirstChild("MagicMug") end
		if not mug and player.Backpack then mug = player.Backpack:FindFirstChild("MagicMug") end

		-- Redraw it instantly!
		if mug then
			updateMugVisuals(mug, newLiquid)
		end
	end)

	player.CharacterAdded:Connect(function(char)
		activeDrinkers[player.UserId] = nil
		task.wait(1) 
		-- Check if Distributor gave them a mug, if so, update its liquid color
		local mug = player.Backpack:FindFirstChild("MagicMug") or char:FindFirstChild("MagicMug")
		if mug then
			updateMugVisuals(mug, player:GetAttribute("SavedMugLiquid"))
		end
	end)
end)

currentDreamStatus.Changed:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		checkRealmTransform(player)
	end
end)

MugAction.OnServerEvent:Connect(function(player, action, targetPart)
	local char = player.Character; 
	local tool = char and char:FindFirstChild("MagicMug"); 
	if not tool or activeDrinkers[player.UserId] then return end

	local root = char:FindFirstChild("HumanoidRootPart"); 
	if not root then return end; 

	if targetPart and (targetPart.Position - root.Position).Magnitude > FILL_DISTANCE_LIMIT then return end

	if action == "Fill" and targetPart then
		local effect = targetPart:FindFirstChild("Effect") or (targetPart.Parent and targetPart.Parent:FindFirstChild("Effect"))
		if effect then 
			local final = effect.Value
			if isDreaming() and DREAM_COLLECT_OVERRIDES[final] then 
				final = DREAM_COLLECT_OVERRIDES[final] 
			end
			player:SetAttribute("SavedMugLiquid", final)
			updateMugVisuals(tool, final)
		end

	elseif action == "Drink" then
		local liquid = player:GetAttribute("SavedMugLiquid")
		if not liquid or liquid == "" then return end

		activeDrinkers[player.UserId] = true
		local stats = LIQUID_STATS[liquid]

		local handle = tool:FindFirstChild("Handle")
		if handle and handle:FindFirstChild("DrinkSound") then handle.DrinkSound:Play() end

		tool.GripPos = Vector3.new(1.5, -0.5, 0.3)
		task.wait(3)
		tool.GripPos = Vector3.new(0.03, 0, 0)

		if stats then
			if stats.ScreenEffect then VoteStatusEvent:FireClient(player, "ScreenEffect", stats.ScreenEffect, stats.EffectTime) end
			if stats.SoundId then local s = Instance.new("Sound", char.Head); s.SoundId = stats.SoundId; s.Volume = 1; s.PlayOnRemove = true; s:Destroy() end
			if stats.Pulse then local hl = Instance.new("Highlight", char); hl.FillColor = stats.Color; game.Debris:AddItem(hl, stats.Duration) end

			if stats.SpecialAction == "GhostWalk" then
				triggerGhostWalk(player, stats.EffectTime)
			end

			local hum = char:FindFirstChild("Humanoid")
			if hum then
				if stats.Type == "Heal" then task.spawn(function() for i=1,10 do hum.Health = math.min(hum.Health + (stats.TotalAmount/10), hum.MaxHealth); task.wait(0.5) end end)
				elseif stats.Type == "InstantDamage" then hum:TakeDamage(stats.Amount or 0) 
				elseif stats.Type == "Damage" then char:SetAttribute("MugDamageActive", true); task.spawn(function() for i=1,25 do hum:TakeDamage(stats.TotalAmount/25); if math.random() > 0.7 then hum.Jump = true end; task.wait(0.2) end; char:SetAttribute("MugDamageActive", nil) end)
				elseif stats.Type == "Speed" then hum.WalkSpeed = stats.Amount; task.delay(stats.Duration, function() hum.WalkSpeed = 16 end) 
			
				elseif stats.Type == "Jump" then 
					hum.UseJumpPower = true 
					hum.JumpPower = stats.Amount 
					task.delay(stats.Duration, function() 
						if hum then hum.JumpPower = 50 end -- Reset to standard JumpPower
					end)
				end
			end
		end
		player:SetAttribute("SavedMugLiquid", "")
		updateMugVisuals(tool, "")
		activeDrinkers[player.UserId] = nil
	end
end)