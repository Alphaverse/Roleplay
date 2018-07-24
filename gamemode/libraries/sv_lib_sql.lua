rp.sql = {}
local sql_stored = {}
local sql_columns = {}
local oldquery = sql.Query



-- Overwrite sql.Query for better debugging
function sql.Query(...)
	-- Check for MySQL
	if rp.cfg["Use MySQL"] then
		-- Get query object from mysqloo
		local q = DB:query(...)

		-- Return if we have no query object
		if not q then return end

		-- Print error on failure
		function q:onError(err, query)
			print(Color(255, 0, 0), "[MySQL] Error: ", err)
			print(Color(255, 0, 0), "[MySQL] Query: ", query)
			debug.Trace()
		end

		-- Perform query
		q:start()

		-- Wait for the query to finish
		q:wait()

		-- Return query results
		return q:getData()
	else
		-- Perform query
		local success = oldquery(...)

		-- Print error on failure
		if success == false then
			print(Color(255, 0, 0), "[SQLite] Error: ", sql.LastError())
			print(Color(255, 0, 0), "[SQLite] Query: ", ...)
			debug.Trace()
		end

		-- Return value
		return success
	end
end

-- Add an sql data structure
function rp.sql.add(data)
	-- Add data structure to table
	sql_stored[data.name] = data.columns

	-- Add columns to table
	sql_columns[data.name] = {}
	for _, v in pairs(data.columns) do
		sql_columns[data.name][v.name] = true
	end

	-- Push changes to the DB
	print("[RP]\tSetting up database table '" .. data.name .. "'")
	sql.Query("CREATE TABLE IF NOT EXISTS " .. data.name .. "(" .. rp.sql.formattablescreate(data.name) .. ")")
end

-- Get the table columns
function rp.sql.get(tbl_name)
	return sql_stored[tbl_name]
end

-- Get all tables
function rp.sql.getall()
	return sql_stored
end

-- Check if a column of a table exists
function rp.sql.iscolumn(tbl, column)
	return sql_columns[tbl][column]
end

-- Escape function to escape dangerous strings
function rp.sql.escape(str)
	if rp.cfg["Use MySQL"] then
		-- Escape for MySQL
		return "'" .. DB:escape(str) .. "'"
	else
		-- Escape for SQLite
		return sql.SQLStr(str)
	end
end

-- Format the table parameters for table creation
function rp.sql.formattablescreate(tbl_name)
	local tbl = sql_stored[tbl_name]
	local str = ""

	-- Return nothing if our table failed
	if not tbl then return str end

	-- Loop through all columns
	for k, v in pairs(tbl) do
		-- Add our name and type
		str = str .. v.name .. " " .. v.type

		-- Add the NOT NULL identifier
		if v.not_null then
			str = str .. " NOT NULL"
		end

		-- Add the PRIMARY KEY identifier
		if v.primary_key then
			str = str .. " PRIMARY KEY"
		end

		-- Add a , if we have another element
		if tbl[k + 1] then
			str = str .. ", "
		end
	end

	-- Return value
	return str
end

-- Format the table parameters for insertion
function rp.sql.formattablesinsert(tbl_name)
	local tbl = sql_stored[tbl_name]
	local str = ""

	-- Return nothing if our table failed
	if not tbl then return str end

	-- Loop through all columns
	for k, v in pairs(tbl) do
		-- Add our column
		str = str .. v.name

		-- Add a , if we have another element
		if tbl[k + 1] then
			str = str .. ", "
		end
	end

	-- Return value
	return str
end

-- Format the values for updating
function rp.sql.formatvalues(data)
	-- Return nothing if we have no data
	if not data then return "" end

	-- Check if our data is a table of values or just a single value
	if istable(data) then
		local str = ""

		-- Loop through all data
		for k, v in pairs(data) do
			-- Check for invalid input
			if v == nil or string.Trim(v) == "" then
				str = str .. "NULL"
			-- Escape strings
			elseif isstring(v) then
				str = str .. rp.sql.escape(v)
			else
				str = str .. tostring(v)
			end

			-- Add a , if we have another element
			if data[k + 1] then
				str = str .. ", "
			end
		end

		-- Return our string
		return str
	else
		-- Check for invalid input
		if not IsValid(data) or data == nil or string.Trim(data) == "" then
			return "NULL"
		-- Escape strings
		elseif isstring(data) then
			return rp.sql.escape(data)
		end

		-- Return our input as a string
		return tostring(data)
	end
end





--[[-------------------------------------------------------------------------
MySQL Database (mysqloo)
---------------------------------------------------------------------------]]
-- Connect to MySQL database if we use MySQL
if rp.cfg["Use MySQL"] and not rp.cfg["Load disabled"] then
	-- Require mysqloo module
	require("mysqloo")

	-- Local variables
	local host = db["MySQL Host"]
	local username = db["MySQL Username"]
	local password = db["MySQL Password"]
	local database = db["MySQL Database"]
	local port = db["MySQL Port"]

	-- Retieve a database object from mysqloo
	DB = mysqloo.connect(host, username, password, database, port)

	-- Define what happens if the connection succeeds
	DB.onConnected = function()
		print(Color(0, 255, 0), "\n[MySQL] Successfully established connection to database!\n")
	end

	-- Define what happens if the connection fails
	DB.onConnectionFailed = function(_, err)
		print(Color(255, 0, 0), "\n[MySQL] Connection to database failed: ", err, "\n")
	end

	-- Connect to the database
	DB:connect()

	-- Add hook to check if the database is still up
	hook.Add("DatabaseSave", "PingDatabase", function()
		DB:ping()
	end)
end



-- Tell the gamemode to load the SQL Database config
hook.Run("LoadSQL")