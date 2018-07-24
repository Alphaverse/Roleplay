--[[---------------------------------------------------------------------------------
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! IF YOU DO NOT KNOW WHAT YOU ARE DOING, DO NOT TOUCH THIS FILE! IT IS LIKELY !!!
!!!  THAT YOU DO NOT WANT TO CHANGE SOMETHING IN HERE BUT IN THE CONFIG FOLDER  !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Now, that we got that bombshell out of the way, let me explain you this file.
All it really does is including/AddCSLuaFile'ing files from the core folders
based on their file tag. The load order, in which files are loaded, is important.

The file tag stands in front of a file that is to be loaded (eg. 'sv_myscript.lua').
These are the file tags to use:

sv_ - for a serversided file
sh_ - for a shared file
cl_ - for a clientsided file


You also can disable certain contributions/plugins by adding the foldername
or filename to the specific table here.
-----------------------------------------------------------------------------------]]


-- Make print really cool
function print(...)
	MsgC(Color(255, 255, 0), ...) -- Need to use ... as the input can be varargs
	MsgC("\n") -- After ... must not be anything
end

-- Initializing notice
if SERVER then
	print("[RP] Initializing shared on serverside")
else
	print("[RP] Initializing shared on clientside")
end

-- GM Info
GM.Name = "Roleplay"
GM.Author = "Arkten"
GM.Email = "n/a"
GM.Website = "n/a"
GM_FOLDERNAME = GM.FolderName

-- Create global tables
rp = {}
rp.cfg = {}
db = {}

-- Enable/disable plugins/contributions
local USE_PLUGINS = false
local USE_CONTRIBUTIONS = false

-- Loop through core files/folders and include them
local function includeCore(path)
	local files, folders = file.Find(GM_FOLDERNAME .. "/gamemode/" .. path .. "/*", "LUA")
	print(Color(255, 0, 0), "\n[RP] Loading " .. path .. "/")

	for _, v in pairs(files) do
		if string.sub(v, 1 , 3) == "cl_" or string.sub(v, 1 , 3) == "sh_" or string.sub(v, 1 , 3) == "sv_" then
			print(Color(0, 255, 0), "[RP] Loading " .. path .. "/" .. v)

			if SERVER then
				if string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_" then
					AddCSLuaFile(path .. "/" .. v)
				end

				if string.sub(v, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_" then
					include(path .. "/" .. v)
				end
			else
				if string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_" then
					include(path .. "/" .. v)
				end
			end
		end
	end

	for _, v in pairs(folders) do
		if v != "." and v != ".." then
			includeCore(path .. "/" .. v)
		end
	end
end

-- Load essential gamemode files
includeCore("config")
includeCore("core")
includeCore("libraries")
includeCore("metatables")
includeCore("commands")
includeCore("vgui")
includeCore("items")

-- Loop through special files/folders and include them
local function includeSpecial(path, exceptions, datatable)
	local files, folders = file.Find(GM_FOLDERNAME .. "/gamemode/" .. path .. "/*", "LUA")
	print(Color(255, 0, 0), "\n[RP] Loading " .. path .. "/")

	for _, v in pairs(files) do
		if (string.sub(v, 1 , 3) == "cl_" or string.sub(v, 1 , 3) == "sh_" or string.sub(v, 1 , 3) == "sv_") and not exceptions[v] then
			print(Color(0, 255, 0), "[RP] Loading " .. path .. "/" .. v)

			if SERVER then
				if string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_" then
					AddCSLuaFile(path .. "/" .. v)
				end

				if string.sub(v, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_" then
					include(path .. "/" .. v)
				end
			else
				if string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_" then
					include(path .. "/" .. v)
				end
			end
		end
	end

	for _, v in pairs(folders) do
		if v != "." and v != ".." and not exceptions[v] then
			table.insert(datatable, v)
			includeSpecial(path .. "/" .. v, exceptions, datatable)
		end
	end
end

-- Load plugins if enabled
if USE_PLUGINS then
	PLUGINS = {}
	DISABLED_PLUGINS = {}

	includeSpecial("plugins", DISABLED_PLUGINS, PLUGINS) -- Needs to be the plugins foldername
end

-- Load contributions if enabled
if USE_CONTRIBUTIONS then
	CONTRIBUTIONS = {}
	DISABLED_CONTRIBUTIONS = {}

	includeSpecial("contributors", DISABLED_CONTRIBUTIONS, CONTRIBUTIONS) -- Needs to be the contributors foldername
end