--[[
	Lighting controller
	Handles the loading and saving of different game lighting states
--]]

local LightingController = {}

---------------------
-- Roblox Services --
---------------------
local Lighting = game:GetService("Lighting")

------------------
-- Dependencies --
------------------
local BaseLighting = require(script.BaseLighting)

-------------
-- Defines --
-------------
local LightingStates = {}
local CurrentLoadedState = ""

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RegisterLightingState
-- @Description : Registers the given lighting state that can be loaded later
-- @Params : string "StateName" - The name to reference the lighting state by
--           table "LightingState" - A table containing the lighting state to register
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LightingController:RegisterLightingState(StateName,LightingState)
	if LightingStates[StateName] == nil then
		LightingStates[StateName] = LightingState
		self:DebugLog("[Lighting Controller] Registered lighting state '"..StateName.."'.")
	else
		self:Log(
			("[Lighting Controller] RegisterLightingState() : Could not register lighting state '%s', a lighting state with that name already exists!")
			:format(StateName),
			"Error"
		)			
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : LoadLightingState
-- @Description : Loads the specified lighting state
-- @Params : string "StateName" - The name of the lighting state to load
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LightingController:LoadLightingState(StateName)
	if LightingStates[StateName] ~= nil then
		local LightingState = LightingStates[StateName]

		Lighting:ClearAllChildren()	
		for LightingProperty_Name,LightingProprty_Value in pairs(LightingState.Properties) do
			Lighting[LightingProperty_Name] = LightingProprty_Value
		end
		for _,LightingEffect in pairs(LightingState.Effects) do
			LightingEffect:Clone().Parent = Lighting
		end
	else
		self:Log(
			("[Lighting Controller] LoadLightingState() : Could not load lighting state %s, no lighting state with that name has been registered!")
			:format(StateName),
			"Error"
		)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Init
-- @Description : Used to initialize controller state
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LightingController:Init()
	self:DebugLog("[Lighting Controller] Initializing...")

	self:RegisterLightingState("Default",BaseLighting)
	self:LoadLightingState("Default")

	self:DebugLog("[Lighting Controller] Initialized!")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Start
-- @Description : Used to run the controller
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function LightingController:Start()
	self:DebugLog("[Lighting Controller] Running!")

end

return LightingController