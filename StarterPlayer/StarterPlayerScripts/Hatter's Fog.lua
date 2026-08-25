-- @ScriptType: LocalScript
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local TARGET_DREAM = "Convivium Potationis Perpetuum"

-- [[ CONSTANTS: HARDCODED TO PREVENT MAP MANAGER CONFLICTS ]]
local TEA_PARTY_FOG_START = 20
local TEA_PARTY_FOG_END = 100
local MIN_FOG_END = 10

-- Creeps in ~9 seconds (10 studs per second)
local FOG_SPEED_IN = 10
local FOG_SPEED_OUT = 30

local isConsumed = false

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")
local dreamEvents = ReplicatedStorage:WaitForChild("DreamEvents")
local fogConsumedEvent = dreamEvents:WaitForChild("FogConsumed", 5)

-- [[ SAFEZONE DETECTION ]]
local function isPlayerInSafeZone(rootPos)
	local safeZoneFolder = Workspace:FindFirstChild("SafeZones", true)
	if not safeZoneFolder then return false end

	for _, part in pairs(safeZoneFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local rel = part.CFrame:PointToObjectSpace(rootPos)
			if math.abs(rel.X) < part.Size.X/2 and math.abs(rel.Y) < part.Size.Y/2 and math.abs(rel.Z) < part.Size.Z/2 then
				return true
			end
		end
	end
	return false
end

-- [[ RESET LOGIC: TRIGGERS WHEN CAUGHT BY FOG ]]
dreamEvents:WaitForChild("ResetFogState").OnClientEvent:Connect(function()
	isConsumed = false
	Lighting.FogStart = TEA_PARTY_FOG_START
	Lighting.FogEnd = TEA_PARTY_FOG_END
end)

-- [[ MAP CHANGE LOGIC ]]
currentDreamStatus.Changed:Connect(function()
	if string.find(currentDreamStatus.Value, TARGET_DREAM) then
		-- ENTERING TEA PARTY: Start the fog at the exact Tea Party bounds immediately
		isConsumed = false
		Lighting.FogStart = TEA_PARTY_FOG_START
		Lighting.FogEnd = TEA_PARTY_FOG_END
	else
		-- LEAVING TEA PARTY: don't touch fog — the map manager's applyMapLighting
		-- already set the correct FogStart/FogEnd for wherever we're headed next.
		isConsumed = false
	end
end)

-- [[ THE FOG CREEP ]]
RunService.Heartbeat:Connect(function(dt)
	-- Strictly lock this out if we are not in the Tea Party
	if not string.find(currentDreamStatus.Value, TARGET_DREAM) then return end

	local character = player.Character
	if not character then return end
	local hum = character:FindFirstChild("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	-- Stop math if dead or teleporting
	if isConsumed or not hum or not root or hum.Health <= 0 then return end

	-- Check status
	local isProtected = character:GetAttribute("LanternActiveTime") and (os.clock() - character:GetAttribute("LanternActiveTime") < 3.0)
	local inSafeZone = isPlayerInSafeZone(root.Position)

	if isProtected or inSafeZone then
		-- Safely push fog back up to 100
		Lighting.FogStart = math.min(TEA_PARTY_FOG_START, Lighting.FogStart + (FOG_SPEED_OUT * dt))
		Lighting.FogEnd = math.min(TEA_PARTY_FOG_END, Lighting.FogEnd + (FOG_SPEED_OUT * dt))
	else
		-- Aggressively pull fog down to 10
		Lighting.FogStart = math.max(0, Lighting.FogStart - (FOG_SPEED_IN * dt))
		Lighting.FogEnd = math.max(MIN_FOG_END, Lighting.FogEnd - (FOG_SPEED_IN * dt))
	end

	-- Trigger teleport when consumed
	if Lighting.FogEnd <= MIN_FOG_END then
		isConsumed = true
		if fogConsumedEvent then fogConsumedEvent:FireServer() end
	end
end)