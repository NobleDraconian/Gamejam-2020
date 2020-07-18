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
			ReplicatedStorage.Modules,
			Players.LocalPlayer.PlayerScripts:WaitForChild("Modules")
		},
	},

	ControllerPaths = {
		Players.LocalPlayer.PlayerScripts:WaitForChild("Controllers")
	}
}