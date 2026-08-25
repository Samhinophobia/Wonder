-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local currentDreamStatus = ReplicatedStorage:WaitForChild("CurrentDreamStatus")

local CARDS_BADGE_ID = 3131894360227811
local VALENTINE_BADGE_ID = 2773698578051092 

local DEFAULT_TITLE = "Wanderer"

local ART_WHITELIST = {
	[986225083] = true, 
	[5782558987] = true, 
	[426073508] = true, 
	[4477038552] = true, 
	[22156521] = true, 
	[2978454934] = true 
}

local OUTFIT_WHITELIST = { 
	[12345678] = true 
}

--Grouped limited permissions to replace the individual whitelists
local LIMITED_PERMISSIONS = {
	[5782558987] = { stars = true, loop = true, lag = true, valentine = true, cards = true, Killer = true },
	[2978454934] = { loop = true, lag = true, valentine = true, cards = true, Killer = true }, --wiki guy
	[4477038552] = { stars = true, loop = true, lag = true, Killer = true},
	[4119810269]  = { lag = true } -- Event Winner
}

local toggleState = { 
	Avatar = {}, Female = {}, Cards = {}, Art = {}, DJ = {}, Love = {}, Stars = {}, loop = {}, lag = {}, Killer = {}
}

local WOMAN_BODY = { 
	Torso = 48474356, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 
}

local MALE_WANDERER = {
	Face = 144075659, SkinColor = Color3.fromRGB(253, 234, 141), 
	BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, 
	Shirt = 107868623831746, Pants = 5794410751, 
	Accessories = {139152472, 1082932, 71629218409765, 144075659} 
}

local FEMALE_WANDERER = {
	Face = 14861743, SkinColor = Color3.fromRGB(253, 234, 141), 
	BodyParts = WOMAN_BODY, 
	Shirt = 121349483867776, Pants = 5794410751, 
	Accessories = {139152472, 1082932, 71629218409765, 144075659, 14021743801} 
}

local HATTER_DREAM_A = {
	Face = 144075659, SkinColor = Color3.fromRGB(255, 255, 255), 
	Shirt = 14813130039, Pants = 14813133051, 
	Accessories = {99039826124593, 110455787211719, 823012694, 70908511376478, 81363729019077, 109099853903199} 
}

local HATTER_DREAM_B = {
	Face = 144075659, SkinColor = Color3.fromRGB(255, 255, 255), 
	Shirt = 110252938626836, Pants = 17762052810, 
	Accessories = {
		8807920971, 13702160, 82434874316735,
		{ Id = 109099853903199, Offset = Vector3.new(0, -0.174, 0), Rotation = Vector3.new(0, 0, 0) }, 
		{ Id = 124746065, Offset = Vector3.new(0, 0.139, 0), Rotation = Vector3.new(-3.074, 0.543, -10.015) }
	} 
}

