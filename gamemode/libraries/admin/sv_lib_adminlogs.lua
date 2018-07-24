local adminlogs_stored = {}
local sv_log = ServerLog
util.AddNetworkString("rp_adminlog_addlogline")


-- Override ServerLog to fit our log system
function ServerLog(event, text)
	-- Backwards compatibility
	if not rp.adminlogs.getall()[event] then return sv_log(event, text) end

	-- Grab date and event color
	local date = tostring(os.date())
	local color = rp.adminlogs.geteventcolor(event)

	-- Store data
	text = text or ""
	adminlogs_stored[event] = adminlogs_stored[event] or {}
	adminlogs_stored[event][date] = text

	-- Draw in server console
	MsgC(color, "[" .. date .. "]  [" .. event .. "]\t", text, "\n")

	-- Notify all admins about this event
	for _, v in pairs(player.GetAll()) do
		if v:IsModerator() then
			net.Start("rp_adminlog_addlogline")
				net.WriteString(event)
				net.WriteString(text)
			net.Send(v)
		end
	end
end


-- Add hooks
hook.Add("ShutDown", "Save logs", function()
	print(Color(255, 0, 0), "[RP] Saving logs")
	for k1, v1 in pairs(adminlogs_stored) do
		print("[RP]\tSaving " .. k1 .. " events")
		for k2, v2 in pairs(v1) do
			sql.Query("INSERT INTO " .. db["Log Table"] .. "(" .. rp.sql.formattablesinsert(db["Log Table"]) .. ") VALUES('" .. k1 .. "', '" .. k2 .. "', '" .. v2 .. "')")
		end
	end
	print(Color(0, 255, 0), "[RP] Successfully saved logs\n")
end)