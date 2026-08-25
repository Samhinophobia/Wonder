-- @ScriptType: Script
local Players = game:GetService("Players")

local TransformModule = require(game.ServerScriptService.TransformModule) 


local AllowedForms = {
	["FrozenBindingDawn"] = {
		HeadCube = game.ServerStorage.Assets.Homunculi.TransformHead,
		BodyCube = game.ServerStorage.Assets.Homunculi.TransformCube,
		Spikes = game.ServerStorage.Assets.Homunculi.TrueForm.BigBlackSpikes,
		Eyes = {
			game.ServerStorage.Assets.Homunculi.TrueForm.RageEye1,
			game.ServerStorage.Assets.Homunculi.TrueForm.RageEye2
		}
	},
	["dj_slurrr"] = {
		HeadCube = game.ServerStorage.Assets.Homunculi.Alice.TransformHeadAlice,
		BodyCube = game.ServerStorage.Assets.Homunculi.Alice.TransformCubeAlice,
	--	Spikes = game.ServerStorage.Assets.Homunculi.Alice.AliceRing1, game.ServerStorage.Assets.Homunculi.Alice.AliceRing2,
		Eyes = {game.ServerStorage.Assets.Homunculi.TrueForm.AliceEye1, game.ServerStorage.Assets.Homunculi.TrueForm.AliceEye2},

		MorphColor = Color3.fromRGB(255, 170, 255), 

		CrownAttachment = game.ServerStorage.Assets.Homunculi.Alice.CrownAttachment, 
		CustomPlate = game.ServerStorage.Assets.Homunculi.Alice.AlicePlateAttachment,


		ScreenTint = Color3.fromRGB(255, 170, 200),


		CrownOffset = Vector3.new(0.7, 1, 0) 
	},
	["jer028q"] = {
		HeadCube = game.ServerStorage.Assets.Homunculi.TransformHead,
		BodyCube = game.ServerStorage.Assets.Homunculi.TransformCube,
		Eyes = {
			game.ServerStorage.Assets.Homunculi.TrueForm.RageEye1,
			game.ServerStorage.Assets.Homunculi.TrueForm.RageEye2},
		ScreenTint = Color3.fromRGB(132, 118, 69),
		MorphColor = Color3.fromRGB(255, 128, 0), 
		MusicId = "rbxassetid://987654321",
		
		OrbitingCores = {
			OrbitRadius = -2.5,
			game.ServerStorage.Assets.Homunculi.Hatter.core,
			game.ServerStorage.Assets.Homunculi.Hatter.core2
		}
	}
}

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if string.lower(msg) == "!transform" then
		
			local myForm = AllowedForms[player.Name]

			if myForm and player.Character then
			
				TransformModule.Active(player, player.Character, myForm)
			end
		end
	end)
end)