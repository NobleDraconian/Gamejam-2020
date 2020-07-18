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
			ServerScriptService.Modules,
		},
		Shared = {
			ReplicatedStorage.Modules,
		}
	},

	ServicePaths = {
		ServerScriptService.Services
	}
}