local DEFAULT_OUTFITS = {
	Male = {
		Awake = MALE_WANDERER,
		Valentine = { Face = 144075659, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, Shirt = 12188127305, Pants = 12188130413, Accessories = {139152472,104578025026782,130749054277934,111290843897782,97379574216962,139630002041416,{ Id = 74881190976043, Offset = Vector3.new(0, -0.313, -0.055), Rotation = Vector3.new(0, 0, 0) }}},
		Artist = { Face = 406000958, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, Shirt = 13517513214, Pants = 13519942144, Accessories = {139152472, 71629218409765, 144075659, { Id = 14894377360, Offset = Vector3.new(0, -0.435, -0.02), Rotation = Vector3.new(2.529, 0, 0) }} },
		DJ = { Face = 406000958, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, Shirt = 0, Pants = 0, Accessories = {139152472} },
		Dreams = { 
			["Default"] = MALE_WANDERER, ["Taberna"] = MALE_WANDERER, ["Nivalis"] = MALE_WANDERER,
			["Regnum Chartarum"] = { Face = 144075659, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, Shirt = 13776425493, Pants = 1882808357, Accessories = {14894403884, 139152472, 71629218409765, 144343310175058} },
			["Karma's Resting Place"] = { Face = 144075659, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 }, Shirt = 13776425493, Pants = 1882808357, Accessories = {14894403884, 139152472, 71629218409765, 144343310175058} },
			["Convivium Potationis Perpetuum"] = { LoreCharacter = "Patrico (Act 2)"},
			["Silva Mendaciorum"] = { LoreCharacter = "Patrico (Act 2)"}
		}
	},
	Female = {
		Awake = FEMALE_WANDERER,
		Valentine = { Face = 406035320, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = WOMAN_BODY, Shirt = 17390381789, Pants = 17390408969, Accessories = {15461268389, 80021724580935, 109926061167821,95732975537169,139152472}},
		Artist = { Face = 9250654, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = WOMAN_BODY, Shirt = 71863730807750, Pants = 84051965804397, Accessories = {139152472, 398673423, 126095520722305, { Id = 14701927521, Offset = Vector3.new(0.036, -0.492, -0.127), Rotation = Vector3.new(-0.409, 0, 0) }} },
		DJ = { Face = 9250654, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = WOMAN_BODY, Shirt = 0, Pants = 0, Accessories = {139152472} },
		Dreams = { 
			["Default"] = FEMALE_WANDERER, ["Taberna"] = FEMALE_WANDERER, ["Nivalis"] = FEMALE_WANDERER,
			["Regnum Chartarum"] = { Face = 9250654, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = WOMAN_BODY, Shirt = 13776425493, Pants = 1882808357, Accessories = {14894403884, 139152472, 71629218409765, 144343310175058, 14021743801} },
			["Karma's Resting Place"] = { Face = 9250654, SkinColor = Color3.fromRGB(253, 234, 141), BodyParts = WOMAN_BODY, Shirt = 13776425493, Pants = 1882808357, Accessories = {14894403884, 139152472, 71629218409765, 144343310175058, 14021743801} },
			["Convivium Potationis Perpetuum"] = { LoreCharacter = "Karma (Act 2)", BodyParts = WOMAN_BODY },
			["Silva Mendaciorum"] = { LoreCharacter = "Karma (Act 2)", BodyParts = WOMAN_BODY }
		}
	}
}

