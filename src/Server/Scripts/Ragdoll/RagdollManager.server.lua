--[[
	This is a test file to demonstrate how ragdolls work. If you don't use
	this file, you need to manually apply the Ragdoll tag to humanoids that
	you want to ragdoll
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local buildRagdoll = require(ReplicatedStorage:WaitForChild("buildRagdoll"))

local RAGDOLLS_PERSIST = false

-- Trying to clone something with Archivable=false will return nil for some reason
-- Helper function to enable Archivable, clone, reset Archivable to what it was before
-- and then return the clone
function safeClone(instance)
	local oldArchivable = instance.Archivable
	
	instance.Archivable = true
	local clone = instance:Clone()
	instance.Archivable = oldArchivable
	
	return clone
end

function characterAdded(player, character)
	player.CharacterAppearanceLoaded:wait()
	wait(0.1)
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	buildRagdoll(humanoid)
end

function characterRemoving(character)
	if RAGDOLLS_PERSIST then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			return
		end

		local clone = safeClone(character)
		local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")

		-- Don't clutter the game with nameplates / healthbars
		cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		-- Roblox will try to rebuild joints when the clone is parented to Workspace and
		-- break the ragdoll, so disable automatic scaling to prevent that. We don't need
		-- it anyway since the character is already scaled from when it was originally created
		cloneHumanoid.AutomaticScalingEnabled = false
		
		-- Clean up junk so we have less scripts running and don't have ragdolls
		-- spamming random sounds
		local animate = character:FindFirstChild("Animate")
		local sound = character:FindFirstChild("Sound")
		local health = character:FindFirstChild("Health")
		
		if animate then
			animate:Destroy()
		end
		if sound then
			sound:Destroy()
		end
		if health then
			health:Destroy()
		end
		
		clone.Parent = workspace
		
		-- State is not preserved when cloning. We need to set it back to Dead or the
		-- character won't ragdoll. This has to be done AFTER parenting the character
		-- to Workspace or the state change won't replicate to clients that can then
		-- start simulating the character if they get close enough
		cloneHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end

function playerAdded(player)
	player.CharacterAdded:connect(function(character)
		characterAdded(player, character)
	end)
	
	player.CharacterRemoving:Connect(characterRemoving)
	
	if player.Character then
		characterAdded(player, player.Character)
	end
end

Players.PlayerAdded:connect(playerAdded)
-- Ugly hack because sometimes PlayerAdded doesn't fire in play solo
for _,player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end
