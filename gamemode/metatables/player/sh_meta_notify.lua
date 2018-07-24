--[[-------------------------------------------------------------------------
Notification System


It is a feature in Garry's Mod, though it's accessablity is not that easy.
We shall change that with this file. You can do Player:Notify(msg, class)
with msg being the message you want to send them and class the type.
See http://wiki.garrysmod.com/page/Enums/NOTIFY for further information on
the class.

Since we network here, this function is available on BOTH the CLIENT and
SERVER. There is also an override in 'vgui/cl_notifications.lua' which
renders the notification box in a new way, so you won't have to worry about
Garry's design not fitting into this gamemode.

Other than that, this file is pretty uninteresting for you, if you want to
customize/configurate your server.
---------------------------------------------------------------------------]]
local pMeta = FindMetaTable("Player")
local generic = Sound("ambient/water/drip2.wav")
local err = Sound("buttons/button10.wav")
local undo = Sound("buttons/button17.wav")
local hint = Sound("buttons/bell1.wav")
local cleanup = Sound("buttons/button15.wav")


if SERVER then
	util.AddNetworkString("Notify")
	util.AddNetworkString("NotifyCustom")
	util.AddNetworkString("NotifyChoice")
	util.AddNetworkString("NotifyCenter")
else
	net.Receive("Notify", function()
		LocalPlayer():Notify(net.ReadString(), net.ReadInt(16))
	end)

	net.Receive("NotifyCustom", function()
		local data = net.ReadTable()
		LocalPlayer():NotifyCustom(data[1], data[2], data[3], data[4])
	end)

	net.Receive("NotifyChoice", function()
		local data = net.ReadTable()
		LocalPlayer():NotifyChoice(data[1], data[2], data[3], data[4], data[5], data[6], data[7])
	end)

	net.Receive("NotifyCenter", function()
		local data = net.ReadTable()
		LocalPlayer():NotifyCenter(data[1], data[2], data[3], data[4], data[5])
	end)
end


-- Notifies a player using Garry's standard hint messages
function pMeta:Notify(message, class)
	if not IsValid(self) then return end

	if SERVER then
		if class == nil then
			class = NOTIFY_GENERIC
		end

		net.Start("Notify")
			net.WriteString(message)
			net.WriteInt(class, 16)
		net.Send(self)
	else
		if not class then
			class = NOTIFY_GENERIC
		end

		local sound = generic

		if class == NOTIFY_ERROR then
			sound = err
		elseif class == NOTIFY_UNDO then
			sound = undo
		elseif class == NOTIFY_HINT then
			sound = hint
		elseif class == NOTIFY_CLEANUP then
			sound = cleanup
		end

		surface.PlaySound(sound)
		notification.AddLegacy(message, class, 10)
		self:PrintMessage(HUD_PRINTCONSOLE, message .. "\n")
	end
end

-- Notifies a player with custom icon, color and length
function pMeta:NotifyCustom(message, icon, color, length)
	if not IsValid(self) then return end

	if SERVER then
		net.Start("NotifyCustom")
			net.WriteTable({message, icon, color, length})
		net.Send(self)
	else
		surface.PlaySound("ambient/water/drip2.wav")
		notification.AddCustom(message, icon, color, length)
		self:PrintMessage(HUD_PRINTCONSOLE, message .. "\n")
	end
end

-- Notifies a player with a choice
function pMeta:NotifyChoice(message, button1, func1, button2, func2, icon, color)
	if not IsValid(self) then return end

	if SERVER then
		net.Start("NotifyChoice")
			net.WriteTable({message, button1, func1, button2, func2, icon, color})
		net.Send(self)
	else
		surface.PlaySound("ambient/water/drip2.wav")
		notification.AddButtons(message, button1, func1, button2, func2, icon, color)
		self:PrintMessage(HUD_PRINTCONSOLE, message .. "\n")
	end
end

-- Notifies a player with a big frame in the center
function pMeta:NotifyCenter(message, icon, color, delay, override)
	if not IsValid(self) then return end

	if SERVER then
		net.Start("NotifyCenter")
			net.WriteTable({message, icon, color, delay, override})
		net.Send(self)
	else
		notification.AddCenter(message, icon, color, delay, override)
		self:PrintMessage(HUD_PRINTCONSOLE, message .. "\n")
	end
end