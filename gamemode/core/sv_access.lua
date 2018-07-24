--[[-------------------------------------------------------------------------
Access

The access flags work by adding or removing a char to a player's string.
When we need to check a player's access we look for that access flag (char)
in that string and if we find it, they have that access.
If we don't they don't.

What access flag covers what is essentially up to you, but I have put my
standards into the sh_config for reference.
---------------------------------------------------------------------------]]
-- Access flags as used by commands
-- Please only add values
-- Changing the current values might break the gamemode
rp.cfg["Access Flags"] = {}
rp.cfg["Access Flags"]["*"] = "owner"
rp.cfg["Access Flags"]["b"] = "everyone"
rp.cfg["Access Flags"]["z"] = "superadmin"
rp.cfg["Access Flags"]["d"] = "developer"
rp.cfg["Access Flags"]["a"] = "admin"
rp.cfg["Access Flags"]["m"] = "moderator"

rp.cfg["Access Flags"]["v"] = "Vehicles"
rp.cfg["Access Flags"]["w"] = "Weapons"
rp.cfg["Access Flags"]["y"] = "Advert"

rp.cfg["Access Flags"]["p"] = "President"
rp.cfg["Access Flags"]["x"] = "F.B.I."
rp.cfg["Access Flags"]["s"] = "S.W.A.T."
rp.cfg["Access Flags"]["o"] = "Police Officer"
rp.cfg["Access Flags"]["l"] = "Paramedic"
rp.cfg["Access Flags"]["f"] = "Fireman"
rp.cfg["Access Flags"]["k"] = "Dispatch"
rp.cfg["Access Flags"]["c"] = "Chef"
rp.cfg["Access Flags"]["h"] = "Doctor"
rp.cfg["Access Flags"]["g"] = "Gun Dealer"
rp.cfg["Access Flags"]["n"] = "Mechanic"

rp.cfg["Normal Access"] = "b"





local pMeta = FindMetaTable("Player")

-- Give a player access
function pMeta:GiveAccess(access)
	self:SetAccess(self:GetAccess() .. access)
end

-- Revoke a player's access
function pMeta:RevokeAccess(access)
	self:SetAccess(string.gsub(self:GetAccess(), access, ""))
end

-- Make a player go on duty
function pMeta:GoOnDuty(rank)
	self:SetNotSolid(true)
	self:GodEnable()
	self:StripWeapons()
	self:StripAmmo()
	self:Give("weapon_physgun")
	self:SetRenderMode(RENDERMODE_NONE)
	self:SetWeaponColor(Vector(0, 1, 0))

	for _, v in pairs(self:GetWeapons()) do
		v:SetRenderMode(RENDERMODE_NONE)
		v:SetColor(Color(0, 255, 0, 0))
	end

	self:SetAccess(rank.access)
	self:SetOnDuty(true)
	ServerLog("ADMIN", self:Nick() .. " (" .. self:SteamID() .. ") is now on duty")
end

-- Make a player go off duty
function pMeta:GoOffDuty()
	self:SetNotSolid(false)
	self:GodDisable()
	self:StripWeapon("weapon_physgun")
	self:SetRenderMode(RENDERMODE_NORMAL)

	for _, v in pairs(self:GetWeapons()) do
		v:SetRenderMode(RENDERMODE_NORMAL)
	end

	self:SetAccess(rp.cfg["Default Access"])
	self:SetOnDuty(false)
	self:Spawn()
	ServerLog("ADMIN", self:Nick() .. " (" .. self:SteamID() .. ") is now off duty")
end


-- Make admins go off duty when they disconnect
hook.Add("PlayerDisconnected", "Go off duty when disconnecting", function(ply)
	if ply:GetOnDuty() then
		ply:GoOffDuty()
	end
end)