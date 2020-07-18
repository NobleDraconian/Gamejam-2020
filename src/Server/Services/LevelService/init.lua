--[[
	Level Service
	Handles the loading and running of levels in the game
--]]

local LevelService = {Client = {}}
LevelService.Client.Server = LevelService

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

------------
-- Events --
------------
local LevelStarted; -- Fired when a level has been started
local LevelStarted_Client; -- Fired to the playing client when a level has been started
local GoalReached; -- Fired when the goal has been reached for the current level
local GoalReached_Client; -- Fired to the playing client when the goal has been reached for the current level

-------------
-- Defines --
-------------
local LevelConfigs = ReplicatedStorage.LevelConfigs

local CurrentLevel = {
	Name = "",
	Map = nil,
	Configs = {}
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetPlayer
-- @Description : Gets the player playing the level
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:GetPlayer()
	if #Players:GetPlayers() == 0 then
		Players.PlayerAdded:wait()
	end
	return Players:GetPlayers()[1]
end	

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RunLevel
-- @Description : Runs the specified level.
-- @Params : string "LevelName" - The name of the level to run
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:RunLevel(LevelName)
	local Player = self:GetPlayer()
	local NewLevel_Configs = require(LevelConfigs[LevelName])
	local Map = NewLevel_Configs.Map:Clone()
		  Map.Parent = Workspace

	Map:SetPrimaryPartCFrame(CFrame.new(0,0,0))	
	CurrentLevel.Name = NewLevel_Configs.Name
	CurrentLevel.Map = Map
	CurrentLevel.Configs = NewLevel_Configs

	Player:LoadCharacter()
	Player.Character:MoveTo(Map.Start.Position)
	
	LevelStarted:Fire(CurrentLevel)
	LevelStarted_Client:FireClient(self:GetPlayer(),CurrentLevel)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Used to initialize service state
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:Init()
	self:DebugLog("[Level Service] Initializing...")

	LevelStarted = self:RegisterServiceServerEvent("LevelStarted")
	LevelStarted_Client = self:RegisterServiceClientEvent("LevelStarted")
	GoalReached = self:RegisterServiceServerEvent("GoalReached")
	GoalReached_Client = self:RegisterServiceClientEvent("GoalReached")

	self:DebugLog("[Level Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Used to run the service
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:Start()
	self:DebugLog("[Level Service] Running!")

end

return LevelService