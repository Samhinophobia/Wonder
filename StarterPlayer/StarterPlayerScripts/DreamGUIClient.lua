-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui") 
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")

local InteractionData = require(ReplicatedStorage:WaitForChild("InteractionData"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local events = ReplicatedStorage:WaitForChild("DreamEvents")
local voteStatusEvent = events:WaitForChild("VoteStatus")
local sendVoteEvent = events:WaitForChild("SendVote")
local countdownSound = SoundService:FindFirstChild("CountdownBeep")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "DreamSystemUI"
screenGui.IgnoreGuiInset = true 
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10000 


local memoryMusicPlayer = Instance.new("Sound")
memoryMusicPlayer.Name = "MemoryMusic"
memoryMusicPlayer.Looped = true
memoryMusicPlayer.Parent = SoundService


local SLEEP_IMAGES = {
	"rbxassetid://81932654794011", 
	"rbxassetid://121543389128518"
}
task.spawn(function()
	local tempLabels = {}
	for _, id in ipairs(SLEEP_IMAGES) do
		local img = Instance.new("ImageLabel")
		img.Image = id
		table.insert(tempLabels, img)
	end
	pcall(function() ContentProvider:PreloadAsync(tempLabels) end)
end)

-- [[ HITBOX ALIGNMENT & OFFSET TUNER ]]
UserInputService.MouseIconEnabled = false 
local CURSOR_DEFAULT = "rbxassetid://5267091169"    
local CURSOR_ACTIVE = "rbxassetid://11841776986"    

local customCursor = Instance.new("ImageLabel", screenGui)
customCursor.Name = "CustomCursor"
customCursor.Image = CURSOR_DEFAULT 
customCursor.BackgroundTransparency = 1
customCursor.Size = UDim2.fromOffset(40, 40)
customCursor.ZIndex = 2000 
customCursor.AnchorPoint = Vector2.new(0, 0) 

local CURSOR_OFFSET_X = -12 
local CURSOR_OFFSET_Y = -15 

local darkenFrame = Instance.new("Frame", screenGui); darkenFrame.Name="DarkenFrame"; darkenFrame.Size=UDim2.fromScale(1,1); darkenFrame.BackgroundColor3=Color3.new(0,0,0); darkenFrame.BackgroundTransparency=1; darkenFrame.ZIndex=5; darkenFrame.Visible=false

local fadeFrame = Instance.new("ImageLabel", screenGui); fadeFrame.Name="FadeFrame"; fadeFrame.Size=UDim2.fromScale(1,1);
fadeFrame.BackgroundColor3=Color3.new(0,0,0); fadeFrame.BackgroundTransparency=1; fadeFrame.ImageTransparency=1; fadeFrame.ScaleType=Enum.ScaleType.Stretch; fadeFrame.Visible=false; fadeFrame.ZIndex=10

local loadingLabel = Instance.new("TextLabel", screenGui); loadingLabel.Name="LoadingLabel"; loadingLabel.Size=UDim2.new(1,0,0.2,0); loadingLabel.Position=UDim2.new(0,0,0.4,0); loadingLabel.BackgroundTransparency=1; loadingLabel.TextColor3=Color3.new(1,1,1); loadingLabel.Font=Enum.Font.IndieFlower; loadingLabel.TextSize=40; loadingLabel.Text="Sleeping"; loadingLabel.Visible=false;
loadingLabel.ZIndex=20
local statusLabel = Instance.new("TextLabel", screenGui); statusLabel.Name="StatusLabel"; statusLabel.Size=UDim2.new(1,0,0.1,0); statusLabel.Position=UDim2.new(0,0,-0.1,0); statusLabel.BackgroundColor3=Color3.new(0,0,0); statusLabel.BackgroundTransparency=0.3; statusLabel.TextColor3=Color3.new(1,1,1); statusLabel.TextScaled=true; statusLabel.Font=Enum.Font.IndieFlower; statusLabel.Text=""

local tooltip = Instance.new("TextLabel", screenGui); tooltip.Name="CursorTooltip"; tooltip.Size=UDim2.new(0,120,0,30);
tooltip.AnchorPoint=Vector2.new(0,0); tooltip.BackgroundColor3=Color3.fromRGB(100,100,100); tooltip.BackgroundTransparency=0.6; tooltip.TextColor3=Color3.new(1,1,1); tooltip.Text="Clickable"; tooltip.Font=Enum.Font.IndieFlower; tooltip.TextSize=25; tooltip.Visible=false; tooltip.ZIndex=20
local uiStroke = Instance.new("UIStroke", tooltip); uiStroke.Thickness = 3

local voteFrame = Instance.new("Frame", screenGui);
voteFrame.Name="VoteFrame"; voteFrame.Size=UDim2.new(0,300,0,150); voteFrame.Position=UDim2.new(0.5,-150,0.5,-75); voteFrame.BackgroundColor3=Color3.fromRGB(20,20,20); voteFrame.BorderColor3=Color3.new(1,1,1); voteFrame.Visible=false
local title = Instance.new("TextLabel", voteFrame); title.Text="Vote Initiated"; title.Size=UDim2.new(1,0,0.4,0); title.BackgroundTransparency=1; title.TextColor3=Color3.new(1,1,1); title.Font=Enum.Font.Fantasy; title.TextSize=24;
title.TextScaled=true
local yesBtn = Instance.new("TextButton", voteFrame); yesBtn.Name="Yes"; yesBtn.Text="YES"; yesBtn.Size=UDim2.new(0.4,0,0.4,0); yesBtn.Position=UDim2.new(0.05,0,0.5,0); yesBtn.BackgroundColor3=Color3.fromRGB(50,100,50); yesBtn.TextColor3=Color3.new(1,1,1); yesBtn.Font=Enum.Font.Fantasy; yesBtn.TextSize=20
local noBtn = Instance.new("TextButton", voteFrame); noBtn.Name="No"; noBtn.Text="NO"; noBtn.Size=UDim2.new(0.4,0,0.4,0);
noBtn.Position=UDim2.new(0.55,0,0.5,0); noBtn.BackgroundColor3=Color3.fromRGB(100,50,50); noBtn.TextColor3=Color3.new(1,1,1); noBtn.Font=Enum.Font.Fantasy; noBtn.TextSize=20

local noteOverlay = Instance.new("Frame", screenGui); noteOverlay.Name="NoteOverlay"; noteOverlay.Size=UDim2.fromScale(1,1); noteOverlay.BackgroundColor3=Color3.new(0,0,0); noteOverlay.BackgroundTransparency=1; noteOverlay.Visible=false; noteOverlay.ZIndex=40
local paperBg = Instance.new("Frame", noteOverlay); paperBg.Name="Paper";
paperBg.Size=UDim2.new(0,400,0,500); paperBg.Position=UDim2.new(0.5,-200,0.5,-250); paperBg.BackgroundColor3=Color3.fromRGB(245, 245, 235); paperBg.BackgroundTransparency=1 
local paperStroke = Instance.new("UIStroke", paperBg); paperStroke.Thickness=2; paperStroke.Color=Color3.fromRGB(50,50,50); paperStroke.Transparency=1
local paperCorner = Instance.new("UICorner", paperBg);
paperCorner.CornerRadius=UDim.new(0,5)

local noteTitle = Instance.new("TextLabel", paperBg); noteTitle.Size=UDim2.new(1,0,0.15,0); noteTitle.Position=UDim2.new(0,0,0.02,0); noteTitle.BackgroundTransparency=1; noteTitle.Font=Enum.Font.SpecialElite; noteTitle.TextScaled=true; noteTitle.TextColor3=Color3.fromRGB(20,20,20); noteTitle.TextTransparency=1
local noteSubject = Instance.new("TextLabel", paperBg); noteSubject.Size=UDim2.new(1,0,0.08,0); noteSubject.Position=UDim2.new(0,0,0.18,0); noteSubject.BackgroundTransparency=1; noteSubject.Font=Enum.Font.IndieFlower;
noteSubject.TextSize=22; noteSubject.TextColor3=Color3.fromRGB(60,60,60); noteSubject.TextTransparency=1
local noteTarget = Instance.new("TextLabel", paperBg); noteTarget.Size=UDim2.new(1,0,0.08,0); noteTarget.Position=UDim2.new(0,0,0.26,0); noteTarget.BackgroundTransparency=1; noteTarget.Font=Enum.Font.IndieFlower; noteTarget.TextSize=22; noteTarget.TextColor3=Color3.fromRGB(60,60,60); noteTarget.TextTransparency=1
local noteBody = Instance.new("TextLabel", paperBg); noteBody.Size=UDim2.new(0.9,0,0.5,0); noteBody.Position=UDim2.new(0.05,0,0.36,0);
noteBody.BackgroundTransparency=1; noteBody.Font=Enum.Font.IndieFlower; noteBody.TextSize=24; noteBody.TextColor3=Color3.fromRGB(30,30,30); noteBody.TextXAlignment=Enum.TextXAlignment.Left; noteBody.TextYAlignment=Enum.TextYAlignment.Top; noteBody.TextWrapped=true; noteBody.TextTransparency=1
local closeNoteBtn = Instance.new("TextButton", paperBg); closeNoteBtn.Size=UDim2.new(1,0,0.1,0); closeNoteBtn.Position=UDim2.new(0,0,0.9,0); closeNoteBtn.BackgroundTransparency=1; closeNoteBtn.Text="[ Close Note ]"; closeNoteBtn.Font=Enum.Font.IndieFlower;
closeNoteBtn.TextSize=24; closeNoteBtn.TextColor3=Color3.fromRGB(150,50,50); closeNoteBtn.TextTransparency=1

local function getGender(char)
	if not char then return "Male" end
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		local desc = hum:GetAppliedDescription()
		if desc and tostring(desc.Torso) == InteractionData.FEMALE_TORSO_ID then return "Female" end
	end
	return "Male"
end

local function getShirtId(char)
	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt then return tonumber(string.match(shirt.ShirtTemplate, "%d+")) end
	return nil
end

local function findValueInAncestors(startPart, valueName)
	if not startPart then return nil end
	local v = startPart:FindFirstChild(valueName)
	if v then return v end
	if startPart.Parent then
		v = startPart.Parent:FindFirstChild(valueName)
		if v then return v end
		if startPart.Parent.Parent then
			v = startPart.Parent.Parent:FindFirstChild(valueName)
			if v then return v end
		end
	end
	return nil
end

local function setFocusMode(enabled)
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not enabled) end)
end

