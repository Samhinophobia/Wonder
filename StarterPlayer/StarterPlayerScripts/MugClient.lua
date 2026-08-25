-- @ScriptType: LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local MugEvents = ReplicatedStorage:WaitForChild("MugEvents")
local MugAction = MugEvents:WaitForChild("MugAction")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--  HIDE MUG PICKUP LOGIC
local function hideMug()
	local pickup = workspace:FindFirstChild("MugPickup")
	if pickup and player:GetAttribute("MugOwned") == true then
		for _, child in pairs(pickup:GetDescendants()) do
			if child:IsA("BasePart") then
				child.Transparency = 1
				child.CanCollide = false
			elseif child:IsA("ClickDetector") then
				child:Destroy()
			end
		end
	end
end

player:GetAttributeChangedSignal("MugOwned"):Connect(hideMug)
task.spawn(function() for i=1,10 do hideMug(); task.wait(1) end end)

-- RAYCAST HELPER
local function getMouseTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- Ignore the character and the mug itself
	params.FilterDescendantsInstances = {player.Character} 

	local result = workspace:Raycast(ray.Origin, ray.Direction * 100, params)
	return result
end

-- INPUT & TOOL LOGIC
local isHoldingMug = false

local function onEquip()
	isHoldingMug = true
end

local function onUnequip()
	isHoldingMug = false
end

-- LISTEN FOR CLICKS MANUALLY (Bypasses ClickDetectors)
UserInputService.InputBegan:Connect(function(input, processed)
	if isHoldingMug and input.UserInputType == Enum.UserInputType.MouseButton1 then

		local result = getMouseTarget()
		local target = result and result.Instance

		-- Check for Water Effect
		local effect = nil
		if target then
			effect = target:FindFirstChild("Effect") 
				or (target.Parent and target.Parent:FindFirstChild("Effect"))
				or (target.Parent.Parent and target.Parent.Parent:FindFirstChild("Effect"))
		end

		if effect then
			-- CASE 1: Clicked Water -> FILL ONLY (Do not drink)
			MugAction:FireServer("Fill", target)
		else
			-- CASE 2: Clicked Air/Ground -> DRINK
			MugAction:FireServer("Drink", nil)
		end
	end
end)

player.CharacterAdded:Connect(function(char)
	hideMug()
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child.Name == "MagicMug" then
			child.Equipped:Connect(onEquip)
			child.Unequipped:Connect(onUnequip)
		end
	end)
end)