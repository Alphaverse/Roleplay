local door = FindMetaTable("Entity")


-- Let it rip
function door:BreachDoor(breachpos)
	if self:IsValid() and self:IsDoor() then
		self:EmitSound(Sound("physics/wood/wood_box_impact_hard3.wav"))
		self:SetNotSolid(true)
		self:SetNoDraw(true)
		self:SetMoveType(MOVETYPE_NONE)
		self:Unlock()

		local push = 10000 * (self:GetPos() - breachpos):GetNormalized()
		local fakedoor = ents.Create("prop_physics")
		fakedoor:SetPos(self:GetPos())
		fakedoor:SetAngles(self:GetAngles())
		fakedoor:SetModel(self:GetModel())
		fakedoor:SetSkin(self:GetSkin())
		fakedoor:Spawn()
		fakedoor:SetVelocity(push)
		fakedoor:GetPhysicsObject():ApplyForceCenter(push)

		timer.Simple(rp.cfg["Remove breached Door"], function()
			if IsValid(self) then
				self:SetNotSolid(false)
				self:SetNoDraw(false)
				self:SetMoveType(MOVETYPE_PUSH)
			end

			if IsValid(fakedoor) then
				fakedoor:Remove()
			end
		end)
	end
end

-- Unlocks a door/vehicle
function door:Unlock()
	self:Fire("unlock")
end

-- Locks a door/vehicle
function door:Lock()
	self:Fire("lock")
end
