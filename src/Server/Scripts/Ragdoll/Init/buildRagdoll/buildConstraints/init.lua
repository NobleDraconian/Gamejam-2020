--[[
	Various ragdoll constraints that are used depending on what type
	of joint they're being applied to. 
	
	This is meant to work with any character, but is mostly tailored 
	to characters with legs/arms, as it is impossible to satisfy all 
	use cases in a generic way. You	can for sure make a spider with 8 
	legs by sticking to the same naming conventions as R15 
	(e.g. LeftUpperLeg1, 2, 3, ...), but something like an eel is not 
	going to come for free out of the box, at least	perfectly. That said, 
	there is a Default waist-like joint for all unknown	joint types. It 
	won't be perfect, but it will be functional. 
	
	If these joint types do not satisfy your use cases, you can tweak them
	or add new ones! Just modify or add to this module's children. These
	constraints are automatically selected based on the last word of the
	joint's name (e.g. Hip from LeftHip). Things to know if you are 
	changing them:
	
	Shoulder twist angles should not be lowered any further or the ragdoll's
	arms will get stuck	in "Aliens" position often
	https://i.imgur.com/Ck5j34M.jpg
	
	Neck is using a HingeConstraint because BallSocketConstraints are 
	kind of	unstable for the head.
	https://gfycat.com/GrotesqueFirsthandBluebottlejellyfish
	
	Ankle and Wrist are HingeConstraints because twist limits are not
	enough for BallSocketConstraints -- due to the "try to do x"
	rather than "force x" nature of constraints, twist limits are
	given a small margin where they are not applied close to 0, and
	this causes the wrists/ankles to jitter back and forth when they 
	are suspended in air. Other limbs are generally not suspended in
	air, so it's only necessary for Ankle/Wrist joints.
--]]
	
local getLastWordFromPascaleCase = require(script.Parent:WaitForChild("getLastWordFromPascalCase"))

local constraints = {}
for _,v in pairs(script:GetChildren()) do
	constraints[v.Name] = v
end

function getConstraintTemplate(jointName)
	jointName = getLastWordFromPascaleCase(jointName)
	return constraints[jointName] or constraints.Default
end

function createConstraint(jointData)
	local jointName = jointData.Joint.Name
	local constraint = getConstraintTemplate(jointName):Clone()
	
	constraint.Attachment0 = jointData.Attachment0
	constraint.Attachment1 = jointData.Attachment1
	constraint.Name = jointName.."RagdollConstraint"
	
	-- Constraints don't work if there is a rigid joint connecting its two parts,
	-- so when we enter ragdoll we need to turn off the joint, and turn it back on
	-- when we leave ragdoll. This allows us to tell which joint corresponds with
	-- which constraint
	local rigidPointer = Instance.new("ObjectValue", constraint)
	rigidPointer.Name = "RigidJoint"
	rigidPointer.Value = jointData.Joint
	
	return constraint
end

return function(attachmentMap)
	local ragdollConstraints = Instance.new("Folder")
	ragdollConstraints.Name = "RagdollConstraints"

	for attachmentName,jointData in pairs(attachmentMap) do
		if jointData.Joint.Name ~= "Root" then
			local ragdollConstraint = createConstraint(jointData)
			ragdollConstraint.Parent = ragdollConstraints
		end
	end
	
	return ragdollConstraints
end