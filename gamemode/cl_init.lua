
include("shared.lua")

-- Hide HUD
function GM:HUDShouldDraw(name)
	return name == "CHudGMod"
end

-- Smooth View
local curView

function GM:CalcView(client, origin, angles, fov, zNear, zFar)
	curView = curView and LerpAngle(math.Clamp(FrameTime() * 5, 0, 1), curView, angles) or angles

	return {
		angles = curView
	}
end

-- Don't render other players
function GM:PrePlayerDraw(client, flags)
	return true
end

net.Receive("CreateNote", function()
	local position = net.ReadVector()

	Derma_StringRequest("Create Echo", "Write your echo below (255 char limit)...", nil, function(message)
		net.Start("CreateNote")
			net.WriteVector(position)
			net.WriteString(message)
		net.SendToServer()
	end, nil, "Echo")
end)

-- Render notes
local noteFadeDist = 1000
local noteMat = Material("echoesbeyond/note.png", "mips")

function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	for i = 1, #notes do
		local note = notes[i]
		local clientPos = LocalPlayer():GetShootPos()
		local notePos = note.drawPos

		-- Fade out if the player gets too close
		local alpha = (math.Clamp((clientPos:DistToSqr(notePos) - noteFadeDist / 2) / noteFadeDist, 0, 1) * 255) * note.init

		local angle = (clientPos - notePos):Angle()
		angle:RotateAroundAxis(angle:Forward(), 90)
		angle:RotateAroundAxis(angle:Right(), -90)
		angle = Angle(angle.p, angle.y, 90) -- Fix rotation

		cam.Start3D2D(notePos, angle, 0.1)
			surface.SetDrawColor(150 + 105 * note.active, 255, 255, alpha)
			surface.SetMaterial(noteMat)
			surface.DrawTexturedRect(-96, -96, 192, 192)

			-- wrap the text eventually
			draw.SimpleText(note.text, "CenterPrintText", 0, -150, Color(255, 255, 255, math.min(note.active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.End3D2D()
	end
end

local activationDist = 5000
local lightRenderDist = 1000000

-- Activate notes when getting close & render DLights
function GM:Think()
	local breatheLayer = math.sin(CurTime() * 1.5) * 0.5

	for i = 1, #notes do
		local note = notes[i]
		local clientPos = LocalPlayer():GetShootPos()
		local notePos = note.pos
		local distance = clientPos:DistToSqr(notePos)

		if (note.init < 1) then
			note.init = math.min(note.init + FrameTime(), 1)
		end

		if (distance < activationDist) then
			notes[i].active = math.min(note.active + FrameTime() * 3, 1)
			notes[i].drawPos = LerpVector(FrameTime() * 3, note.drawPos, note.pos + Vector(0, 0, 24 + breatheLayer))
		else
			notes[i].active = math.max(note.active - FrameTime() * 3, 0)
			notes[i].drawPos = LerpVector(FrameTime() * 3, note.drawPos, note.pos)
		end

		if (distance > lightRenderDist) then continue end -- Don't render DLights if too far away

		local dLight = DynamicLight(i)
		dLight.Pos = note.drawPos
		dLight.r = 150 + 105 * note.active
		dLight.g = 255
		dLight.b = 255
		dLight.Brightness = 3
		dLight.Size = (256 * ((distance - lightRenderDist) / lightRenderDist * -1)) * note.init -- Fadeout
		dLight.Decay = 1000
		dLight.DieTime = CurTime() + 0.1
	end
end

-- Fetch notes on join
function GM:InitPostEntity()
	net.Start("FetchNotes")
	net.SendToServer()
end

net.Receive("FetchNotes", function()
	notes = net.ReadTable()
end)

-- Create notes
net.Receive("RegisterNote", function()
	local position = net.ReadVector()
	local client = net.ReadPlayer()
	local text = net.ReadString()

	notes[#notes + 1] = {
		pos = position,
		drawPos = position,
		text = text,
		active = 0,
		init = 0
	}
end)
