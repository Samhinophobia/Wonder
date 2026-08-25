-- @ScriptType: Script
local Players = game:GetService("Players")

local MIN_FALL_HEIGHT = 15   
local DAMAGE_MULTIPLIER = 1.5 
local SOUND_COOLDOWN = 0.5  

local HURT_SOUND_ID = "rbxassetid://96758654650340" 

local function setupCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local head = character:WaitForChild("Head")
	local player = Players:GetPlayerFromCharacter(character)

	local hurtSound = Instance.new("Sound")
	hurtSound.Name = "HurtSound"
	hurtSound.SoundId = HURT_SOUND_ID
	hurtSound.Volume = 0.8
	hurtSound.Parent = head

	local lastHeight = 0
	local isFalling = false
	local lastHealth = humanoid.Health
	local lastSoundPlay = 0 

	-- [[ LUCK CHARM CHECK ]]
	local hasLuckCharm = false
	if player then
		-- Wait for data to load
		local ls = player:WaitForChild("leaderstats", 10)
		if ls and ls:FindFirstChild("LuckCharmActive") and ls.LuckCharmActive.Value == true then
			hasLuckCharm = true
			-- Apply permanent +10 HP on spawn!
			humanoid.MaxHealth = humanoid.MaxHealth + 10
			humanoid.Health = humanoid.Health + 10
			lastHealth = humanoid.Health
		end
	end


	-- If they have the charm, fall damage is cut in half (0.75 instead of 1.5)
	local currentDamageMultiplier = hasLuckCharm and (DAMAGE_MULTIPLIER * 0.5) or DAMAGE_MULTIPLIER

	humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			if newHealth <= 0 then
				lastHealth = newHealth
				return 
			end

			local now = tick()
			if now - lastSoundPlay >= SOUND_COOLDOWN then
				hurtSound:Play()
				lastSoundPlay = now
			end
		end
		lastHealth = newHealth
	end)

	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Freefall then
			lastHeight = rootPart.Position.Y
			isFalling = true

		elseif newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
			if isFalling then
				isFalling = false
				local currentHeight = rootPart.Position.Y
				local heightDifference = lastHeight - currentHeight

				if heightDifference > MIN_FALL_HEIGHT then
					-- Use the dynamic multiplier we calculated at the top!
					local damage = (heightDifference - MIN_FALL_HEIGHT) * currentDamageMultiplier
					humanoid:TakeDamage(damage)
				end
			end
		end
	end)
end

local function onPlayerJoined(player)
	player.CharacterAdded:Connect(setupCharacter)
end

Players.PlayerAdded:Connect(onPlayerJoined)