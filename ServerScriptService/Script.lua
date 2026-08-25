-- @ScriptType: Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ==========================================
-- CONFIGURATION
-- ==========================================
local COMMAND = "!spoken"
local EMOTE_ANIM_ID = "rbxassetid://102695799904899"
local EMOTE_AUDIO_ID = "rbxassetid://91007571302298"

local SYNC_RADIUS = 25 

local function formatShirtPants(id)
	return "http://www.roblox.com/asset/?id=" .. tostring(id)
end

local function formatFace(id)
	return "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
end

-- [[ OUTFIT DICTIONARY ]]
local OUTFITS = {
	MaleWanderer   = { FolderName = "MaleWanderer", Shirt = formatShirtPants(107868623831746), Pants = formatShirtPants(5794410751), Face = formatFace(144075659), SkinColor = Color3.fromRGB(253, 234, 141) },
	FemaleWanderer = { FolderName = "FemaleWanderer", Shirt = formatShirtPants(121349483867776), Pants = formatShirtPants(5794410751), Face = formatFace(14861743), SkinColor = Color3.fromRGB(253, 234, 141) },
	ArtVariantFemale = { FolderName = "ArtVariantFemale", Shirt = formatShirtPants(71863730807750), Pants = formatShirtPants(84051965804397), Face = formatFace(9250654), SkinColor = Color3.fromRGB(253, 234, 141) },
	ArtVariantMale = { FolderName = "ArtVariantMale", Shirt = formatShirtPants(13517513214), Pants = formatShirtPants(13519942144), Face = formatFace(406000958), SkinColor = Color3.fromRGB(253, 234, 141) },
	LoveVariantFemale = { FolderName = "LoveVariantFemale", Shirt = formatShirtPants(17390381789), Pants = formatShirtPants(17390408969), Face = formatFace(406035320), SkinColor = Color3.fromRGB(253, 234, 141) },
	LoveVariantMale = { FolderName = "LoveVariantMale", Shirt = formatShirtPants(12188127305), Pants = formatShirtPants(12188130413), Face = formatFace(144075659), SkinColor = Color3.fromRGB(253, 234, 141) },
	CardsFemale = { FolderName = "CardsFemale", Shirt = formatShirtPants(13776425493), Pants = formatShirtPants(1882808357), Face = formatFace(9250654), SkinColor = Color3.fromRGB(253, 234, 141) },
	CardsMale = { FolderName = "CardsMale", Shirt = formatShirtPants(13776425493), Pants = formatShirtPants(1882808357), Face = formatFace(144075659), SkinColor = Color3.fromRGB(253, 234, 141) },
	KingOfHearts   = { FolderName = "KingOfHearts", Shirt = formatShirtPants(8769295178), Pants = formatShirtPants(1882808357), Face = formatFace(144075659), SkinColor = Color3.fromRGB(255, 255, 255) },
	Alice          = { FolderName = "Alice", Shirt = formatShirtPants(11615362958), Pants = formatShirtPants(6333079449), Face = formatFace(14861743), SkinColor = Color3.fromRGB(253, 234, 141) },
	MadHatter      = { FolderName = "MadHatter", Shirt = formatShirtPants(14813130039), Pants = formatShirtPants(14813133051), Face = formatFace(144075659), SkinColor = Color3.fromRGB(255, 255, 255) },
	Jester         = { FolderName = "Jester", Shirt = formatShirtPants(12171455784), Pants = formatShirtPants(9108403548), Face = formatFace(144075659), SkinColor = Color3.fromRGB(253, 234, 141) }
}

