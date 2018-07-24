hook.Add("LoadLogEvents", "Load Log Events", function()
	print(Color(255, 0, 0), "\n[RP] Setting up log events:")

	rp.adminlogs.addevent({
		name = "SPAWN",
		color = Color(0, 255, 0, 255),
		hook = "PostPlayerSpawn",
		func = function(ply)
			local t = team.GetName(ply:Team())

			if t == "" then
				ServerLog("SPAWN", ply:Nick() .. " (" .. ply:SteamID() .. ") has spawned")
			else
				ServerLog("SPAWN", ply:Nick() .. " (" .. ply:SteamID() .. ") has spawned as a " .. t)
			end
		end
	})

	rp.adminlogs.addevent({
		name = "KILL",
		color = Color(255, 0, 0, 255),
		hook = "PlayerDeath",
		func = function(victim, weapon, killer)
			if IsValid(weapon) and not weapon:IsRPVehicle() then
				if IsValid(killer) and killer:IsPlayer() then
					ServerLog("KILL", victim:Nick() .. " (" .. victim:SteamID() .. ") was killed by " .. killer:Nick() .. " (" .. killer:SteamID() .. ") using " .. tostring(weapon))
				else
					ServerLog("KILL", victim:Nick() .. " (" .. victim:SteamID() .. ") was killed by " .. tostring(weapon))
				end
			end
		end
	})

	rp.adminlogs.addevent({
		name = "DMG",
		color = Color(255, 255, 0, 255)
	})

	rp.adminlogs.addevent({
		name = "CDM",
		color = Color(255, 128, 0, 255),
		hook = "PlayerDeath",
		func = function(victim, weapon, killer)
			if IsValid(weapon) and weapon:IsRPVehicle() then
				local drivern, drivers

				if IsValid(weapon:GetDriver()) then
					drivern, drivers = weapon:GetDriver():Nick() or "*Unknown*", weapon:GetDriver():SteamID() or "*Unknown*"
				else
					drivern, drivers = "*Unknown*", "*Unknown*"
				end

				ServerLog("CDM", victim:Nick() .. " (" .. victim:SteamID() .. ") has been run over by " .. drivern .. " (" .. drivers .. ") using " .. weapon:GetModel())
			end
		end
	})

	rp.adminlogs.addevent({
		name = "COMMAND",
		color = Color(0, 128, 255, 255),
		hook = "PlayerUseCommand",
		func = function(ply, cmd, args)
			if #args > 0 then
				ServerLog("COMMAND", ply:Nick() .. " (" .. ply:SteamID() .. ") used command " .. cmd .. " with arguments " .. table.concat(args, ", "))
			else
				ServerLog("COMMAND", ply:Nick() .. " (" .. ply:SteamID() .. ") used command " .. cmd)
			end
		end
	})

	rp.adminlogs.addevent({
		name = "ITEMUSE",
		color = Color(0, 255, 255, 255)
	})

	rp.adminlogs.addevent({
		name = "ITEMDROP",
		color = Color(0, 255, 255, 255)
	})

	rp.adminlogs.addevent({
		name = "ITEMGIVE",
		color = Color(0, 255, 255, 255)
	})

	rp.adminlogs.addevent({
		name = "ITEMPICKUP",
		color = Color(0, 255, 255, 255)
	})

	rp.adminlogs.addevent({
		name = "ADMIN",
		color = Color(255, 0, 255, 255)
	})

	rp.adminlogs.addevent({
		name = "DISCONNECT",
		color = Color(255, 255, 255, 255),
		hook = "PlayerDisconnected",
		func = function(ply)
			ServerLog("DISCONNECT", ply:Nick() .. "(" .. ply:SteamID() .. ") has left the server")
		end
	})

	rp.adminlogs.addevent({
		name = "CONNECT",
		color = Color(255, 255, 255, 255),
		hook = "PlayerConnect",
		func = function(nick, ip)
			if SERVER then
				ip = ip or "none"
				ServerLog("CONNECT", nick .. " (" .. ip .. ") connected")
			end
		end
	})

	print(Color(0, 255, 0), "[RP] Finished setting up log events\n")
end)