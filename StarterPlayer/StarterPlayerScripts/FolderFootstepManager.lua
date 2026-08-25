-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local folderSounds = {
	["PathSFX"] = "rbxassetid://128782926246740", 
	["Grass"] = "rbxassetid://101324373280613", 
	["WaterArea"] = "rbxassetid://685934149",
	["DreamWorld"] = "rbxassetid://287390974",
	["Sand"] = "rbxassetid://75761627743979",
	["Dock"] = "rbxassetid://86757586209661",
	["Stairs"] = "rbxassetid://86757586209661",
	["Ice"] = "rbxassetid://18927324650",
}

local DEFAULT_STEP_SOUND = "rbxassetid://287390974"


local STEP_SPEED = 0.45 
local SWAP_COOLDOWN = 0.2 
local VOLUME = 0.5


local lastStepTime = 0
local lastSoundId = nil 
local character = nil
local rootPart = nil
local footstepSound = nil  
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function findMapSFXFolder(startPart)
	local current = startPart.Parent
	while current and current ~= workspace do
		local sfx = current:FindFirstChild("SFX")
		if sfx and sfx:IsA("Folder") then
			return sfx
		end
		current = current.Parent
	end
	return nil
end

local function onCharacterAdded(newChar)
	character = newChar
	rootPart = character:WaitForChild("HumanoidRootPart")

	footstepSound = Instance.new("Sound")
	footstepSound.Name = "CustomFootstep"
	footstepSound.Parent = rootPart


	local partsToIgnore = {character}
	raycastParams.FilterDescendantsInstances = partsToIgnore

	task.spawn(function()
		local defaultRunning = rootPart:WaitForChild("Running", 10)
		if defaultRunning then
			defaultRunning.Volume = 0
			defaultRunning.SoundId = "rbxassetid://0" 
		end
	end)
end

if LocalPlayer.Character then
	onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

RunService.RenderStepped:Connect(function()
	if not character or not rootPart or not footstepSound then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local horizontalVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
	local actualSpeed = horizontalVelocity.Magnitude


	if humanoid.MoveDirection.Magnitude > 0.1 and actualSpeed > 1 and humanoid.FloorMaterial ~= Enum.Material.Air then

		local currentSoundId = nil

		local rayOrigin = rootPart.Position
		local rayDirection = Vector3.new(0, -5, 0)
		local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		if rayResult and rayResult.Instance then
			local hitPart = rayResult.Instance
			local partName = hitPart.Name
			local parentFolder = hitPart.Parent

			-- 1. Check the Map's local "SFX" folder first
			local mapSFXFolder = findMapSFXFolder(hitPart)
			if mapSFXFolder then
				local mapSound = mapSFXFolder:FindFirstChild(partName)
				if mapSound and mapSound:IsA("Sound") then
					currentSoundId = mapSound.SoundId
				end
			end

			-- 2. If not found in map, check the Global "SFX" folder in ReplicatedStorage
			if not currentSoundId then
				local globalSFXFolder = ReplicatedStorage:FindFirstChild("SFX")
				if globalSFXFolder then
					local globalSound = globalSFXFolder:FindFirstChild(partName)
					if globalSound and globalSound:IsA("Sound") then
						currentSoundId = globalSound.SoundId
					end
				end
			end

			-- 3. If STILL not found, use the legacy Fallback Folders
			if not currentSoundId then
				if folderSounds[parentFolder.Name] then
					currentSoundId = folderSounds[parentFolder.Name]
				else
					currentSoundId = DEFAULT_STEP_SOUND
				end
			end
		end

		-- CALCULATE DELAY
		if currentSoundId then
			local requiredDelay = STEP_SPEED

			if lastSoundId ~= nil and currentSoundId ~= lastSoundId then
				requiredDelay = STEP_SPEED + SWAP_COOLDOWN 
			end

			-- CHECK TIMER
			if tick() - lastStepTime > requiredDelay then
				lastStepTime = tick()
				lastSoundId = currentSoundId 

				-- PLAY THE SOUND USING THE DEDICATED PLAYER
				footstepSound.SoundId = currentSoundId
				footstepSound.Volume = VOLUME
				footstepSound.PlaybackSpeed = 0.9 + (math.random() * 0.2) 
				footstepSound:Play()
			end
		end
	else
	
		if footstepSound and footstepSound.IsPlaying then
			footstepSound:Stop() 
		end

		-- Reset the timer so the next step is immediate when they start moving again
		lastStepTime = 0 
	end
end)