-- [[ THE ANIMATION TIMELINE ]]
local SWAP_TIMELINE = {
	{ Frame = 164,  Outfit = OUTFITS.FemaleWanderer,   SpawnVFX = true },
	{ Frame = 242,  Outfit = OUTFITS.MaleWanderer,     SpawnVFX = true },
	{ Frame = 362,  Outfit = OUTFITS.ArtVariantFemale, SpawnVFX = true }, 
	{ Frame = 388,  Outfit = OUTFITS.ArtVariantMale,   SpawnVFX = true },
	{ Frame = 414,  Outfit = OUTFITS.LoveVariantFemale,SpawnVFX = true },
	{ Frame = 440,  Outfit = OUTFITS.LoveVariantMale,  SpawnVFX = true },
	{ Frame = 466,  Outfit = OUTFITS.CardsFemale,      SpawnVFX = true },
	{ Frame = 492,  Outfit = OUTFITS.CardsMale,        SpawnVFX = true },
	{ Frame = 518,  Outfit = OUTFITS.FemaleWanderer,   SpawnVFX = true },
	{ Frame = 544,  Outfit = OUTFITS.MaleWanderer,     SpawnVFX = true },
	{ Frame = 572,  Outfit = OUTFITS.KingOfHearts,     SpawnVFX = true },  
	{ Frame = 695,  Outfit = OUTFITS.Alice,            SpawnVFX = true }, 
	{ Frame = 796,  Outfit = OUTFITS.MadHatter,        SpawnVFX = true },
	{ Frame = 1176, Outfit = OUTFITS.Jester,           SpawnVFX = true }, 
	{ Frame = 1411, Outfit = OUTFITS.MaleWanderer,     SpawnVFX = true }, 
	{ Frame = 1504, Outfit = OUTFITS.Alice,            SpawnVFX = true } 
}

local activeEmotes = {}

-- ==========================================
-- CORE FUNCTIONS
-- ==========================================

local function vacuumAndPrepAccessories(char)
	local cacheFolder = char:FindFirstChild("OriginalAccessoriesCache")
	if not cacheFolder then return end

	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Accoutrement") then
			if v.Name == "EmoteAccessory" then
				v:Destroy() 
			else
				v.Parent = cacheFolder 
			end
		elseif v:IsA("ShirtGraphic") then
			v.Parent = cacheFolder 
		end
	end
end

local function stopEmote(player)
	if activeEmotes[player] then
		local data = activeEmotes[player]
		if data.Track then data.Track:Stop() end
		if data.Sound then data.Sound:Destroy() end
		if data.Microphone then data.Microphone:Destroy() end
		if data.MoveConnection then data.MoveConnection:Disconnect() end
		if data.TimelineConnection then data.TimelineConnection:Disconnect() end

		local char = player.Character
		if char then
			local currentShirt = char:FindFirstChildOfClass("Shirt")
			local currentPants = char:FindFirstChildOfClass("Pants")
			local head = char:FindFirstChild("Head")
			local currentFace = head and head:FindFirstChildOfClass("Decal")

			if currentShirt and data.OriginalShirt then currentShirt.ShirtTemplate = data.OriginalShirt end
			if currentPants and data.OriginalPants then currentPants.PantsTemplate = data.OriginalPants end
			if currentFace and data.OriginalFace then currentFace.Texture = data.OriginalFace end

			if data.OriginalBodyColors then
				local currentBC = char:FindFirstChildOfClass("BodyColors")
				if currentBC then currentBC:Destroy() end
				data.OriginalBodyColors:Clone().Parent = char
			end

			for _, v in pairs(char:GetChildren()) do
				if v:IsA("Accoutrement") and v.Name == "EmoteAccessory" then v:Destroy() end
			end

			local cacheFolder = char:FindFirstChild("OriginalAccessoriesCache")
			local hum = char:FindFirstChild("Humanoid")
			if cacheFolder and hum then
				for _, item in pairs(cacheFolder:GetChildren()) do
					if item:IsA("Accoutrement") then
						hum:AddAccessory(item)
					elseif item:IsA("ShirtGraphic") then
						item.Parent = char
					end
				end
				cacheFolder:Destroy()
			end
		end

		activeEmotes[player] = nil

		-- Free up the attribute lock so they can emote again
		if player:GetAttribute("ActiveEmote") == COMMAND then
			player:SetAttribute("ActiveEmote", nil)
		end
	end
end

