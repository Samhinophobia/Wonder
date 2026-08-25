-- @ScriptType: Script
local Players = game:GetService("Players")

local WALK_SPEED = 14
local JUMP_POWER = 50

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")


	character:WaitForChild("Animate", 10)
	local animScript = character:FindFirstChild("Animate")
	if animScript then
		animScript:Destroy()
	end

	
	local currentWalkSpeed = WALK_SPEED
	local currentJumpPower = JUMP_POWER

	
	if player.UserId == 3457196097 then
		currentWalkSpeed = currentWalkSpeed + 2
		currentJumpPower = currentJumpPower + 10
	end

	humanoid.WalkSpeed = currentWalkSpeed
	humanoid.JumpPower = currentJumpPower
	humanoid.UseJumpPower = true


	if not character:FindFirstChild("Torso") then
		warn("Error")
	end
end

local function onPlayerAdded(player)
	-- Pass the player object along with the character to the function
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)