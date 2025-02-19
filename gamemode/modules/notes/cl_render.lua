
-- Render notes
local noteFadeDist = 1000
local noteMat = Material("echoesbeyond/note.png", "mips")

function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	surface.SetFont("CenterPrintText")

	for i = 1, #notes do
		local note = notes[i]
		local clientPos = LocalPlayer():GetShootPos()
		local notePos = note.drawPos
		local bOwner = note.ply == LocalPlayer():SteamID()

		-- Fade out if the player gets too close
		local alpha = (math.Clamp((clientPos:DistToSqr(notePos) - noteFadeDist / 2) / noteFadeDist, 0, 1) * 255) * note.init

		local angle = (clientPos - notePos):Angle()
		angle:RotateAroundAxis(angle:Forward(), 90)
		angle:RotateAroundAxis(angle:Right(), -90)
		angle = Angle(angle.p, angle.y, 90) -- Fix rotation

		-- Wrap the text
		local text = {}
		local line = ""
		local words = string.Explode(" ", note.text)

		for i = 1, #words do
			local word = words[i]

			if (surface.GetTextSize(line .. " " .. word) > 512) then
				table.insert(text, line)
				line = word
			else
				line = line .. " " .. word
			end
		end

		table.insert(text, line)

		-- Flip the table
		for i = 1, #text / 2 do
			local temp = text[i]

			text[i] = text[#text - i + 1]
			text[#text - i + 1] = temp
		end

		cam.Start3D2D(notePos, angle, 0.1)
			local r = !note.expired and (bOwner and 255 or (150 + 105 * note.active)) or (100 + 155 * note.active)
			local g = !note.expired and 255 or (100 + 155 * note.active)
			local b = !note.expired and (bOwner and (255 * note.active) or 255) or (100 + 155 * note.active)

			surface.SetDrawColor(r, g, b, alpha)
			surface.SetMaterial(noteMat)
			surface.DrawTexturedRect(-96, -96, 192, 192)

			for i = 1, #text do
				draw.SimpleText(text[i], "CenterPrintText", 0, -(150 + i * 15), Color(255, 255, 255, math.min(note.active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()
	end
end

local activationDist = 5000
local lightRenderDist = 3000000

-- Activate notes when getting close & render DLights
function GM:Think()
	local breatheLayer = math.sin(CurTime() * 1.5) * 0.5

	for i = 1, #notes do
		local note = notes[i]
		local clientPos = LocalPlayer():GetShootPos()
		local notePos = note.pos
		local distance = clientPos:DistToSqr(notePos)
		local bOwner = note.ply == LocalPlayer():SteamID()

		if (note.init < 1) then
			note.init = math.min(note.init + FrameTime(), 1)
		end

		if (distance < activationDist) then
			local active = math.min(note.active + FrameTime() * 3, 1)

			notes[i].active = active
			notes[i].drawPos = LerpVector(FrameTime() * 3, note.drawPos, note.pos + Vector(0, 0, 24 + breatheLayer))

			if (!note.soundActive) then
				note.soundActive = true

				surface.PlaySound("echoesbeyond/note_activate.wav")
			end

			if (active == 1 and !bOwner) then
				notes[i].expired = true
			end
		else
			notes[i].active = math.max(note.active - FrameTime() * 3, 0)
			notes[i].drawPos = LerpVector(FrameTime() * 3, note.drawPos, note.pos - (notes[i].expired and Vector(0, 0, 24) or Vector(0, 0, 0)))

			if (note.soundActive) then
				note.soundActive = false
			end
		end

		if (distance > lightRenderDist) then continue end -- Don't render DLights if too far away

		local r = !note.expired and (bOwner and 255 or (100 + 155 * note.active)) or (50 + 205 * note.active)
		local g = !note.expired and 255 or (50 + 205 * note.active)
		local b = !note.expired and (bOwner and (255 * note.active) or 255) or (50 + 205 * note.active)

		local dLight = DynamicLight(i)
		dLight.Pos = note.drawPos
		dLight.r = r
		dLight.g = g
		dLight.b = b
		dLight.Brightness = 3
		dLight.Size = (256 * ((distance - lightRenderDist) / lightRenderDist * -1)) * note.init -- Fadeout
		dLight.Decay = 1000
		dLight.DieTime = CurTime() + 0.1
	end
end
