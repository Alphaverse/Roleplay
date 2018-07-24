rp.team = {}

local team_index = 0
local team_stored = {}
local string = string
local table = table
local tonumber = tonumber


-- Add a new team
function rp.team.add(data)
	-- Increase index by one
	-- Store the team data
	team_index = team_index + 1
	data.index = team_index
	team_stored[team_index] = data
	team.SetUp(team_index, data.name, data.color)
	print("[RP]\tSetting up team (" .. team_index .. ") '" .. data.name .. "'")

	return data.index
end

-- Get a team from an index or name
function rp.team.get(name, playerToNotify)
	local t = nil
	local foundteams = {}

	-- Check if we can make it a number (index)
	if tonumber(name) then
		return team_stored[name]
	else
		-- Check all stored teams for a matching name
		for _, v in pairs(team_stored) do
			-- Check for exact match
			if string.lower(v.name) == string.lower(name) then
				return v
				--Check for partial match
			elseif string.find(string.lower(v.name), string.lower(name)) then
				if t == nil then
					t = v
					table.insert(foundteams, v)
				else
					t = false
					table.insert(foundteams, v)
				end
			end
		end
	end

	-- Safety check incase no team was found
	if t == nil then
		t = false
		foundteams = {}
	end

	-- Do everything if we have someone to notify
	if playerToNotify then -- Can either be a player or a bool (true)
		-- Check if we have a valid team
		if t then
			return t
		-- Check if we had more than one team
		elseif #foundteams > 0 then
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("Multiple teams found: " .. rp.team.teamstostring(foundteams), NOTIFY_ERROR)
			end

			return false
		-- Check if we found anything at all
		else
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("This is not a valid team!", NOTIFY_ERROR)
			end

			return false
		end
	end

	-- Return the team that we found
	return t, foundteams
end

-- Get all teams
function rp.team.getall()
	return team_stored
end

-- Format a table of teams into a string
function rp.team.teamstostring(teams)
	local names = {}

	for _, v in pairs(teams) do
		table.insert(names, v.name .. " (" .. v.index .. ")")
	end

	return string.Implode(", ", names)
end



-- Tell the config to load our teams
hook.Run("LoadTeams")