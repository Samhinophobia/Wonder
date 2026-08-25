-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DreamEvents = ReplicatedStorage:WaitForChild("DreamEvents")
local performInteract = DreamEvents:WaitForChild("PerformInteraction")

-- Auto-create our quest remotes so you don't have to!
if not DreamEvents:FindFirstChild("MomoBlessingEvent") then
	local e = Instance.new("RemoteEvent", DreamEvents); e.Name = "MomoBlessingEvent"
end
if not DreamEvents:FindFirstChild("WakeUpFade") then
	local e = Instance.new("RemoteEvent", DreamEvents); e.Name = "WakeUpFade"
end
-- [[ NEW: Atmosphere Event ]]
if not DreamEvents:FindFirstChild("DarkenAtmosphere") then
	local e = Instance.new("RemoteEvent", DreamEvents); e.Name = "DarkenAtmosphere"
end

local REQUIRED_LIQUID = "Energy Drink" 
local playerLiquids = {}

-- The Note UI Data
local QUEST_NOTE_DATA = {
	Title = "The Ticking End",
	Subject = "The Endless Tea Party",
	Target = "Dreamers",
	Body = "The clock dictates the realm...\nSilence its ticking, and the illusion will shatter.\nSeek Momo for the key."
}

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("TeaQuestState", 0)
	playerLiquids[player.UserId] = player:GetAttribute("SavedMugLiquid")

	-- Listen for when they drink!
	player:GetAttributeChangedSignal("SavedMugLiquid"):Connect(function()
		local newLiquid = player:GetAttribute("SavedMugLiquid")
		local oldLiquid = playerLiquids[player.UserId]

		-- If liquid becomes empty, it means MugManager just finished the Drink action (3 sec delay)
		if newLiquid == "" and oldLiquid == REQUIRED_LIQUID then
			print("[Quest] " .. player.Name .. " finished drinking Dream Water.")

			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local questFolder = workspace:FindFirstChild("TeaPartyQuest", true)

			if root and questFolder then
				local drinkArea = questFolder:FindFirstChild("DrinkArea")

				if drinkArea then
					local distance = (root.Position - drinkArea.Position).Magnitude

					-- Increased to 50 studs to account for players walking while drinking
					if distance <= 50 then 

						-- Spawn YOUR custom MomoNote from ServerStorage!
						if not questFolder:FindFirstChild("MomoNote") then
							local customPaperTemplate = ServerStorage:FindFirstChild("MomoNote")

							if customPaperTemplate then
								local paper = customPaperTemplate:Clone()
								paper.Name = "MomoNote"
								paper.Anchored = true 
								paper.CanCollide = false

								if questFolder:FindFirstChild("PaperSpawn") then
									paper.Position = questFolder.PaperSpawn.Position
								else
									paper.Position = root.Position + Vector3.new(0, 3, 0)
								end

								-- Add the Sparkles!
								local sparkles = Instance.new("Sparkles")
								sparkles.SparkleColor = Color3.fromRGB(255, 215, 0) -- Golden Yellow
								sparkles.Parent = paper

								paper.Parent = questFolder

								-- Find or create the ClickDetector
								local clickDetector = paper:FindFirstChildWhichIsA("ClickDetector") or Instance.new("ClickDetector", paper)

								clickDetector.MouseClick:Connect(function(reader)
									reader:SetAttribute("TeaQuestState", 1) -- Progresses their quest

									-- Triggers YOUR existing Note UI!
									performInteract:FireClient(reader, "Note", QUEST_NOTE_DATA)
								end)
							else
								warn("[Quest] ERROR: Could not find 'MomoNote' in ServerStorage!")
							end
						end
					end
				end
			end
		end
		playerLiquids[player.UserId] = newLiquid
	end)
end)

-- Give Blessing when Momo tells the server to
DreamEvents.MomoBlessingEvent.OnServerEvent:Connect(function(player)
	if player:GetAttribute("TeaQuestState") == 1 then
		local blessing = ServerStorage:FindFirstChild("Momo's Blessing")
		if blessing then
			blessing:Clone().Parent = player.Backpack
			player:SetAttribute("TeaQuestState", 2) -- Prevents getting infinite copies
		end
	end
end)