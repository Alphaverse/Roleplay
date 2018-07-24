rp.adminlogs = {}
local adminlogs_event_stored = {}
local adminlogs_event_index = 0


-- Add an event to log
function rp.adminlogs.addevent(data)
	if not data then return end

	-- Add the data to the stored table
	adminlogs_event_index = adminlogs_event_index + 1
	adminlogs_event_stored[data.name] = data
	print("[RP]\tSetting up log event (" .. adminlogs_event_index .. ") '" .. data.name .. "'")

	-- Add the hooks if we have a name and function
	if data.hook and data.func then
		hook.Add(data.hook, "Log[" .. adminlogs_event_index .. "] " ..  data.hook, data.func)
	end
end

-- Get log event data from a name
function rp.adminlogs.getevent(eventname)
	return adminlogs_event_stored[eventname]
end

-- Get the log event color from a name
function rp.adminlogs.geteventcolor(eventname)
	local data = adminlogs_event_stored[eventname]
	if not data then return Color(255, 255, 255, 255) end
	return data.color or Color(255, 255, 255, 255)
end

-- Return all log events
function rp.adminlogs.getall()
	return adminlogs_event_stored
end


-- Tell the config to load our log events
hook.Run("LoadLogEvents")