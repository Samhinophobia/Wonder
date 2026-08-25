-- @ScriptType: ModuleScript
local module = {}
local CollectionService = game:GetService("CollectionService")

local classBlacklist = {
	["BaseScript"] = true,
	["ValueBase"] = true,
	["Folder"] = true,
	["Tool"] = true,
	["Humanoid"] = true,
	["ForceField"] = true,
	["ClickDetector"] = true,
	["PlayerGui"] = true,
	--["Motor6D"] = true,
	--["Weld"] = true,
	--["ManualWeld"] = true,
	--["Attachment"] = true,

}
local propToCopy = {
	["Color"] = true,
	["Material"] = true,
	["Reflectance"] = true,
	["Transparency"] = true,
	["Color3"] = true,
	["Texture"] = true,
	["Enabled"] = true,
}

local function isBlacklisted(part)
	for i,v in pairs(classBlacklist) do
		if part:IsA(i) then
			return true
		end
	end
end

local function doDestroy(part)
	if part.Parent.Name == "Torso" and part.Name == "Orb" then -- mana shield
		return
	end

	if not CollectionService:HasTag(part,"TransformEff") then
		part:Destroy()
	end
end


local dontDestroy = {}
local starterChar = game.StarterPlayer:FindFirstChild("StarterCharacter")

if starterChar then

	for i,v in pairs(starterChar:GetChildren()) do
		dontDestroy[v.Name] = true
	end
else

	local defaultLimbs = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"}
	for _, limb in pairs(defaultLimbs) do
		dontDestroy[limb] = true
	end
end

for i,v in pairs(game.StarterPlayer.StarterCharacterScripts:GetChildren()) do
	dontDestroy[v.Name] = true
end

local dontCopyFrom = {
	["Hilt"] = true,
}

module.getOriginalMorph = function(player)
	if player:IsA("Model") then
		player = game.Players:GetPlayerFromCharacter(player)
		if not player then
			return
		end
	end
	local orignalMorph = game.ServerStorage:FindFirstChild(player.Name.. "'s Original")
	if not orignalMorph then
		player.Character.Archivable = true
		orignalMorph = player.Character:Clone()
		player.Character.Archivable = false
		orignalMorph.Name = player.Name.. "'s Original"
		orignalMorph.Parent = game.ServerStorage
	end
	return orignalMorph
end

local function copyTo(from,to,fromChar,toChar)

	if from.Parent.Name == "Torso" and from.Name == "Orb" then -- mana shield
		return
	end

	local cln = from:Clone()
	cln.Parent = to
	if cln:IsA("BasePart") then
		cln.Anchored = false
		cln.Massless = true
		cln.CanCollide = false
	end
	for i,v in pairs(cln:GetDescendants()) do
		if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("Motor6D") then
			local parts = {
				["Part0"] = v.Part0,
				["Part1"] = v.Part1
			}
			local newParts = {}
			for property,part in pairs(parts) do
				if part == from.Parent then
					newParts[property] = to
				elseif part == from then
					newParts[property] = cln
				elseif part.Parent == from then
					newParts[property] = cln:FindFirstChild(part.Name)
				elseif part.Parent == fromChar then
					newParts[property] = toChar:FindFirstChild(part.Name)
				end
			end
			for property,part in pairs(newParts) do
				v[property] = part
			end
		end
	end
end

local function copyProperties(from,to)
	if not from or not to then
		return
	end
	for i,v in pairs(propToCopy) do
		local fromHasProperty,toHasProperty
		pcall(function()
			fromHasProperty = from[i]
		end)
		pcall(function()
			toHasProperty = to[i]
		end)
		if fromHasProperty and toHasProperty then
			if toHasProperty ~= fromHasProperty then
				to[i] = fromHasProperty
			end
		end
	end
end

module.clearStuff = function(Character)
	for i,v in pairs(Character:GetChildren()) do
		if not isBlacklisted(v) then
			if not dontDestroy[v.Name] then
				print("Destroying",v:GetFullName())
				doDestroy(v)
			end
		end
	end

	local sChar = game.StarterPlayer:FindFirstChild("StarterCharacter")

	for i,v in pairs(Character:GetChildren()) do
		local origPart = sChar and sChar:FindFirstChild(v.Name) or nil
		local newPart = v
		if origPart and v:IsA("BasePart") then
			local noDestroy = {}
			for i,v in pairs(origPart:GetChildren()) do
				noDestroy[v.Name] = true
			end
			copyProperties(origPart,v)
			for i,v in pairs(v:GetChildren()) do
				if not isBlacklisted(v) then
					if not noDestroy[v.Name] then
						print("Destroying",v:GetFullName())
						doDestroy(v)
					else
						if v:IsA("BasePart") then
							if newPart:FindFirstChild(v.Name) then
								newPart:FindFirstChild(v.Name):Destroy()
							end
							copyTo(origPart:FindFirstChild(v.Name),newPart,sChar,Character)
						else
							copyProperties(origPart:FindFirstChild(v.Name),v)
						end
					end
				end
			end
		end
	end
