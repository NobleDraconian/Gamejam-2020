local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	Properties = {
		Ambient = Color3.fromRGB(0,0,0),
		Brightness = 4,
		ColorShift_Bottom = Color3.fromRGB(0,0,0),
		ColorShift_Top = Color3.fromRGB(216,192,153),
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		GlobalShadows = true,
		OutdoorAmbient = Color3.fromRGB(76,107,154),
		ShadowSoftness = 0.15,
		ClockTime = 13.853,
		GeographicLatitude = 15.601,
		ExposureCompensation = 0,
		FogColor = Color3.fromRGB(192,192,192),
		FogEnd = 100000,
		FogStart = 0
	},
	Effects = {
		ReplicatedStorage.Assets.Lighting.Levels.Level1.Skybox
	}
}