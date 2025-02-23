
-- Fetch notes and send them to the client
mapCount = mapCount or 0 -- Total amount of maps with notes, used in the main menu
globalNoteCount = globalNoteCount or 0 -- Total amount of notes, ditto
nextNote = nextNote or 0 -- Time a new note can be made

function FetchNotes(bNoSound)
	local map = game.GetMap()

	http.Fetch("https://hl2rp.net/echoes/fetch.php?map=" .. map, function(body)
		local data = util.JSONToTable(body)
		if (!data) then return end

		mapCount = data.stats.maps
		globalNoteCount = data.stats.notes

		if (data.ratelimit) then
			nextNote = data.ratelimit
		end

		if (data.mapRatelimit) then
			mapRatelimit = data.mapRatelimit
		end

		if (data.mapList) then
			mapList = data.mapList
		end

		if (!data.notes) then return end

		local savedData = file.Read("echoesbeyond/expirednotes.txt", "DATA")
		savedData = util.JSONToTable(savedData and savedData != "" and savedData or "[]")

		local savedNotes = file.Read("echoesbeyond/writtennotes.txt", "DATA")
		savedNotes = util.JSONToTable(savedNotes and savedNotes != "" and savedNotes or "[]")

		local noteCount = #notes

		expiredNoteCount = 0

		for i = 1, #data.notes do
			local newNote = data.notes[i]
			local exists = false

			for k = 1, #notes do
				if (notes[k].id != newNote.id) then continue end

				exists = true

				break
			end

			local expired = table.HasValue(savedData, newNote.id)

			if (expired) then
				expiredNoteCount = expiredNoteCount + 1
			end

			-- Don't add notes that already exist
			if (exists) then continue end

			-- Figure out if we own the note
			local isOwner = false

			for k = 1, #savedNotes do
				if (savedNotes[k].id != newNote.id) then continue end

				isOwner = true

				break
			end

			-- Convert the position string to a vector
			local position = string.Explode(",", newNote.pos)
			position = Vector(tonumber(position[1]), tonumber(position[2]), tonumber(position[3]))

			local text = newNote.text

			notes[#notes + 1] = {
				explicit = IsOffensive(text),
				expiredTime = expired and 0,
				special = newNote.special,
				angle = Angle(0, 0, 90),
				soundActive = false,
				drawPos = position,
				expired = expired,
				isOwner = isOwner,
				id = newNote.id,
				pos = position,
				text = text,
				active = 0,
				init = 0
			}
		end

		if (!bNoSound and noteCount < #notes) then
			LocalPlayer():EmitSound("echoesbeyond/note_create.wav", 75, math.random(95, 105))
		end
	end, function(error)
		EchoNotify(error)
	end)
end

hook.Add("InitPostEntity", "notes_fetch_InitPostEntity", function()
	FetchNotes(true)

	timer.Create("notes_fetch_timer", 60, 0, FetchNotes) -- Fetch notes every minute
end)
