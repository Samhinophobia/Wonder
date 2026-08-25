-- @ScriptType: Script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local ChatService = game:GetService("Chat")
local TweenService = game:GetService("TweenService")

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")
local playerData = DataStoreService:GetDataStore("FrozenSoulData_v1")

local KING_ID = 4477038552
local KING_GREETING = "Oh Hello my king!"
local KNIGHT_LINES = {
	"Taxes are due!", "The King demands payment!", "Pay your debt!", 
	"Surrender your souls!", "You cannot run from the Crown!"
}
local KNIGHT_NAMES = {
	"Royal Guard", "King's Strongest Knight", "Debt Collector", 
	"Palace Warden", "Card Soldier", "Crimson Enforcer"
}

local DREAM_MAPS = { ["Regnum Chartarum"] = true, ["Void"] = true }

-- Track active knights to kill them with "GO AWAY"
local ActiveKnights = {} 

local function fadeAndDestroy(model)
	if not model or not model.Parent then return end

	-- Remove from active list
	if ActiveKnights[model] then ActiveKnights[model] = nil end

	-- Fade Effect
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Decal") then
			TweenService:Create(part, TweenInfo.new(1), {Transparency = 1}):Play()
		end
		if part:IsA("BillboardGui") then
			part.Enabled = false
		end
	end

	-- Wait for fade then destroy
	task.wait(1.1)
	if model then model:Destroy() end
end

local function applyAnimations(knight, player)
	if not player or not player.Character then return end
	local playerAnim = player.Character:FindFirstChild("Animate")

	-- Clean old
	local old = knight:FindFirstChild("Animate")
	if old then old:Destroy() end

	if playerAnim then
		local clone = playerAnim:Clone()
		clone.Parent = knight
		clone.Disabled = true -- Reset
		task.wait()
		clone.Disabled = false -- Force Restart
	end
end

