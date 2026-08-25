-- @ScriptType: LocalScript


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local soundFolderName = "Ambience" -- The main folder in Workspace


local ambienceConfig = {
	["Water"] = {
		ID = "rbxassetid://104201603829792", 
		Range = 40,  -- How far away you can hear it (Studs)
		Vol = 0.45    -- How loud it is when you are right on top of it
	},
	["Fire"] = {
		ID = "rbxassetid://907053790", 
		Range = 25, 
		Vol = 0.8
	},
	["Wind"] = {
		ID = "rbxassetid://117459581041092", 
		Range = 60, 
		Vol = 0.4
	}
}

-- STORAGE FOR PLAYING SOUNDS
local activeSounds = {}

-- SETUP FUNCTION
local function setupSounds()
	for name, data in pairs(ambienceConfig) do
		-- Create the sound object locally
		local sound = Instance.new("Sound")
		sound.Name = name .. "_Ambience"
		sound.SoundId = data.ID
		sound.Volume = 0 -- Start silent
		sound.Looped = true
		sound.Parent = script -- Keep it inside the script or SoundService
		sound:Play()

		-- Store it for the loop
		activeSounds[name] = {
			Object = sound,
			Config = data
		}
	end
end

-- CALCULATE CLOSEST DISTANCE
local function getDistanceToClosestZone(zoneName, rootPart)
	local mainFolder = workspace:FindFirstChild(soundFolderName)
	if not mainFolder then return 9999 end

	local zoneFolder = mainFolder:FindFirstChild(zoneName)
	if not zoneFolder then return 9999 end

	local closestDist = 9999

	-- Check every part in the specific folder
	for _, part in pairs(zoneFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local dist = (part.Position - rootPart.Position).Magnitude

			-- Simple optimization: Start measuring from the edge of the part, not the center
			-- (Makes large ocean plates work better)
			dist = dist - (math.min(part.Size.X, part.Size.Z) / 2)
			if dist < 0 then dist = 0 end -- We are inside the part

			if dist < closestDist then
				closestDist = dist
			end
		end
	end

	return closestDist
end

-- MAIN LOOP
-- We use a timer to run this 10 times a second instead of every frame (Optimization)
local lastCheck = 0
local CHECK_RATE = 0.1

RunService.RenderStepped:Connect(function()
	if tick() - lastCheck < CHECK_RATE then return end
	lastCheck = tick()

	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Update every sound type
	for name, soundData in pairs(activeSounds) do
		local dist = getDistanceToClosestZone(name, rootPart)
		local maxRange = soundData.Config.Range
		local maxVol = soundData.Config.Vol

		local targetVolume = 0

		-- If we are within range, calculate volume
		if dist < maxRange then
			-- Math: 0 distance = 100% volume. Max distance = 0% volume.
			local scale = 1 - (dist / maxRange)
			targetVolume = scale * maxVol
		end

		-- Smoothly tween volume so it doesn't jitter
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
		TweenService:Create(soundData.Object, tweenInfo, {Volume = targetVolume}):Play()
	end
end)

-- Initialize
setupSounds()