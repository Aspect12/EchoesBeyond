
-- Fetch notes and send them to the client
mapCount = mapCount or 0 -- Total amount of maps with notes, used in the main menu
globalNoteCount = globalNoteCount or 0 -- Total amount of notes, ditto

function FetchNotes(bNoSound)
	local map = game.GetMap()

	http.Fetch("https://hl2rp.net/echoes/fetch.php?map=" .. map, function(body)
		local data = util.JSONToTable(body)
		if (!data) then return end

		mapCount = data.stats.maps
		globalNoteCount = data.stats.notes

		if (!data.notes) then return end

		local savedData = file.Read("echoesbeyond/expirednotes.txt", "DATA")
		savedData = util.JSONToTable(savedData and savedData != "" and savedData or "[]")

		local noteCount = #notes

		for i = 1, #data.notes do
			local exists = false

			for k = 1, #notes do
				if (notes[k].id != data.notes[i].id) then continue end

				exists = true

				break
			end

			-- Don't add notes that already exist
			if (exists) then continue end

			-- Convert the position string to a vector
			local position = string.Explode(",", data.notes[i].pos)
			position = Vector(tonumber(position[1]), tonumber(position[2]), tonumber(position[3]))

			local text = data.notes[i].text

			notes[#notes + 1] = {
				expired = table.HasValue(savedData, data.notes[i].id),
				explicit = IsOffensive(text),
				drawPos = position,
				text = text,
				soundActive = false,
				ply = data.notes[i].ply,
				pos = position,
				id = data.notes[i].id,
				special = data.notes[i].special,
				angle = Angle(0, 0, 90),
				active = 0,
				init = 0,
			}
		end

		if (!bNoSound and noteCount < #notes) then
			LocalPlayer():EmitSound("echoesbeyond/note_create.wav", 75, math.random(95, 105))
		end

		-- Save own notes
		local ownNotes = {}

		for i = 1, #notes do
			if (notes[i].ply != LocalPlayer():SteamID()) then continue end

			ownNotes[#ownNotes + 1] = notes[i]
		end

		local savedNotes = file.Read("echoesbeyond/writtennotes.txt", "DATA")
		savedNotes = util.JSONToTable(savedNotes and savedNotes != "" and savedNotes or "[]")

		local ownMapNotes = {}

		-- Get only notes from the current map
		for i = 1, #savedNotes do
			if (savedNotes[i].map != map) then continue end

			ownMapNotes[#ownMapNotes + 1] = savedNotes[i]
		end

		-- We wrote something new
		if (#ownMapNotes >= #ownNotes) then return end

		local newNotes = {}

		-- Find which notes are new
		for i = 1, #ownNotes do
			local exists = false

			for k = 1, #ownMapNotes do
				if (ownMapNotes[k].id != ownNotes[i].id) then continue end

				exists = true

				break
			end

			if (exists) then continue end

			newNotes[#newNotes + 1] = ownNotes[i]
		end

		local newExplicit = false

		-- Check if any of the new notes are explicit
		for i = 1, #newNotes do
			if (!IsOffensive(newNotes[i].text)) then continue end

			newExplicit = true

			break
		end

		if (newExplicit) then -- If we wrote something explicit, turn off the profanity filter
			local profanity = GetConVar("echoes_profanity")

			profanity:SetBool(true)
		end

		for i = 1, #newNotes do
			savedNotes[#savedNotes + 1] = {
				map = game.GetMap(),
				pos = newNotes[i].pos,
				text = newNotes[i].text,
				id = newNotes[i].id,
			}
		end

		file.CreateDir("echoesbeyond")
		file.Write("echoesbeyond/writtennotes.txt", util.TableToJSON(savedNotes))
	end)
end

hook.Add("InitPostEntity", "notes_fetch_InitPostEntity", function()
	FetchNotes(true)

	timer.Create("notes_fetch_timer", 60, 0, FetchNotes) -- Fetch notes every minute
end)
