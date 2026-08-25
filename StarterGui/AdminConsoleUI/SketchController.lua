-- @ScriptType: LocalScript

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminEvent = ReplicatedStorage:WaitForChild("AdminCommandEvent")
local Players = game:GetService("Players")

local player = Players.LocalPlayer


local ADMINS = {
	[779537167] = true,
	[3762045417] = true,
	[7745255477] = true,
	[4477038552] = true,
	[5782558987] = true, --Humdgueon - Testing reasons
}
if not ADMINS[player.UserId] then 
	script.Parent:Destroy() 
	return 
end


local screenGui = script.Parent
local openBtn = screenGui:WaitForChild("OpenButton")
local consoleFrame = screenGui:WaitForChild("ConsoleFrame")
local input = consoleFrame:WaitForChild("CommandInput")

local btnBasePos = openBtn.Position
local consoleBasePos = consoleFrame.Position
local isVisible = false


openBtn.Text = "" 
local cmdLetters = {}
local wordStr = "CMD"


for i = 1, #wordStr do
	local letterLbl = Instance.new("TextLabel", openBtn)
	letterLbl.BackgroundTransparency = 1
	letterLbl.Size = UDim2.new(1 / #wordStr, 0, 1, 0)
	letterLbl.Position = UDim2.new((i - 1) / #wordStr, 0, 0, 0)
	letterLbl.Font = Enum.Font.IndieFlower
	letterLbl.TextSize = 25
	letterLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	letterLbl.Text = string.sub(wordStr, i, i)
	table.insert(cmdLetters, letterLbl)
end


local ghostHints = {
	"> setdream Nivalis...",
	"> speed Alact 50...",
	"> give Alice Coffee...",
	"> morph Alact Alice...",
	"> hp Player 500...",
	"> liquid Alact Blood",
	"> kick player",
	"> Vanish player - Alice only",
	"> Erase player - Alice only"
}

task.spawn(function()
	local index = 1
	while task.wait(2.5) do
	
		if input.Text == "" and not input:IsFocused() then
			input.PlaceholderText = ghostHints[index]
			index = index + 1
			if index > #ghostHints then index = 1 end
		end
	end
end)


task.spawn(function()
	while true do
		task.wait(0.08)
		

		openBtn.Rotation = math.random(-2, 2) / 10 
		openBtn.Position = btnBasePos + UDim2.fromOffset(math.random(-1, 1), math.random(-1, 1))
		
	
		for _, lbl in ipairs(cmdLetters) do
			lbl.Position = UDim2.new(lbl.Position.X.Scale, 0, 0, math.random(-3, 3))
			lbl.Rotation = math.random(-4, 4)
		end
		
		if isVisible then
		
			consoleFrame.Rotation = math.random(-2, 2) / 10
			consoleFrame.Position = consoleBasePos + UDim2.fromOffset(math.random(-1, 1), math.random(-1, 1))
			
		
			if not input:IsFocused() then
				input.Rotation = math.random(-5, 5) / 10
				input.TextSize = 22 + math.random(-1, 1)
			else
			
				input.Rotation = 0
				input.TextSize = 22
			end
		end
	end
end)


local function closeConsole()
	isVisible = false

	local closeTween = TweenService:Create(consoleFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(100, 20),
		Rotation = math.random(-25, 25), 
		BackgroundTransparency = 1
	})
	

	TweenService:Create(input, TweenInfo.new(0.1), {TextTransparency = 1, PlaceholderColor3 = Color3.fromRGB(255,255,255)}):Play()
	
	closeTween:Play()
	closeTween.Completed:Connect(function()
		if not isVisible then consoleFrame.Visible = false end
	end)
	input:ReleaseFocus()
end

openBtn.MouseButton1Click:Connect(function()
	if isVisible then
		closeConsole()
	else
		isVisible = true
		consoleFrame.Visible = true
		input.TextTransparency = 0
		input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
		

		consoleFrame.Size = UDim2.fromOffset(50, 20)
		consoleFrame.Rotation = math.random(-30, 30)
		consoleFrame.BackgroundTransparency = 1
		
	
		TweenService:Create(consoleFrame, TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(400, 80),
			Rotation = 0,
			BackgroundTransparency = 0
		}):Play()
		
		input:CaptureFocus()
	end
end)


input.FocusLost:Connect(function(enterPressed)
	if enterPressed and input.Text ~= "" then
		adminEvent:FireServer(input.Text)
		input.Text = ""
		closeConsole()
	end
end)