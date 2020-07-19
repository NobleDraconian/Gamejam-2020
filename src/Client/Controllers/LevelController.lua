--[[
	Level controller
	Handles the loading and running of levels in the game
--]]

local LevelController = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")

------------------
-- Dependencies --
------------------
local LevelService;
local LightingController;
local PerspectiveController;

-------------
-- Defines --
-------------
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local CurrentLevel;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetCurrentMap
-- @Description : Returns the current level's map
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:GetCurrentMap()
	return CurrentLevel.Map
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Used to initialize controller state
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:Init()
	self:DebugLog("[Level Controller] Initializing...")

	self:DebugLog("[Level Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Used to run the controller
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelController:Start()
	self:DebugLog("[Level Controller] Running!")

	LevelService = self:GetService("LevelService")
	LightingController = self:GetController("LightingController")
	PerspectiveController = self:GetController("PerspectiveController")

	---------------------------------------
	-- Registering level lighting states --
	---------------------------------------
	for _,LightingState in pairs(PlayerScripts.LightingStates.Levels:GetChildren()) do
		LightingController:RegisterLightingState(LightingState.Name,require(LightingState))
	end

	----------------------------------------------------
	-- Doing level logic stuff when a level is loaded --
	----------------------------------------------------
	LevelService.LevelStarted:connect(function(Level)
		CurrentLevel = Level
		wait(1) -- Let map finish replicating
		PerspectiveController:SetPerspective(Level.Configs.StartingPerspective)
		LightingController:LoadLightingState(Level.Configs.LightingState)
	end)
end

return LevelController