rp.rank = {}

local pMeta = FindMetaTable("Player")
local rank_index = 0
local rank_stored = {}
local string = string
local table = table


-- Add a new rank
function rp.rank.add(data)
	-- Increase index by one
	-- Store the rank data
	rank_index = rank_index + 1
	rank_stored[rank_index] = data
	print("[RP]\tSetting up rank (" .. rank_index .. ") '" .. data.name .. "'")

	-- Check if we should check for a higher rank when asking the usergroup
	if data.check_for_higher_rank and rank_index != 1 then
		-- Higher rank is always the rank with the lower index
		local higherrank = rp.rank.get(rank_index - 1)

		-- Add metamethods
		if data.not_admin then
			pMeta["Is" .. data.name] = function(self)
				return self:GetSVRank() == string.lower(data.name) or self["Is" .. higherrank.name]
			end
		else
			pMeta["Is" .. data.name] = function(self)
				return (self:GetSVRank() == string.lower(data.name) or self["Is" .. higherrank.name]) and self:GetOnDuty()
			end
		end
	else
		-- Add metamethods
		if data.not_admin then
			pMeta["Is" .. data.name] = function(self)
				return self:GetSVRank() == string.lower(data.name)
			end
		else
			pMeta["Is" .. data.name] = function(self)
				return self:GetSVRank() == string.lower(data.name) and self:GetOnDuty()
			end
		end
	end

	-- Return the name
	return string.lower(data.name)
end

-- Get a rank from an index or name
function rp.rank.get(name, playerToNotify)
	local r = nil
	local foundranks = {}

	-- Check if we can make it a number (index)
	if tonumber(name) then
		return rank_stored[name]
	else
		-- Check all stored ranks for a matching name
		for _, v in pairs(rank_stored) do
			-- Check for exact match
			if string.lower(v.name) == string.lower(name) then
				return v
			-- Check for partial match
			elseif string.find(string.lower(v.name), string.lower(name)) then
				if r == nil then
					r = v
					table.insert(foundranks, v)
				else
					r = false
					table.insert(foundranks, v)
				end
			end
		end
	end

	-- Safety check incase no rank was found
	if r == nil then
		r = false
		foundranks = {}
	end

	-- Do everything if we have someone to notify
	if playerToNotify then -- Can either be a player or a bool (true)
		-- Check if we have a valid rank
		if r then
			return r
		-- Check if we had more than one rank
		elseif #foundranks > 0 then
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("Multiple ranks found: " .. rp.rank.rankstostring(foundranks), NOTIFY_ERROR)
			end

			return false
		-- Check if we found anything at all
		else
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("This is not a valid rank!", NOTIFY_ERROR)
			end

			return false
		end
	end

	-- Return the rank that we found
	return r, foundranks
end

-- Get all ranks
function rp.rank.getall()
	return rank_stored
end

-- Format a table of teams into a string
function rp.rank.rankstostring(ranks)
	local names = {}

	for _, v in pairs(ranks) do
		table.insert(names, v.name .. " (" .. v.index .. ")")
	end

	return string.Implode(", ", names)
end


-- Override metafunctions to work with the rank system
function pMeta:IsRank(rank)
	return self:GetSVRank() == rank
end

function pMeta:IsUserGroup(rank)
	return self:GetSVRank() == rank
end

function pMeta:GetUserGroup()
	return self:GetSVRank()
end



-- Tell the config to load our ranks
hook.Run("LoadRanks")