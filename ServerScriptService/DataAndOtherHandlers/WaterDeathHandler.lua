-- @ScriptType: Script


local Players = game:GetService("Players")


local KICK_MESSAGE = "You drowned in the deep... The dream has ended."
local KICK_DELAY = 2.5 


local DEATH_MUSIC_ID = "rbxassetid://115929118191660" 

local function monitorCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local player = Players:GetPlayerFromCharacter(character)

	humanoid.Died:Connect(function()
		if player then

			-- 1. CHECK THE CAUSE OF DEATH
			-- We check if the water script put the "IsDrowning" sticky note on us.
			local isDrowning = humanoid:GetAttribute("IsDrowning")

			if isDrowning == true then
		

				-- 2. PLAY CLIENT-SIDED MUSIC
				-- By parenting the sound to PlayerGui, ONLY this specific player hears it.
				-- It also plays in "2D" (Headphones mode), which is scarier.
				local playerGui = player:FindFirstChild("PlayerGui")
				if playerGui then
					local music = Instance.new("Sound")
					music.Name = "DrowningMusic"
					music.SoundId = DEATH_MUSIC_ID
					music.Volume = 3
					music.Looped = false
					music.Parent = playerGui -- Private audio!
					music:Play()
				end

				-- 3. WAIT AND KICK
				task.wait(KICK_DELAY)
				player:Kick(KICK_MESSAGE)

			else
			
				-- Do nothing. They just respawn normally.
			end
		end
	end)
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(monitorCharacter)
end

Players.PlayerAdded:Connect(onPlayerAdded)