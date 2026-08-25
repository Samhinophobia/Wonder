-- @ScriptType: Script
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")


local TIME_MOVE_NAMES = {
	"TimeRewind",
	"HatterSpeed"
}

local USER_REWARDS = {
	-- Username-based rewards
	["YourUsernameHere"] = {"TimeRewind", "HatterSpeed"},

	-- UserId-based rewards
	[4477038552] = {"Cards", "RoyalDie"}, --Law
	[885558216] = {"Disponere denuo", "Encore"}, -- Hatter
	-- Example: one person with only rewind
	-- [123456789] = {"TimeRewind"},

	-- Example: one person with only dash
	-- [987654321] = {"HatterSpeed"},
}

local function findToolSource(itemName)
	local sourceItem = ServerStorage.LoreMoves:FindFirstChild(itemName)
	if sourceItem then
		return sourceItem
	end

	local adminTools = ServerStorage:FindFirstChild("AdminTools")
	if adminTools then
		sourceItem = adminTools:FindFirstChild(itemName)
		if sourceItem then
			return sourceItem
		end
	end

	return nil
end

local function playerHasTool(player, itemName)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	if backpack and backpack:FindFirstChild(itemName) then
		return true
	end

	if character and character:FindFirstChild(itemName) then
		return true
	end

	return false
end

local function grantItem(player, itemName)
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end

	if playerHasTool(player, itemName) then
		return
	end

	local sourceItem = findToolSource(itemName)
	if not sourceItem then
		warn("TimeDistributor Error: " .. itemName .. " not found in ServerStorage or AdminTools!")
		return
	end

	local clone = sourceItem:Clone()
	clone.Parent = backpack
	print("TimeDistributor: Gave " .. itemName .. " to " .. player.Name)
end

local function giveTimeMoves(player)
	local nameRewards = USER_REWARDS[player.Name]
	if nameRewards then
		for _, itemName in ipairs(nameRewards) do
			grantItem(player, itemName)
		end
	end

	local idRewards = USER_REWARDS[player.UserId]
	if idRewards then
		for _, itemName in ipairs(idRewards) do
			grantItem(player, itemName)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		giveTimeMoves(player)
	end)
end)
