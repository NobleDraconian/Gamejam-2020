--[[
	Constructs ragdoll constraints and flags some limbs so they can't collide with each other
	for stability purposes. After this is finished, it tags the humanoid so the client/server
	ragdoll scripts can listen to StateChanged and disable/enable the rigid Motor6D joints when
	the humanoid enters valid ragdoll states
--]]

local buildConstraints = require(script:WaitForChild("buildConstraints"))
local buildCollisionFilters = require(script:WaitForChild("buildCollisionFilters"))

--[[
	 Builds a map that allows us to find Attachment0/Attachment1 when we have the other,
		and keep track of the joint that connects them. Format is
		{
			["WaistRigAttachment"] = {
				Joint = UpperTorso.Waist<Motor6D>,
				Attachment0 = LowerTorso.WaistRigAttachment<Attachment>,
				Attachment1 = UpperToros.WaistRigAttachment<Attachment>,
			},
			...
		}
--]]
function buildAttachmentMap(character)
	local attachmentMap = {}
	
	-- NOTE: GetConnectedParts doesn't work until parts have been parented to Workspace, so
	-- we can't use it (unless we want to have that silly restriction for creating ragdolls)
	for _,part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			for _,attachment in pairs(part:GetChildren()) do
				if attachment:IsA("Attachment") then
					local jointName = attachment.Name:match("^(.+)RigAttachment$")
					local joint = jointName and attachment.Parent:FindFirstChild(jointName) or nil
					
					if joint then
						attachmentMap[attachment.Name] = {
							Joint = joint,
							Attachment0=joint.Part0[attachment.Name]; 
							Attachment1=joint.Part1[attachment.Name];
						}
					end
				end
			end
		end
	end
	
	return attachmentMap
end

return function(humanoid)
	local character = humanoid.Parent
	
	-- Trying to recover from broken joints is not fun. It's impossible to reattach things like
	-- armor and tools in a generic way that works across all games, so we just prevent that
	-- from happening in the first place.
	humanoid.BreakJointsOnDeath = false
	
	-- Roblox decided to make the ghost HumanoidRootPart CanCollide=true for some reason, so
	-- we correct this and disable collisions. This prevents the invisible part from colliding
	-- with the world and ruining the physics simulation (e.g preventing a roundish torso from
	-- rolling)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.CanCollide = false
	end 

	local attachmentMap = buildAttachmentMap(character)
	local ragdollConstraints = buildConstraints(attachmentMap)
	local collisionFilters = buildCollisionFilters(attachmentMap, character.PrimaryPart)

	collisionFilters.Parent = ragdollConstraints
	ragdollConstraints.Parent = character
	
	game:GetService("CollectionService"):AddTag(humanoid, "Ragdoll")
end