local VIP_PLAYERS = {
	[4477038552] = { -- King of Hearts
		Title = "King of Hearts", TitleColor = Color3.fromRGB(220, 20, 60), TitleFont = Enum.Font.IndieFlower, NameColor = Color3.fromRGB(255, 80, 80), NameFont = Enum.Font.PermanentMarker, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))}), 
		MainOutfit = { SkinColor = Color3.fromRGB(255, 255, 255), Face = 144075659, Shirt = 8769295178, Pants = 1882808357, Accessories = {7259123616, 7963401282, 11821812288, 144075659} }, DreamOutfit = nil 
	},
	[885558216] = { -- Mad Hatter
		Title = "Mad Hatter", TitleColor = Color3.fromRGB(255, 255, 255), TitleFont = Enum.Font.IndieFlower, NameColor = Color3.fromRGB(170, 80, 255), NameFont = Enum.Font.PermanentMarker, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 0, 170)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 255))}),
		MainOutfit = "DEFAULT", DreamVariants = {HATTER_DREAM_A, HATTER_DREAM_B}
	},
	[3457196097] = { -- Momo
		Title = "The White Rabbit", TitleColor = Color3.fromRGB(240, 240, 240), TitleFont = Enum.Font.IndieFlower, NameColor = Color3.fromRGB(210, 210, 210), NameFont = Enum.Font.PermanentMarker, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 160)), ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240))}),
		MainOutfit = { LoreCharacter = "Momo", BodyParts = WOMAN_BODY }, 
		DreamOutfit = { LoreCharacter = "Momo", BodyParts = WOMAN_BODY },
	},
	[22156521] = { -- Alice
		Title = "The Dreamsphere", TitleColor = Color3.fromRGB(255, 255, 0), TitleFont = Enum.Font.IndieFlower, NameColor = Color3.fromRGB(255, 170, 0), NameFont = Enum.Font.PermanentMarker, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))}),
		MainOutfit = { SkinColor = Color3.fromRGB(253, 234, 141), Face = 144075659, Shirt = 11615362958, Pants = 6333079449, Accessories = {139247981043370, 75654134505201, 90426356141324, 100885379897368, 122115037077558, 79926521633523, 139541600769860, 81617066495511} },
		DreamOutfit = { SkinColor = Color3.fromRGB(253, 234, 141), Face = 144075659, Shirt = 11615362958, Pants = 6333079449, Accessories = {139247981043370, 75654134505201, 90426356141324, 100885379897368, 122115037077558, 79926521633523, 139541600769860, 81617066495511} }
	},
	[0] = { -- Red
		Title = "The Last Native", 
		MainOutfit = { SkinColor = Color3.fromRGB(253, 234, 141), Face = 144075659, BodyParts = WOMAN_BODY, Shirt = 402624467, Pants = 5342706331, Accessories = { { Id = 92480468904840, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 18922458373, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 96516195044234, Offset = Vector3.new(-4, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 138420216496838, Offset = Vector3.new(-4.001, -0.001, 0.08), Rotation = Vector3.new(0, 0, 0), Scale = Vector3.new(1.088, 1.02, 1.237) } } },
		DreamOutfit = { SkinColor = Color3.fromRGB(253, 234, 141), Face = 144075659, BodyParts = WOMAN_BODY, Shirt = 402624467, Pants = 5342706331, Accessories = { { Id = 92480468904840, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 18922458373, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 96516195044234, Offset = Vector3.new(-4, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 138420216496838, Offset = Vector3.new(-4.001, -0.001, 0.08), Rotation = Vector3.new(0, 0, 0), Scale = Vector3.new(1.088, 1.02, 1.237) } } }
	},
	[0] = { -- Jester
		Title = "Artist", TitleColor = Color3.fromRGB(255, 255, 255), TitleFont = Enum.Font.Kalam, NameColor = Color3.fromRGB(255, 150, 200), NameFont = Enum.Font.Kalam, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 45, 67)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(138, 43, 226)), ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 45, 67))}), 
		MainOutfit = { SkinColor = Color3.fromRGB(255, 255, 255), Face = 144075659, BodyParts = WOMAN_BODY, Shirt = 79711832585062, Pants = 73974099517212, Accessories = { { Id = 92480468904840, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 18922458373, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 96516195044234, Offset = Vector3.new(-0, 0.2, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 138420216496838, Offset = Vector3.new(-0, -0.3, -0.105), Rotation = Vector3.new(0, 0, 0), Scale = Vector3.new(1.088, 1.02, 1.237) } } },
		DreamOutfit = { SkinColor = Color3.fromRGB(255, 255, 255), Face = 144075659, BodyParts = WOMAN_BODY, Shirt = 79711832585062, Pants = 73974099517212, Accessories = { { Id = 92480468904840, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 18922458373, Offset = Vector3.new(0, 0, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 96516195044234, Offset = Vector3.new(-0, 0.2, 0), Rotation = Vector3.new(0, 0, 0) }, { Id = 138420216496838, Offset = Vector3.new(-0, -0.3, -0.105), Rotation = Vector3.new(0, 0, 0), Scale = Vector3.new(1.088, 1.02, 1.237) } }, WaistHalo = game.ServerStorage:FindFirstChild("JesterHalo") }
	},
	[513348034] = { Title = "Tester", TitleColor = Color3.fromRGB(255, 170, 255), MainOutfit = "DEFAULT", DreamOutfit = "DEFAULT" },
	[779537167] = { Title = "Owner", TitleColor = Color3.fromRGB(85, 0, 0), MainOutfit = "DEFAULT", DreamOutfit = "DEFAULT" },
	[5782558987] = { Title = "Lead Tester", TitleColor = Color3.fromRGB(85, 0, 127), TitleFont = Enum.Font.Kalam, NameColor = Color3.fromRGB(170, 85, 255), NameFont = Enum.Font.Kalam, UseGradient = true, GradientColors = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 255))}), MainOutfit = "DEFAULT", DreamOutfit = "DEFAULT" }
}

local function formatAssetId(id) 
	return id and id ~= 0 and "http://www.roblox.com/asset/?id=" .. id or nil 
end

local function applyAnimatedHalo(character, haloTemplate)
	if not haloTemplate then return end
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	local halo = haloTemplate:Clone()
	halo.Name = "AnimatedWaistHalo"
	halo.Massless = true; halo.CanCollide = false; halo.CanTouch = false; halo.Anchored = false 
	halo.CFrame = hrp.CFrame; halo.Parent = character

	local weld = Instance.new("Weld"); weld.Part0 = hrp; weld.Part1 = halo; weld.Parent = halo
	weld.C0 = CFrame.new(0.11, 0.018, 0.026) * CFrame.Angles(math.rad(16.386), math.rad(-172.736), math.rad(42.905))

	local baseSize = halo.Size
	local timePassed = 0

	RunService.Heartbeat:Connect(function(dt)
		if not halo.Parent or not hrp.Parent then return end
		timePassed = timePassed + dt
		weld.C1 = CFrame.Angles(0, math.rad(timePassed * 90), 0)
		local sideMultiplier = 1.125 + (math.sin(timePassed * 2.5) * 0.125)
		halo.Size = Vector3.new(baseSize.X, baseSize.Y * sideMultiplier, baseSize.Z * sideMultiplier)
		halo.Transparency = 0.15 + (math.sin(timePassed * 5) * 0.15)
	end)
