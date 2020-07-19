--[[
	Roblox avatars are a nightmare to physically simulate, either because of innate clipping
	or because package hitboxes are insane. Don't believe me?
	
	- https://i.imgur.com/471ffsb.png (bundle id=475)
	- https://i.imgur.com/fRpkSdS.png (bundle id=429)
	- https://i.imgur.com/k07QVWR.png (bundle id=162)
	- https://i.imgur.com/F2lo4Te.jpg (bundle id=168)
	- https://i.imgur.com/je4GEas.png (bundle id=475)
	- https://i.imgur.com/0oUu1ra.png (bundle id=192)
	
	So we have to disable collisions between a bunch of parts to get them to simulate without
	spazzing out due to overconstraints.
	
	We don't want to disable all collision, as that would result in ugly things like the
	legs phasing through each other, or a hand phasing through a leg. Specifically looking
	at Roblox bundles, the torso clipping is by far the worst (e.g. Deathspeaker UpperTorso
	clips with EVERY OTHER BODY PART), with next up being nearby ballsocketish joints (e.g.
	a shoulder and the head, or the two upper legs). We can't just hardcode limb names
	and get it over with though (Humanoids are already bad enough at this...) if we want
	ragdolls to work with arbitrary characters, so my solution was:
	
	"Parent" limbs (e.g. torso is a parent to the head, arms, and legs) should not collide
	with their children. This solves the torso problem in a generic way that should work with
	most characters.
	
	Limb "roots" (e.g. shoulder, head, hips) can't collide with each other. Again, this solves
	the problems we had with Roblox bundles while still working with arbitrary characters
	
	Maybe this approach won't work for 100% of characters, but hopefully it should work in
	most cases.
--]]

local getLastWordFromPascaleCase = require(script.Parent:WaitForChild("getLastWordFromPascalCase"))

-- The hand is actually part of the arm/etc, so remap their limb types
local LIMB_TYPE_ALIASES = {
	Hand = "Arm",
	Foot = "Leg",
}

-- LeftUpperArm -> Arm, LeftHand -> Arm
function getLimbType(limbName)
	local limbType = getLastWordFromPascaleCase(limbName)
	return LIMB_TYPE_ALIASES[limbType] or limbType
end

--[[
	We need a lot of information to determine which collisions to filter, but they are all
	condensed into one place to minimize redundant loops in case someone is spam-spawning
	characters with hundreds of limbs. Returns the following information:
	
	limbs:
	{
		["Arm"] = { LeftUpperArm, LeftLowerArm, LeftHand, RightUpperArm, RightLowerArm, RightHand},
		["Head"] = { Head },
		["Torso"] = { LowerTorso, UpperTorso },
		...	
	}
	
	limbRootParts:
	{ {Part=Head, Type=Head}, {Part=LeftUpperArm, Type="Arm"}, {Part=RightUpperArm, Type="Arm"}, ... }
	
	limbParents:
	{
		["Arm"] = { "Torso" },
		["Head"] = { "Torso" },
		["Torso"] = {},
		...	
	}
--]]
function getLimbs(characterRoot, attachmentMap)
	local limbs = {}
	local limbRootParts = {}
	local limbParents = {}

	local function parsePart(part, lastLimb)
		if part.Name ~= "HumanoidRootPart" then
			local limbType = getLimbType(part.Name)
			limbs[limbType] = limbs[limbType] or {}
			
			table.insert(limbs[limbType], part)
			
			local limbData = limbs[limbType]
			if limbType ~= lastLimb then
				limbParents[limbType] = limbParents[limbType] or {}
				if lastLimb then
					limbParents[limbType][lastLimb] = true
				end
				
				table.insert(limbRootParts, {Part=part, Type=limbType})
				lastLimb = limbType
			end
		end
		
		for _,v in pairs(part:GetChildren()) do
			if v:isA("Attachment") and attachmentMap[v.Name] then
				local part1 = attachmentMap[v.Name].Attachment1.Parent
				if part1 and part1 ~= part then
					parsePart(part1, lastLimb)
				end
			end
		end
	end
	parsePart(characterRoot)
	
	return limbs, limbRootParts, limbParents
end

function createNoCollision(part0, part1)
	local noCollision = Instance.new("NoCollisionConstraint")
	noCollision.Name = part0.Name.."<->"..part1.Name
	noCollision.Part0 = part0
	noCollision.Part1 = part1
	
	return noCollision
end

return function(attachmentMap, characterRoot)
	local noCollisionConstraints = Instance.new("Folder")
	noCollisionConstraints.Name = "NoCollisionConstraints"
	
	local limbs, limbRootParts, limbParents = getLimbs(characterRoot, attachmentMap)
	
	--[[
		Disable collisions between all limb roots (e.g. left/right shoulders, head, etc) unless
		one of them is a parent of the other (handled in next step). This is to ensure limbs
		maintain free range of motion and we don't have issues like
			- Large shoulders clipping with the head and all of them being unable to move
			- Legs being stuck together because rotating would cause the collision boxes to intersect
	--]]
	for i=1, #limbRootParts do
		for j=i+1, #limbRootParts do
			local limbType0, limbType1 = limbRootParts[i].Type, limbRootParts[j].Type

			if not (limbParents[limbType0][limbType1] or limbParents[limbType1][limbType0]) then
				createNoCollision(limbRootParts[i].Part, limbRootParts[j].Part).Parent = noCollisionConstraints
			end
		end
	end

	--[[
		Disable collisions between limbs and their parent limbs. This is mostly to address
		bundle torsos having insane hitboxes that touch more than just limb roots
	--]]
	for limbType, parts in pairs(limbs) do
		for parentLimbType,_ in pairs(limbParents[limbType]) do
			for _,part2 in pairs(limbs[parentLimbType]) do
				for _,part in pairs(parts) do
					createNoCollision(part, part2).Parent = noCollisionConstraints
				end
			end
		end
	end
	
	return noCollisionConstraints
end