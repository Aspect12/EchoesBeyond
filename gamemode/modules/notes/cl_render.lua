
-- Render notes
local noteFadeDist = 1000
local noteMat = Material("echoesbeyond/note.png", "mips")

hook.Add("PostDrawTranslucentRenderables", "notes_render_PostDrawTranslucentRenderables", function(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	surface.SetFont("CenterPrintText")
	local client = LocalPlayer()

	-- Sort notes by distance
	local sortedNotes = table.Copy(notes)
	table.sort(sortedNotes, function(a, b)
		return client:GetShootPos():DistToSqr(a.pos) > client:GetShootPos():DistToSqr(b.pos)
	end)

	for i = 1, #sortedNotes do
		local note = sortedNotes[i]
		local clientPos = client:GetShootPos()
		local notePos = note.drawPos
		local bOwner = note.ply == client:SteamID()

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
end)

local activationDist = 5000
local lightRenderDist = 3000000

-- Activate notes when getting close & render DLights
hook.Add("Think", "notes_render_Think", function()
	local breatheLayer = math.sin(CurTime() * 1.5) * 0.5
	local client = LocalPlayer()

	-- Sort notes by distance
	local sortedNotes = table.Copy(notes)
	table.sort(sortedNotes, function(a, b)
		return client:GetShootPos():DistToSqr(a.pos) > client:GetShootPos():DistToSqr(b.pos)
	end)

	for i = 1, #sortedNotes do
		local sortedNote = sortedNotes[i]
		local noteID

		-- Get the note from the normal notes table by its id member value
		for id, note in pairs(notes) do
			if (note.id == sortedNote.id) then
				noteID = id

				break
			end
		end

		if (!noteID) then continue end

		local clientPos = client:GetShootPos()
		local notePos = sortedNote.pos
		local distance = clientPos:DistToSqr(notePos)
		local bOwner = sortedNote.ply == client:SteamID()

		if (sortedNote.init < 1) then
			notes[noteID].init = math.min(sortedNote.init + FrameTime(), 1)
		end

		if (distance < activationDist) then
			local active = math.min(sortedNote.active + FrameTime() * 3, 1)

			notes[noteID].active = active
			notes[noteID].drawPos = LerpVector(FrameTime() * 3, sortedNote.drawPos, sortedNote.pos + Vector(0, 0, 24 + breatheLayer))

			if (!sortedNote.soundActive) then
				notes[noteID].soundActive = true

				client:EmitSound("echoesbeyond/note_activate.wav", 75, math.random(95, 105))
			end

			if (active == 1 and !bOwner and !notes[noteID].expired) then
				notes[noteID].expired = true

				-- Mark note as expired
				local savedData = file.Read("echoesbeyond/expirednotes.txt", "DATA")
				savedData = util.JSONToTable(savedData and savedData != "" and savedData or "[]")
				savedData[#savedData + 1] = notes[noteID].id

				file.CreateDir("echoesbeyond")
				file.Write("echoesbeyond/expirednotes.txt", util.TableToJSON(savedData))
			end
		else
			notes[noteID].active = math.max(sortedNote.active - FrameTime() * 0.5, 0)
			notes[noteID].drawPos = LerpVector(FrameTime() * 1.5, sortedNote.drawPos, sortedNote.pos - (notes[noteID].expired and Vector(0, 0, 20) or Vector(0, 0, 0)))

			if (sortedNote.soundActive) then
				sortedNote.soundActive = false
			end
		end

		if (distance > lightRenderDist) then continue end -- Don't render DLights if too far away

		local r = !sortedNote.expired and (bOwner and 255 or (100 + 155 * sortedNote.active)) or (25 + 230 * sortedNote.active)
		local g = !sortedNote.expired and 255 or (25 + 230 * sortedNote.active)
		local b = !sortedNote.expired and (bOwner and (255 * sortedNote.active) or 255) or (25 + 230 * sortedNote.active)

		local dLight = DynamicLight(i)
		dLight.Pos = sortedNote.drawPos
		dLight.r = r
		dLight.g = g
		dLight.b = b
		dLight.Brightness = 3
		dLight.Size = (256 * ((distance - lightRenderDist) / lightRenderDist * -1)) * sortedNote.init -- Fadeout
		dLight.Decay = 1000
		dLight.DieTime = CurTime() + 0.1
	end
end)
