rp.player = {}

local pairs = pairs
local string = string
local table = table


-- Get a player by a part of their name or their UserID/SteamID
function rp.player.get(name, playerToNotify)
	local p = nil
	local foundnames = {}

	-- Check if the name is a UserID or SteamID
	if tonumber(name) and IsValid(Player(tonumber(name))) then
		return Player(tonumber(name))
	elseif string.find(string.upper(name), "STEAM_") and player.GetBySteamID(name) then
		return player.GetBySteamID(name)
	end

	for _, v in pairs(player.GetAll()) do
		-- Check if a player's name partially matches
		if string.lower(v:Name()) == string.lower(name) then
			return v
		elseif string.find(string.lower(v:Name()), string.lower(name)) then
			if p == nil then
				p = v
				table.insert(foundnames, v)
			else
				p = false
				table.insert(foundnames, v)
			end
		end
	end

	-- Safety check incase no player was found
	if p == nil then
		p = false
		foundnames = {}
	end

	-- Do everything if we have someone to notify
	if playerToNotify then -- Can either be a player or a bool (true)
		-- Check if we have a valid player
		if p then
			return p
		-- Check if we had more than one player
		elseif #foundnames > 0 then
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("Multiple users found: " .. rp.player.playerstostring(foundnames), NOTIFY_ERROR)
			end

			return false
		-- Check if we found anything at all
		else
			if IsEntity(playerToNotify) and playerToNotify:IsPlayer() then
				playerToNotify:Notify("This is not a valid player!", NOTIFY_ERROR)
			end

			return false
		end
	end

	return p, foundnames
end

-- Format a table of players to a string
function rp.player.playerstostring(players)
	local names = {}

	for _, v in pairs(players) do
		table.insert(names, v:Nick() .. " (" .. v:UserID() .. ")")
	end

	return string.Implode(", ", names)
end