local function applySwap(char, outfitData, spawnVFX)
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end

	vacuumAndPrepAccessories(char)

	local shirt = char:FindFirstChildOfClass("Shirt")
	local pants = char:FindFirstChildOfClass("Pants")
	if shirt and outfitData.Shirt then shirt.ShirtTemplate = outfitData.Shirt end
	if pants and outfitData.Pants then pants.PantsTemplate = outfitData.Pants end

	local head = char:FindFirstChild("Head")
	if head and outfitData.Face then
		local faceDecal = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face")
		if not faceDecal then
			faceDecal = Instance.new("Decal")
			faceDecal.Name = "face"
			faceDecal.Face = Enum.NormalId.Front
			faceDecal.Parent = head
		end
		faceDecal.Texture = outfitData.Face
	end

	local bodyColors = char:FindFirstChildOfClass("BodyColors")
	if bodyColors and outfitData.SkinColor then
		bodyColors.HeadColor3 = outfitData.SkinColor
		bodyColors.LeftArmColor3 = outfitData.SkinColor
		bodyColors.RightArmColor3 = outfitData.SkinColor
		bodyColors.LeftLegColor3 = outfitData.SkinColor
		bodyColors.RightLegColor3 = outfitData.SkinColor
		bodyColors.TorsoColor3 = outfitData.SkinColor
	end

	if outfitData.FolderName then
		local assetsFolder = game.ServerStorage:FindFirstChild("EmoteAssets")
		local accessoriesFolder = assetsFolder and assetsFolder:FindFirstChild("Accessories")
		local targetFolder = accessoriesFolder and accessoriesFolder:FindFirstChild(outfitData.FolderName)

		if targetFolder then
			for _, acc in pairs(targetFolder:GetChildren()) do
				if acc:IsA("Accoutrement") then
					local newAcc = acc:Clone()
					newAcc.Name = "EmoteAccessory" 
					hum:AddAccessory(newAcc) 
				end
			end
		end
	end

	if spawnVFX then
		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		local vfxTemplate = game.ServerStorage:FindFirstChild("EmoteAssets") and game.ServerStorage.EmoteAssets:FindFirstChild("SpokenVFX")
		if vfxTemplate and torso then
			local vfx = vfxTemplate:Clone()
			vfx.Parent = torso

			for _, particle in pairs(vfx:GetDescendants()) do
				if particle:IsA("ParticleEmitter") then
					particle:Emit(particle.GetAttribute(particle, "EmitCount") or 30)
				end
			end
			game.Debris:AddItem(vfx, 5)
		end
	end
end

