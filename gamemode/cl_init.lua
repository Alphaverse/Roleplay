print("[RP] Initializing Clientside")
include("shared.lua")



-- Called when the gamemode initializes
function GM:Initialize()
	print(Color(0, 255, 0), "\n[RP] Initialized Clientside\n")
end

-- Called when the server shuts down or the map changes
function GM:ShutDown()
	print(Color(255, 0, 0), "\n[RP] Shutting down Clientside\n")
end

-- Disable the default Scoreboard
function GM:HUDDrawScoreBoard()
end
function GM:ScoreboardHide()
end
function GM:ScoreboardShow()
end

-- Called when the target ID should be drawn
local math = math
function GM:HUDDrawTargetID()
	local ent = LocalPlayer():GetEyeTrace().Entity

	if LocalPlayer():GetPos():Distance(ent:GetPos()) > rp.cfg["Talk Radius"] then return end

	-- Get the x and y position and the alpha
	local x = ScrW() / 2
	local y = (ScrH() / 2) + math.sin(CurTime())
	local alpha = math.Clamp(255 - (255 / rp.cfg["Talk Radius"] * LocalPlayer():GetPos():Distance(ent:GetPos())), 0, 255)

	if ent:IsPlayer() then
		-- Draw certain teams (President only for now)
		if rp.cfg["TargetID Teams"][ent:Team()] then
			draw.DrawText(ent:GetJob("ERROR"), rp.cfg["TargetID"], x, y, ColorAlpha(team.GetColor(ent:Team()), alpha))
		end

		-- Draw wanted persons
		if ent:GetWanted() then
			draw.DrawText("This person is wanted by the police!", rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 195, 15), alpha))
		end

		-- Draw restraints (Handcuffs, Hostage Rope, Zipties)
		if ent:GetRoped() then
			draw.DrawText("Tied up", rp.cfg["TargetID"], x, y, ColorAlpha(255, 195, 15, alpha))
		elseif ent:GetCuffed() then
			draw.DrawText("Handcuffed", rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 195, 15), alpha))
		elseif ent:GetZiptied() then
			draw.DrawText("Ziptied", rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 195, 15), alpha))
		end

		-- Draw blindfolds
		if ent:GetBlindfolded() then
			draw.DrawText("Blindfolded", rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 195, 15), alpha))
		end

		-- Draw heavy weaponary
		if ent:IsCarryingHeavyWeapon() then
			draw.DrawText("This person is carrying a heavy weapon!", rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 195, 15), alpha))
		end
	elseif ent:IsRPVehicle() then
		-- Draw vehicle's license plate
		draw.DrawText("License Plate: " .. ent:GetSerialPlate(), rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 255, 255), alpha))
	elseif ent:IsItem() then
		-- Draw item name
		draw.DrawText(ent:GetItemName(), rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 125, 0), alpha))

		if ent:IsMoney() then
			-- Draw amount of money
			draw.DrawText("$" .. ent:GetAmount(), rp.cfg["TargetID"], x, y, ColorAlpha(Color(255, 255, 255), alpha))
		end
	end
end


-- Variables for drawing weapons and kevlar
local offsetvector = Vector(3, -5.6, 0)
local offsetangle = Angle(180, 90,-90)
local heavyweapon = ClientsideModel("models/thrusters/jetpack.mdl")
local kevlar = ClientsideModel("models/thrusters/jetpack.mdl")
heavyweapon:SetNoDraw(true)
kevlar:SetNoDraw(true)

