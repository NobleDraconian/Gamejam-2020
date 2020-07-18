--[[
	Clientpaths

	Contains resource paths for the client sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Shared = {
			ReplicatedStorage.Utils,
			Players.LocalPlayer.PlayerScripts:WaitForChild("Utils")
		},
	},

	ControllerPaths = {
		Players.LocalPlayer.PlayerScripts:WaitForChild("Controllers")
	}
}