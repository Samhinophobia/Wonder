-- @ScriptType: LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local SPEED = 60

local ADMINS = {[779537167]=true, [3762045417]=true, [7745255477]=true}
if not ADMINS[player.UserId] then return end

RunService.Heartbeat:Connect(function(dt)
	if not player:GetAttribute("IsFlying") then return end

	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local bp = root:FindFirstChild("FlyBP")
	local bg = root:FindFirstChild("FlyBG")
	if not bp or not bg then return end

	local cam = workspace.CurrentCamera
	local moveDir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
		moveDir += Vector3.new(0,1,0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
		moveDir += Vector3.new(0,-1,0)
	end

	if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

	bp.Position += moveDir * SPEED * dt
	bg.CFrame = cam.CFrame
end)
