--[[
	Returns the last word in a PascalCase string, ignoring any trailing numbers. E.g.
	
	LeftUpperArm -> Arm
	LeftElbow -> Elbow
	LeftUpperLeg4 -> Leg
	TestT3st4 -> T3st
	test -> test (whole string returned if there are no uppercase characters)
	3 -> ""
--]]

return function (str)
	-- Get the last word in the PascalCase name (e.g. Arm from UpperLeftArm)
	local lastWord = str:sub(#str - ((str:reverse():find("%u") or #str+1) - 1))
	-- Remove trailing numbers from the name
	lastWord = lastWord:gsub("%d+$", "")
	
	return lastWord
end
