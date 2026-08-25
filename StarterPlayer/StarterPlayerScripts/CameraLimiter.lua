-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- SETTINGS
local MAX_ZOOM = 15 -- The furthest they can zoom out (Studs)

local function enforceZoom()
	player.CameraMaxZoomDistance = MAX_ZOOM
end

-- Apply immediately
enforceZoom()

-- Ensure it stays set even if they reset or load in
player.CharacterAdded:Connect(function()
	task.wait(0.1)
	enforceZoom()
end)

-- Monitor for changes (in case another script tries to overwrite it)
player:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
	if player.CameraMaxZoomDistance ~= MAX_ZOOM then
		player.CameraMaxZoomDistance = MAX_ZOOM
	end
end)