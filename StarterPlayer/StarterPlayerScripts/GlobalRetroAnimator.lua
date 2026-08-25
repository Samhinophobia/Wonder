-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local JUMP_SOUND_ID = "rbxassetid://12222200"

-- VARIABLES
local playerStates = {} 

--  HELPER: PLAY SOUND
local function playJumpSound(rootPart)
	if not rootPart then return end
	local sound = Instance.new("Sound")
	sound.SoundId = JUMP_SOUND_ID
	sound.Volume = 0.5
	sound.Parent = rootPart
	sound:Play()
	game.Debris:AddItem(sound, 1)
end

--  HELPER: MOVE LIMBS
local function updateCharacter(character, dt)
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso")

	-- If they are dead or R15, skip
	if not humanoid or humanoid.Health <= 0 or not torso then return end

	-- Get Motors
	local rs = torso:FindFirstChild("Right Shoulder")
	local ls = torso:FindFirstChild("Left Shoulder")
	local rh = torso:FindFirstChild("Right Hip")
	local lh = torso:FindFirstChild("Left Hip")

	if not (rs and ls and rh and lh) then return end

	-- Initialize State if missing
	if not playerStates[character] then
		playerStates[character] = {
			time = 0,
			pose = "Standing",
			lastJump = false
		}
	end
	local state = playerStates[character]

	-- === DETERMINE POSE ===
	local pose = "Standing"
	local humState = humanoid:GetState()
	local velocity = torso.Velocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	-- 1. Check Sitting & Climbing
	if humanoid.Sit or humState == Enum.HumanoidStateType.Seated or humState == Enum.HumanoidStateType.Climbing then
		return 
	end

	-- 2. Check Jumping/Freefall
	if humState == Enum.HumanoidStateType.Jumping or 
		humState == Enum.HumanoidStateType.Freefall then
		pose = "Jumping"
	elseif speed > 0.5 then
		pose = "Running"
	end

	-- DETECT JUMP START (For Sound)
	if pose == "Jumping" and not state.lastJump then
		playJumpSound(torso)
	end
	state.lastJump = (pose == "Jumping")

	-- === ANIMATION MATH ===
	state.time = state.time + dt

	if pose == "Jumping" then
		-- Arms up, legs straight
		rs.MaxVelocity = 0.5; ls.MaxVelocity = 0.5
		rs.DesiredAngle = 3.14
		ls.DesiredAngle = -3.14
		rh.DesiredAngle = 0; lh.DesiredAngle = 0

	elseif pose == "Running" then
		-- Classic Retro Walk Cycle
		local runAmp = 1
		local runFreq = 9
		rs.MaxVelocity = 0.15; ls.MaxVelocity = 0.15

		local angle = runAmp * math.sin(state.time * runFreq)

		-- Right arm swings completely naturally again!
		rs.DesiredAngle = angle
		ls.DesiredAngle = angle
		rh.DesiredAngle = -angle
		lh.DesiredAngle = -angle

	else -- Standing
		-- Classic Breathing/Idle
		local standAmp = 0.1
		local standFreq = 1
		local angle = standAmp * math.sin(state.time * standFreq)

		-- Right arm breathes naturally again!
		rs.DesiredAngle = angle
		ls.DesiredAngle = angle
		rh.DesiredAngle = -angle / 2 
		lh.DesiredAngle = -angle / 2
	end
end

--  MAIN LOOP
RunService.Heartbeat:Connect(function(dt)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			updateCharacter(player.Character, dt)
		end
	end
end)

--  CLEANUP
Players.PlayerRemoving:Connect(function(player)
	if player.Character then
		playerStates[player.Character] = nil
	end
end)