--[[
	Remodel deployment script
	Deploys the CurrentBuild.rbxlx file to the live servers.
	! This script should only be ran on a CD machine.
--]]

local PLACE_ID = "5153983728"

local function splitstring(pString, pPattern)
	local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = pString:find(fpat, 1)
	while s do
	   if s ~= 1 or cap ~= "" then
	  table.insert(Table,cap)
	   end
	   last_end = e+1
	   s, e, cap = pString:find(fpat, last_end)
	end
	if last_end <= #pString then
	   cap = pString:sub(last_end)
	   table.insert(Table, cap)
	end
	return Table
 end

local Datamodel = remodel.readPlaceFile('../Temp/CurrentBuild.rbxlx')
remodel.writeExistingPlaceAsset(Datamodel,PLACE_ID)