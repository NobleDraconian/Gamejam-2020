local Loading_UI = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LoadingUI = ReplicatedStorage.Assets.UIs.LoadingUI:Clone()
	  LoadingUI.Frame.Transparency = 1
	  LoadingUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

function Loading_UI:Show()
	local FadeTween = TweenService:Create(
		LoadingUI.Frame,
		TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{
			Transparency = 0
		}
	)
	FadeTween:Play()
	FadeTween.Completed:wait()
end

function Loading_UI:Hide()
	local FadeTween = TweenService:Create(
		LoadingUI.Frame,
		TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
		{
			Transparency = 1
		}
	)
	FadeTween:Play()
	FadeTween.Completed:wait()
end

return Loading_UI