local function createKnightHUD(knight)
	local head = knight:WaitForChild("Head", 5)
	if not head then return end

	local bb = Instance.new("BillboardGui", head)
	bb.Name = "StatusHUD"
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true

	local nameLabel = Instance.new("TextLabel", bb)
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = KNIGHT_NAMES[math.random(1, #KNIGHT_NAMES)]
	nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.Sarpanch
	nameLabel.TextScaled = true

	local hpLabel = Instance.new("TextLabel", bb)
	hpLabel.Size = UDim2.new(1, 0, 0.3, 0)
	hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "HP: 100%"
	hpLabel.TextColor3 = Color3.new(1,1,1)
	hpLabel.TextStrokeTransparency = 0
	hpLabel.TextScaled = true

	-- Update HP loop
	local hum = knight:FindFirstChild("Humanoid")
	if hum then
		hum.HealthChanged:Connect(function()
			hpLabel.Text = "HP: " .. math.floor(hum.Health) .. "%"
		end)
	end
end


local function spawnDebtCollector(targetPlayer, duration)
	if not targetPlayer.Character then return end
	local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local lifeTime = duration or 15
	local steps = lifeTime * 2 
	local isKing = (targetPlayer.UserId == KING_ID)

	-- 1. Create Model
	local knight = nil
	local modelInStorage = ServerStorage:FindFirstChild("Knight")

	if modelInStorage then
		knight = modelInStorage:Clone()
	else
		-- Fallback Ghost
		knight = Instance.new("Model"); knight.Name = "Royal Guard"
		local part = Instance.new("Part", knight); part.Name = "HumanoidRootPart"; part.Size = Vector3.new(2, 5, 2); part.Color = isKing and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 0, 0); part.Material = Enum.Material.Neon; part.Transparency = 0.5; part.Anchored = false; part.CanCollide = false
		local head = Instance.new("Part", knight); head.Name = "Head"; head.Size = Vector3.new(1,1,1); head.Transparency = 1; head.CanCollide = false
		local hum = Instance.new("Humanoid", knight)
		local weld = Instance.new("WeldConstraint", part); weld.Part0 = part; weld.Part1 = head
	end

	knight.Parent = workspace
	local offset = Vector3.new(math.random(-10,10), 5, math.random(-10,10))
	knight:SetPrimaryPartCFrame(CFrame.new(root.Position + offset))

	-- Register to list
	ActiveKnights[knight] = true

	-- 2. Setup (Anims, HUD, Chat)
	applyAnimations(knight, targetPlayer)
	createKnightHUD(knight)

	task.delay(0.5, function()
		if knight and knight:FindFirstChild("Head") then
			local msg = isKing and KING_GREETING or KNIGHT_LINES[math.random(1, #KNIGHT_LINES)]
			local color = isKing and Enum.ChatColor.Blue or Enum.ChatColor.Red
			pcall(function() ChatService:Chat(knight.Head, msg, color) end)
		end
	end)

	-- 3. AI Loop
	task.spawn(function()
		local hum = knight:FindFirstChild("Humanoid")
		local kRoot = knight:FindFirstChild("HumanoidRootPart")

		for i = 1, steps do
			if not knight.Parent or not hum or hum.Health <= 0 then break end

			-- Refresh Target logic
			local currentCharacter = targetPlayer.Character
			local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
			local currentHum = currentCharacter and currentCharacter:FindFirstChild("Humanoid")

			if currentRoot and currentHum and currentHum.Health > 0 then
				hum:MoveTo(currentRoot.Position)

				-- Attack Logic (Ignores King)
				if not isKing then
					if (currentRoot.Position - kRoot.Position).Magnitude < 5 then
						currentHum:TakeDamage(5)

					
						-- Give souls to player to help them escape debt loop
						local ls = targetPlayer:FindFirstChild("leaderstats")
						local souls = ls and ls:FindFirstChild("Souls")
						if souls then
							souls.Value = souls.Value + 1 -- Gain 1 soul per hit taken
						end
					end
				end
			end
			task.wait(0.5)
		end

		fadeAndDestroy(knight)
	end)
end


Players.PlayerAdded:Connect(function(player)
	local ls = Instance.new("Folder", player); ls.Name="leaderstats"
	local souls = Instance.new("IntValue", ls); souls.Name = "Souls"
	local dreams = Instance.new("IntValue", ls); dreams.Name = "Dreams"
	local dVal = Instance.new("IntValue", player); dVal.Name="Dreaming"; dVal.Value = 0

	local s, d = pcall(function() return playerData:GetAsync("Player_" .. player.UserId) end)
	if s and d then dreams.Value = d.Dreams or 0 end 

	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then return end
		hum.Died:Connect(function()
			local currentLs = player:FindFirstChild("leaderstats")
			local currentSouls = currentLs and currentLs:FindFirstChild("Souls")
			if currentSouls then
				local loss = math.random(1, 5)
				currentSouls.Value = currentSouls.Value - loss
			end
		end)
	end)

	
	if player.UserId == KING_ID then
		player.Chatted:Connect(function(msg)
			local upperMsg = string.upper(msg)

			
			if upperMsg == "TAXES!" and currentDreamStatus.Value == "Regnum Chartarum" then
				for _, p in pairs(Players:GetPlayers()) do
					local pSouls = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Souls")
					if pSouls and pSouls.Value < 0 and p.UserId ~= KING_ID then
						spawnDebtCollector(p, 30) 
					end
				end
			end

			-- COMMAND 2: "GO AWAY" (Kill All Guards)
			if upperMsg == "GO AWAY" then
				for knightModel, _ in pairs(ActiveKnights) do
					fadeAndDestroy(knightModel)
				end
				ActiveKnights = {} -- Clear list
			end
		end)
	end
end)

currentDreamStatus.Changed:Connect(function(newMapName)
	local isDream = DREAM_MAPS[newMapName] or false
	for _, p in pairs(Players:GetPlayers()) do
		local d = p:FindFirstChild("Dreaming")
		if d then d.Value = isDream and 1 or 0 end
	end
end)


task.spawn(function()
	while true do
		task.wait(15) 
		if currentDreamStatus.Value == "Regnum Chartarum" then
			for _, p in pairs(Players:GetPlayers()) do
				local souls = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Souls")

				if souls and souls.Value < 0 then
					-- 1 in 10 Chance
					if math.random(1, 75) == 1 then
						spawnDebtCollector(p, 15)
						task.wait(0.5)
						spawnDebtCollector(p, 15)
					end
				end
			end
		end
	end
end)