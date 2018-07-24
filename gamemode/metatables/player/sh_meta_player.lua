local pMeta = FindMetaTable("Player")



-- Check a player's privileges
function pMeta:HasAccess(access)
	return string.find(self:GetAccess(), access) != nil
end

-- Check if a player has any restraints on them
function pMeta:IsRestrained()
	return self:GetRoped() or self:GetCuffed() or self:GetZiptied()
end

-- Return the appropiate pronoun
function pMeta:Pronoun()
	if self:GetGender() == "Male" then
		return "he"
	else
		return "she"
	end
end

-- Return the appropriate pronoun (possessive)
function pMeta:PronounPossessive()
	if self:GetGender() == "Male" then
		return "his"
	else
		return "her"
	end
end

-- Get whether a player is carrying a heavy weapon
function pMeta:IsCarryingHeavyWeapon()
	for _, v in pairs(self:GetWeapons()) do
		if v.IsHeavyWeapon and self:GetActiveWeapon() != v then
			return true
		end
	end

	return false
end