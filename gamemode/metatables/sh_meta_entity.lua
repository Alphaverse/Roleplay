local eMeta = FindMetaTable("Entity")

-- Check to see if the entity is a door
function eMeta:IsDoor()
	return rp.cfg["Valid Doors"][self:GetClass()]
end

-- Check to see if the entity is an item
function eMeta:IsItem()
	return self:GetClass() == "rp_item"
end

-- Check to see if the entity is money
function eMeta:IsMoney()
	return self:GetItemName() == "Money"
end

-- Check to see if the entity is an actual vehicle (because Garry counts chairs as vehicles - WTF?)
function eMeta:IsRPVehicle()
	return self:GetClass() == "prop_vehicle_jeep"
end