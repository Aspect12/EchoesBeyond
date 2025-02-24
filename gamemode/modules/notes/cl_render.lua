
CreateClientConVar("echoes_hideexpired", "1")
CreateClientConVar("echoes_renderdist", "25000000")

local noteMat = Material("echoesbeyond/note.png", "mips")
local lightRenderDist = 3000000 -- How far the dynamic light should render
local activationDist = 6500 -- How close the player should be to activate the note
local noteFadeDist = 2500 -- How far the note should start fading

hook.Add("PostDrawTranslucentRenderables", "notes_render_Combined", function(bDrawingDepth, bDrawingSkybox)
	if (bDrawingDepth or bDrawingSkybox) then return end

	local client = LocalPlayer()
	local clientPos = client:GetShootPos()
	local frameTime = FrameTime()
	local curTime = CurTime()
	local profanity = GetConVar("echoes_profanity"):GetBool()
	local hideExpired = GetConVar("echoes_hideexpired"):GetBool()
	local cutOffDist = GetConVar("echoes_renderdist"):GetInt()
	local lerpFactor = math.Clamp(frameTime * 5, 0, 1)
	local activationOffset = Vector(0, 0, 24 + math.sin(curTime * 1.5) * 0.5)
	local expiredOffset = Vector(0, 0, 20)

	surface.SetFont("CenterPrintText")

	-- Create a shallow copy of notes and sort by distance (squared)
	local sortedNotes = {}

	for i = 1, #notes do
		sortedNotes[i] = notes[i]
		sortedNotes[i].distSqr = clientPos:DistToSqr(sortedNotes[i].pos)
	end

	table.sort(sortedNotes, function(a, b)
		return a.distSqr > b.distSqr
	end)

	for i = 1, #sortedNotes do
		local note = sortedNotes[i]
		local noteDistSqr = clientPos:DistToSqr(note.pos)
		local expired = note.expired
		local bOwner = note.isOwner

		-- Update angle (smooth rotation)
		local ang = (clientPos - note.pos):Angle()

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)
		ang = Angle(ang.p, ang.y, 90)

		note.angle = LerpAngle(lerpFactor, note.angle, ang)

		-- Update initialization factor based on explicit flag and profanity setting
		if (expired and hideExpired) then
			if (!note.expiredTime) then
				note.expiredTime = curTime
			end

			-- Fade out note if expired for more than 60 seconds
			if (curTime - note.expiredTime > 60) then
				note.init = math.max(note.init - frameTime, 0)
			end
		else
			if (note.explicit and !profanity) then
				note.init = math.max(note.init-frameTime, 0)
			elseif (note.init < 1) then
				if ((note.explicit and profanity) or (!note.explicit)) then
					note.init = math.min(note.init + frameTime, 1)
				end
			end
		end

		if (note.init == 0) then continue end -- Skip rendering if note is not initialized

		-- Activate note if within activation distance
		if ((note.explicit and profanity) or (!note.explicit)) then
			if (noteDistSqr < activationDist) then
				local active = math.min(note.active + frameTime * 3, 1)

				note.active = active
				note.drawPos = LerpVector(frameTime * 3, note.drawPos, note.pos + activationOffset)

				if (!note.soundActive) then
					note.soundActive = true

					client:EmitSound("echoesbeyond/note_activate.wav", 75, note.special and math.random(115, 125) or note.explicit and math.random(65, 75) or math.random(95, 105))
				end

				if (active == 1 and !bOwner and !note.expired and !note.special) then
					local savedData = file.Read("echoesbeyond/expirednotes.txt", "DATA")

					note.expired = true

					savedData = util.JSONToTable((savedData and savedData != "" and savedData) or"[]")
					savedData[#savedData + 1] = note.id

					expiredNoteCount = expiredNoteCount + 1

					file.CreateDir("echoesbeyond")
					file.Write("echoesbeyond/expirednotes.txt", util.TableToJSON(savedData))
				end
			else
				note.active = math.max(note.active - frameTime * 0.5, 0)
				note.drawPos = LerpVector(frameTime * 1.5, note.drawPos, note.pos - (note.expired and expiredOffset or Vector(0, 0, 0)))

				if (note.soundActive) then
					note.soundActive = false
				end
			end
		end

		local special = note.special
		local active = note.active
		local explicit = note.explicit

		-- Render dynamic light if within render distance (using note.pos for distance)
		if (noteDistSqr <= lightRenderDist and GetConVar("echoes_dlights"):GetBool()) then
			local r = !expired and (special and 255 or explicit and 255 or bOwner and 255 or (100 + 155 * active)) or (25 + 230 * active)
			local g = !expired and (special and (255 * active) or explicit and (25 + 230 * active) or bOwner and 255 or 255) or (25 + 230 * active)
			local b = !expired and (special and 255 or explicit and (25 + 230 * active) or bOwner and (255 * active) or 255) or (25 + 230 * active)

			local dLight = DynamicLight(i)

			if (dLight) then
				dLight.Pos = note.drawPos
				dLight.r = r
				dLight.g = g
				dLight.b = b
				dLight.Brightness = 3
				dLight.Size = 256 * ((lightRenderDist - noteDistSqr) / lightRenderDist) * note.init
				dLight.Decay = 1000
				dLight.DieTime = curTime + 0.1
			end
		end

		-- Draw note if within cutoff distance (using note.drawPos)
		if (noteDistSqr > cutOffDist) then continue end

		local alpha = (math.Clamp((noteDistSqr - noteFadeDist / 2) / noteFadeDist, 0, 1) * 255) * note.init

		-- Cache wrapped text to avoid recalculations
		if (!note.cachedText) then
			local words = string.Explode(" ", note.text)
			local lines = {}
			local line = ""

			for j = 1, #words do
				local word = words[j]

				if (surface.GetTextSize(line .. " " .. word) > 512) then
					table.insert(lines, line)
					line = word
				else
					line = (line == ""and word or line .. " " .. word)
				end
			end

			table.insert(lines, line)

			for j = 1, math.floor(#lines / 2)do
				lines[j], lines[#lines - j + 1] = lines[#lines - j + 1], lines[j]
			end

			note.cachedText = lines
		end

		-- Draw the note's texture and text
		local rDraw = !expired and (special and (200 + 55 * active) or explicit and 255 or bOwner and 255 or (150 + 105 * active)) or (100 + 155 * active)
		local gDraw = !expired and (special and (255 * active) or explicit and (50 + 205 * active) or bOwner and 255 or 255) or (100 + 155 * active)
		local bDraw = !expired and (special and (200 + 55 * active) or explicit and (50 + 205 * active) or bOwner and (255 * active) or 255) or (100 + 155 * active)

		cam.Start3D2D(note.drawPos, note.angle, 0.1)
			surface.SetDrawColor(rDraw, gDraw, bDraw, alpha)
			surface.SetMaterial(noteMat)
			surface.DrawTexturedRect(-96, -96, 192, 192)

			for j = 1, #note.cachedText do
				draw.SimpleText(note.cachedText[j], "CenterPrintText", 0, -(150 + j * 15), Color(255, 255, 255, math.min(active * 255, alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()
	end
end)