local isInteracting = false
local function showLocalMessage(text)
	if isInteracting or noteOverlay.Visible then return end
	isInteracting = true
	setFocusMode(true)
	statusLabel.Text = text
	statusLabel:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5)
	task.spawn(function()
		task.wait(4)
		statusLabel:TweenPosition(UDim2.new(0, 0, -0.1, 0), "In", "Quad", 0.5)
		task.wait(0.5)
		setFocusMode(false)
		isInteracting = false
	end)
end

local isPlayingMemory = false

local function playMemorySequence(memoryId)
	if isPlayingMemory or isInteracting or noteOverlay.Visible then return end

	local memoryData = InteractionData.MEMORIES[memoryId]
	if not memoryData then return end

	isPlayingMemory = true
	setFocusMode(true)

	-- Fade out surrounding map music
	local fadingSounds = {}
	local function scanForSounds(parentFolder)
		for _, obj in ipairs(parentFolder:GetDescendants()) do
			if obj:IsA("Sound") and obj.IsPlaying and obj ~= memoryMusicPlayer then
				fadingSounds[obj] = obj.Volume
				TweenService:Create(obj, TweenInfo.new(1.5), {Volume = 0}):Play()
			end
		end
	end
	scanForSounds(workspace)
	scanForSounds(SoundService)

	-- Initial Memory Soundtrack Setup
	memoryMusicPlayer.SoundId = memoryData.Soundtrack and ("rbxassetid://" .. memoryData.Soundtrack) or ""
	memoryMusicPlayer.Volume = 0
	if memoryData.Soundtrack then
		memoryMusicPlayer:Play()
		local targetVol = memoryData.SoundtrackVolume or 0.5
		TweenService:Create(memoryMusicPlayer, TweenInfo.new(1.5), {Volume = targetVol}):Play()
	end

	local blur = Instance.new("BlurEffect", Lighting)
	blur.Size = 0
	TweenService:Create(blur, TweenInfo.new(1.5), {Size = 24}):Play()

	local imagesToPreload = {}
	for _, page in ipairs(memoryData) do
		if type(page) == "table" and page.Image then
			local tempImg = Instance.new("ImageLabel")
			tempImg.Image = page.Image
			table.insert(imagesToPreload, tempImg)
		end
	end
	if #imagesToPreload > 0 then
		pcall(function()
			ContentProvider:PreloadAsync(imagesToPreload)
		end)
	end

	local currentImageLabel = nil

	for pageIndex, page in ipairs(memoryData) do
		if type(page) == "table" and page.Segments then

			local targetImage = page.Image
			local currentImageId = currentImageLabel and currentImageLabel.Image or nil

			-- Handle Background Images
			if targetImage ~= currentImageId then
				local oldLabel = currentImageLabel
				local newLabel = nil

				if targetImage then
					newLabel = Instance.new("ImageLabel", screenGui)
					newLabel.Name = "MemoryBackground"
					newLabel.Size = UDim2.fromScale(1, 1)
					newLabel.BackgroundColor3 = Color3.new(0, 0, 0)
					newLabel.BackgroundTransparency = 1 
					newLabel.Image = targetImage
					newLabel.ImageTransparency = 1
					newLabel.ScaleType = Enum.ScaleType.Stretch 
					newLabel.ZIndex = 5 

					TweenService:Create(newLabel, TweenInfo.new(1.5), {ImageTransparency = 0.4, BackgroundTransparency = 0}):Play()
				end

				if oldLabel then
					local fadeOut = TweenService:Create(oldLabel, TweenInfo.new(1.5), {ImageTransparency = 1, BackgroundTransparency = 1})
					fadeOut:Play()
					fadeOut.Completed:Connect(function() oldLabel:Destroy() end)
				end

				currentImageLabel = newLabel

				if pageIndex == 1 and targetImage then
					task.wait(1.5)
				end
			end

			-- Setup the UI Container
			local masterContainer = Instance.new("Frame", screenGui)
			masterContainer.Size = UDim2.new(1, 0, 0, 150)
			masterContainer.Position = UDim2.new(0, 0, 0.7, 0)
			masterContainer.BackgroundTransparency = 1
			masterContainer.ZIndex = 10 

			local vLayout = Instance.new("UIListLayout", masterContainer)
			vLayout.FillDirection = Enum.FillDirection.Vertical
			vLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			vLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			vLayout.Padding = UDim.new(0, 5)

			local speakerLbl = nil
			if page.Speaker then
				speakerLbl = Instance.new("TextLabel", masterContainer)
				speakerLbl.BackgroundTransparency = 1
				speakerLbl.Text = page.Speaker
				speakerLbl.Font = Enum.Font.SpecialElite 
				speakerLbl.TextSize = 26 
				speakerLbl.TextColor3 = page.SpeakerColor or Color3.new(1, 1, 1)
				speakerLbl.AutomaticSize = Enum.AutomaticSize.XY
				speakerLbl.ZIndex = 15

				speakerLbl.TextTransparency = 1
				speakerLbl.TextStrokeTransparency = 1
				speakerLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
			end

			local lineFrame = Instance.new("Frame", masterContainer)
			lineFrame.Size = UDim2.new(0, 0, 0, 40)
			lineFrame.BackgroundTransparency = 1
			lineFrame.AutomaticSize = Enum.AutomaticSize.X

			local hLayout = Instance.new("UIListLayout", lineFrame)
			hLayout.FillDirection = Enum.FillDirection.Horizontal
			hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			hLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local labelsAndSegments = {}

			-- PREPARE THE LABELS FOR TYPEWRITER
			for i, segment in ipairs(page.Segments) do
				local wrapper = Instance.new("Frame", lineFrame)
				wrapper.BackgroundTransparency = 1
				wrapper.LayoutOrder = i
				wrapper.AutomaticSize = Enum.AutomaticSize.XY

				local lbl = Instance.new("TextLabel", wrapper)
				lbl.BackgroundTransparency = 1
				lbl.Text = "" -- Start empty so we can type it!
				lbl.RichText = true -- Allows <font color='red'> tags to work invisibly!
				lbl.Font = Enum.Font.SpecialElite 
				lbl.TextSize = 34
				lbl.TextColor3 = segment.color or Color3.new(1, 1, 1)
				lbl.AutomaticSize = Enum.AutomaticSize.XY 
				lbl.ZIndex = 15

				lbl.TextTransparency = 0 
				lbl.TextStrokeTransparency = 0
				lbl.TextStrokeColor3 = Color3.new(0, 0, 0)

				table.insert(labelsAndSegments, {Label = lbl, Segment = segment, Wrapper = wrapper})
			end

			-- Slide the container up and fade in speaker
			TweenService:Create(masterContainer, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0.5, -75)}):Play()
			if speakerLbl then
				TweenService:Create(speakerLbl, TweenInfo.new(1.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
			end
			task.wait(1.5)

			local shakeConnections = {}

			-- [[ THE NEW RPG MAKER TYPEWRITER LOOP ]]
			for _, item in ipairs(labelsAndSegments) do
				local lbl = item.Label
				local segment = item.Segment

				-- 1. Trigger RPG Maker Audio Effects
				if segment.SilenceMusic then
					TweenService:Create(memoryMusicPlayer, TweenInfo.new(0.5), {Volume = 0}):Play()
				end
				if segment.NewMusic then
					memoryMusicPlayer.SoundId = "rbxassetid://" .. segment.NewMusic
					memoryMusicPlayer.Volume = 0
					if not memoryMusicPlayer.IsPlaying then memoryMusicPlayer:Play() end
					TweenService:Create(memoryMusicPlayer, TweenInfo.new(1.5), {Volume = 0.5}):Play()
				end
				if segment.SFX then
					local sfx = Instance.new("Sound")
					sfx.SoundId = "rbxassetid://" .. segment.SFX
					sfx.Volume = 1
					sfx.Parent = workspace
					sfx:Play()
					Debris:AddItem(sfx, 5)
				end

				-- 2. Trigger UI Shaking Effect
				if segment.shake or segment.Shake then
					local originalPos = lbl.Position
					local conn = RunService.RenderStepped:Connect(function()
						if lbl and lbl.Parent then
							lbl.Position = originalPos + UDim2.fromOffset(math.random(-3, 3), math.random(-3, 3))
						end
					end)
					table.insert(shakeConnections, conn)
				end

				-- 3. Dynamic Typewriter
				local fullText = segment.text or segment.Text or ""
				local displayedText = ""
				local i = 1
				local length = string.len(fullText)
				local typeSpeed = segment.TypeSpeed or 0.04

				while i <= length do
					local char = string.sub(fullText, i, i)

					-- Skip past <font color> tags instantly so it doesn't break the code on screen
					if char == "<" then
						local endRich = string.find(fullText, ">", i)
						if endRich then
							displayedText = displayedText .. string.sub(fullText, i, endRich)
							lbl.Text = displayedText
							i = endRich + 1
							continue
						end
					end

					displayedText = displayedText .. char
					lbl.Text = displayedText
					i = i + 1

					-- Dynamic Pacing (Wait longer at punctuation)
					if char == "." or char == "?" or char == "!" then
						task.wait(typeSpeed * 6)
					elseif char == "," then
						task.wait(typeSpeed * 3)
					else
						task.wait(typeSpeed)
					end
				end

				-- Pause momentarily before typing the next segment
				task.wait(segment.Pause or 0.1)
			end

			-- Wait for the player to finish reading the page
			local readTime = page.ReadTime or 2.5
			task.wait(readTime)

			for _, conn in ipairs(shakeConnections) do conn:Disconnect() end

			-- Fade everything out
			TweenService:Create(masterContainer, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 0.6, -75)}):Play()
			if speakerLbl then
				TweenService:Create(speakerLbl, TweenInfo.new(1.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
			for _, item in ipairs(labelsAndSegments) do
				TweenService:Create(item.Label, TweenInfo.new(1.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end

			task.wait(1.5)
			masterContainer:Destroy()
			task.wait(0.5) 
		end
	end

	if currentImageLabel then
		local fadeOut = TweenService:Create(currentImageLabel, TweenInfo.new(1.5), {ImageTransparency = 1, BackgroundTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Connect(function() currentImageLabel:Destroy() end)
	end

	-- Fade out custom memory music
	local fadeOutMem = TweenService:Create(memoryMusicPlayer, TweenInfo.new(1.5), {Volume = 0})
	fadeOutMem:Play()
	fadeOutMem.Completed:Connect(function() memoryMusicPlayer:Stop() end)

	-- Restore original map audio
	for snd, origVol in pairs(fadingSounds) do
		if snd and snd.Parent then
			TweenService:Create(snd, TweenInfo.new(1.5), {Volume = origVol}):Play()
		end
	end

	TweenService:Create(blur, TweenInfo.new(1.5), {Size = 0}):Play()
	task.wait(1.5)
	blur:Destroy()
	setFocusMode(false)
	isPlayingMemory = false
end

local function showPaperNote(data)
	if noteOverlay.Visible then return end
	setFocusMode(true)

	noteTitle.Text = data.Title
	noteSubject.Text = "Subject: " .. data.Subject
	noteTarget.Text = data.Target
	noteBody.Text = data.Body

	noteOverlay.Visible = true

	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	TweenService:Create(noteOverlay, ti, {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(paperBg, ti, {BackgroundTransparency = 0}):Play()
	TweenService:Create(paperStroke, ti, {Transparency = 0}):Play()
	TweenService:Create(noteTitle, ti, {TextTransparency = 0}):Play()
	TweenService:Create(noteSubject, ti, {TextTransparency = 0}):Play()
	TweenService:Create(noteTarget, ti, {TextTransparency = 0}):Play()
	TweenService:Create(noteBody, ti, {TextTransparency = 0}):Play()
	TweenService:Create(closeNoteBtn, ti, {TextTransparency = 0}):Play()

	local s = Instance.new("Sound", workspace)
	s.SoundId = "rbxassetid://9119713990" 
	s.Volume = 0.5
	s:Play()
	game.Debris:AddItem(s, 2)
end

local function hidePaperNote()
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	TweenService:Create(noteOverlay, ti, {BackgroundTransparency = 1}):Play()
	TweenService:Create(paperBg, ti, {BackgroundTransparency = 1}):Play()
	TweenService:Create(paperStroke, ti, {Transparency = 1}):Play()
	TweenService:Create(noteTitle, ti, {TextTransparency = 1}):Play()
	TweenService:Create(noteSubject, ti, {TextTransparency = 1}):Play()
	TweenService:Create(noteTarget, ti, {TextTransparency = 1}):Play()
	TweenService:Create(noteBody, ti, {TextTransparency = 1}):Play()
	local t = TweenService:Create(closeNoteBtn, ti, {TextTransparency = 1})
	t:Play()

	t.Completed:Connect(function()
		noteOverlay.Visible = false
		setFocusMode(false)
	end)
end

closeNoteBtn.MouseButton1Click:Connect(hidePaperNote)

local function checkZoom()
	local char = player.Character;
	if not char then return false end
	local head = char:FindFirstChild("Head");
	if not head then return false end
	return (camera.CFrame.Position - head.Position).Magnitude <= InteractionData.MAX_CAMERA_ZOOM_DIST
end

local requestInteract = events:WaitForChild("RequestInteraction")
local performInteract = events:WaitForChild("PerformInteraction")

-- [[ THE FIX: RESTORED ORIGINAL CLICK HANDLER WITH TOOL CANCELLATION HACK ]]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not checkZoom() then return end

	local target = mouse.Target
	local character = player.Character
	if not target or not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local dist = (character.HumanoidRootPart.Position - mouse.Hit.Position).Magnitude
	if dist <= InteractionData.MAX_INTERACT_DISTANCE then

		-- Stop Tool from Swinging Hack
		local currentTool = character:FindFirstChildWhichIsA("Tool")
		if currentTool then
			local targetModel = target:FindFirstAncestorOfClass("Model")
			local isNPC = targetModel and targetModel:FindFirstChild("Humanoid")

			-- Check if we are interacting with something important
			local isInteractable = findValueInAncestors(target, "InteractMessage_" .. currentTool.Name) 
				or findValueInAncestors(target, "InteractMessage") 
				or findValueInAncestors(target, "MemoryID") 
				or findValueInAncestors(target, "NoteID") 
				or findValueInAncestors(target, "ClickDetector")
				or isNPC

			if isInteractable then
				-- Trick Roblox into canceling the swing by temporarily disabling ManualActivationOnly
				local originalState = currentTool.ManualActivationOnly
				currentTool.ManualActivationOnly = true
				task.delay(0.1, function()
					if currentTool then currentTool.ManualActivationOnly = originalState end
				end)
			end
		end

		requestInteract:FireServer(target, mouse.Hit.Position)
	end
end)

performInteract.OnClientEvent:Connect(function(actionType, data)
	if actionType == "Message" then
		showLocalMessage(data)
	elseif actionType == "Memory" then
		playMemorySequence(data)
	elseif actionType == "Note" then
		showPaperNote(data)
	end
end)

RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()

	-- [[ POSITION THE IMAGE EXACTLY ON THE HARDWARE MOUSE LOCATION + OFFSET ]]
	customCursor.Position = UDim2.fromOffset(mousePos.X + CURSOR_OFFSET_X, mousePos.Y + CURSOR_OFFSET_Y)

	local target = mouse.Target
	local character = player.Character

	if not checkZoom() or noteOverlay.Visible or isPlayingMemory then
		tooltip.Visible = false
		customCursor.Image = CURSOR_DEFAULT
		return
	end

	if target and character and character:FindFirstChild("HumanoidRootPart") then
		local dist = (character.HumanoidRootPart.Position - mouse.Hit.Position).Magnitude

		if dist <= InteractionData.MAX_INTERACT_DISTANCE then
			local currentTool = character:FindFirstChildWhichIsA("Tool")
			local targetModel = target:FindFirstAncestorOfClass("Model")
			local targetPlayer = targetModel and Players:GetPlayerFromCharacter(targetModel)

			local isNPC = targetModel and targetModel:FindFirstChild("Humanoid") and not targetPlayer

			if findValueInAncestors(target, "MemoryID") then
				tooltip.Visible = true;
				tooltip.Text = "Recall Memory"; tooltip.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
			elseif findValueInAncestors(target, "NoteID") then
				tooltip.Visible = true; tooltip.Text = "Read Note";
				tooltip.BackgroundColor3 = Color3.fromRGB(240, 230, 200)
			elseif targetPlayer then
				if targetPlayer ~= player then
					tooltip.Visible = true; tooltip.Text = "Interact";
					tooltip.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
				else
					tooltip.Visible = true; tooltip.Text = "Inspect Self";
					tooltip.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
				end
			elseif isNPC then
				tooltip.Visible = true; tooltip.Text = "Interact";
				tooltip.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
			elseif currentTool and currentTool.Name == "MagicMug" and findValueInAncestors(target, "Effect") then
				tooltip.Visible = true; tooltip.Text = "Scoop?";
				tooltip.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

			elseif currentTool and findValueInAncestors(target, "InteractMessage_" .. currentTool.Name) then
				tooltip.Visible = true; tooltip.Text = "Use " .. currentTool.Name;
				tooltip.BackgroundColor3 = Color3.fromRGB(200, 150, 50)

			elseif findValueInAncestors(target, "ClickDetector") then
				tooltip.Visible = true
				tooltip.BackgroundColor3 = Color3.fromRGB(100, 100, 150)

				-- Check if we are clicking the sleep or wake buttons
				if target.Name == "DreamBed" or (target.Parent and target.Parent.Name == "DreamBed") then
					tooltip.Text = "Sleep"
				elseif target.Name == "WakeUpPart" or (target.Parent and target.Parent.Name == "WakeUpPart") then
					tooltip.Text = "Wake Up"
				else
					tooltip.Text = "Interact"
				end

			elseif findValueInAncestors(target, "InteractMessage") then
				tooltip.Visible = true; tooltip.Text = "Clickable";
				tooltip.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			else
				tooltip.Visible = false
			end

			if tooltip.Visible then
				customCursor.Image = CURSOR_ACTIVE
				tooltip.Position = UDim2.fromOffset(mousePos.X + CURSOR_OFFSET_X + 10, mousePos.Y + CURSOR_OFFSET_Y + 45)
			else
				customCursor.Image = CURSOR_DEFAULT
			end
		else
			tooltip.Visible = false
			customCursor.Image = CURSOR_DEFAULT
		end
	else
		tooltip.Visible = false
		customCursor.Image = CURSOR_DEFAULT
	end
end)

yesBtn.MouseButton1Click:Connect(function() voteFrame.Visible = false; sendVoteEvent:FireServer(true) end)
noBtn.MouseButton1Click:Connect(function() voteFrame.Visible = false; sendVoteEvent:FireServer(false) end)

local isSleepingAnim = false
voteStatusEvent.OnClientEvent:Connect(function(action, value, extraData)
	if action == "ShowVote" then
		voteFrame.Visible = true; title.Text = value .. " wants to " .. extraData .. "..."
	elseif action == "HideVote" then
		voteFrame.Visible = false
	elseif action == "UpdateTopText" then
		statusLabel.Text = value;
		statusLabel:TweenPosition(UDim2.new(0,0,0,0), "Out", "Quad", 0.5)
	elseif action == "ClearTopText" then
		statusLabel:TweenPosition(UDim2.new(0,0,-0.1,0), "In", "Quad", 0.5)
	elseif action == "PlaySound" and countdownSound then
		countdownSound:Play()
	elseif action == "ShowIntroText" then
		while loadingLabel.Visible or statusLabel.Position.Y.Scale > -0.1 do task.wait(0.5) end
		local introLabel = Instance.new("TextLabel", screenGui)
		introLabel.Size = UDim2.new(1,0,0.2,0);
		introLabel.Position = UDim2.new(0,0,0.4,0); introLabel.BackgroundTransparency = 1; introLabel.Text = value; introLabel.TextColor3 = Color3.new(1,1,1); introLabel.Font = Enum.Font.IndieFlower; introLabel.TextSize = 40;
		introLabel.TextScaled = false; introLabel.TextTransparency = 1
		TweenService:Create(introLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
		local shakeLoop = true
		task.spawn(function()
			local originalPos = introLabel.Position
			while shakeLoop do
				introLabel.Position = UDim2.new(0, math.random(-3,3), 0.4, math.random(-3,3))
				task.wait(0.05)
			end
			introLabel.Position = originalPos
		end)
		task.delay(5, function()
			shakeLoop = false
			local t = TweenService:Create(introLabel, TweenInfo.new(1), {TextTransparency = 1})
			t:Play(); t.Completed:Connect(function() introLabel:Destroy() end)
		end)
	elseif action == "ScreenEffect" and value == "Darken" then
		darkenFrame.Visible = true;
		darkenFrame.BackgroundTransparency = 1
		TweenService:Create(darkenFrame, TweenInfo.new(1), {BackgroundTransparency = 0.3}):Play()
		task.delay(tonumber(extraData) or 5, function()
			local t = TweenService:Create(darkenFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
			t:Play(); t.Completed:Connect(function() darkenFrame.Visible = false end)
		end)

	elseif action == "FadeOut" then
		fadeFrame.Image = SLEEP_IMAGES[math.random(1, #SLEEP_IMAGES)]
		fadeFrame.Visible = true;

		fadeFrame.BackgroundTransparency = 1
		fadeFrame.ImageTransparency = 1

		TweenService:Create(fadeFrame, TweenInfo.new(2), {BackgroundTransparency = 0, ImageTransparency = 0}):Play()

		local textToDisplay = value or "Sleeping"
		isSleepingAnim = true;
		loadingLabel.Visible = true
		task.spawn(function()
			while isSleepingAnim do
				loadingLabel.Text = textToDisplay; task.wait(0.5)
				if isSleepingAnim then loadingLabel.Text = textToDisplay.."."; task.wait(0.5) end
				if isSleepingAnim then loadingLabel.Text = textToDisplay..".."; task.wait(0.5) end
				if isSleepingAnim then loadingLabel.Text = textToDisplay.."..."; task.wait(0.5) end
			end
		end)
	elseif action == "FadeIn" then

		isSleepingAnim = false; 
		loadingLabel.Visible = false; 

		TweenService:Create(fadeFrame, TweenInfo.new(2), {BackgroundTransparency = 1, ImageTransparency = 1}):Play()
		task.delay(2, function() fadeFrame.Visible = false end)
	end
end)