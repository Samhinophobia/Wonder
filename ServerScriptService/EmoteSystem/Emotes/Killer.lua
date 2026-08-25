-- @ScriptType: ModuleScript
local ServerStorage = game:GetService("ServerStorage")

local emote = {}

emote.WindupAnim = "rbxassetid://89749016110031"
emote.LoopAnim   = "rbxassetid://74442451918331"
emote.Audio = {
	"rbxassetid://104736446987832",
	"rbxassetid://134631398466009",
}
emote.SyncKey = "Killer"

-- Updated to accept 5 parameters to match your OnStart calls
local function holdItem(ctx, itemName, part1Name, part2Name, limbName)
	local template = ServerStorage.EmoteProps:FindFirstChild(itemName)
	if not template then return end

	local item = template:Clone()
	local limb = ctx.Character:FindFirstChild(limbName)

	-- If the target limb doesn't exist, destroy the clone and abort
	if not limb then
		item:Destroy()
		return
	end

	-- Helper function to find a part and connect its internal Motor6D to the limb
	local function attachMotor(targetPartName)
		local part = item:FindFirstChild(targetPartName, true)
		local motor = part and part:FindFirstChildOfClass("Motor6D")

		if part and motor then
			motor.Part0 = limb   -- connect to the arm
			motor.Part1 = part
		end
	end

	-- Attach both parts of the prop (e.g., Handle and Blade)
	attachMotor(part1Name)
	attachMotor(part2Name)

	item.Parent = ctx.Character
	ctx.Janitor:Add(item) -- auto-destroyed when the emote ends
end

function emote.OnStart(ctx)
	holdItem(ctx, "Cleaver", "CleaverHandle", "CleaverBlade", "Right Arm")
	holdItem(ctx, "HeartLantern", "LanternHandle", "LanternHeart", "Left Arm")
end

return emote