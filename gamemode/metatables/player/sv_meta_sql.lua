local pMeta = FindMetaTable("Player")
local oldgetpdata = pMeta.GetPData
local oldsetpdata = pMeta.SetPData



-- Override GetPData
function pMeta:GetPData(key, default)
	-- Compability for addons
	if not rp.sql.iscolumn(db["Player Table"], key) then
		return oldgetpdata(key, default)
	end

	-- Return if we don't load
	if rp.cfg["Load disabled"] then return end

	-- Query
	local result = sql.Query("SELECT " .. key .. " FROM " .. db["Player Table"] .. " WHERE SteamID='" .. self:SteamID() .. "' LIMIT 1")

	-- Return default if query failed
	if not result then
		return default
	end

	-- Grab the value
	result = result[1][key]

	-- Return the proper Lua nil
	if result == nil or result == "NULL" or string.Trim(result) == "" then
		return nil
	end

	-- Convert to number if possible
	if tonumber(result) != nil then
		result = tonumber(result)
	end

	-- Return the result
	return result
end

-- Override SetPData
function pMeta:SetPData(key, value)
	-- Compability for addons
	if not rp.sql.iscolumn(db["Player Table"], key) then
		return oldsetpdata(key, value)
	end

	-- Return if we don't save
	if rp.cfg["Save disabled"] then return end

	-- Convert values to work with SQL
	if value == nil or string.Trim(value) == "" then
		value = "NULL"
	elseif isstring(value) and not tonumber(value) then
		value = rp.sql.escape(value)
	end

	-- Query
	sql.Query("UPDATE " .. db["Player Table"] .. " SET " .. key .. "=" .. value .. " WHERE SteamID='" .. self:SteamID() .. "'")
end

-- Additional check to see if an entry needs to be created
function pMeta:CheckSQLTable()
	local values = {}

	-- Loop through all columns
	for _, v in pairs(rp.sql.get(db["Player Table"])) do
		-- Exclude our SteamID
		if v.name == "SteamID" then
			table.insert(values, self:SteamID())
		else
			-- Grab the NSVar
			table.insert(values, self:GetNSVar(v.name, rp.cfg["Default " .. v.name]))
		end
	end

	-- Save our values to a new entry if needed
	if rp.cfg["Use MySQL"] then
		sql.Query("INSERT IGNORE INTO " .. db["Player Table"] .. "(" .. rp.sql.formattablesinsert(db["Player Table"]) .. ") VALUES(" .. rp.sql.formatvalues(values) .. ")")
	else -- This is as ridiculous as it looks like. Stupid database differences ...
		sql.Query("INSERT OR IGNORE INTO " .. db["Player Table"] .. "(" .. rp.sql.formattablesinsert(db["Player Table"]) .. ") VALUES(" .. rp.sql.formatvalues(values) .. ")")
	end
end

-- Load all PlayerData from DB
function pMeta:LoadData()
	for _, v in pairs(rp.sql.get(db["Player Table"])) do
		-- Exclude our SteamID value
		if v.name != "SteamID" then
			self:SetNSVar(v.name, self:GetPData(v.name, rp.cfg["Default " .. v.name]))
		end
	end
end

-- Save all PlayerData to DB
function pMeta:SaveData()
	-- Loop through all columns to save to
	for _, v in pairs(rp.sql.get(db["Player Table"])) do
		-- Exclude our SteamID value
		if v.name == "SteamID" then
			self:SetPData(v.name, self:SteamID())
		else
			self:SetPData(v.name, self:GetNSVar(v.name))
		end
	end
end



-- Add hooks
hook.Add("PlayerInitialSpawn", "Load PlayerData", function(ply)
	if not rp.cfg["Load disabled"] then
		print(Color(255, 0, 0), "[RP] Loading " .. ply:Name() .. "'s PlayerData")
		ply:CheckSQLTable()
		ply:LoadData()
		print(Color(0, 255, 0), "[RP] Successfully loaded " .. ply:Name() .. "'s PlayerData\n")
	else
		print(Color(255, 0, 0), "[RP] Did not load " .. ply:Name() .. "'s PlayerData as loading is disabled\n")
	end
end)

hook.Add("ShutDown", "Save PlayerData", function()
	if not rp.cfg["Save disabled"] then
		print(Color(255, 0, 0), "[RP] Saving PlayerData")
		for _, v in pairs(player.GetAll()) do
			print("[RP]\tSaving " .. v:Name() .. "'s PlayerData")
			v:SaveData()
		end
		print(Color(0, 255, 0), "[RP] Successfully saved PlayerData\n")
	else
		print(Color(255, 0, 0), "[RP] Did not save PlayerData as saving is disabled\n")
	end
end)
