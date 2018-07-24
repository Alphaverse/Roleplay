--[[-------------------------------------------------------------------------
Ragdolls

Because Garry's way of doing things didn't suffice for my needs.
We are now creating actual ragdolls and not just a nocollided replica.
This also works with the first person mode from cl_init.lua

Apart from ragdolling you can also do other stuff to people like:
	- Knocking them out
	- Injure them
	- Troll them

Be advised to proceed with caution...
---------------------------------------------------------------------------]]

local pMeta = FindMetaTable("Player")




-- Overwrite Player:CreateRagdoll() to fit our style
function pMeta:CreateRagdoll()
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetSkin(self:GetSkin())
	ragdoll:SetMaterial(self:GetMaterial())
	ragdoll:SetHealth(self:Health())
	ragdoll:SetHunger(self:GetHunger(), true)
	ragdoll:SetRagdollOwner(self)
	ragdoll:Spawn()
	self:SetRagdoll(ragdoll)

	-- Loop through each of the ragdoll's physics objects
	for i = 1, ragdoll:GetPhysicsObjectCount() do
		local physicsObject = ragdoll:GetPhysicsObjectNum(i)

		-- Check if the physics object is a valid entity
		if IsValid(physicsObject) then
			local position, angle = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
			-- Set the position and angle of the physics object, then add velocity to it
			physicsObject:SetPos(position)
			physicsObject:SetAngles(angle)
			physicsObject:AddVelocity(self:GetVelocity())
		end
	end

	hook.Run("CreateEntityRagdoll", self, ragdoll)

	return ragdoll
end

-- Ragdoll a player
function pMeta:Ragdoll()
	if self:GetRagdolled() then return end

	local ragdoll = self:CreateRagdoll()

	-- No collide with vehicle, if needed
	if self:InVehicle() and IsValid(self:GetVehicle()) then
		constraint.NoCollide(ragdoll, self:GetVehicle())
	end

	-- Drop weapon we held, if possible
	if self:GetActiveWeapon().ShouldDropOnDie then
		rp.item.drop(self, self:GetActiveWeapon(), 1, self:GetPos())
	end

	self:KillSilent()
	self:StripWeapons()
	self:Flashlight(false)
	self:SetRagdolled(true)

	return ragdoll
end

-- Unragdoll a player
function pMeta:UnRagdoll(NoReset)
	if not self:GetRagdolled() then return end

	if NoReset then
		self:SetRagdolled(false)
		return
	end

	local ragdoll = self:GetRagdoll()

	self:UnSpectate()
	self:LightSpawn()
	self:SetPos(ragdoll:GetPos())
	self:SetHealth(ragdoll:Health())
	self:SetModel(ragdoll:GetModel())
	self:SetSkin(ragdoll:GetSkin())
	self:SetMaterial(ragdoll:GetMaterial())
	self:SetHunger(ragdoll:GetHunger())
	self:SetStamina(0)
	self:SetRagdolled(false)

	ragdoll:Remove()
end

-- Knock out a player
function pMeta:KnockOut(seconds)
	if timer.Exists("knockout: " .. self:UniqueID()) then
		timer.Remove("knockout: " .. self:UniqueID())
	end

	if seconds then
		timer.Create("knockout: " .. self:UniqueID(), seconds, 1, function()
			self:UnKnockOut()
		end)
	end

	if self:GetKnockedOut() then return end

	self:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 3, 0)
	self:Ragdoll()
	self:SetKnockedOut(true)

	timer.Simple(3, function()
		self:SetNoRender(true)
	end)
end

-- Bring a player back to consciousness
function pMeta:UnKnockOut(reset)
	if not self:GetKnockedOut() then return end

	if reset then
		self:UnRagdoll()
	end

	self:SetNoRender(false)
	self:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.5, 0.1)
	self:SetKnockedOut(false)

	if timer.Exists("knockout: " .. self:UniqueID()) then
		timer.Remove("knockout: " .. self:UniqueID())
	end
end

-- Injure a player
function pMeta:Injure()
	if self:GetInjured() then return end

	self:Ragdoll()
	self:SetInjured(true)
	self:Bleed(true)
end

-- Revive a player
function pMeta:UnInjure(reset)
	if not self:GetInjured() then return end

	if reset then
		self:UnRagdoll()
	end

	self:SetInjured(false)
	self:Bleed(false)
end