Players.PlayerAdded:Connect(function(player)

	-- [[ CROSS-SCRIPT COMMUNICATION ]]
	-- Listens to see if another script has taken over the active emote!
	player:GetAttributeChangedSignal("ActiveEmote"):Connect(function()
		if player:GetAttribute("ActiveEmote") ~= COMMAND then
			stopEmote(player)
		end
	end)

	player.Chatted:Connect(function(msg)
		if string.lower(msg) == COMMAND then
			local char = player.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChild("Humanoid")

			local isR15 = true
			local rightArm = char:FindFirstChild("RightHand") 
			if not rightArm then 
				rightArm = char:FindFirstChild("Right Arm")
				isR15 = false
			end

			if not hrp or not hum or not rightArm or hum.Health <= 0 then return end

			-- [[ NEW ACTIVE EMOTE CHECK ]]
			-- If they type !spoken while it's already playing, stop it.
			if player:GetAttribute("ActiveEmote") == COMMAND then
				player:SetAttribute("ActiveEmote", nil)
				return
			end

			-- Overwrite the invisible nametag to tell other scripts to shut down
			player:SetAttribute("ActiveEmote", COMMAND)
			task.wait() -- Wait 1 frame so the other script can clean up its props

			-- 1. SAVE ORIGINAL OUTFIT
			local ogShirt = char:FindFirstChildOfClass("Shirt") and char:FindFirstChildOfClass("Shirt").ShirtTemplate
			local ogPants = char:FindFirstChildOfClass("Pants") and char:FindFirstChildOfClass("Pants").PantsTemplate

			local head = char:FindFirstChild("Head")
			local faceDecal = head and (head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face"))
			local ogFace = faceDecal and faceDecal.Texture

			local ogBodyColors = char:FindFirstChildOfClass("BodyColors")
			local clonedOgBodyColors = ogBodyColors and ogBodyColors:Clone()

			local cacheFolder = Instance.new("Folder")
			cacheFolder.Name = "OriginalAccessoriesCache"
			cacheFolder.Parent = char

			activeEmotes[player] = {
				OriginalShirt = ogShirt,
				OriginalPants = ogPants,
				OriginalFace = ogFace,
				OriginalBodyColors = clonedOgBodyColors,
			}
			local emoteData = activeEmotes[player]

			-- 2. SETUP ANIMATION & AUDIO
			local animator = hum:FindFirstChild("Animator") or Instance.new("Animator", hum)
			local anim = Instance.new("Animation")
			anim.AnimationId = EMOTE_ANIM_ID
			local track = animator:LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Action
			emoteData.Track = track

			local sound = Instance.new("Sound")
			sound.Name = "EmoteMusic" 
			sound.SoundId = EMOTE_AUDIO_ID
			sound.Parent = hrp
			sound.Looped = false
			sound.Volume = 1
			sound.RollOffMaxDistance = 40 
			emoteData.Sound = sound

			-- 3. SETUP THE MICROPHONE
			local mic = nil
			local micTemplate = game.ServerStorage:FindFirstChild("EmoteAssets") and game.ServerStorage.EmoteAssets:FindFirstChild("Microphone")

			if micTemplate then
				mic = micTemplate:Clone()
				mic.Massless = true
				mic.CanCollide = false
				mic.Parent = char

				local weld = Instance.new("Weld")
				weld.Part0 = rightArm
				local micPart = mic:IsA("Model") and mic.PrimaryPart or mic
				weld.Part1 = micPart
				weld.Parent = mic

				if isR15 then
					weld.C0 = CFrame.new(0, 0, -0.5) * CFrame.Angles(0, math.rad(90), 0)
				else
					weld.C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(0, math.rad(90), -90)
				end
			end
			emoteData.Microphone = mic

			-- 4. SYNCING LOGIC
			local syncTime = 0
			for otherPlr, data in pairs(activeEmotes) do
				if otherPlr ~= player and otherPlr.Character and otherPlr.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (hrp.Position - otherPlr.Character.HumanoidRootPart.Position).Magnitude
					if dist <= SYNC_RADIUS and data.Track and data.Track.IsPlaying then
						syncTime = data.Track.TimePosition
						break
					end
				end
			end

			track:Play()

			if syncTime > 0 then
				track.TimePosition = syncTime
				sound:Destroy()
				emoteData.Sound = nil
			else
				sound:Play()
			end

			-- 5. TIMELINE TRACKER
			local currentSwapIndex = 1

			while currentSwapIndex <= #SWAP_TIMELINE and syncTime >= (SWAP_TIMELINE[currentSwapIndex].Frame / 60) do
				currentSwapIndex = currentSwapIndex + 1
			end

			if currentSwapIndex > 1 then
				local step = SWAP_TIMELINE[currentSwapIndex - 1]
				applySwap(char, step.Outfit, false)
			end

			local timelineConn = RunService.Heartbeat:Connect(function()
				if currentSwapIndex <= #SWAP_TIMELINE then
					local targetTime = SWAP_TIMELINE[currentSwapIndex].Frame / 60
					if track.TimePosition >= targetTime then
						local step = SWAP_TIMELINE[currentSwapIndex]

						applySwap(char, step.Outfit, step.SpawnVFX)

						currentSwapIndex = currentSwapIndex + 1
					end
				end
			end)
			emoteData.TimelineConnection = timelineConn

			-- 6. AUTO-STOP ON MOVEMENT
			local moveConn = hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
				if hum.MoveDirection.Magnitude > 0 then
					stopEmote(player)
				end
			end)
			emoteData.MoveConnection = moveConn
		end
	end)

	player.AncestryChanged:Connect(function()
		stopEmote(player)
	end)
end)