-- Called after all players have been drawn
function GM:PostPlayerDraw(ply)
	if ply:IsCarryingHeavyWeapon() then
		local boneid = ply:LookupBone("ValveBiped.Bip01_Spine2")
		if not boneid then return end
		local matrix = ply:GetBoneMatrix(boneid)
		if not matrix then return end

		local newposition, newangle = LocalToWorld(offsetvector, offsetangle, matrix:GetTranslation(), matrix:GetAngles())
		heavyweapon:SetPos(newposition)
		heavyweapon:SetAngles(newangle)
		heavyweapon:SetupBones()
		heavyweapon:DrawModel()
	end

	if ply:GetKevlar() then
		local boneid = ply:LookupBone("ValveBiped.Bip01_Spine2")
		if not boneid then return end
		local matrix = ply:GetBoneMatrix(boneid)
		if not matrix then return end

		local newposition, newangle = LocalToWorld(offsetvector, offsetangle, matrix:GetTranslation(), matrix:GetAngles())
		kevlar:SetPos(newposition)
		kevlar:SetAngles(newangle)
		kevlar:SetupBones()
		kevlar:DrawModel()
	end
end


-- Override the ammo pickup function
function GM:HUDAmmoPickedUp()
end

-- Override the weapon pickup function
function GM:HUDWeaponPickedUp()
end

-- Override the item pickup function
function GM:HUDItemPickedUp()
end

-- Disable all HUD Elements except allowed ones
local elements = rp.cfg["Allowed HUD Elements"]
function GM:HUDShouldDraw(name)
	return elements[name]
end

-- Called when a player says something or a message is received from the server
function GM:ChatText(index, name, text, filter)
	return false
end

-- Disable 'C menu'
function GM:ContextMenuOpen()
	return false
end

-- Prevent the normal chatbox from appearing
function GM:StartChat()
	return false
end

-- Only draw physgun beam if we are admin
function GM:DrawPhysgunBeam(ply, weapon, bOn, target, boneid, pos)
	return LocalPlayer():IsModerator()
end

-- Called when screen space effects should be rendered
local waterrefract = 0.0001
local bloodrefract = 0
local modify = {}
modify["$pp_colour_addr"] = 0
modify["$pp_colour_addg"] = 0
modify["$pp_colour_addb"] = 0
modify["$pp_colour_brightness"] = 0
modify["$pp_colour_contrast"] = 1
modify["$pp_colour_colour"] = 1
modify["$pp_colour_mulr"] = 0
modify["$pp_colour_mulg"] = 0
modify["$pp_colour_mulb"] = 0
local DrawMotionBlur = DrawMotionBlur
local DrawColorModify = DrawColorModify
local DrawBloom = DrawBloom
local DrawSunbeams = DrawSunbeams
local DrawMaterialOverlay = DrawMaterialOverlay
function GM:RenderScreenspaceEffects()
	-- Disable cool shaders and effects, cuz you're lame
	if rp.cfg["Low Quality Mode"] then return end

	-- Vignette Effect
	surface.SetDrawColor(Color(0, 0, 0, 255 - (LocalPlayer():Health() / 2)))
	surface.SetMaterial(Material("vgui/zoom"))
	surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW() + 4, ScrH() + 4, 0)
	surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW() + 4, ScrH() + 4, 180)
	surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH() + 4, ScrW() + 4, 90)
	surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH() + 4, ScrW() + 4, -90)


	-- Shaders
	if LocalPlayer():Health() < 50 then
		DrawMotionBlur(math.Clamp(LocalPlayer():Health() / 100, 0.1, 1), 1, 0)
	end

	modify["$pp_colour_colour"] = math.Clamp(LocalPlayer():Health() / 100, 0, 1)
	DrawColorModify(modify)
	DrawBloom(0, 0.7, 3, 3, 0, 3, 1, 1, 1)

	if util.GetSunInfo().obstruction > 0 then
		local scrpos = (EyePos() + util.GetSunInfo().direction * 4096):ToScreen()
		DrawSunbeams(0.5, 0.5, 0.25, scrpos.x / ScrW(), scrpos.y / ScrH())
	end

	-- Overlays
	if LocalPlayer():WaterLevel() == 3 and LocalPlayer():Alive() then
		waterrefract = 0.1
	else
		if waterrefract > 0 then
			waterrefract = Lerp(FrameTime(), waterrefract, 0)
		end
	end

	if LocalPlayer():GetBleeding() and not LocalPlayer():GetKnockedOut() then
		bloodrefract = 0.1
	else
		if bloodrefract > 0 then
			bloodrefract = Lerp(FrameTime(), bloodrefract, 0)
		end
	end

	if waterrefract > 0 then -- Stupid Check, but Lerp will never 0 it
		DrawMaterialOverlay("effects/water_warp", waterrefract)
	end

	if bloodrefract > 0.001 then -- Stupid Check, but Lerp will never 0 it
		DrawMaterialOverlay("effects/bleed_overlay", bloodrefract)
	end
