-- @ScriptType: LocalScript
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local function spiritualPressure(character)
	local maxIntensity,intensityDropOff,intensityMin = 50,30,5
	local activationDistance,removeDistance = 150,200
	local mag = 0
	local enabled = false

	local function showPressure()
		enabled = true
		local isCaster = (game.Players.LocalPlayer.Character == character)

		local stunVal = Instance.new("Folder")
		stunVal.Name = "Stun"


		tweenService:Create(game.Lighting,TweenInfo.new(.5),{FogColor = Color3.fromRGB(0,0,0),FogStart = 50,FogEnd = 500}):Play()

		local pressureLighting = game.Lighting:FindFirstChild("Pressure")
		if pressureLighting then
			tweenService:Create(pressureLighting,TweenInfo.new(.5),{Contrast = .5, Saturation = -1, TintColor = Color3.fromRGB(192,187,255)}):Play()
			pressureLighting.Enabled = true 
		end


		local spFolder = character:FindFirstChild("SpiritualPressure")

	
		local localDimGui
		local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui and not playerGui:FindFirstChild("LocalSpiritualDim") then
			localDimGui = Instance.new("ScreenGui")
			localDimGui.Name = "LocalSpiritualDim"
			localDimGui.IgnoreGuiInset = true

			local dimFrame = Instance.new("Frame")
			dimFrame.Size = UDim2.new(1, 0, 1, 0)

	
			local customTint = spFolder and spFolder:GetAttribute("ScreenTint")
			dimFrame.BackgroundColor3 = customTint or Color3.new(0, 0, 0)

			dimFrame.BackgroundTransparency = 1 
			dimFrame.BorderSizePixel = 0
			dimFrame.Parent = localDimGui

			localDimGui.Parent = playerGui

		
			local targetDim = isCaster and 0.1 or 0
			tweenService:Create(dimFrame, TweenInfo.new(0.5), {BackgroundTransparency = targetDim}):Play()
		end
	
		local spFolder = character:FindFirstChild("SpiritualPressure")
		local skipDefault = spFolder and spFolder:GetAttribute("SkipDefaultPlate")

		local pressurePlate
		if not skipDefault then

			local assetsFolder = game.ReplicatedStorage:FindFirstChild("Assets")

			if not assetsFolder then
				warn("[ERROR] Move your 'Assets' folder into ReplicatedStorage so the LocalScript can see it!")
			else
				local homunculi = assetsFolder:FindFirstChild("Homunculi") or assetsFolder:FindFirstChild("homunculi")
				if homunculi and homunculi:FindFirstChild("TrueForm") then
					local plate = homunculi.TrueForm:FindFirstChild("PressurePlate")
					if plate then
						pressurePlate = plate:Clone()
					end
				end
			end

			if pressurePlate then
				local hrp = character:WaitForChild("HumanoidRootPart", 3)
				if hrp then
					pressurePlate.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
					if pressurePlate:FindFirstChild("Weld") then pressurePlate.Weld:Destroy() end

					local newWeld = Instance.new("WeldConstraint")
					newWeld.Part0 = pressurePlate
					newWeld.Part1 = hrp
					newWeld.Parent = pressurePlate
					pressurePlate.Parent = character

					tweenService:Create(pressurePlate.PointLight,TweenInfo.new(.5),{Range = 6, Brightness = 40}):Play()
					task.delay(.25,function()
						if pressurePlate:FindFirstChild("ParticleEmitter") then pressurePlate.ParticleEmitter.Enabled = true end
						if pressurePlate:FindFirstChild("ParticleEmitter2") then pressurePlate.ParticleEmitter2.Enabled = true end
					end)
				end
			end
		end

		task.spawn(function()
			local con
			repeat task.wait(.01)
				local intensity = maxIntensity
				local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if not hum then continue end

				if mag > intensityDropOff then
					intensity = math.max(intensityMin,maxIntensity - (mag - intensityDropOff))
				end

				if isCaster then
					intensity = 1 
				else
					if mag <= 35 then
						hum.WalkSpeed = 0
						hum.JumpPower = 0
						if stunVal.Parent ~= hum.Parent then
							stunVal.Parent = hum.Parent
							con = hum.Parent.ChildAdded:Connect(function(child)
								game:GetService("RunService").RenderStepped:Wait()
								if child:IsA("Tool") then
									hum:UnequipTools()
								end
							end)
						end
					elseif mag > 35 and stunVal.Parent == hum.Parent then
						stunVal.Parent = nil
						if con then
							con:Disconnect()
						end
					end
				end
				hum.CameraOffset = CFrame.new(math.random(-intensity,intensity)/100,math.random(-intensity,intensity)/100,math.random(-intensity,intensity)/100) * CFrame.Angles(math.random(-intensity,intensity)/100,math.random(-intensity,intensity)/100,math.random(-intensity,intensity)/100).Position
			until not enabled

			if con then con:Disconnect() end
			stunVal.Parent = nil
			local restoreHum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if restoreHum then
				restoreHum.WalkSpeed = 16
				restoreHum.JumpPower = 50
				restoreHum.CameraOffset = CFrame.new(0,0,0) * CFrame.Angles(0,0,0).Position
			end
		end)

		task.wait(.5)
		repeat task.wait() until not enabled


		if pressurePlate then
			if pressurePlate:FindFirstChild("ParticleEmitter") then pressurePlate.ParticleEmitter.Enabled = false end
			if pressurePlate:FindFirstChild("ParticleEmitter2") then pressurePlate.ParticleEmitter2.Enabled = false end
			tweenService:Create(pressurePlate.PointLight,TweenInfo.new(.5),{Range = 0, Brightness = 0}):Play()
			task.delay(0.5, function() pressurePlate:Destroy() end)
		end

		tweenService:Create(game.Lighting,TweenInfo.new(.5),{FogColor = Color3.fromRGB(0,0,0),FogStart = 50,FogEnd = 10000}):Play()
		if game.Lighting:FindFirstChild("Pressure") then
			tweenService:Create(game.Lighting.Pressure,TweenInfo.new(.5),{Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255,255,255)}):Play()
			task.delay(0.5, function() game.Lighting.Pressure.Enabled = false end)
		end

		if localDimGui then
			local frame = localDimGui:FindFirstChildWhichIsA("Frame")
			if frame then
				local fadeOut = tweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
				fadeOut:Play(); fadeOut.Completed:Connect(function() localDimGui:Destroy() end)
			else
				localDimGui:Destroy()
			end
		end

		pcall(function() game.Players.LocalPlayer.PlayerGui.Main.areaval.Value = "None" end)
		enabled = false
	end


	repeat task.wait()
		local s,e = pcall(function()
			if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
			if not character or not character:FindFirstChild("HumanoidRootPart") then return end

			mag = (character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
			if not enabled and mag < activationDistance then
				task.spawn(showPressure)
			elseif enabled and mag > removeDistance then
				enabled = false
			end
		end)
	until not character:FindFirstChild("SpiritualPressure") or not character.Parent

	enabled = false
end


local function setupCharacter(character)
	local function addedToChar(child)
		if child.Name == "SpiritualPressure" then
			spiritualPressure(character)
		end
	end

	for _, child in pairs(character:GetChildren()) do
		task.spawn(function() addedToChar(child) end)
	end

	character.ChildAdded:Connect(addedToChar)
end

local function onPlayerAdded(plr)
	if plr.Character then
		setupCharacter(plr.Character)
	end
	plr.CharacterAdded:Connect(setupCharacter)
end

for _, plr in pairs(game.Players:GetPlayers()) do
	onPlayerAdded(plr)
end
game.Players.PlayerAdded:Connect(onPlayerAdded)