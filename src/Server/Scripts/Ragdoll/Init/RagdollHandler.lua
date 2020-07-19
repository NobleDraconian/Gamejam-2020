local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local TAG_NAME = "Ragdoll"
local RAGDOLL_STATES = {
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Physics] = true,
	-- DO NOT USE THE Ragdoll HUMANOID STATE TYPE! This is the state you go into
	-- temporarily when you trip. It ends automatically and will feel weird to
	-- players because they are entering the ragdoll state for half a second "randomly"
	-- when they get flung
}

local connections = {}

function setRagdollEnabled(humanoid, isEnabled)
	local ragdollConstraints = humanoid.Parent:FindFirstChild("RagdollConstraints")
	
	for _,constraint in pairs(ragdollConstraints:GetChildren()) do
		if constraint:IsA("Constraint") then
			local rigidJoint = constraint.RigidJoint.Value
			local expectedValue = (not isEnabled) and constraint.Attachment1.Parent or nil
			
			if rigidJoint.Part1 ~= expectedValue then
				rigidJoint.Part1 = expectedValue 
			end
		end
	end
end

function hasRagdollOwnership(humanoid)
	if runService:IsServer() then
		-- Always set on the server, even if the owning client has already
		-- toggled the ragdoll. We don't want the server to be desynced in
		-- case the character changes ownership
		return true
	end

	local player = players:GetPlayerFromCharacter(humanoid.Parent)
	return player == players.LocalPlayer
end

function ragdollAdded(humanoid)
	connections[humanoid] = humanoid.StateChanged:Connect(function(oldState, newState)
		if hasRagdollOwnership(humanoid) then
			if RAGDOLL_STATES[newState] then
				setRagdollEnabled(humanoid, true)
			else
				setRagdollEnabled(humanoid, false)
			end
		end
	end)
end

function ragdollRemoved(humanoid)
	connections[humanoid]:Disconnect()
	connections[humanoid] = nil
end

collectionService:GetInstanceAddedSignal(TAG_NAME):Connect(ragdollAdded)
collectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(ragdollRemoved)
for _,humanoid in pairs(collectionService:GetTagged(TAG_NAME)) do
	ragdollAdded(humanoid)
end

return nil