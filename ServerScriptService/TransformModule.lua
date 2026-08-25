-- @ScriptType: ModuleScript
local module = {}

local CollectionService = game:GetService("CollectionService")
local playerCooldowns = {} 


local function ActionCheck(character)
	if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
		return true 
	end
	return false 
end


module.Active = function(Player, Character, FormConfig)

	if ActionCheck(Character) then return end


	local lastUsed = playerCooldowns[Player.UserId]
	if lastUsed and (os.clock() - lastUsed) < 3 then 
		return 
	end
	playerCooldowns[Player.UserId] = os.clock()


	local appearanceModule = require(game.ServerStorage.Assets.Homunculi.CopyAppearance)
	local originalMorph = appearanceModule.getOriginalMorph(Player)

	local spiritualPressure = Character:FindFirstChild("SpiritualPressure")


	if spiritualPressure then
		spiritualPressure:Destroy() 

		appearanceModule.transformEff(Character)
		appearanceModule.copyStuff(originalMorph, Character)
		CollectionService:RemoveTag(Character, "Morphed")

	
	else
		
		local newPressure = Instance.new("Folder")
		newPressure.Name = "SpiritualPressure"

	
		if FormConfig.MusicId then
			newPressure:SetAttribute("MusicId", FormConfig.MusicId)
		end

	
		local currentRadius = FormConfig.OrbitRadius or 6

	
		if FormConfig.CustomPlate then
			newPressure:SetAttribute("SkipDefaultPlate", true)
		end


		if FormConfig.ScreenTint then
			newPressure:SetAttribute("ScreenTint", FormConfig.ScreenTint)
		end

		newPressure.Parent = Character

		appearanceModule.clearStuff(Character)
		appearanceModule.transformEff(Character)

	
		local appearanceParts = {}
		local limbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

		for _, limbName in pairs(limbs) do
			local foundPart = Character:FindFirstChild(limbName)
			if foundPart then
				local cube = (limbName == "Head") and FormConfig.HeadCube:Clone() or FormConfig.BodyCube:Clone()

				CollectionService:AddTag(cube, "TransformEff")
				cube.Size = foundPart.Size * 1.05

				if FormConfig.MorphColor then
					cube.Color = FormConfig.MorphColor
				end

				local weld = Instance.new("Weld")
				weld.Part0 = foundPart
				weld.Part1 = cube
				weld.Parent = cube
				cube.Parent = foundPart

				table.insert(appearanceParts, cube)
			end
		end

		if FormConfig.Spikes then
			local spikes = FormConfig.Spikes:Clone()
			spikes.Parent = Character:FindFirstChild("Torso")
			spikes.Enabled = true
			table.insert(appearanceParts, spikes)
		end

		local head = Character:FindFirstChild("Head")
		local rootPart = Character:FindFirstChild("HumanoidRootPart")

		if FormConfig.Eyes and head then
			for _, eyeTemplate in pairs(FormConfig.Eyes) do
				local eyeClone = eyeTemplate:Clone()
				eyeClone.Parent = head
				if eyeClone:FindFirstChild("Weld") then
					eyeClone.Weld.Part1 = head
				end
				table.insert(appearanceParts, eyeClone)
			end
		end


		if FormConfig.CrownAttachment and head then
			local crown = FormConfig.CrownAttachment:Clone()
			crown.Parent = head


			crown.Position = FormConfig.CrownOffset or Vector3.new(0, 2.5, 0) 

		
			for _, child in pairs(crown:GetChildren()) do
				if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
					child.Enabled = true
				end
			end

			table.insert(appearanceParts, crown)
		end
		if FormConfig.AliceRing1 and head then
			local Ring1 = FormConfig.AliceRing1:Clone()
			Ring1.Parent = Character:FindFirstChild("Torso")

			for _, child in pairs(Ring1:GetChildren()) do
				if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
					child.Enabled = true
				end
			end

			table.insert(appearanceParts, Ring1)
		end
		if FormConfig.AliceRing2 and head then
			local Ring2 = FormConfig.AliceRing2:Clone()
			Ring1.Parent = Character:FindFirstChild("Torso")

			for _, child in pairs(Ring2:GetChildren()) do
				if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("PointLight") then
					child.Enabled = true
				end
			end

			table.insert(appearanceParts, Ring2)
		end

		if FormConfig.CustomPlate and rootPart then
			local customPlate = FormConfig.CustomPlate:Clone()
			customPlate.Parent = rootPart

	
			customPlate.Position = Vector3.new(0, -2.5, 0)

			
			for _, child in pairs(customPlate:GetChildren()) do
				if child:IsA("ParticleEmitter") or child:IsA("PointLight") then
					child.Enabled = true
				end
			end

			table.insert(appearanceParts, customPlate)
		end


		if FormConfig.OrbitingCores and rootPart then
			local orbitAnchor = Instance.new("Part")
			orbitAnchor.Size = Vector3.new(1, 1, 1)
			orbitAnchor.Transparency = 1
			orbitAnchor.CanCollide = false
			orbitAnchor.Massless = true
			orbitAnchor.CFrame = rootPart.CFrame
			orbitAnchor.Parent = Character
			table.insert(appearanceParts, orbitAnchor)

			local att0 = Instance.new("Attachment", rootPart)
			local att1 = Instance.new("Attachment", orbitAnchor)
			local hinge = Instance.new("HingeConstraint")
			hinge.Attachment0 = att0
			hinge.Attachment1 = att1
			hinge.ActuatorType = Enum.ActuatorType.Motor
			hinge.MotorMaxTorque = 100000 
			hinge.AngularVelocity = 1.5 
			hinge.Parent = orbitAnchor

			local numCores = #FormConfig.OrbitingCores
			local angleStep = (math.pi * 2) / numCores
			local orbitRadius = 6 

			for i, coreTemplate in ipairs(FormConfig.OrbitingCores) do
				local core = coreTemplate:Clone()
				local angle = i * angleStep

				if core:IsA("Attachment") then
					core.Parent = orbitAnchor
					core.Position = Vector3.new(math.cos(angle) * orbitRadius, 0, math.sin(angle) * orbitRadius)
				elseif core:IsA("BasePart") or core:IsA("Model") then
					core.Parent = orbitAnchor
					local offset = Vector3.new(math.cos(angle) * orbitRadius, 0, math.sin(angle) * orbitRadius)
					local mainPart = core:IsA("Model") and core.PrimaryPart or core
					if mainPart then
						mainPart.CFrame = orbitAnchor.CFrame * CFrame.new(offset)
						local weld = Instance.new("WeldConstraint")
						weld.Part0 = orbitAnchor
						weld.Part1 = mainPart
						weld.Parent = core
					end
				end
				table.insert(appearanceParts, core)
			end
		end


		newPressure:GetPropertyChangedSignal("Parent"):Connect(function()
			if not newPressure.Parent then
				for _, v in pairs(appearanceParts) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
						task.delay(1, function() v:Destroy() end)
					else
						v:Destroy()
					end
				end
			end
		end)
	end
end

return module
