-- @ScriptType: Script
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local SPAWN_BADGE_ID = 368724966411346
local DEATH_BADGE_ID = 3352548146889849


local function awardBadge(player, badgeId)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
	end)

	if not success or hasBadge then return end

	local awardSuccess, errorMsg = pcall(function()
		return BadgeService:AwardBadge(player.UserId, badgeId)
	end)

	if awardSuccess then
		print("Badge " .. tostring(badgeId) .. " awarded to: " .. player.Name)
	else
		warn("Error awarding badge to " .. player.Name .. ": " .. tostring(errorMsg))
	end
end

local function onCharacterAdded(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	-- 1. Award Spawn Badge
	awardBadge(player, SPAWN_BADGE_ID)


	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.Died:Connect(function()
			awardBadge(player, DEATH_BADGE_ID)
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end)