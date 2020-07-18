local Lighting = game:GetService("Lighting")

return {
	Properties = {
		Ambient = Color3.fromRGB(0,0,0),
		Brightness = 0.46,
		ColorShift_Bottom = Color3.fromRGB(0,0,0),
		ColorShift_Top = Color3.fromRGB(0,0,0),
		EnvironmentDiffuseScale = 0,
		EnvironmentSpecularScale = 0,
		GlobalShadows = true,
		OutdoorAmbient = Color3.fromRGB(118,118,118),
		ShadowSoftness = 0.5,
		ClockTime = 14,
		GeographicLatitude = 41.733,
		ExposureCompensation = 0,
		FogColor = Color3.fromRGB(255,255,255),
		FogEnd = 3500,
		FogStart = 130
	},
	Effects = {
		Lighting.Skybox:Clone(),
		Lighting.ColorCorrection:Clone()
	}
}