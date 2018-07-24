-- Normal clientside config values
rp.cfg["TargetID"] = rp.cfg["Talk Radius"]
rp.cfg["Allowed HUD Elements"] = {}
rp.cfg["Allowed HUD Elements"]["CHudChat"] = true
rp.cfg["Allowed HUD Elements"]["CHudGMod"] = true
rp.cfg["Allowed HUD Elements"]["CHudMenu"] = true
rp.cfg["Allowed HUD Elements"]["CHudWeaponSelection"] = true
rp.cfg["Allowed HUD Elements"]["NetGraph"] = true
rp.cfg["HUDPaint"] = "Trebuchet24"


-- Values that are loaded from the client_config.txt
-- Default values incase file is corrupt/broken/whatever
rp.cfg["Low Quality Mode"] = rp.cfg["Low Quality Mode"] or false
rp.cfg["First Person Mode"] = rp.cfg["First Person Mode"] or false


rp.cfg["Config Values"] = {}
rp.cfg["Config Values"]["Low Quality Mode"] = true
rp.cfg["Config Values"]["First Person Mode"] = true

concommand.Add("low_qual", function(ply, cmd, args, argstr)
	rp.cfg["Low Quality Mode"] = !rp.cfg["Low Quality Mode"]
end)

concommand.Add("first_person_mode", function(ply, cmd, args, argstr)
	rp.cfg["First Person Mode"] = !rp.cfg["First Person Mode"]
end)