end

-- Disable restoring game
function GM:Restored()
	return false
end

-- Disable saving game
function GM:Saved()
	return false
end

-- Fill in world leaks
function GM:PreRender()
	cam.Start2D()
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	cam.End2D()
end

-- Stop Rendering when wanted
function GM:RenderScene()
	if LocalPlayer():GetNoRender() then
		cam.Start2D()
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

		return true
	end
end

-- Called every time the HUD should be painted.
local font = rp.cfg["HUDPaint"]
function GM:HUDPaint()
	if LocalPlayer():GetInjured() then
		surface.SetFont(font)
		local w, h = surface.GetTextSize("You are injured. You need to wait for someone to treat you with medical assistance. Hold JUMP to kill yourself")
		surface.SetDrawColor(22, 22, 22, 200)
		surface.DrawRect(ScrW() / 2 - (w + 10) / 2, ScrH() / 2 - (h + 10) / 2, w + 10, h + 10)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 2 - h / 2)
		surface.DrawText("You are injured. You need to wait for someone to treat you with medical assistance. Hold JUMP to kill yourself")
	elseif LocalPlayer():GetBlindfolded() then
		surface.SetFont(font)
		local w, h = surface.GetTextSize("You have been blindfolded")
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 2 - h / 2)
		surface.DrawText("You have been blindfolded")
	end
end

-- Handle ear grabbing animation
function GM:GrabEarAnimation(ply)
	-- Don't play when taunting or not able to
	if ply:IsPlayingTaunt() or ply:IsRestrained() or ply:GetArrested() or ply:GetRagdolled() then return end

	-- Add weight when using voiceradio
	if ply:GetUsingVoiceRadio() then
		ply:SetGestureWeight(math.Approach(ply:GetGestureWeight(0), 1, FrameTime() * 5), true)
	end

	-- If our animation has weight, play it
	if ply:GetGestureWeight(0) > 0 then
		if not ply:GetUsingVoiceRadio() then
			ply:SetGestureWeight(math.Approach(ply:GetGestureWeight(0), 0, FrameTime() * 5), true)
		end

		ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, ply:GetGestureWeight(0))
	end
end

-- Calculate a player's view
function GM:CalcView(ply, origin, angles, fov, znear, zfar)
	local ent
	local eyes = {}

	-- First Person Mode (Drawing First Person from the actual eyes)
	if rp.cfg["First Person Mode"] and ply:Alive() then
		ent = ply
	else
		-- Draw first person on ragdoll
		if not ply:Alive() and IsValid(ply:GetRagdoll()) then
			ent = ply:GetRagdoll()
		end
	end

	-- If we have an entity to draw the first person for, grab their eyes
	if ent then
		eyes = ent:GetAttachment(ent:LookupAttachment("eyes"))
	else
		-- else remain with the normal values
		eyes.Pos = origin
		eyes.Ang = angles
	end

	-- Let the BaseClass function handle the rest for stuff like weapon/vehicle view
	return self.BaseClass:CalcView(ply, eyes.Pos, eyes.Ang, fov, znear, zfar)
end

-- Draw LocalPlayer if First Person Mode is on
function GM:ShouldDrawLocalPlayer()
	return rp.cfg["First Person Mode"]
end