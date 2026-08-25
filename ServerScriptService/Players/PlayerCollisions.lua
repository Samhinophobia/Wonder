-- @ScriptType: Script


local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SOLID_GROUP = "Players"
local GHOST_GROUP = "Ghosts"

-- 1. SETUP GROUPS
local function registerGroup(name)
	pcall(function()
		PhysicsService:RegisterCollisionGroup(name)
	end)
end

registerGroup(SOLID_GROUP)
registerGroup(GHOST_GROUP)

-- 2. CONFIGURE COLLISIONS
-- Solid collides with Solid (Normal Game)
PhysicsService:CollisionGroupSetCollidable(SOLID_GROUP, SOLID_GROUP, true) 

-- Ghost DOES NOT collide with anything (Teleport Mode)
PhysicsService:CollisionGroupSetCollidable(GHOST_GROUP, SOLID_GROUP, false)
PhysicsService:CollisionGroupSetCollidable(GHOST_GROUP, GHOST_GROUP, false)

-- 3. HELPER: Set Collision Group
local function setCollisionGroup(character, groupName)
	if not character then return end
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() part.CollisionGroup = groupName end)
		end
	end
end

-- 4. HELPER: Freeze/Unfreeze
local function setFrozen(character, isFrozen)
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = isFrozen
	end
end

-- 5. NEW PLAYER HANDLING
local function onCharacterAdded(character)
	task.wait(0.1)
	setCollisionGroup(character, SOLID_GROUP) -- Default to solid

	-- Keep new parts (tools) in sync
	character.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			pcall(function() part.CollisionGroup = SOLID_GROUP end)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)

-- 6. DREAM TELEPORT LOGIC (SPLIT TIMER)
local currentDreamStatus = ReplicatedStorage:FindFirstChild("CurrentDreamStatus")

if currentDreamStatus then
	currentDreamStatus.Changed:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				task.spawn(function()
					-- A. Ghost & Freeze Immediately
					setCollisionGroup(player.Character, GHOST_GROUP)
					setFrozen(player.Character, true)

					-- B. FAST UNFREEZE (1.5 Seconds)
					-- Allows players to move as soon as the screen fades in
					task.wait(1.5)
					if player.Character then
						setFrozen(player.Character, false)
					end

					-- C. DELAYED SOLIDIFY (2 Extra Seconds)
					-- Keeps collision OFF so players can walk out of each other safely
					task.wait(2.0)
					if player.Character then
						setCollisionGroup(player.Character, SOLID_GROUP)
					end
				end)
			end
		end
	end)
end