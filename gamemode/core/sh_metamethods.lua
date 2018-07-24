--[[------------------------------------------------------------------------------------
The Network Shared Variable system

This system allows you to easily set and get unique variables for entities.
These variables are available on both CLIENT and SERVER as they are networked from
SERVER to CLIENT. You cannot network from CLIENT to SERVER due to security reasons.
After all, this system is used for ranks. As long as you don't wanteveryone to be
an admin (and change other values) on your server it should be that way.


The code looks like this:

local ent = Entity(1)
ent:SetNSVar("Stamina", 100)  		// Sets the value 'Stamina' to '100'
print(ent:GetNSVar("Stamina")) 		// Prints '100' into the console



However, as we are editing the entity's metatable here, you can also say:

local ent = Entity(1)
ent:SetStamina(100)					// Sets the value 'Stamina' to '100'
print(ent:GetStamina())				// Prints '100' into the console



The syntax is:

Entity:SetStamina(value, ShouldNotNetwork) and
Entity:GetStamina(default)

-- Entity is the Class this function is called on
-- value is the value that is to be assigned
-- ShouldNotNetwork will prevent the variable from getting networked from SERVER to CLIENT
-- default is the fallback value incase we found nil




Setting the ShouldNotNetwork parameter is optional. It will network by default.
It is also not needed to set this parameter on the CLIENT as it will not be
networked either way.
The default parameter is also optional but useful, if you expect nil to be returned.
If the default parameter is nil and anil value is found it will return the default value
from the configuration (rp.cfg["Default " .. varname])

I strongly advise not to put in a table as a value as the current way the
Garry's Mod net library handles tables is inefficient and redundant.
Instead write each variable on its own.


Garry's Mod also has a built in way to network Entities.
It however only has a limit of 32 Variables at max (4, if they are strings) so we
use this instead.   ->   http://wiki.garrysmod.com/page/Networking_Entities
--------------------------------------------------------------------------------------]]
local eMeta = FindMetaTable("Entity")
local pMeta = FindMetaTable("Player")
local wMeta = FindMetaTable("Weapon")
local vMeta = FindMetaTable("Vehicle")

local cfg = rp.cfg
local net = net
local string = string
local vars = {}


-- Networking stuff
if SERVER then
	-- Adding network messages
	util.AddNetworkString("rp_global")
	util.AddNetworkString("rp_nsvar")
else
	-- Applying the given value globally (CLIENT ONLY)
	net.Receive("rp_global", function()
		local varname = net.ReadString()
		local value = net.ReadType()

		vars[varname] = value
	end)

	-- Applying the given values to an ent (CLIENT ONLY)
	net.Receive("rp_nsvar", function()
		local ent = net.ReadEntity()
		local varname = net.ReadString()
		local value = net.ReadType()

		ent[varname] = value
	end)
end


-- Retrieve a global variable
function GetGlobal(varname, default)
	if vars[varname] == nil then
		vars[varname] = default
	end

	return vars[varname]
end

-- Set a global variable
function SetGlobal(varname, value, ShouldNotNetwork)
	vars[varname] = value

	if SERVER and not ShouldNotNetwork then
		net.Start("rp_global")
			net.WriteString(varname)
			net.WriteType(value)
		net.Broadcast()
	end
end


-- Retrieve a variable
function eMeta:GetNSVar(varname, default)
	if self[varname] == nil then
		if default == nil then
			self[varname] = cfg["Default " .. varname]
		else
			self[varname] = default
		end
	end

	return self[varname]
end

-- Set a variable (set ShouldNotNetwork to true to not network it)
function eMeta:SetNSVar(varname, value, ShouldNotNetwork)
	-- Don't do anything if it already is the same (saves unnecessary networking)
	if self[varname] == value then return end

	self[varname] = value

	if SERVER and not ShouldNotNetwork then
		net.Start("rp_nsvar")
			net.WriteEntity(self)
			net.WriteString(varname)
			net.WriteType(value)
		net.Broadcast()
	end
end


-- Locals for faster access
local getnsvar = eMeta.GetNSVar
local setnsvar = eMeta.SetNSVar

