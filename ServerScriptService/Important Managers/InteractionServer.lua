-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage") 
local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")

local InteractionData = require(ReplicatedStorage:WaitForChild("InteractionData"))
local events = ReplicatedStorage:WaitForChild("DreamEvents")
local requestInteract = events:WaitForChild("RequestInteraction")
local performInteract = events:WaitForChild("PerformInteraction")
local voteStatusEvent = events:WaitForChild("VoteStatus") 

local NPC_TRADES = {
	["Shadrico"] = {
		RequiredItem = "Blood", -- Works for Liquids OR Tool Names
		RewardItem = "Luck Charm", 
		BadgeId = 959022383074696, --  actual Badge ID (or leave 0 if no badge)
		SuccessText = "He seems quite happy with your offering. You received something in return."
	},
}

-- [[ THE FIX: MUG-HANDLER COMPATIBLE SEARCH ]]
local function attemptNPCTrade(player, npcName)
	local cleanNpcName = string.match(string.lower(npcName), "^%s*(.-)%s*$")
	local tradeData = nil

	for key, data in pairs(NPC_TRADES) do
		local cleanKey = string.match(string.lower(key), "^%s*(.-)%s*$")
		if cleanKey == cleanNpcName then
			tradeData = data
			break
		end
	end

	if not tradeData then return false end

	local requiredItem = string.lower(tradeData.RequiredItem)
	local foundTool = nil
	local wasLiquid = false

	-- [[ 1. Check if the player has it stored in their MugHandler profile ]]
	local savedLiquid = player:GetAttribute("SavedMugLiquid")
	if savedLiquid and string.lower(tostring(savedLiquid)) == requiredItem then
		-- They have the liquid! Now we just need to find the physical mug to empty it
		wasLiquid = true

		if player.Character and player.Character:FindFirstChild("MagicMug") then
			foundTool = player.Character:FindFirstChild("MagicMug")
		elseif player.Backpack and player.Backpack:FindFirstChild("MagicMug") then
			foundTool = player.Backpack:FindFirstChild("MagicMug")
		end
	else
		-- [[ 2. If it wasn't a liquid, check for a normal Item/Tool ]]
		local function searchForTool(parentFolder)
			for _, item in ipairs(parentFolder:GetChildren()) do
				if item:IsA("Tool") and string.lower(item.Name) == requiredItem then
					return item
				end
			end
			return nil
		end

		foundTool = searchForTool(player.Backpack)
		if not foundTool and player.Character then 
			foundTool = searchForTool(player.Character) 
		end
	end

	-- [[ 3. Process the Trade ]]
	if foundTool then
		-- Consumption
		if wasLiquid then
			-- Tell the MugHandler the player is now empty
			player:SetAttribute("SavedMugLiquid", "")

			-- Wipe the physical Tool's effect string so the visual updates
			local currentEffect = foundTool:FindFirstChild("CurrentEffect")
			if currentEffect and currentEffect:IsA("StringValue") then
				currentEffect.Value = ""
			end
		else
			foundTool:Destroy() 
		end

		-- Reward
		local rewardName = tradeData.RewardItem
		local rewardTemplate = ServerStorage:FindFirstChild(rewardName)

		if rewardTemplate then
			if not player.Backpack:FindFirstChild(rewardName) and (not player.Character or not player.Character:FindFirstChild(rewardName)) then
				rewardTemplate:Clone().Parent = player.Backpack
			end
		else
			warn("InteractionServer: Could not find reward item " .. rewardName .. " in ServerStorage!")
		end

		-- Badge
		if tradeData.BadgeId and tradeData.BadgeId > 0 then
			pcall(function()
				if not BadgeService:UserHasBadgeAsync(player.UserId, tradeData.BadgeId) then
					BadgeService:AwardBadge(player.UserId, tradeData.BadgeId)
				end
			end)
		end

		voteStatusEvent:FireClient(player, "UpdateTopText", tradeData.SuccessText)
		task.delay(3.5, function() voteStatusEvent:FireClient(player, "ClearTopText") end)

		return true 
	end

	print("TRADE FAILED: " .. player.Name .. " talked to " .. npcName .. " but did not have the exact item: " .. tradeData.RequiredItem)
	return false 
end


local function getGender(char)
	if not char then return "Male" end
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		local desc = hum:GetAppliedDescription()
		if desc and tostring(desc.Torso) == InteractionData.FEMALE_TORSO_ID then return "Female" end
	end
	return "Male"
end

local function getShirtId(char)
	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt then return tonumber(string.match(shirt.ShirtTemplate, "%d+")) end
	return nil
end

local function findValueInAncestors(startPart, valueName)
	if not startPart then return nil end
	local v = startPart:FindFirstChild(valueName)
	if v then return v end
	if startPart.Parent then
		v = startPart.Parent:FindFirstChild(valueName)
		if v then return v end
		if startPart.Parent.Parent then
			v = startPart.Parent.Parent:FindFirstChild(valueName)
			if v then return v end
		end
	end
	return nil
end


requestInteract.OnServerEvent:Connect(function(player, target, hitPosition)

	if not target or not target:IsDescendantOf(workspace) then return end
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local dist = (character.HumanoidRootPart.Position - hitPosition).Magnitude
	if dist > InteractionData.MAX_INTERACT_DISTANCE + 5 then return end


	local memoryIdVal = findValueInAncestors(target, "MemoryID")
	if memoryIdVal and InteractionData.MEMORIES[memoryIdVal.Value] then
		performInteract:FireClient(player, "Memory", memoryIdVal.Value)
		return
	end


	local noteIdVal = findValueInAncestors(target, "NoteID")
	if noteIdVal and InteractionData.NOTES[noteIdVal.Value] then
		performInteract:FireClient(player, "Note", InteractionData.NOTES[noteIdVal.Value])
		return
	end


	local targetModel = target:FindFirstAncestorOfClass("Model")
	local targetPlayer = Players:GetPlayerFromCharacter(targetModel)

	if targetPlayer and targetPlayer ~= player then
		local myGender = getGender(character)
		local targetGender = getGender(targetModel)
		local myId, targetId = player.UserId, targetPlayer.UserId
		local myShirtId = getShirtId(character)
		local theirShirtId = getShirtId(targetModel)
		local isDreaming = (targetPlayer:FindFirstChild("Dreaming") and targetPlayer.Dreaming.Value == 1)
		local state = isDreaming and "Dream" or "Normal"

		if InteractionData.SPECIAL_RELATIONSHIPS[myId] and InteractionData.SPECIAL_RELATIONSHIPS[myId][targetId] then
			local relData = InteractionData.SPECIAL_RELATIONSHIPS[myId][targetId]
			performInteract:FireClient(player, "Message", type(relData) == "table" and relData[state] or relData)
			return
		end

		local vipData = InteractionData.VIP_QUOTES[targetId]
		if vipData and vipData[state] and vipData[state][myGender] then
			performInteract:FireClient(player, "Message", vipData[state][myGender])
			return
		end

		if InteractionData.VIP_OUTFIT_REACTIONS[myId] and theirShirtId then
			local quote = InteractionData.VIP_OUTFIT_REACTIONS[myId][theirShirtId]
			if quote then performInteract:FireClient(player, "Message", quote); return end
		end

		if theirShirtId then
			local outfitData = InteractionData.OUTFIT_REACTIONS[theirShirtId] or InteractionData.OUTFIT_REACTIONS["DEFAULT"]
			if targetPlayer == player and outfitData.Self then performInteract:FireClient(player, "Message", outfitData.Self); return end
			local complexKey = "Target" .. targetGender .. "_" .. myGender .. "Viewer"
			if outfitData[complexKey] then performInteract:FireClient(player, "Message", outfitData[complexKey]); return end
			local simpleKey = (myGender == "Male") and "MaleViewer" or "FemaleViewer"
			if outfitData[simpleKey] then performInteract:FireClient(player, "Message", outfitData[simpleKey]); return end
		end

		performInteract:FireClient(player, "Message", "Just another wanderer.")
		return
	end


	if targetModel and not targetPlayer then
		if attemptNPCTrade(player, targetModel.Name) then
			return -- The trade happened! Stop here so the normal dialogue doesn't pop up.
		end
	end


	local currentTool = character:FindFirstChildWhichIsA("Tool")
	local messageToShow = nil
	local myGender = getGender(character)

	if currentTool then
		if currentTool.Name == "MagicMug" then
			local effectObj = findValueInAncestors(target, "Effect")
			if effectObj then messageToShow = "I wonder if this is safe to drink." end
		end
		if not messageToShow then
			local toolVal = findValueInAncestors(target, "InteractMessage_" .. currentTool.Name)
			if toolVal then messageToShow = toolVal.Value end
		end
	end

	if not messageToShow then
		local genderVal = findValueInAncestors(target, "InteractMessage_" .. myGender)
		if genderVal then messageToShow = genderVal.Value end
	end
	if not messageToShow then
		local defaultVal = findValueInAncestors(target, "InteractMessage")
		if defaultVal then messageToShow = defaultVal.Value end
	end

	if messageToShow then 
		performInteract:FireClient(player, "Message", messageToShow) 
	end
end)