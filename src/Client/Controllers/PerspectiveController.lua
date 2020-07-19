--[[
	Perspective Controller
	Manages player dimensional switching
--]]

local PerspectiveController = {}

---------------------
-- Roblox Services --
---------------------
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

------------------
-- Dependencies --
------------------
local LevelService;
local LevelController;

-------------
-- Defines --
-------------
local PerspectiveUI = ReplicatedStorage.Assets.UIs.PerspectiveUI:Clone()
      PerspectiveUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local CurrentPerspective = "3D"
local Perspective_MapCache = {} --Stores original 3D positions of map geometry since 2D / 4D perspectives shift it around.
local Player_3DCoords = {}
local CurrentFloorPart;
local CurrentFloorPart_RelPos;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cleares the map geometry cache
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ClearCache()
	for Key,_ in pairs(Perspective_MapCache) do
		Perspective_MapCache[Key] = nil
	end
	Perspective_MapCache = {}
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sinks W and S key inputs
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SinkZMovement() --! Hack...we should be using physics to lock the avatar to the XY axis, not disabling input.
	                           --! But hey it's gamejam, so no one cares.
	return Enum.ContextActionResult.Sink
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : GetCurrentPerspective
-- @Description : Returns the current perspective the player is in
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PerspectiveController:GetCurrentPerspective()
	return CurrentPerspective
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : SetPerspective
-- @Description : Sets the current perspective the player is in
-- @Params : string "Perspective" - The perspective to force the player into
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PerspectiveController:SetPerspective(Perspective)
	if CurrentPerspective ~= Perspective then
		local CurrentMap = LevelController:GetCurrentMap()

		if Perspective == "2D" then

			-----------------------------
			-- Displacing map geometry --
			-----------------------------
			Player_3DCoords = Players.LocalPlayer.Character.HumanoidRootPart.Position
			Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(
				Players.LocalPlayer.Character.HumanoidRootPart.Position.X,
				Players.LocalPlayer.Character.HumanoidRootPart.Position.Y,
				0
			)))
			for _,Object in pairs(CurrentMap.Geometry:GetDescendants()) do
				if Object:IsA("Part") or Object:IsA("MeshPart") or Object:IsA("UnionOperation") then
					local GUID = HttpService:GenerateGUID(false)

					Object.Name = GUID
					Perspective_MapCache[GUID] = Object.Position
					Object.Position = Vector3.new(Object.Position.X,Object.Position.Y,0)
				end
			end

			--------------------------------------
			-- Disabling movement on the Z axis --
			--------------------------------------
			ContextActionService:BindAction("SinkZMovement",SinkZMovement,false,Enum.KeyCode.W)
			ContextActionService:BindAction("SinkNZMovement",SinkZMovement,false,Enum.KeyCode.S)

			------------------------
			-- Configuring camera --
			------------------------
			local Blur = Instance.new('BlurEffect')
			      Blur.Parent = Lighting
			local Blur_InTween = TweenService:Create(
				Blur,
				TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{
					Size = 54
				}
			)
			local Blur_OutTween = TweenService:Create(
				Blur,
				TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			)
			local FOVTween = TweenService:Create(
				Workspace.CurrentCamera,
				TweenInfo.new(0.35,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
				{
					FieldOfView = 1
				}
			)
			local CFrameTween = TweenService:Create(
				Workspace.CurrentCamera,
				TweenInfo.new(0.8,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
				{
					CFrame = CurrentMap.PrimaryPart.CFrame * CFrame.new(0,35,3000 + (CurrentMap.PrimaryPart.Size.X * 2))
				}
			)
			Workspace.CurrentCamera.CFrame = CurrentMap.PrimaryPart.CFrame * CFrame.new(Players.LocalPlayer.Character.PrimaryPart.CFrame.Position)
			Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			Workspace.CurrentCamera.Focus = CurrentMap.PrimaryPart.CFrame
			Workspace.CurrentCamera.CameraSubject = CurrentMap.PrimaryPart

			Blur_InTween:Play()
			FOVTween:Play()
			CFrameTween:Play()
			wait(0.3)
			Blur_OutTween:Play()
			Blur_OutTween.Completed:wait()
			Blur:Destroy()

			CurrentPerspective = "2D"
		else

			----------------------------
			-- Restoring map geometry --
			----------------------------
			for _,Object in pairs(CurrentMap.Geometry:GetDescendants()) do
				if Object:IsA("Part") or Object:IsA("MeshPart") or Object:IsA("UnionOperation") then
					Object.Position = Perspective_MapCache[Object.Name]
				end
			end
			if CurrentFloorPart ~= nil then
				Player_3DCoords = Vector3.new(
					Players.LocalPlayer.Character.HumanoidRootPart.Position.X,
					Players.LocalPlayer.Character.HumanoidRootPart.Position.Y,
					CurrentFloorPart.Position.Z
				)
			end
			Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Vector3.new(
				Players.LocalPlayer.Character.HumanoidRootPart.Position.X,
				Players.LocalPlayer.Character.HumanoidRootPart.Position.Y,
				Player_3DCoords.Z
			)))

			-------------------------------------
			-- Enabling movement on the Z axis --
			-------------------------------------
			ContextActionService:UnbindAction("SinkZMovement")
			ContextActionService:UnbindAction("SinkNZMovement")

			------------------------
			-- Configuring camera --
			------------------------
			local Blur = Instance.new('BlurEffect')
			      Blur.Parent = Lighting
			local Blur_InTween = TweenService:Create(
				Blur,
				TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{
					Size = 54
				}
			)
			local Blur_OutTween = TweenService:Create(
				Blur,
				TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			)
			local FOVTween = TweenService:Create(
				Workspace.CurrentCamera,
				TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			)
			local CFrameTween = TweenService:Create(
				Workspace.CurrentCamera,
				TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
				{
					CFrame = CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.new(0,0,12)
				}
			)

			Blur_InTween:Play()
			FOVTween:Play()
			CFrameTween:Play()
			wait(0.3)
			Blur_OutTween:Play()
			Blur_OutTween.Completed:wait()
			Blur:Destroy()

			Workspace.CurrentCamera.Focus = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
			Workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character.Humanoid
			Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

			ClearCache()
			CurrentPerspective = "3D"
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Used to initialize controller state
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PerspectiveController:Init()
	self:DebugLog("[Perspective Controller] Initializing...")

	self:DebugLog("[Perspective Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Used to run the controller
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PerspectiveController:Start()
	self:DebugLog("[Perspective Contrller] Running!")

	LevelService = self:GetService("LevelService")
	LevelController = self:GetController("LevelController")

	LevelService.LevelStarted:connect(function()
		ClearCache()
	end)

	local ToggleDebounce = false
	PerspectiveUI.Button.MouseButton1Click:connect(function()
		if not ToggleDebounce then
			ToggleDebounce = true
			if self:GetCurrentPerspective() == "3D" then
				self:SetPerspective("2D")
			else
				self:SetPerspective("3D")
			end
			ToggleDebounce = false
		end
	end)

	while wait(0.1) do
		if self:GetCurrentPerspective() == "2D" then
			local raycastParams = RaycastParams.new()
				  raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
				  raycastParams.FilterDescendantsInstances = {Players.LocalPlayer.Character,LevelController:GetCurrentMap().PrimaryPart}
			local RayResult = Workspace:Raycast(Players.LocalPlayer.Character.HumanoidRootPart.Position,Vector3.new(0,-1,0).Unit * 50,raycastParams)
			local FloorPart = RayResult.Instance

			if FloorPart ~= nil then
				if FloorPart.Name ~= "Root" then
					CurrentFloorPart = FloorPart
				end
			end
		end
	end
end

return PerspectiveController