end

local function loadAccessoriesDirect(playerCharacter, accessoryDataList)
	if not accessoryDataList or #accessoryDataList == 0 then return end
	for _, entry in ipairs(accessoryDataList) do
		local assetId, offset, rotation, scale = nil, nil, nil, nil
		if type(entry) == "table" then 
			assetId = entry.Id; offset = entry.Offset; rotation = entry.Rotation; scale = entry.Scale
		else 
			assetId = entry 
		end

		local acc = nil
		local modelToDestroy = nil

		if type(assetId) == "string" then
			local serverItem = game:GetService("ServerStorage"):FindFirstChild(assetId)
			if serverItem then
				local clonedItem = serverItem:Clone()
				if clonedItem:IsA("Accessory") then acc = clonedItem
				else acc = clonedItem:FindFirstChildOfClass("Accessory"); modelToDestroy = clonedItem end
			end
		else
			local s, loadedModel = pcall(function() return InsertService:LoadAsset(assetId) end)
			if s and loadedModel then acc = loadedModel:FindFirstChildOfClass("Accessory"); modelToDestroy = loadedModel end
		end

		if acc then
			acc.Parent = playerCharacter
			local handle = acc:FindFirstChild("Handle")
			if handle then
				if scale and handle:IsA("MeshPart") then handle.Size = scale
				elseif scale and handle:FindFirstChildWhichIsA("SpecialMesh") then handle:FindFirstChildWhichIsA("SpecialMesh").Scale = scale end

				local weld = handle:WaitForChild("AccessoryWeld", 1)
				if weld then
					if offset then weld.C0 = weld.C0 + offset end
					if rotation then weld.C0 = weld.C0 * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)) end
				end
			end
		end

		if modelToDestroy then modelToDestroy:Destroy() end
	end
end

