-- @ScriptType: Script
-- Script Name: JournalServerCore


local DataStoreService = game:GetService("DataStoreService")
local BadgeService = game:GetService("BadgeService")
local TextService = game:GetService("TextService")
local JournalStore = DataStoreService:GetDataStore("PlayerJournals_V1")

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("JournalRemotes")

local BADGES_TO_CHECK = {
	123456789, 
	987654321  
}

local sessionData = {}
local MAX_NOTE_LENGTH = 1000 -- Prevents hackers from lagging the server with massive text walls!


Remotes.FetchData.OnServerInvoke = function(player)
	local data = {Notes = {}, Badges = {}}
	if sessionData[player.UserId] then
		data.Notes = sessionData[player.UserId]
	else
		local success, savedNotes = pcall(function() return JournalStore:GetAsync("User_" .. player.UserId) end)
		if success and savedNotes then
			data.Notes = savedNotes
			sessionData[player.UserId] = savedNotes
		else
			sessionData[player.UserId] = {} 
		end
	end

	for _, badgeId in pairs(BADGES_TO_CHECK) do
		local success, hasBadge = pcall(function() return BadgeService:UserHasBadgeAsync(player.UserId, badgeId) end)
		if success then data.Badges[tostring(badgeId)] = hasBadge end
	end

	return data
end


Remotes.SaveNote.OnServerEvent:Connect(function(player, pageIndex, text)

	local safeText = string.sub(text, 1, MAX_NOTE_LENGTH)
	local filteredText = safeText

	local success, result = pcall(function()
		local filterResult = TextService:FilterStringAsync(safeText, player.UserId)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if success and result then filteredText = result end

	if not sessionData[player.UserId] then sessionData[player.UserId] = {} end
	sessionData[player.UserId][tostring(pageIndex)] = filteredText
end)


Remotes.RipNote.OnServerEvent:Connect(function(player, pageIndex)
	if not sessionData[player.UserId] then return end

	local rippedText = sessionData[player.UserId][tostring(pageIndex)]
	if not rippedText or rippedText == "" then return end 

	sessionData[player.UserId][tostring(pageIndex)] = nil 


	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local paper = Instance.new("Part")
		paper.Size = Vector3.new(1.5, 0.1, 2)
		paper.Color = Color3.fromRGB(222, 209, 180)
		paper.Material = Enum.Material.Fabric
		paper.Name = "DroppedNote"

	
		paper.Anchored = true 
		paper.CanCollide = false 


		local rayOrigin = character.HumanoidRootPart.Position
		local rayDirection = Vector3.new(0, -15, 0) 
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = {character}

		local hit = workspace:Raycast(rayOrigin, rayDirection, rayParams)
		if hit then
			paper.Position = hit.Position + Vector3.new(0, 0.05, 0) -- Slightly above the floor
			paper.Orientation = Vector3.new(0, math.random(0, 360), 0) -- Random angle so it looks natural
		else
			paper.Position = character.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
		end

		paper.Parent = workspace

		
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 15 
		clickDetector.CursorIcon = "rbxasset://textures/HoverCursor.png" 
		clickDetector.Parent = paper

		clickDetector.MouseClick:Connect(function(reader)
			Remotes.ShowDroppedNote:FireClient(reader, rippedText)
		end)

	
		game:GetService("Debris"):AddItem(paper, 60) 
	end
end)


game.Players.PlayerRemoving:Connect(function(player)
	if sessionData[player.UserId] then
		pcall(function() JournalStore:SetAsync("User_" .. player.UserId, sessionData[player.UserId]) end)
		sessionData[player.UserId] = nil
	end
end)