end

module.copyStuff = function(fromChar,Character)
	for i,v in pairs(fromChar:GetChildren()) do
		if not isBlacklisted(v) then
			if not dontDestroy[v.Name] then
				copyTo(v,Character,fromChar,Character)
			else
				copyProperties(v,Character:FindFirstChild(v.Name))
			end
		end
	end
	local copyHum = fromChar:FindFirstChildOfClass("Humanoid")
	local nameCopy = copyHum.DisplayName
	if nameCopy == "" then
		nameCopy = fromChar.Name
	end
	Character.Humanoid.DisplayName = nameCopy

	local sChar = game.StarterPlayer:FindFirstChild("StarterCharacter")

	for i,v in pairs(fromChar:GetChildren()) do
		local origPart = sChar and sChar:FindFirstChild(v.Name) or nil
		local newPart = Character:FindFirstChild(v.Name)

		if origPart and v:IsA("BasePart") and not dontCopyFrom[v.Name] then
			local noDestroy = {}
			for i,v in pairs(origPart:GetChildren()) do
				noDestroy[v.Name] = true
			end
			for i,v in pairs(v:GetChildren()) do
				if not isBlacklisted(v) then
					if not noDestroy[v.Name] then
						copyTo(v,newPart,fromChar,Character)
					else
						if v:IsA("BasePart") then
							if newPart:FindFirstChild(v.Name) then
								newPart:FindFirstChild(v.Name):Destroy()
							end
							copyTo(v,newPart,fromChar,Character)
						else
							copyProperties(v,newPart:FindFirstChild(v.Name))
						end
					end
				end
			end
		end
	end
end

module.transformEff = function(Character,Length)
	Length = Length or .5
	local parts = {
		"Head",
		"Torso",
		"Left Arm",
		"Right Arm",
		"Left Leg",
		"Right Leg",
	}
	local boneSound = game.ServerStorage.Assets.Homunculi.TransformSound:Clone()
	boneSound.Parent = Character.HumanoidRootPart
	boneSound:Play()
	game:GetService("Debris"):AddItem(boneSound,3)
	for i,v in pairs(parts) do
		local foundPart = Character:FindFirstChild(v)
		if foundPart then

			local cube
			if v == "Head" then
				cube = game.ServerStorage.Assets.Homunculi.TransformHead:Clone()
			else
				cube = game.ServerStorage.Assets.Homunculi.TransformCube:Clone()
			end
			CollectionService:AddTag(cube,"TransformEff")
			cube.Size = foundPart.Size * 1.05
			local weld = Instance.new("Weld")
			weld.Part0 = foundPart
			weld.Part1 = cube
			weld.Parent = cube
			cube.Parent = foundPart

			local effectParts = {}
			for i=1,10 do
				local sphere = game.ServerStorage.Assets.Homunculi.TransformBubble:Clone()
				CollectionService:AddTag(sphere,"TransformEff")
				local weld = Instance.new("Weld")
				weld.Part0 = foundPart
				weld.Part1 = sphere
				weld.Parent = sphere
				local sd2 = (foundPart.Size/2) * 5
				sd2 = Vector3.new(math.floor(sd2.X),math.floor(sd2.Y),math.floor(sd2.Z))
				weld.C0 = CFrame.new(math.random(-sd2.X,sd2.X)/5,math.random(-sd2.Y,sd2.Y)/5,math.random(-sd2.Z,sd2.Z)/5)
				sphere.Parent = foundPart
				task.spawn(function()
					local tween
					repeat
						local waitFor = math.random(5, 10) / 50
						tween = game.TweenService:Create(sphere.Mesh, TweenInfo.new(waitFor, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, 0), {
							Scale = Vector3.new(math.random(100, 150) / 100, math.random(100, 150) / 100, math.random(100, 150) / 100)
						});
						tween:Play();
						task.wait(waitFor)
					until CollectionService:HasTag(sphere,"Done")

					tween:Cancel()
					game.TweenService:Create(sphere.Mesh, TweenInfo.new(0.3), {
						Scale = Vector3.new(0, 0, 0)
					}):Play();

					task.wait(.3)

					sphere:Destroy()
				end)
				table.insert(effectParts,sphere)
			end

			local function cancel()
				for i,v in pairs(effectParts) do
					CollectionService:AddTag(v,"Done")
				end
				local tween = game.TweenService:Create(cube,TweenInfo.new(.3),{
					Transparency = 1
				})
				tween:Play()
				task.wait(.3)
				cube:Destroy()
			end

			if typeof(Length) == "number" then
				task.delay(Length,cancel)
			else
				local obj = Length
				obj:GetPropertyChangedSignal("Parent"):Connect(function()
					if not obj.Parent then
						cancel()
					end
				end)
			end			

		end
	end
	task.wait(.5)
end

return module