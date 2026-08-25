-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- REQUIRE THE NEW MODULE!
local RichTextModule = require(ReplicatedStorage:WaitForChild("RichText"))
local DialogueData = require(ReplicatedStorage:WaitForChild("NPCDialogueData"))
local TriggerEvent = ReplicatedStorage:WaitForChild("TriggerDialogue")

local player = Players.LocalPlayer
local gui = script.Parent
local frame = gui:WaitForChild("MainFrame")
local speakerLabel = frame:WaitForChild("SpeakerName")
local dialogueContainer = frame:WaitForChild("DialogueText") 
local portrait = frame:WaitForChild("Portrait")
local optionsFrame = frame:WaitForChild("OptionsFrame")

speakerLabel.RichText = true

-- Ensure OptionsFrame cuts off any accidental rendering overflows
optionsFrame.ClipsDescendants = true

-- Setup UIListLayout for Horizontal (Left to Right) flow
local listLayout = optionsFrame:FindFirstChildOfClass("UIListLayout")
if not listLayout then
	listLayout = Instance.new("UIListLayout")
	listLayout.Parent = optionsFrame
end

local GAP_SIZE = 6 -- Pixel gap between buttons
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Padding = UDim.new(0, GAP_SIZE) 
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Locate the template button from your Explorer (OptionTemplate or OptionButton)
local buttonTemplate = optionsFrame:FindFirstChild("OptionTemplate") or optionsFrame:FindFirstChild("OptionButton")
if not buttonTemplate then
	buttonTemplate = Instance.new("TextButton")
	buttonTemplate.Name = "OptionTemplate"
	buttonTemplate.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
	buttonTemplate.BorderColor3 = Color3.fromRGB(200, 200, 200) 
	buttonTemplate.BorderSizePixel = 1
	buttonTemplate.TextColor3 = Color3.fromRGB(255, 255, 255) 
	buttonTemplate.Font = Enum.Font.IndieFlower
	buttonTemplate.TextSize = 18
	buttonTemplate.Parent = optionsFrame
end

-- Ensure template text scales automatically so it fits inside horizontal buttons
buttonTemplate.TextScaled = true
buttonTemplate.TextWrapped = true
buttonTemplate.Visible = false

local talkCounts = {} 
local npcStates = {} 
local isTyping = false
local currentTextObject = nil

local baseFramePos = frame.Position 

RunService.RenderStepped:Connect(function()
	if frame.Visible then
		local t = os.clock()
		local frameY = math.sin(t * 2) * 6
		local frameX = math.sin(t * 1.5) * 3
		frame.Position = UDim2.new(
			baseFramePos.X.Scale, baseFramePos.X.Offset + frameX,
			baseFramePos.Y.Scale, baseFramePos.Y.Offset + frameY
		)
	end
end)

local function typewrite(text)
	isTyping = true
	local safeText = text or "..." 

	if currentTextObject then
		currentTextObject:Hide()
	end

	local startProps = {
		Font = "Garamond",
		TextScaled = false, 
		TextSize = 20,        
		TextColor3 = "White",
		AnimateStepTime = 0.10, 
		AnimateStepGrouping = "Letter",
		AnimateStyle = "Appear"
	}

	currentTextObject = RichTextModule:New(dialogueContainer, safeText, startProps)

	coroutine.wrap(function()
		currentTextObject:Animate(true)
		isTyping = false
	end)()
end

local function showOptions(options, npcID)
	-- Clear old active buttons without deleting the template
	for _, child in pairs(optionsFrame:GetChildren()) do
		if child:IsA("TextButton") and child ~= buttonTemplate then 
			child:Destroy() 
		end
	end

	if not options or #options == 0 then 
		options = {{Text = "...", Next = "Close"}} 
	end

	local numOptions = #options
	-- Calculate width share so all options fit perfectly side-by-side
	local widthScale = 1 / numOptions
	local widthOffset = -((numOptions - 1) * GAP_SIZE) / numOptions

	for index, opt in ipairs(options) do
		local btn = buttonTemplate:Clone()
		btn.Name = "ActiveOption_" .. index
		btn.Text = opt.Text or "Continue"
		btn.LayoutOrder = index
		btn.Size = UDim2.new(widthScale, widthOffset, 1, 0) -- Fits 100% height and auto-divided width
		btn.Visible = true
		btn.Parent = optionsFrame

		btn.MouseButton1Click:Connect(function()
			if isTyping and currentTextObject then 
				currentTextObject:Show(false)
				isTyping = false
				return 
			end 

			if opt.Next == "Close" then
				frame.Visible = false
			elseif opt.Next == "Return" then
				local msg, newOpts, newName, newPortrait = DialogueData[npcID].GetChat(player, talkCounts[npcID], npcStates[npcID])

				speakerLabel.Text = newName or DialogueData[npcID].Name or DialogueData[npcID].DefaultName or "???"
				portrait.Image = newPortrait or DialogueData[npcID].Portrait or ""

				typewrite(msg)
				showOptions(newOpts, npcID)
			else
				local extraData = DialogueData[npcID].Extra(player, npcStates[npcID])[opt.Next]
				if extraData then
					if extraData.Action then extraData.Action() end
					speakerLabel.Text = extraData.NameOverride or speakerLabel.Text or "???"
					portrait.Image = extraData.Portrait or DialogueData[npcID].Portrait or ""

					typewrite(extraData.Text)
					showOptions(extraData.Options, npcID)
				end
			end
		end)
	end
end

TriggerEvent.OnClientEvent:Connect(function(npcID)
	local data = DialogueData[npcID]
	if not data then return end

	if not talkCounts[npcID] then talkCounts[npcID] = 0 end
	if not npcStates[npcID] then npcStates[npcID] = {Met = false, NameRevealed = false} end

	talkCounts[npcID] += 1

	frame.Position = baseFramePos

	local message, options, currentName, currentPortrait = data.GetChat(player, talkCounts[npcID], npcStates[npcID])

	speakerLabel.Text = currentName or data.Name or data.DefaultName or "???"
	portrait.Image = currentPortrait or data.Portrait or ""

	frame.Visible = true
	showOptions(options, npcID)
	typewrite(message)
end)