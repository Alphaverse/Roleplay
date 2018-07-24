rp.screengrab = {}

util.AddNetworkString("rp_sg_requestimg")
util.AddNetworkString("rp_sg_sendimgtoserver")
util.AddNetworkString("rp_sg_forwardimg")


-- Request an image from a player and send it to admin
function rp.screengrab.requestimg(admin, victim)
	-- Check for invalid victim
	if not IsValid(victim) or victim:IsBot() then
		admin:Notify("Invalid victim or victim is BOT!", NOTIFY_ERROR)
		return
	end

	-- Notify admin
	admin:Notify("Screengrabbing " .. victim:Name() .. " (" .. victim:UserID() .. ") now. Please allow up to 5 seconds", NOTIFY_GENERIC)

	-- Send a request to the client
	net.Start("rp_sg_requestimg")
		net.WriteEntity(admin)
	net.Send(victim)
end

-- Forward any messages received to the corresponding admin
net.Receive("rp_sg_sendimgtoserver", function(len, ply)
	-- Grab data
	local destination = net.ReadEntity()
	local length = net.ReadUInt(32)
	local i = net.ReadUInt(32)
	local data = net.ReadData(length)

	-- Cancel if we do not have a destination to send to
	if not destination then return end

	-- Forward imagedata
	net.Start("rp_sg_forwardimg")
		net.WriteEntity(ply)
		net.WriteUInt(length, 32)
		net.WriteUInt(i, 32)
		net.WriteData(data, length)
	net.Send(destination)
end)