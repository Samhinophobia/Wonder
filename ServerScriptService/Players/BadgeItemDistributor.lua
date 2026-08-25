-- @ScriptType: Script
local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")
local ServerStorage = game:GetService("ServerStorage")

local REWARDS = {
	{
		Name = "MagicMug", -- Name of Tool in ServerStorage
		BadgeID = 763992846304955
	},
	{
		Name = "Lantern",  -- From your previous requests
		BadgeID = 3158421169844618
	}

}


local USER_REWARDS = {
	-- You can use exact Usernames:
	["YourUsernameHere"] = {"", ""},

	-- Or you can use UserIDs (which is safer if they change their name):
	[5782558987] = {"StarCrafts",}
}

-- Cache to stop us from checking BadgeService every time they die (Optimization)
local ownedCache = {} 

-- [[ NEW: HELPER FUNCTION TO FIND AND GIVE ITEMS ]]
local function grantItem(player, itemName)
	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end

	-- Check if they already have the tool in Backpack or Character
	local hasTool = backpack:FindFirstChild(itemName) or (player.Character and player.Character:FindFirstChild(itemName))

	if not hasTool then
		-- 1. Search directly in ServerStorage
		local sourceItem = ServerStorage:FindFirstChild(itemName)

		-- 2. If not found, search in ServerStorage > AdminTools
		if not sourceItem then
			local adminTools = ServerStorage:FindFirstChild("AdminTools")
			if adminTools then
				sourceItem = adminTools:FindFirstChild(itemName)
			end
		end

		if sourceItem then
			local clone = sourceItem:Clone()
			clone.Parent = backpack
			print("Distributor: Gave " .. itemName .. " to " .. player.Name)

			-- Special handling for Mug Visuals (Needs to sync with saved liquid)
			if itemName == "MagicMug" then
				local liquid = player:GetAttribute("SavedMugLiquid")
				-- We manually update visuals here or wait for MugManager to catch it
				-- But usually, cloning is enough.
			end
		else
			warn("Distributor Error: " .. itemName .. " not found in ServerStorage or AdminTools!")
		end
	end
end

local function giveItems(player)
	-- Ensure cache table exists for player
	if not ownedCache[player.UserId] then ownedCache[player.UserId] = {} end

	for _, reward in ipairs(REWARDS) do
		local itemName = reward.Name
		local badgeId = reward.BadgeID

		-- Check if they already own it (Cached) or check BadgeService
		local ownsBadge = ownedCache[player.UserId][badgeId]

		if ownsBadge == nil then
			-- Not cached yet, check Roblox
			local success, hasBadge = pcall(function()
				return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
			end)
			if success then
				ownsBadge = hasBadge
				ownedCache[player.UserId][badgeId] = hasBadge -- Save result
			end
		end

		-- If they own the badge, grant the item
		if ownsBadge then
			grantItem(player, itemName)
		end
	end

	
	-- Check for String Username
	local nameRewards = USER_REWARDS[player.Name]
	if nameRewards then
		for _, itemName in ipairs(nameRewards) do
			grantItem(player, itemName)
		end
	end

	-- Check for Integer UserID
	local idRewards = USER_REWARDS[player.UserId]
	if idRewards then
		for _, itemName in ipairs(idRewards) do
			grantItem(player, itemName)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	-- Clear cache on join
	ownedCache[player.UserId] = {}

	player.CharacterAdded:Connect(function(char)
		task.wait(1) -- Wait for load
		giveItems(player)
	end)
end)

-- Cleanup cache when they leave
Players.PlayerRemoving:Connect(function(player)
	ownedCache[player.UserId] = nil
end)