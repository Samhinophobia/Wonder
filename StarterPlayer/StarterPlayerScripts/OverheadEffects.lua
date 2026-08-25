-- @ScriptType: LocalScript


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

-- CONSTANTS
local FADE_START_DIST = 20 
local FADE_END_DIST = 35   

local ANIM_FRAME_RATE = 1/12 -- 12 FPS
local JITTER_INTENSITY = 2   

local timeAccumulator = 0

RunService.RenderStepped:Connect(function(dt)
	-- 1. UPDATE TIMER
	local updateJitter = false
	timeAccumulator += dt
	if timeAccumulator >= ANIM_FRAME_RATE then
		updateJitter = true
		timeAccumulator = 0
	end

	-- 2. LOOP PLAYERS
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local billboard = head:FindFirstChild("OverheadRank")

			if billboard then
				local container = billboard:FindFirstChild("Container")
				if container then
					-- === FADE LOGIC ===
					local dist = (camera.CFrame.Position - head.Position).Magnitude

					if dist < FADE_START_DIST then
						container.GroupTransparency = 0
					elseif dist > FADE_END_DIST then
						container.GroupTransparency = 1
					else
						local alpha = (dist - FADE_START_DIST) / (FADE_END_DIST - FADE_START_DIST)
						container.GroupTransparency = alpha
					end

					-- === JITTER LOGIC (TITLE ONLY - ALWAYS RUNS) ===
					if updateJitter then
						local titleLbl = container:FindFirstChild("TitleLabel")

						if titleLbl then
							titleLbl.Rotation = math.random(-JITTER_INTENSITY, JITTER_INTENSITY)
						end

						-- Ensure Name stays straight
						local nameLbl = container:FindFirstChild("NameLabel")
						if nameLbl then
							nameLbl.Rotation = 0
						end
					end
				end
			end
		end
	end
end)