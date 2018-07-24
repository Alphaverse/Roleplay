rp.config = {}
local file = file
local pairs = pairs


-- Check if the config folder exists and create one if it doesn't
local function CheckForConfigFolder()
	if not file.Exists(GM_FOLDERNAME, "DATA") then
		print("[RP]\tCould not find configuration folder. Creating one now.")
		file.CreateDir(GM_FOLDERNAME)
	end
end

-- Load a client's data
function rp.config.loadclientdata()
	-- Check for config folder
	CheckForConfigFolder()

	-- Open config
	local data = file.Read(GM_FOLDERNAME .. "/config.txt", "DATA")
	print(Color(0, 255, 0), "\n[RP] Opening configuration data")
	if not data then return print(Color(255, 0, 0), "[RP] Could not open configuration data. Aborting.\n") end

	-- Read config
	local tab = util.JSONToTable(data)
	print(Color(0, 255, 0), "[RP] Reading configuration data")
	if not tab then return print(Color(255, 0, 0), "[RP] Could not read configuration data. Aborting.\n") end

	-- Load config values
	print(Color(0, 255, 0), "[RP] Loading configuration data:")
	for k, v in pairs(tab) do
		-- Only load values we want to load
		if rp.cfg["Config Values"][k] then
			print("[RP]\tLoading " .. tostring(v) .. " into " .. tostring(k))
			rp.cfg[k] = v
		end
	end
	print(Color(0, 255, 0), "[RP] Successfully loaded configuration data\n")
end

-- Save a client's data
function rp.config.saveclientdata()
	local vars = {}
	print(Color(0, 255, 0), "\n[RP] Saving configuration data:")

	-- Check for config folder
	CheckForConfigFolder()

	-- Load config values into the vars table...
	for k, _ in pairs(rp.cfg["Config Values"]) do
		print("[RP]\tSaving " .. tostring(rp.cfg[k]) .. " to " .. tostring(k))
		vars[k] = rp.cfg[k]
	end

	-- ...and write it to the 'config.txt' file
	file.Write(GM_FOLDERNAME .. "/config.txt", util.TableToJSON(vars))
	print(Color(0, 255, 0), "[RP] Successfully saved configuration data\n")
end

-- Delete a client's data
function rp.config.deleteclientdata()
	-- Check for config folder
	CheckForConfigFolder()

	-- Delete all files inside the config folder
	print(Color(255, 0, 0), "\n[RP] Deleting configuration data:")
	local files, _ = file.Find(GM_FOLDERNAME .. "/config.txt", "DATA")
	for _, v in pairs(files) do
		print("[RP]\tDeleting " .. v)
		file.Delete(GM_FOLDERNAME .. "/" .. v)
	end
	print(Color(0, 255, 0), "[RP] Successfully deleted configuration data\n")
end


--[[-------------------------------------------------------------------------
INITIALIZE
---------------------------------------------------------------------------]]
-- Check for config folder
CheckForConfigFolder()

-- Load config data
rp.config.loadclientdata()

-- Add hooks
hook.Add("ShutDown", "Save Client Config", function()
	rp.config.saveclientdata()
end)