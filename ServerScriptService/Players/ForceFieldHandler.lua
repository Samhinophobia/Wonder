-- @ScriptType: Script
local Players = game:GetService("Players")

-- Function to handle the visual effects for a specific ForceField instance
local function applyCustomVisuals(character, realForceField)

	-- 1. Hide the default Roblox forcefield effect
	realForceField.Visible = false

	-- 2. Create a folder to hold our visual parts (so we can delete them easily later)
	local visualFolder = Instance.new("Folder")
	visualFolder.Name = "RainbowFF_Visuals"
	visualFolder.Parent = character

	-- Table to track boxes for the rainbow loop
	local activeBoxes = {}

	-- Helper to add outline to a specific part
	local function addOutline(part)
		-- Must be a BasePart (MeshPart, Part, etc.)
		if not part:IsA("BasePart") then return end

		-- Ignore the Invisible Root Part
		if part.Name == "HumanoidRootPart" then return end

		-- EXCLUDE ACCESSORIES: Check if the part belongs to an Accessory
		if part.Parent:IsA("Accessory") or part.Parent:IsA("Accoutrement") then return end

		-- EXCLUDE TOOLS: Check if the part is inside a Tool
		if part.Parent:IsA("Tool") then return end

		-- Create the outline
		local box = Instance.new("SelectionBox")
		box.Name = "ClassicOutline"
		box.Adornee = part
		box.LineThickness = 0.05
		box.Color3 = Color3.new(1, 0, 0)
		box.SurfaceTransparency = 0.8 -- The shell transparency
		box.SurfaceColor3 = Color3.new(1, 0, 0)
		box.Parent = visualFolder

		table.insert(activeBoxes, box)
	end

	-- Apply to current body parts
	for _, child in pairs(character:GetDescendants()) do
		addOutline(child)
	end

	-- If the player regrows a limb (rare) or changes, this catches it, 
	-- but usually the loop above is sufficient for a ForceField duration.

	-- 3. Rainbow Loop
	-- This loop runs only as long as the ForceField exists
	task.spawn(function()
		while realForceField.Parent do
			local hue = tick() % 5 / 5 -- Rainbow Speed (Lower number = Faster)
			local color = Color3.fromHSV(hue, 1, 1)

			-- Update all boxes at once
			for _, box in pairs(activeBoxes) do
				box.Color3 = color
				box.SurfaceColor3 = color
			end
			task.wait()
		end

		-- 4. Cleanup: When the loop breaks (FF gone), destroy visuals
		if visualFolder then
			visualFolder:Destroy()
		end
	end)
end

-- Main Connection Logic
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)

		-- Listen for when a ForceField is added to the character
		-- (Roblox usually adds one immediately on spawn)
		character.ChildAdded:Connect(function(child)
			if child:IsA("ForceField") then
				applyCustomVisuals(character, child)
			end
		end)

		-- Safety Check: If the script loads slightly late and FF is already there
		local existingFF = character:FindFirstChildOfClass("ForceField")
		if existingFF then
			applyCustomVisuals(character, existingFF)
		end
	end)
end)