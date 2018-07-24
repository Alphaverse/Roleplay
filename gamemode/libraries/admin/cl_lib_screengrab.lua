--[[-------------------------------------------------------------------------
VICTIM	(Capture image and send it to the server)
---------------------------------------------------------------------------]]
local math = math
local net = net
local render = render
local string = string
local timer = timer
local util = util

local ScrenGrabRequested = false
local destination = nil


net.Receive("rp_sg_requestimg", function()
	ScrenGrabRequested = true
	destination = net.ReadEntity()
end)

hook.Add("PostRender", "ScreenGrabHook", function(args)
	-- Spam prevention
	if not ScrenGrabRequested then return end
	if not destination then return end
	ScrenGrabRequested = false

	-- Capture their screen
	local cachedata = {}
	local img = render.Capture({
		format = "jpeg",
		quality = 50,
		h = ScrH(),
		w = ScrW(),
		x = 0,
		y = 0,
	})

	-- If we have nothing send the finishing message
	if img == nil then
		local netpackage = util.Compress(LocalPlayer():SteamID())
		local len = string.len(netpackage)

		net.Start("rp_sg_sendimgtoserver")
			net.WriteEntity(destination)
			net.WriteUInt(len, 32)
			net.WriteUInt(0, 32)
			net.WriteData(netpackage, len)
		net.SendToServer()

		return false
	end

	local chunksize = 20000 -- Keep it at 20000. This chunk size delivers the best transition even at full quality without dropping out.
	local strlen = string.len(img)
	local amountofchunks = math.ceil(strlen / chunksize)

	-- Cut the img into chunks
	for i = 1, amountofchunks do
		local start = ((i - 1) * chunksize) + 1
		local stop = i * chunksize

		if stop > strlen then
			stop = strlen
		end

		cachedata[i] = string.sub(img, start, stop)
	end

	-- Network the chunks to the server
	for i = 1, #cachedata + 1 do
		timer.Simple(i / 20, function() -- Keep it at i / 20. This processing rate delivers the best transition even at full quality without dropping out.
			local netpackage

			-- Send the finished message if we have sent everything
			if i == #cachedata + 1 then
				netpackage = util.Compress(LocalPlayer():SteamID())
			else
				netpackage = util.Compress(tostring(cachedata[i]))
			end

			local len = string.len(netpackage)

			net.Start("rp_sg_sendimgtoserver")
				net.WriteEntity(destination)
				net.WriteUInt(len, 32)
				net.WriteUInt(i, 32)
				net.WriteData(netpackage, len)
			net.SendToServer()
		end)
	end
end)



--[[-------------------------------------------------------------------------
ADMIN	(Receive image and display it)
---------------------------------------------------------------------------]]
local imgcache = {}

net.Receive("rp_sg_forwardimg", function()
	local ply = net.ReadEntity()
	local length = net.ReadUInt(32)
	local i = net.ReadUInt(32)
	local data = net.ReadData(length)

	-- Check for end message (SteamID)
	if util.Decompress(data) == ply:SteamID() then
		-- Create DFrame
		local imgdata = table.concat(imgcache)
		local frame = vgui.Create("DFrame")
		local x = ScrW() * 0.8
		local y = ScrH() * 0.8

		frame:SetSize(x, y)
		frame:SetTitle("Screengrab of     " .. ply:Nick() .. " (" .. ply:UserID() .. ") [" .. ply:SteamID() .. "]")
		frame:MakePopup()
		frame:Center()
		frame.Paint = function()
			surface.SetDrawColor(Color(30, 30, 30))
			surface.DrawRect(0, 0, x, y)
		end

		-- Create warning message
		local text = vgui.Create("DLabel", frame)
		surface.SetFont("Trebuchet24")
		local w, h = surface.GetTextSize("If you see this message the image could not be displayed.\nPossible sources:\n\n    -Faulty update installation\n    -Packages lost while networking the image\n    -Player disabled/corrupted render.Capture() via cheats")
		text:SetPos(x / 2 - w / 2, y / 2 - h / 2)
		text:SetFont("Trebuchet24")
		text:SetText("If you see this message the image could not be displayed.\nPossible sources:\n\n    -Faulty update installation\n    -Packages lost while networking the image\n    -Player disabled/corrupted render.Capture() via cheats")
		text:SizeToContents()


		-- Draw captured imagedate if we have some
		if #imgdata != 0 then
			local image = vgui.Create("HTML", frame)
			image:SetSize(x - 50, y - 50)
			image:SetPos(25, 25)
			image:SetHTML([[ <img width="]] .. x - 75 .. [[" height="]] .. y - 75 .. [[" src="data:image/jpeg;base64, ]] .. util.Base64Encode(imgdata) .. [["/> ]])

			-- Save button
			local btn = vgui.Create("DButton", frame)
			btn:SetSize(x, 30)
			btn:SetPos(0, y - 30)
			btn:SetText("Save image")
			btn.Paint = function()
				surface.SetDrawColor(Color(222, 222, 222))
				surface.DrawRect(0, 0, x, y)
			end

			btn.DoClick = function()
				frame:Close()
				file.Write(GM_FOLDERNAME .. "/screengrab_" .. util.DateStamp() .. ".jpg", imgdata)
				LocalPlayer():Notify("Saved image to " .. GM_FOLDERNAME .. "/screengrab_" .. util.DateStamp() .. ".jpg", 0)
			end
		end

		-- Clear the image cache
		imgcache = {}
	else
		-- Put the image into the data cache
		imgcache[i] = util.Decompress(data)
	end
end)