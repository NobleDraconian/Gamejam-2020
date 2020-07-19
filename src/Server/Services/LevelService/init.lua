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
-- @Name : Client.PlayLevel
-- @Descriptoin : Loads the specified level for the player
-- @Params : string "LevelName" - The name of the level to load
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService.Client:PlayLevel(_,LevelName)
	self.Server:RunLevel(LevelName)
end

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
	warn(LevelName)
	local Player = self:GetPlayer()
	local NewLevel_Configs = require(LevelConfigs[LevelName])
	local Map = NewLevel_Configs.Map:Clone()
		  Map.Parent = Workspace

	if CurrentLevel ~= nil then
		CurrentLevel.Map:Destroy()
	end

	Map:SetPrimaryPartCFrame(CFrame.new(0,0,0))

	local TouchedConnection;
	TouchedConnection = Map.End.Touched:connect(function(TP)
		if TP.Parent:FindFirstChild("Humanoid") ~= nil then
			TouchedConnection:Disconnect()
			GoalReached:Fire()
			GoalReached_Client:FireClient(Player)
			wait(1)
			Player.Character:Destroy()
		end
	end)
	CurrentLevel = {}
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

	CurrentLevel = nil

	self:DebugLog("[Level Service] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Used to run the service
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LevelService:Start()
	self:DebugLog("[Level Service] Running!")

	local function CharacterAdded(Player,Character)
		Character.Humanoid.Died:connect(function()
			wait(6)
			Character:Destroy()
			Player:LoadCharacter()
			Player.Character:MoveTo(CurrentLevel.Map.Start.Position)
		end)
	end

	local Player = self:GetPlayer()

	if Player.Character ~= nil then
		coroutine.wrap(CharacterAdded)(Player,Player.Character)
	end
	Player.CharacterAdded:connect(function(Character)
		CharacterAdded(Player,Character)
	end)
end

return LevelService