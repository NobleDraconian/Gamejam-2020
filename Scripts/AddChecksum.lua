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
local ChecksumFile = io.open("../Temp/Checksum.txt","r")
local ChecksumValue = splitstring(ChecksumFile:read("*l")," ")[1]
local ChecksumInstance = Instance.new('StringValue')
	  ChecksumInstance.Parent = Datamodel.ReplicatedStorage

remodel.setRawProperty(ChecksumInstance,"Name","String","_BuildChecksum")
remodel.setRawProperty(ChecksumInstance,"Value","String",ChecksumValue)
remodel.writePlaceFile(Datamodel,'../Temp/CurrentBuild.rbxlx')

ChecksumFile:close()