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
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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
local LevelNameUI = ReplicatedStorage.Assets.UIs.LevelNameUI:Clone()
	  LevelNameUI.TextLabel.TextTransparency = 1
	  LevelNameUI.Parent = Player.PlayerGui
local CurrentLevel;
local WeatherRand = Random.new()

local function ShowLevelName(LevelName)
	local InTween = TweenService:Create(
		LevelNameUI.TextLabel,
		TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			TextTransparency = 0,
			TextStrokeTransparency = 0.8
		}
	)
	local OutTween = TweenService:Create(
		LevelNameUI.TextLabel,
		TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)
	LevelNameUI.TextLabel.Text = LevelName
	InTween:Play()
	wait(4)
	OutTween:Play()
end

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
	local MenuBackdrop = ReplicatedStorage.Assets.MenuBackdrop:Clone()
		  MenuBackdrop.Parent = Workspace
	
	Player.PlayerGui.PerspectiveUI.Enabled = false
	MenuBackdrop:MoveTo(Vector3.new(0,0,0))
	Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Workspace.CurrentCamera.CFrame = CFrame.new(
		Vector3.new(
			MenuBackdrop.PrimaryPart.Position.X,
			MenuBackdrop.PrimaryPart.Position.Y + 42,
			MenuBackdrop.PrimaryPart.Position.Z + 80
		),
		MenuBackdrop.PrimaryPart.Position
	)
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
			MenuBackdrop:Destroy()
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

	-------------
	-- Defines --
	-------------
	local Music = Instance.new('Sound')
	      Music.Volume = 0
		  Music.Looped = true
		  Music.Parent = MenuUI
	local Music_FadeIn_Tween = TweenService:Create(
		Music,
		TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			Volume = 0.5
		}
	)
	local Music_FadeOut_Tween = TweenService:Create(
		Music,
		TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
		{
			Volume = 0
		}
	)

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
		Music.SoundId = Level.Configs.Music
		Music:Play()
		Music_FadeIn_Tween:Play()
		if WeatherRand:NextInteger(1,4) == 1 then
			Rain:Enable()
		else
			Rain:Disable()
		end
		wait(1) -- Let map finish replicating
		if Workspace:FindFirstChild("MenuBackdrop") ~= nil then
			Workspace.MenuBackdrop:Destroy()
		end
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		Workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character.Humanoid
		PerspectiveController:SetPerspective(Level.Configs.StartingPerspective)
		ShowLevelName(Level.Name)
	end)

	--------------------------------------------
	-- Running menu when a level is completed --
	--------------------------------------------
	LevelService.GoalReached:connect(function()
		LoadingUI:Show()
		MenuUI.Enabled = true
		local MenuBackdrop = ReplicatedStorage.Assets.MenuBackdrop:Clone()
		      MenuBackdrop.Parent = Workspace
  
		Music_FadeOut_Tween:Play()
		Music_FadeOut_Tween.Completed:wait()
		Music:Stop()
		PerspectiveController:SetPerspective("3D")
		Player.PlayerGui.PerspectiveUI.Enabled = false
		MenuBackdrop:MoveTo(Vector3.new(0,0,0))
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		Workspace.CurrentCamera.CFrame = CFrame.new(
			Vector3.new(
				MenuBackdrop.PrimaryPart.Position.X,
				MenuBackdrop.PrimaryPart.Position.Y + 42,
				MenuBackdrop.PrimaryPart.Position.Z + 80
			),
			MenuBackdrop.PrimaryPart.Position
		)
		LoadingUI:Hide()
	end)
end

return LevelController