-- Entity index accessor
function eMeta:__index(key)
	local val = nil

	-- Search the metatable
	val = eMeta[key]
	if val != nil then return val end

	-- Search the entity table
	local tab = eMeta.GetTable(self)
	if tab != nil then
		val = tab[key]
		if val != nil then return val end
	end


	-- You really shouldn't change this or else everything will break
	-- This code handles Entity:Get<variable name> and Entity:Set<variable name>
	-- with <variable name> being any variable you would like to manipulate on this entity
	--
	-- Thanks
	--			Arkten
	if string.sub(key, 1, 3) == "Get" then
		local func = function(ent, default)
			return getnsvar(ent, string.sub(key, 4), default)
		end

		return func
	elseif string.sub(key, 1, 3) == "Set" then
		local func = function(ent, value, netbool)
			return setnsvar(ent, string.sub(key, 4), value, netbool)
		end

		return func
	end

	-- Backwards compatibility
	if key == "Owner" then return eMeta.GetOwner(self) end

	return nil
end

-- Player index accessor
function pMeta:__index(key)
	local val = nil

	-- Search the metatable
	val = pMeta[key]
	if val != nil then return val end

	-- Search the entity metatable
	val = eMeta[key]
	if val != nil then return val end

	-- Search the entity table
	local tab = eMeta.GetTable(self)
	if tab != nil then
		val = tab[key]
		if val != nil then return val end
	end


	-- You really shouldn't change this or else everything will break
	-- This code handles Entity:Get<variable name> and Entity:Set<variable name>
	-- with <variable name> being any variable you would like to manipulate on this entity
	--
	-- Thanks
	--			Arkten
	if string.sub(key, 1, 3) == "Get" then
		local func = function(ply, default)
			return getnsvar(ply, string.sub(key, 4), default)
		end

		return func
	elseif string.sub(key, 1, 3) == "Set" then
		local func = function(ply, value, netbool)
			return setnsvar(ply, string.sub(key, 4), value, netbool)
		end

		return func
	end

	return nil
end

-- Weapon index accessor
function wMeta:__index(key)
	local val = nil

	-- Search the metatable
	val = wMeta[key]
	if val != nil then return val end

	-- Search the entity metatable
	val = eMeta[key]
	if val != nil then return val end


	-- You really shouldn't change this or else everything will break
	-- This code handles Entity:Get<variable name> and Entity:Set<variable name>
	-- with <variable name> being any variable you would like to manipulate on this entity
	--
	-- Thanks
	--			Arkten
	if string.sub(key, 1, 3) == "Get" and key != "GetViewModelPosition" then -- Yup, i know. Thx garry.
		local func = function(wep, default)
			return getnsvar(wep, string.sub(key, 4), default)
		end

		return func
	elseif string.sub(key, 1, 3) == "Set" then
		local func = function(wep, value, netbool)
			return setnsvar(wep, string.sub(key, 4), value, netbool)
		end

		return func
	end

	-- Search the entity table
	local tab = eMeta.GetTable(self)
	if tab != nil then
		val = tab[key]
		if val != nil then return val end
	end

	-- Backwards compatibility
	if key == "Owner" then return eMeta.GetOwner(self) end

	return nil
end

-- Vehicle index accessor
function vMeta:__index(key)
	local val = nil

	-- Search the metatable
	val = vMeta[key]
	if val != nil then return val end

	-- Search the entity metatable
	val = eMeta[key]
	if val != nil then return val end


	-- You really shouldn't change this or else everything will break
	-- This code handles Entity:Get<variable name> and Entity:Set<variable name>
	-- with <variable name> being any variable you would like to manipulate on this entity
	--
	-- Thanks
	--			Arkten
	if string.sub(key, 1, 3) == "Get" then
		local func = function(veh, default)
			return getnsvar(veh, string.sub(key, 4), default)
		end

		return func
	elseif string.sub(key, 1, 3) == "Set" then
		local func = function(veh, value, netbool)
			return setnsvar(veh, string.sub(key, 4), value, netbool)
		end

		return func
	end

	-- Search the entity table
	local tab = eMeta.GetTable(self)
	if tab != nil then
		val = tab[key]
		if val != nil then return val end
	end

	return nil
end