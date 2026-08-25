-- @ScriptType: ModuleScript
local ServerStorage = game:GetService("ServerStorage")

local emote = {}

emote.LoopAnim = "rbxassetid://110251860612460"
emote.Audio    = "rbxassetid://104042146788213"
emote.SyncKey  = "LagPatrico"

function emote.OnStart(ctx)
	-- Look for the Lag folder in EmoteProps
	local lagTemplate = ServerStorage.EmoteProps:FindFirstChild("Lag")
	if not lagTemplate then return end

	-- Clone the folder so we can use its contents
	local clonedFolder = lagTemplate:Clone()

	-- Loop through the folder and grab the emitters (ParticleEmitterP, R, Y)
	for _, child in ipairs(clonedFolder:GetChildren()) do
		if child:IsA("ParticleEmitter") then

			-- Override the Rate and Lifetime properties
			child.Rate = 10
			child.Lifetime = NumberRange.new(0.2)

			-- Move the emitter into the HumanoidRootPart so it emits from the player
			child.Parent = ctx.HRP

			-- Add the emitter to the Janitor so it cleans up when the emote stops
			ctx.Janitor:Add(child)
		end
	end

	-- Destroy the empty cloned folder since we moved the emitters out of it
	clonedFolder:Destroy()
end

return emote