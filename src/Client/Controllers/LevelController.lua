--[[
	Level controller
	Handles the loading and running of levels in the game
--]]

local LevelController = {}

---------------------
-- Roblox Services --
---------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------
-- Dependencies --
------------------
local LevelService;
local LightingController;
local PerspectiveController;
local LoadingUI;
local Rain;

-------------
-- Defines --
-------------
local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local LevelConfigs = ReplicatedStorage.LevelConfigs
local MenuUI = ReplicatedStorage.Assets.UIs.MenuUI:Clone()
      MenuUI.Parent = Player:WaitForChild("PlayerGui")
local CurrentLevel;
local WeatherRand = Random.new()

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

	LoadingUI = self:GetModule("LoadingUI")
	Rain = self:GetModule("Rain")

	------------------------
	-- Setting up menu UI --
	------------------------
	for _,Level in pairs(LevelConfigs:GetChildren()) do
		local LevelButton = MenuUI.BaseButton:Clone()
		local LevelNumber = tonumber(string.sub(Level.Name,-1))

		LevelButton.Name = Level.Name
		LevelButton.LayoutOrder = LevelNumber
		LevelButton.Button.TextLabel.Text = "Level "..LevelNumber
		LevelButton.Visible = true
		LevelButton.Parent = MenuUI.LevelSelect
		LevelButton.Button.MouseButton1Click:connect(function()
			LoadingUI:Show()
			MenuUI.Enabled = false
			LevelService:PlayLevel(LevelButton.Name)
			wait(3)
			LoadingUI:Hide()
		end)
	end
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
		LightingController:LoadLightingState(Level.Configs.LightingState)
		if WeatherRand:NextInteger(1,10) == 1 then
			Rain:Enable()
		else
			Rain:Disable()
		end
		wait(1) -- Let map finish replicating
		PerspectiveController:SetPerspective(Level.Configs.StartingPerspective)
	end)

	--------------------------------------------
	-- Running menu when a level is completed --
	--------------------------------------------
	LevelService.GoalReached:connect(function()
		LoadingUI:Show()
		MenuUI.Enabled = true
		PerspectiveController:SetPerspective("3D")
		LoadingUI:Hide()
	end)
end

return LevelController