local function applyOutfit(player, character, outfitData)
	local hum = character:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end 

	-- 1A. Signal Script 1 to stop any playing emotes immediately
	character:SetAttribute("OutfitChanged", tick())

	-- 1B. Stamp the character with the current Lore skin so Script 1 can read it
	if outfitData and outfitData.LoreCharacter then
		character:SetAttribute("ActiveSkin", outfitData.LoreCharacter)
	else
		character:SetAttribute("ActiveSkin", "Default")
	end

	-- 1C. Hard-Delete any lingering Emote effects (Spirals & Music) left in the rig
	for _, v in pairs(character:GetChildren()) do
		if v.Name == "SpiralDisc" then
			v:Destroy()
		end
	end
	-- 1C. Hard-Delete any lingering Emote effects (Spirals & Music) left in the rig
	for _, v in pairs(character:GetChildren()) do
		if v.Name == "SpiralDisc" then
			v:Destroy()
		end
	end

	-- 1D. Remove any Lore skin effects (particles/trails/beams) cloned onto body parts
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			for _, child in ipairs(part:GetChildren()) do
				if child:GetAttribute("LoreSkinEffect") then
					child:Destroy()
				end
			end
		end
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, v in pairs(hrp:GetChildren()) do
			if v.Name == "EmoteMusic" then
				v:Destroy()
			end
		end
	end

	-- 1. Remove all old accessories and clothing
	hum:RemoveAccessories()
	for _, v in pairs(character:GetChildren()) do 
		if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v.Name == "AnimatedWaistHalo" then 
			v:Destroy() 
		end 
	end


	-- 2. Base HumanoidDescription (Handles Body Parts & Skin Colors first!)
	local s, realDesc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(player.UserId) end)
	if not s then realDesc = Instance.new("HumanoidDescription") end

	if outfitData then
		local cd = Instance.new("HumanoidDescription")
		cd.HeightScale = realDesc.HeightScale; cd.WidthScale = realDesc.WidthScale; cd.DepthScale = realDesc.DepthScale; cd.HeadScale = realDesc.HeadScale

		if outfitData.BodyParts then
			if outfitData.BodyParts.Torso ~= 0 then cd.Torso = outfitData.BodyParts.Torso end
			if outfitData.BodyParts.LeftArm ~= 0 then cd.LeftArm = outfitData.BodyParts.LeftArm end
			if outfitData.BodyParts.RightArm ~= 0 then cd.RightArm = outfitData.BodyParts.RightArm end
			if outfitData.BodyParts.LeftLeg ~= 0 then cd.LeftLeg = outfitData.BodyParts.LeftLeg end
			if outfitData.BodyParts.RightLeg ~= 0 then cd.RightLeg = outfitData.BodyParts.RightLeg end
		end

		if outfitData.SkinColor then 
			cd.HeadColor = outfitData.SkinColor; cd.TorsoColor = outfitData.SkinColor; 
			cd.LeftArmColor = outfitData.SkinColor; cd.RightArmColor = outfitData.SkinColor; 
			cd.LeftLegColor = outfitData.SkinColor; cd.RightLegColor = outfitData.SkinColor 
		end

		-- Only set the Face Decal ID if it is provided
		if outfitData.Face then cd.Face = outfitData.Face end

		for i=1,3 do
			local err = pcall(function() hum:ApplyDescription(cd) end)
			if err then break end
			task.wait(0.2)
		end

		-- 3. Now apply the specific items (Lore vs Normal)
		local head = character:FindFirstChild("Head")

		if outfitData.LoreCharacter then
			local loreFolder = game:GetService("ServerStorage"):FindFirstChild("LoreCharacters")
			if loreFolder then
				local dummy = loreFolder:FindFirstChild(outfitData.LoreCharacter)
				if dummy then

					-- Remove the player's current face so we can use the Dummy's face
					if head then
						for _, v in pairs(head:GetChildren()) do
							if v:IsA("Decal") and v.Name == "face" then v:Destroy() end
						end
					end

					-- [FIX] Skin Colors: Dynamically apply BodyColors from the dummy to override HumanoidDescription
					local dummyBodyColors = dummy:FindFirstChildWhichIsA("BodyColors")
					if dummyBodyColors then
						dummyBodyColors:Clone().Parent = character
					else
						-- Fallback: Create a BodyColors dynamically by sampling the dummy's part colors
						local newBc = Instance.new("BodyColors")
						local function getColor(partName) 
							local p = dummy:FindFirstChild(partName)
							return p and p.Color or newBc.HeadColor3
						end
						newBc.HeadColor3 = getColor("Head")
						newBc.TorsoColor3 = getColor("Torso")
						newBc.LeftArmColor3 = getColor("Left Arm")
						newBc.RightArmColor3 = getColor("Right Arm")
						newBc.LeftLegColor3 = getColor("Left Leg")
						newBc.RightLegColor3 = getColor("Right Leg")
						newBc.Parent = character
					end

					-- Apply Clothing and Accessories
					for _, item in ipairs(dummy:GetChildren()) do
						if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") then
							item:Clone().Parent = character
						elseif item:IsA("BasePart") then
							-- [FIX] Particle Effects: Transfer Particles, Trails, Beams, Attachments from the Dummy's parts (like Torso)
							local charPart = character:FindFirstChild(item.Name)
							if charPart then
								for _, effect in ipairs(item:GetChildren()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Fire") or effect:IsA("Sparkles") 
										or effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("Attachment") 
										or effect:IsA("Light") then
										local fxClone = effect:Clone()
										fxClone:SetAttribute("LoreSkinEffect", true) -- mark it so cleanup can find it later
										fxClone.Parent = charPart
									end
								end
							end
						end
					end

					local dummyHead = dummy:FindFirstChild("Head")
					if dummyHead and head then
						local dummyFace = dummyHead:FindFirstChildOfClass("Decal")
						if dummyFace then dummyFace:Clone().Parent = head end
					end
				else
					warn("AvatarManager: Could not find '" .. outfitData.LoreCharacter .. "' in ServerStorage.LoreCharacters")
				end
			else
				warn("AvatarManager: 'LoreCharacters' folder is missing from ServerStorage!")
			end
		else
			-- Normal Outfit Application
			if outfitData.Shirt then local sh = Instance.new("Shirt", character); sh.ShirtTemplate = formatAssetId(outfitData.Shirt) end
			if outfitData.Pants then local pa = Instance.new("Pants", character); pa.PantsTemplate = formatAssetId(outfitData.Pants) end

			loadAccessoriesDirect(character, outfitData.Accessories or {})
		end

		if outfitData.WaistHalo then applyAnimatedHalo(character, outfitData.WaistHalo) end
	else
		pcall(function() hum:ApplyDescription(realDesc) end)
	end
end

local function createOverheadUI(character, titleText, titleColor, useGradient, gradientColors, nameColor, nameFont, titleFont)
	local head = character:WaitForChild("Head", 10); if not head then return end
	if head:FindFirstChild("OverheadRank") then head.OverheadRank:Destroy() end

	local b = Instance.new("BillboardGui", head); b.Name="OverheadRank"; b.Size=UDim2.new(0,200,0,100); b.StudsOffset=Vector3.new(0,3,0); b.AlwaysOnTop=true; b.MaxDistance=40
	local c = Instance.new("CanvasGroup", b); c.Name="Container"; c.Size=UDim2.fromScale(1,1); c.BackgroundTransparency=1

	local nl = Instance.new("TextLabel", c); nl.Name="NameLabel"; nl.Size=UDim2.new(1,0,0.3,0); nl.Position=UDim2.new(0,0,0.2,0); nl.Text=character.Name; nl.TextColor3=nameColor or Color3.new(1,1,1); nl.Font=nameFont or Enum.Font.IndieFlower; nl.BackgroundTransparency=1; nl.TextScaled=true
	local tl = Instance.new("TextLabel", c); tl.Name="TitleLabel"; tl.Size=UDim2.new(1,0,0.25,0); tl.Position=UDim2.new(0,0,0.5,0); tl.Text=titleText; tl.TextColor3=titleColor or Color3.new(1,0.8,0); tl.Font=titleFont or Enum.Font.PermanentMarker; tl.BackgroundTransparency=1; tl.TextScaled=true

	if useGradient and gradientColors then local g = Instance.new("UIGradient", tl); g.Color = gradientColors end
end

local function findPlayerByPartialName(nameStr)
	for _, p in ipairs(Players:GetPlayers()) do
		if string.lower(p.Name):find(string.lower(nameStr)) or string.lower(p.DisplayName):find(string.lower(nameStr)) then
			return p
		end
	end
	return nil
end

local function updateCharacter(player, character)
	if not character or not character.Parent then return end
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local hum = character:WaitForChild("Humanoid", 5)
	if not root or not hum or hum.Health <= 0 then return end

	local userId = player.UserId
	local currentMapName = currentDreamStatus.Value
	local isPlayerDreaming = (currentMapName ~= "")

	if isPlayerDreaming then
		local dVal = player:FindFirstChild("Dreaming")
		if dVal and dVal.Value ~= 1 then dVal.Value = 1 end
	end

	local genderSet = toggleState.Female[userId] and DEFAULT_OUTFITS.Female or DEFAULT_OUTFITS.Male
	player:SetAttribute("ActiveMorph", toggleState.Female[userId] and "Karma" or "Patrico")
	local targetOutfit = genderSet.Awake

	local myTitle, myColor, useGradient, gradientColors, myNameColor, myNameFont, myTitleFont = DEFAULT_TITLE, Color3.new(1,1,1), false, nil, Color3.new(1,1,1), Enum.Font.IndieFlower, Enum.Font.PermanentMarker
	local vipData = VIP_PLAYERS[userId]

	if vipData then
		myTitle = vipData.Title; myColor = vipData.TitleColor; useGradient = vipData.UseGradient; gradientColors = vipData.GradientColors; myNameColor = vipData.NameColor; myNameFont = vipData.NameFont; myTitleFont = vipData.TitleFont
	end

	if toggleState.Avatar[userId] then 
		targetOutfit = nil 
	elseif toggleState.Stars[userId] then 
		if toggleState.Female[userId] then
			targetOutfit = { LoreCharacter = "StarKarma", BodyParts = WOMAN_BODY }
		else
			targetOutfit = { LoreCharacter = "StarPatrico", BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 } }
		end
	elseif toggleState.Killer[userId] then 
		if toggleState.Female[userId] then
			targetOutfit = { LoreCharacter = "ButcherKarma", BodyParts = WOMAN_BODY }
		else
			targetOutfit = { LoreCharacter = "ButcherPatrico", BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 } }
		end
	elseif toggleState.lag[userId] then 
		targetOutfit = { LoreCharacter = "LagPatrico", BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0,} }
	elseif toggleState.loop[userId] then 
		targetOutfit = { LoreCharacter = "LoopPatrico", BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 } }
	elseif toggleState.Cards[userId] then 
		targetOutfit = genderSet.Dreams["Regnum Chartarum"] 
	elseif toggleState.Art[userId] then 
		targetOutfit = genderSet.Artist
	elseif toggleState.DJ[userId] then 
		targetOutfit = genderSet.DJ 
	elseif toggleState.Love[userId] then 
		targetOutfit = genderSet.Valentine
	else
		if vipData then
			if myTitle == "Tester" then
				if isPlayerDreaming then
					if genderSet.Dreams[currentMapName] then targetOutfit = genderSet.Dreams[currentMapName]
					else targetOutfit = genderSet.Dreams["Default"] end
				else
					targetOutfit = genderSet.Awake
				end
			else
				-- Normal VIP Logic (King, Hatter, Momo, etc.)
				if isPlayerDreaming then
					if vipData.DreamVariants and #vipData.DreamVariants > 0 then
						targetOutfit = vipData.DreamVariants[math.random(1, #vipData.DreamVariants)]
					elseif vipData.DreamOutfit ~= nil then
						local dreamSetting = vipData.DreamOutfit
						if type(dreamSetting) == "string" and string.upper(dreamSetting) == "DEFAULT" then
							if genderSet.Dreams[currentMapName] then targetOutfit = genderSet.Dreams[currentMapName]
							else targetOutfit = genderSet.Dreams["Default"] end
						elseif type(dreamSetting) == "string" and (string.upper(dreamSetting) == "ROBLOX" or string.upper(dreamSetting) == "NIL") then
							targetOutfit = nil
						else
							targetOutfit = dreamSetting
						end
					else
						targetOutfit = nil
					end
				else
					if vipData.MainOutfit ~= nil then
						local mainSetting = vipData.MainOutfit
						if type(mainSetting) == "string" and string.upper(mainSetting) == "DEFAULT" then targetOutfit = genderSet.Awake
						elseif type(mainSetting) == "string" and (string.upper(mainSetting) == "ROBLOX" or string.upper(mainSetting) == "NIL") then targetOutfit = nil
						else targetOutfit = mainSetting end
					else
						targetOutfit = nil
					end
				end
			end
		else 
			-- Normal Player Logic
			if isPlayerDreaming then 

				if userId == 2978454934 and not toggleState.Female[userId] then
					targetOutfit = { LoreCharacter = "Emperor Rico", BodyParts = { Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0 } }

				elseif genderSet.Dreams[currentMapName] then 
					targetOutfit = genderSet.Dreams[currentMapName] 
				elseif genderSet.Dreams["Default"] then 
					targetOutfit = genderSet.Dreams["Default"]
				else 
					targetOutfit = genderSet.Awake 
				end 
			else 
				targetOutfit = genderSet.Awake 
			end 
		end
	end

	if vipData and hum then 
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		createOverheadUI(character, myTitle, myColor, useGradient, gradientColors, myNameColor, myNameFont, myTitleFont) 
	else 
		if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
		if character.Head:FindFirstChild("OverheadRank") then character.Head.OverheadRank:Destroy() end 
	end

	task.spawn(function()
		if not player:HasAppearanceLoaded() then player.CharacterAppearanceLoaded:Wait() end
		task.wait(0.5)
		if character and character.Parent and hum.Health > 0 then
			applyOutfit(player, character, targetOutfit)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local low = msg:lower(); local refresh = false; local id = player.UserId
		local isGlobalAdmin = ART_WHITELIST[id]; local isOutfitAdmin = OUTFIT_WHITELIST[id] or VIP_PLAYERS[id]

		-- Helper to check the grouped limited permissions easily
		local function hasLimitedSkin(skinName)
			if isGlobalAdmin then return true end
			if LIMITED_PERMISSIONS[id] and LIMITED_PERMISSIONS[id][skinName] then return true end
			return false
		end

		local function setExclusiveOutfit(outfitName)
			local wasActive = toggleState[outfitName][id]
			-- Disabled ALL other toggle states so they don't overlap
			toggleState.Avatar[id] = false; toggleState.Cards[id] = false; toggleState.Art[id] = false; 
			toggleState.DJ[id] = false; toggleState.Love[id] = false; toggleState.Stars[id] = false; toggleState.Killer[id] = false;
			toggleState.loop[id] = false; toggleState.lag[id] = false;
			toggleState[outfitName][id] = not wasActive
			refresh = true
		end

		if low == "!f" or low == "!female" then toggleState.Female[id] = not toggleState.Female[id]; refresh = true end
		if low == "!avatar" and (isOutfitAdmin or isGlobalAdmin) then setExclusiveOutfit("Avatar") end

		if isGlobalAdmin then
			if low == "!art" then setExclusiveOutfit("Art") end
			if low == "!dj" then setExclusiveOutfit("DJ") end
		end

		-- Cleaned up toggles using the new `hasLimitedSkin` grouping logic
		if low == "!stars" and hasLimitedSkin("stars") then setExclusiveOutfit("Stars") end
		if low == "!vanity" and hasLimitedSkin("Killer") then setExclusiveOutfit("Killer") end
		if low == "!loop" and hasLimitedSkin("loop") then setExclusiveOutfit("loop") end
		if low == "!lag" and hasLimitedSkin("lag") then setExclusiveOutfit("lag") end

		if (low == "!card" or low == "!cards") then 
			local s, has = pcall(function() return BadgeService:UserHasBadgeAsync(id, CARDS_BADGE_ID) end)
			if (s and has) or hasLimitedSkin("cards") then setExclusiveOutfit("Cards") end
		end

		if (low == "!love" or low == "!valentine") then
			local s, has = pcall(function() return BadgeService:UserHasBadgeAsync(id, VALENTINE_BADGE_ID) end)
			if (s and has) or hasLimitedSkin("valentine") then setExclusiveOutfit("Love") end
		end

		if refresh and player.Character then updateCharacter(player, player.Character) end
	end)

	player.CharacterAdded:Connect(function(char) updateCharacter(player, char) end)
	player.ChildAdded:Connect(function(child)
		if child.Name == "Dreaming" then
			child.Changed:Connect(function() updateCharacter(player, player.Character) end)
		end
	end)
end)

currentDreamStatus.Changed:Connect(function()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then updateCharacter(p, p.Character) end
	end
end)

local adminForceEvent = game:GetService("ServerStorage"):WaitForChild("AdminForceOutfit", 10)

if adminForceEvent then
	adminForceEvent.Event:Connect(function(targetPlayer, outfitStyle)
		local id = targetPlayer.UserId

		-- Reset all outfit booleans when forcing
		toggleState.Avatar[id] = false; toggleState.Cards[id] = false; toggleState.Art[id] = false; 
		toggleState.DJ[id] = false; toggleState.Love[id] = false; toggleState.Stars[id] = false;
		toggleState.loop[id] = false; toggleState.lag[id] = false; toggleState.Killer[id] = false;

		local styleLower = string.lower(outfitStyle)
		if styleLower == "valentine" or styleLower == "love" then toggleState.Love[id] = true
		elseif styleLower == "art" or styleLower == "artist" then toggleState.Art[id] = true
		elseif styleLower == "dj" then toggleState.DJ[id] = true
		elseif styleLower == "cards" or styleLower == "card" then toggleState.Cards[id] = true
		elseif styleLower == "default" or styleLower == "avatar" then toggleState.Avatar[id] = true
		elseif styleLower == "stars" then toggleState.Stars[id] = true
		elseif styleLower == "vanity" then toggleState.Killer[id] = true
		elseif styleLower == "lag" then toggleState.lag[id] = true
		elseif styleLower == "loop" then toggleState.loop[id] = true
		else warn("Admin attempted to force unknown outfit style: " .. outfitStyle); return end

		print("Admin forcing " .. targetPlayer.Name .. " into " .. outfitStyle .. " outfit with visual effect.")

		task.spawn(function()
			local char = targetPlayer.Character
			local hum = char and char:FindFirstChild("Humanoid")

			if char and hum and hum.Health > 0 then
				local hl = Instance.new("Highlight"); hl.Name = "MorphHighlight"; hl.FillColor = Color3.fromRGB(255, 255, 255); hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.FillTransparency = 1; hl.OutlineTransparency = 1; hl.Parent = char

				local pulseTime = 4.5; local steps = 45; local waitTime = pulseTime / steps
				for i = 1, steps do
					if not char or not char.Parent or hum.Health <= 0 then break end
					hl.FillTransparency = 0.5 + 0.5 * math.sin(i * 0.5)
					hl.OutlineTransparency = hl.FillTransparency
					task.wait(waitTime)
				end

				if char and char.Parent and hum.Health > 0 then
					local flashIn = TweenService:Create(hl, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { FillTransparency = 0, OutlineTransparency = 0 })
					flashIn:Play(); flashIn.Completed:Wait()

					updateCharacter(targetPlayer, char)

					task.wait(1) 
					local flashOut = TweenService:Create(hl, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FillTransparency = 1, OutlineTransparency = 1 })
					flashOut:Play(); flashOut.Completed:Wait()
					hl:Destroy()
				end
			else
				updateCharacter(targetPlayer, char)
			end
		end)
	end)
end