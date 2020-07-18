--[[
	ServerPaths

	Contains resource paths for the server sided engine.
]]

---------------------
-- Roblox Services --
---------------------
local ServerScriptService=game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	ModulePaths = {
		Server = {
			ServerScriptService.Classes,
			ServerScriptService.Utils
		},
		Shared = {
			ReplicatedStorage.Utils,
		}
	},

	ServicePaths = {
		ServerScriptService.Services
	}
}