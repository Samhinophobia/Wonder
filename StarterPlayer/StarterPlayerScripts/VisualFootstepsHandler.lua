-- @ScriptType: LocalScript
-- Script Name: VisualFootsteps
-- Parent: StarterPlayer -> StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- 1. TEXTURE CONFIGURATION
-- This is a generic "dark smudge" footprint. 
-- You can change this ID to a specific boot print if you have one.
local FOOTPRINT_TEXTURE = "http://www.roblox.com/asset/?id=7447638611" 

-- 2. SURFACE CONFIGURATION
-- Set 'true' for materials/folders that SHOULD leave footprints.
local validSurfaces = {
	-- MATERIALS
	[Enum.Material.Sand] = true,
	[Enum.Material.Snow] = true,
	[Enum.Material.Mud] = true,
	[Enum.Material.Grass] = true, -- Optional: Remove if you don't want steps on grass

	-- FOLDERS (Using your map system)
	--["PathSFX"] = true,
	["Sand"] = true,
}

-- 3. SETTINGS
local STEP_DISTANCE = 3.5  -- How many studs between footprints
local LIFETIME = 3        -- How long (seconds) the footprint stays
local FADE_TIME = 2        -- How long it takes to fade out

-- Variables
local lastPosition = Vector3.new(0,0,0)
local rightLegTurn = true -- Toggle between Left/Right leg

-- Function to create the footprint
local function createFootprint(position, normal, cframeDirection)

	-- 1. Create the invisible part holder
	local part = Instance.new("Part")
	part.Name = "Footprint"
	part.Size = Vector3.new(1, 0.05, 1)
	part.Transparency = 0.5
	part.CanCollide = false
	part.Anchored = true
	part.CastShadow = false

	-- 2. Position it on the ground
	-- We align it with the ground normal so it works on slopes
	part.CFrame = CFrame.lookAt(position, position + normal) * CFrame.Angles(-math.pi/2, 0, 0)

	-- 3. Create the Image (Decal)
	local decal = Instance.new("Decal")
	decal.Texture = FOOTPRINT_TEXTURE
	decal.Face = Enum.NormalId.Top
	decal.Parent = part

	-- Offset left or right slightly based on which foot
	local offset = rightLegTurn and 0.5 or -0.5
	part.CFrame = part.CFrame * CFrame.new(offset, 0, 0)

	part.Parent = workspace.CurrentCamera -- Put in Camera so it doesn't clutter workspace

	-- 4. FADING EFFECT
	-- Wait for (Lifetime - FadeTime), then tween transparency
	task.delay(LIFETIME - FADE_TIME, function()
		local tween = TweenService:Create(decal, TweenInfo.new(FADE_TIME), {Transparency = 1})
		tween:Play()
	end)

	-- 5. CLEANUP
	Debris:AddItem(part, LIFETIME)

	-- Flip foot for next time
	rightLegTurn = not rightLegTurn
end

local function onUpdate()
	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")

	if not rootPart or not humanoid then return end

	-- Only spawn if moving on ground
	if humanoid.MoveDirection.Magnitude > 0.1 and humanoid.FloorMaterial ~= Enum.Material.Air then

		-- Check distance moved since last step
		if (rootPart.Position - lastPosition).Magnitude > STEP_DISTANCE then
			lastPosition = rootPart.Position

			-- RAYCAST DOWN
			local rayOrigin = rootPart.Position
			local rayDirection = Vector3.new(0, -5, 0)

			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {character}
			params.FilterType = Enum.RaycastFilterType.Exclude

			local result = workspace:Raycast(rayOrigin, rayDirection, params)

			if result and result.Instance then
				local hitPart = result.Instance
				local mat = hitPart.Material
				local folderName = hitPart.Parent.Name

				-- CHECK: Is this a valid surface?
				if validSurfaces[mat] or validSurfaces[folderName] then
					createFootprint(result.Position, result.Normal, rootPart.CFrame)
				end
			end
		end
	end
end

RunService.RenderStepped:Connect(onUpdate)